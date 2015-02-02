tnebot
======

The Nintendo Elements RSS Crawler and Twitter poster bot.
(Support for other social media is being worked on.)

So far the Bot works well as a Twitter bot.
It's currently used on the @NintendoElement Twitter account.
We have the script set up to run every hour on the hour.


How to set up: (Twitter only at the moment.)

1. Go to http://apps.twitter.com with the account for the bot and create a new app with read/write permissions.
2. Edit the urlList array to contain your RSS feeds.
3. Set the twitter_api_key, twitter_api_key_secret, twitter_oauth_token and twitter_oauth_token_secret variables
4. Schedule the script to run every so often. (See your system documentation on how to accomplish this.)

And you're done!


