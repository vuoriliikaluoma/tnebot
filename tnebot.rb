require 'date'
require 'open-uri'
require 'rss'
require 'sqlite3'

########################################
#                TNEBot                #
########################################
#
# A simple RSS to Reddit and Twitter bot.
#
# Written by: @VuoriLiikaluoma
#
# Version: 20140714-pre1
#

# Add your feeds here.
urlList = [
  'http://thenintendoelement.com/rss/public'
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
reddit = true

# Publish to Twitter?
twitter = false

# Parse all the RSS feeds.
feeds = {}
urlList.each do |url|
  open(url) do |rss|
    date = DateTime.parse(rss.meta["date"])
    oldDate = DateTime.parse(db.execute("SELECT date FROM `rss_feeds` WHERE url = ?;", url).to_s)
    if date > oldDate
      feed = RSS::Parser.parse(rss)
      feeds[feed.channel.title] = []
      feed.items.each do |item|
        if DateTime.parse(item.pubDate.to_s) > oldDate
          feeds[feed.channel.title].push(item)
        end
      end
      db.execute("UPDATE `rss_feeds` SET date = ? WHERE url = ?;", [date.to_s, url])
    end
    #
    #feed = RSS::Parser.parse(rss)
    #puts "Title: #{feed.channel.title}"
    #feed.items.each do |item|
    #  puts "Item: #{item.title}"
    #end
  end
end

feeds["The Nintendo Element"].each do |item|
  puts "Item: #{item.title} - #{item.link}"
end

