# Smith_ebooks

Twitter _ebooks bot for Heroku deploy (or not).

install gems and bundle
```
gem install bundler
gem install twitter_ebooks
gem install heroku-api
gem install dotenv
bundle install
```
configure env vars
```
EBOOKS_APP_NAME
EBOOKS_CONSUMER_KEY
EBOOKS_CONSUMER_SECRET
EBOOKS_FREQUENCY
EBOOKS_OAUTH_TOKEN
EBOOKS_OAUTH_TOKEN_SECRET
EBOOKS_TEXT_MODEL
EBOOKS_TWITTER_USERNAME
HEROKU_API_KEY
```
to generate a model from a new text file
```
ebooks consume corpus/file.ext
````
