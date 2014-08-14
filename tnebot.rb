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
# A simple RSS to Twitter and Reddit bot.
#
# Written by: @VuoriLiikaluoma
#
# Version: 20140814
#

# Add your feeds here.
urlList = [
  'http://example.com/rss'
]

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

# Publish to Reddit?
reddit = false

# Publish to Twitter?
twitter = true

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

## Twitter - Prepare Twitters OAuth access token.
def prepare_access_token(oauth_token, oauth_token_secret)
  consumer = OAuth::Consumer.new("API key", "API secret",
    { :site => "https://api.twitter.com",
      :scheme => :header })
  # now create the access token object from passed values
  token_hash = {
    :oauth_token => oauth_token,
    :oauth_token_secret => oauth_token_secret
  }
  access_token = OAuth::AccessToken.from_hash(consumer, token_hash)
  return access_token
end

## Reddit - OAuth2 stuff.
#TODO: Add OAuth2 code for Reddit...

## Output the feed items.
feedTitles.each do |title|
  feeds[title].each do |item|
    if twitter === true
      twitter_access_token = prepare_access_token("Access token", "Access token secret")
      if item.title.length > 108
        tweet = "TNEBot: #{item.title[0..104]}... - #{item.link}"
      else
        tweet = "TNEBot: #{item.title} - #{item.link}"
      end
      twitter_update_hash = {'status' => tweet}
      twitter_response = twitter_access_token.request(:post, 'https://api.twitter.com/1.1/statuses/update.json', twitter_update_hash, { 'Accept' => 'application/xml', 'Content-Type' => 'application/x-www-form-urlencoded' })
    end
    if reddit === true
      #TODO: Add reddit support...
    end
  end
end

