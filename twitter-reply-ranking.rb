require "twitter"
require "json"
require "erb"
require "fileutils"

cohort_filename = ARGV[0]
template_filename = ARGV[1]
days_to_measure = 90

# Load the credentials
credentials = JSON.parse(File.read("credentials.json"))

# Initialize the Twitter client
client = Twitter::REST::Client.new do |config|
  config.consumer_key        = credentials['consumer_key']
  config.consumer_secret     = credentials['consumer_secret']
  config.access_token        = credentials['access_token']
  config.access_token_secret = credentials['access_token_secret']
end

# Load the template
template_file = File.read("#{template_filename}")
renderer = ERB.new(template_file)

# Load the JSON source
cohort_file = File.read("#{cohort_filename}")
@officials = JSON.parse(cohort_file)

# Start collecting Twitter data
start_time = Time.now

@officials.each do |official|
  puts "#{official['first']} #{official['last']}".upcase

  if official['screen_name'].nil?
    puts "  No screen name, skipping..."

    official['tweets_total'] = 0
    official['tweets_daily'] = 0
    official['replies_total'] = 0
    official['replies_daily'] = 0
  else
    mention_count = 0
    tweet_count = 0
    reply_count = 0

    # Normalize screen name field to an array
    # (some officials tweet via multiple screen names)
    unless official['screen_name'].kind_of?(Array)
      official['screen_name'] = [ official['screen_name'] ]
    end

    official['screen_name'].each do |screen_name|
      date_reached = false
      last_status_id = nil
      options = { count: 200, tweet_mode: 'extended' }

      loop do
        unless last_status_id.nil?
          options["max_id"] = last_status_id
        end

        tweets = client.user_timeline(screen_name, options)
        puts "  #{tweets.count} tweets retrieved from #{screen_name}..."

        tweets.each_with_index do |tweet, index|
          date_reached = tweet.created_at < Time.now - (days_to_measure * 24 * 60 * 60)

          if date_reached
            puts "  Reached #{days_to_measure} limit with tweet #{index} created at #{tweet.created_at}"
            break
          end
          
          tweet_count += 1

          tweet_attrs = tweet.attrs

          # DO NOT count tweets where the official is replying to him/herself
          if !tweet.in_reply_to_status_id.nil? && tweet.in_reply_to_screen_name.downcase != screen_name.downcase
            # This is a traditional reply
            reply_count += 1
          elsif !tweet.quoted_status.nil? && tweet.quoted_status.user.screen_name.downcase != screen_name.downcase
            # Check quoted retweet to see if official had been mentioned
            quoted_mentions = tweet.quoted_status.user_mentions.map{|x| x.screen_name.downcase }
            if quoted_mentions.include? screen_name.downcase
              # Official was "officially" mentioned
              reply_count += 1
              puts "  +1 reply to quoted mention"
            elsif tweet.quoted_status.text.downcase.include? "@#{screen_name.downcase}"
              # Official's screen_name was in the quoted text
              reply_count += 1
              puts "  +1 reply to quoted mention (from full text)"
            end
          end
          
          last_status_id = tweet.id - 1
        end

        break if date_reached || tweets.count == 0
      end
    end

    official['tweets_total'] = tweet_count
    official['tweets_daily'] = tweet_count.to_f / 90
    official['replies_total'] = reply_count
    official['replies_daily'] = reply_count.to_f / 90

    puts "> #{tweet_count} tweets, #{reply_count} replies"
  end
end

puts "\nComputing leaders..."

responsive = @officials.sort_by { |official| official["replies_daily"] }
@most_responsive = responsive.pop(5).reverse

talkative = @officials.sort_by { |official| official["tweets_daily"] }
@most_talkative = talkative.pop(5).reverse

@missing = @officials.dup.keep_if { |official| official["tweets_total"] == 0 }

puts "\nRendering output..."

# Create output directory if it doesn't exist
FileUtils.mkdir_p 'out'

output_file = "out/" + File.basename(cohort_filename).split(".")[0] + "_" + start_time.strftime('%Y-%m-%d-%H-%M-%S') + ".html"
File.write(output_file, renderer.result(binding))