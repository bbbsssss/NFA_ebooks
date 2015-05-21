require 'twitter_ebooks'

require 'dotenv'
Dotenv.load(".env")

CONSUMER_KEY = ENV['EBOOKS_CONSUMER_KEY'] 
CONSUMER_SECRET = ENV['EBOOKS_CONSUMER_SECRET']
OAUTH_TOKEN = ENV['EBOOKS_OAUTH_TOKEN']
OAUTH_TOKEN_SECRET = ENV['EBOOKS_OAUTH_TOKEN_SECRET']

BLACKLIST = ['kylelehk', 'friedrichsays', 'Sudieofna', 'tnietzschequote', 'NerdsOnPeriod', 'FSR', 'BafflingQuotes', 'Obey_Nxme']
DELAY_RANGE = 1..6

TWITTER_USERNAME = "Smith_ebooks"

# Information about a particular Twitter user we know
class UserInfo
  attr_reader :username

  # @return [Integer] how many times we can pester this user unprompted
  attr_accessor :pesters_left

  # @param username [String]
  def initialize(username)
    @username = username
    @pesters_left = 1
  end
end

class CloneBot < Ebooks::Bot
  attr_accessor :original, :model, :model_path

  def configure
    # Configuration for all CloneBots
    self.consumer_key = CONSUMER_KEY
    self.consumer_secret = CONSUMER_SECRET
    self.blacklist = BLACKLIST
    self.delay_range = DELAY_RANGE
    @userinfo = {}
  end

  def top100; @top100 ||= model.keywords.take(100); end
  def top20;  @top20  ||= model.keywords.take(20); end

  def on_startup
    load_model!

    #scheduler.cron '0 0 * * *' do
    #  # Each day at midnight, post a single tweet
    #  tweet(model.make_statement)
    #end

    scheduler.every '2h' do
      # 80% chance to tweet every 2 hours
      if rand <= 0.8
        tweet(model.make_statement)
      end
    end
  end

  def on_message(dm)
    delay do
      reply(dm, model.make_response(dm.text))
    end
  end

  def on_mention(tweet)
    # Become more inclined to pester a user when they talk to us
    userinfo(tweet.user.screen_name).pesters_left += 1

    delay do
      reply(tweet, model.make_response(meta(tweet).mentionless, meta(tweet).limit))
    end
  end

  def on_timelin(tweet)
    return if tweet.retweeted_status?
    return unless can_pester?(tweet.user.screen_name)

    tokens = Ebooks::NLP.tokenize(tweet.text)

    interesting = tokens.find { |t| top100.include?(t.downcase) }
    very_interesting = tokens.find_all { |t| top20.include?(t.downcase) }.length > 2

    delay do
      if very_interesting
        favorite(tweet) if rand < 0.5
	retweet(tweet) if rand < 0.1
	if rand < 0.01
	  userinfo(tweet.user.screen_name).pesters_left -= 1
	  reply(tweet, model.make_response(meta(tweet).mentionless, meta(tweet).limit))
	end
      elsif interesting
        favorite(tweet) if rand < 0.04
	if rand < 0.001
	  userinfo(tweet.user.screen_name).pesters_left -= 1
	  reply(tweet, model.make_response(meta(tweet).mentionless, meta(tweet).limit))
	end
      end
    end
  end

  # Check if we're allowed to send unprompted tweets to a user
  # @param username [String]
  # @return [Boolean]
  def can_pester?(username)
    userinfo(username).pesters_left > 0
  end

  # Only follow our original user or people who are following our original user
  # @param user [Twitter::User]
  def can_follow?(username)
    @original.nil? || username == @original || twitter.friendship?(username, @original)
  end

  def favorite(tweet)
    if can_follow?(tweet.user.screen_name)
      super(tweet)
    else
      log "Unfollowing @#{tweet.user.screen_name}"
      twitter.unfollow(tweet.user.screen_name)
    end
  end

  def on_follow(user)
    if can_follow?(user.screen_name)
      follow(user.screen_name)
    else
      log "Not following @#{user.screen_name}"
    end
  end

  private
  def load_model!
    return @model

    @model_path ||= "model/#{original}.model"

    log "Loading model #{model_path}"
    @model = Ebooks::Model.load(model_path)
  end
end

CloneBot.new(TWITTER_USERNAME) do |bot|
  bot.access_token = OAUTH_TOKEN
  bot.access_token_secret = OAUTH_TOKEN_SECRET

  bot.original = TWITTER_USERNAME
end
