require 'dotenv'
Dotenv.load(".env")

task :scale_up => :environment do
  heroku = Heroku::API.new
  heroku.post_ps_scale(ENV['EBOOKS_APP_NAME'], 'worker', 1)
end

task :scale_down => :environment do
  heroku = Heroku::API.new
  heroku.post_ps_scale(ENV['EBOOKS_APP_NAME'], 'worker', 0)
end
