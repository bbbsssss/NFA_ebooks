#!/usr/bin/env ruby

require 'twitter_ebooks'
include Ebooks

require 'dotenv'
Dotenv.load(".env")

CONSUMER_KEY = ENV['EBOOKS_CONSUMER_KEY'] 
CONSUMER_SECRET = ENV['EBOOKS_CONSUMER_SECRET']
ACCESS_TOKEN = ENV['EBOOKS_OAUTH_TOKEN']
ACCESS_TOKEN_SECRET = ENV['EBOOKS_OAUTH_TOKEN_SECRET']

class NFABot < Ebooks::Bot
  attr_accessor :original, :model, :model_path
  
  def configure
    self.consumer_key = CONSUMER_KEY
	self.consumer_secret = CONSUMER_SECRET
  end
  
  def top100; @top100 ||= model.keywords.top(100); end
  def top50;  @top50  ||= model.keywords.top(50); end
	  
  def on_startup
    load_model!
	
	# tweet every 2 hours
	scheduler.cron '0 */2 * * *' do
	  tweet(model.make_statement)
	end
  end
  
  private
  def load_model!
    return if @model
	
	@model_path ||= "model/#{original}.model"
	
	log "Loading model #{model_path}"
	@model = Ebooks::Model.load(model_path)
  end
end

NFABot.new("NFA_ebooks") do |bot|
  bot.access_token = ACCESS_TOKEN
  bot.access_token_secret = ACCESS_TOKEN_SECRET

  bot.original = "NFA_ebooks"
end
