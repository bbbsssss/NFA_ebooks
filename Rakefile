require 'heroku-api'

require 'dotenv'
Dotenv.load(".env")

task :scale_up do
  heroku = Heroku::API.new(:api_key => ENV['HEROKU_API_KEY'])
  heroku.post_ps_scale(ENV['EBOOKS_APP_NAME'], 'worker', 1)
end

task :scale_down do
  heroku = Heroku::API.new(:api_key => ENV['HEROKU_API_KEY'])
  heroku.post_ps_scale(ENV['EBOOKS_APP_NAME'], 'worker', 0)
end
