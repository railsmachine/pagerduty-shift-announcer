#!/usr/bin/ruby

require 'rubygems'

require 'yaml'
require 'pagerduty'
require 'firetower'

class PagerReminder
  require 'twilio'
  
  PEEPS = {
    "Engineer Uno"    => "5555555555"
  }
  
  TWILIO_DIGITS = "1234567890" # the phone number you own on Twilio - texts will appear to be from this number
  
  def self.send(name, oncall_until)
    Twilio::Config.setup do
      account_sid   'sekrit'
      auth_token    'sekriter'
    end
    
    Twilio::SMS.create :to => "+1#{PEEPS[name]}", :from => "+1#{TWILIO_DIGITS}",
                       :body => "Hey #{name}, just a reminder that you're on-call until #{oncall_until}."
  end
end

pagerduty  = PagerDuty::Agent.new
escalation = PagerDuty::Escalation.new nil, "Weekly Alerts and Urgent Tickets"
dashboard  = pagerduty.fetch "/dashboard"
levels     = escalation.parse dashboard.body
level1     = levels.first

person = level1['person']
cache_file = Pathname.new('/tmp/last-on-call')
last_person = if cache_file.exist?
                cache_file.read
              end

if !last_person || person != last_person
  end_time = level1['end_time']

  config_path = Pathname.new 'firetower.conf'
  session = Firetower::Session.new
  session.instance_eval do
    options = YAML.load_file('campfire_credentials.yml')
    account options[:account], options[:api_key], :ssl => true
    default options[:account], options[:default]
  end
  room = session.default_room

  message = "#{person} is on call until #{end_time}"
  PagerReminder.send(person, end_time)
  if last_person
    message << ", was #{last_person}"
  end

  room.account.say!(room.name, message)

  cache_file.open('w') {|f| f.write(person) }
end