require 'date'
require 'json'
require 'oauth'
require 'open-uri'
require 'rss'
require 'sqlite3'

########################################
#                TNEBot                #
########################################
#
# A simple RSS to Social Media bot.
#
# Written by: @VuoriLiikaluoma
#
# Version: 20150202
#

# Add your feeds here.
urlList = [
  'http://example.com/rss'
]

# Publish to Facebook?
#facebook = false

# Publish to Reddit?
#reddit = false

# Publish to Twitter?
twitter = true
twitter_api_key = "123456789ABCDEFGHIJKLMNOP"
twitter_api_key_secret = "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmno"
twitter_oauth_token = "12345678-9ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmn"
twitter_oauth_token_secret = "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghij"

################################################################################
#        Do not touch the stuff below unless you know what you're doing.       #
################################################################################

# Open the database.
db = SQLite3::Database.new "tnebot.sqlite3"

# Add URLs to the Database if they don't already exist.
urlList.each do |url|
  db.execute("INSERT OR IGNORE INTO `rss_feeds` ('url') VALUES (?);", url)
end

# Remove any URLs not in the list from the Database.
query = "DELETE FROM `rss_feeds` WHERE "
urlList.each do |url|
  query << "url <> '"+url+"' AND "
end
query = query[0..-6]+";"
db.execute query

## RSS - Parse the RSS feeds.
feeds = {}
feedTitles = []
urlList.each do |url|
  open(url) do |rss|
    date = DateTime.parse(rss.meta["date"])
    oldDate = DateTime.parse(db.execute("SELECT date FROM `rss_feeds` WHERE url = ?;", url).to_s)
    if date > oldDate
      feed = RSS::Parser.parse(rss)
      feeds[feed.channel.title] = []
      feedTitles.push(feed.channel.title)
      feed.items.each do |item|
        if DateTime.parse(item.pubDate.to_s) > oldDate
          feeds[feed.channel.title].push(item)
        end
      end
      db.execute("UPDATE `rss_feeds` SET date = ? WHERE url = ?;", [date.to_s, url])
    end
  end
end

## Facebook - Prepare Facebook OAuth2 stuff.

## Reddit - Prepare Reddit OAuth2 stuff.

## Twitter - Prepare Twitter OAuth access token.
def prepare_access_token(api_key, api_key_secret, oauth_token, oauth_token_secret)
  consumer = OAuth::Consumer.new(api_key, api_key_secret,
    { :site => "https://api.twitter.com",
      :scheme => :header })
  # now create the access token object from passed values
  token_hash = {
    :oauth_token => oauth_token,
    :oauth_token_secret => oauth_token_secret
  }
  oauth_access_token = OAuth::AccessToken.from_hash(consumer, token_hash)
  return oauth_access_token
end

## Output the feed items.
feedTitles.each do |title|
  feeds[title].each do |item|
    if facebook === true
      #TODO: Add facebook support...
    end
    if reddit === true
      #TODO: Add reddit support...
    end
    if twitter === true
      twitter_access_token = prepare_access_token(twitter_api_key, twitter_api_key_secret, twitter_oauth_token, twitter_oauth_token_secret)
      if item.title.length > 116
        tweet = "#{item.title[0..113]}... - #{item.link}"
      else
        tweet = "#{item.title} - #{item.link}"
      end
      twitter_update_hash = {'status' => tweet}
      twitter_response = twitter_access_token.request(:post, 'https://api.twitter.com/1.1/statuses/update.json', twitter_update_hash, { 'Accept' => 'application/xml', 'Content-Type' => 'application/x-www-form-urlencoded' })
    end
  end
end

