require 'dotenv'
Dotenv.load
require 'twitter'

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV["TWITTER_API_KEY"]
  config.consumer_secret     = ENV["TWITTER_API_SECRET"]
  config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
  config.access_token_secret = ENV["TWITTER_ACCESS_SECRET"]
end

@tweets = client.search("#loveproscape", :since_id => "693128269173002240")

i = 1

@tweets.each do |t|
	if (t.user.screen_name != "proscapetech")
		#puts "@#{t.user.screen_name} #{t.text}"
		puts t.id
	end

	if @tweets.count == i
		puts "LAST TWEET BY @#{t.user.screen_name}"
	end
	i += 1
end
