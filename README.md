# PagerDuty Shift Announcer

PagerDuty shift announcer is a simple script meant to be added into your crontab — every 5 minutes or so should be plenty. From there, it'll check to see if the person on-call has changed since the last checkin, and if it has, it'll paste the notification in Campfire and send a text message to the engineer who just came on-call.

We use Firetower for our Campfire bot, so we just reuse the same firetower.conf via this script to load Campfire credentials and to paste into the Campfire room.

For the text messaging, we use the Twilio API and a private Twilio number we purchased.

***

Unless otherwise specified, all content copyright &copy; 2014, [Rails Machine, LLC](http://railsmachine.com)
