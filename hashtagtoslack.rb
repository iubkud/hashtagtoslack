require 'rubygems'
require 'dotenv'
require 'twitter'
require 'net/http'
require 'json'

Dotenv.load

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


# Loop through each tweet
def check_tweets
	# Set counter for last tweet check
	i = 1

	@tweets.each do |t|
		# Only post tweets NOT from @proscapetech
		if (t.user.screen_name != "proscapetech")
			slack_message(t.id, t.user.screen_name, t.text)
		end

		# On the last tweet, store the ID in ENV["LAST_TWEET_ID"]
		if @tweets.count == i
			text = File.read(".env")
			new_contents = text.gsub("#{ENV['LAST_TWEET_ID']}", "#{t.id}")
			File.open(".env", "w") {|file| file.puts new_contents }
		end
		i += 1
	end
end

# Post slack message
def slack_message(id, screen_name, text)
	uri = URI.parse(ENV["SLACK_WEBHOOK_URL"])
	http = Net::HTTP.new(uri.host, uri.port)
	http.use_ssl = true
	request = Net::HTTP::Post.new(uri.request_uri, {'Content-Type' => 'application/json'})
	request.body = {
		"username" => "twitterbot",
		"icon_emoji" => ":rseixas:",
	  "text"     => "<http://twitter.com/statuses/#{id}|@#{screen_name}> : #{text}"
	}.to_json

	response = http.request(request)
	puts response.body
end

check_tweets