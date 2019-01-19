'''
Local Settings for a heroku_ebooks account. 
'''

import os

# Configuration for Twitter API
ENABLE_TWITTER_POSTING = True # Tweet resulting status?
MY_CONSUMER_KEY = os.environ.get('EBOOKS_CONSUMER_KEY')
MY_CONSUMER_SECRET = os.environ.get('EBOOKS_CONSUMER_SECRET')
MY_ACCESS_TOKEN_KEY = os.environ.get('EBOOKS_OAUTH_TOKEN')
MY_ACCESS_TOKEN_SECRET = os.environ.get('EBOOKS_OAUTH_TOKEN_SECRET')

# Sources (Twitter, Mastodon, local text file or a web page)
SOURCE_EXCLUDE = r'^$'  # Source tweets that match this regexp will not be added to the Markov chain. You might want to filter out inappropriate words for example.
STATIC_TEST = True # Set this to True if you want to test Markov generation from a static file instead of the API.
TEST_SOURCE = os.environ.get('EBOOKS_SOURCE_FILE') + ".txt"  # The name of a text file of a string-ified list for testing. To avoid unnecessarily hitting Twitter API. You can use the included testcorpus.txt, if needed.

ODDS = 8  # How often do you want this to run? 1/8 times?
ORDER = 2  # How closely do you want this to hew to sensical? 2 is low and 4 is high.
SLEEP = os.environ.get('EBOOKS_SLEEP_S')

DEBUG = False  # Set this to False to start Tweeting live
TWEET_ACCOUNT = os.environ.get('EBOOKS_TWITTER_USERNAME')  # The name of the account you're tweeting to.

