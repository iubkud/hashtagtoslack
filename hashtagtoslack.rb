require 'dotenv'
Dotenv.load
require 'twitter'

# Authenticate user
client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV["TWITTER_API_KEY"]
  config.consumer_secret     = ENV["TWITTER_API_SECRET"]
  config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
  config.access_token_secret = ENV["TWITTER_ACCESS_SECRET"]
end

# Get tweets with #loveproscape since last time script ran
@tweets = client.search("#loveproscape", :since_id => ENV["LAST_TWEET_ID"])

# Tweets come in sorted newest to oldest, we need to reverse them
@tweets = @tweets.sort {|a,b| a.id <=> b.id}

# Set counter for last tweet check
i = 1

# Loop through each tweet
@tweets.each do |t|
	if (t.user.screen_name != "proscapetech")
		puts "@#{t.user.screen_name} #{t.created_at}"
		puts t.id
	end

	if @tweets.count == i
		text = File.read(".env")
		new_contents = text.gsub("#{ENV['LAST_TWEET_ID']}", "#{t.id}")
		File.open(".env", "w") {|file| file.puts new_contents }
	end
	i += 1
end
