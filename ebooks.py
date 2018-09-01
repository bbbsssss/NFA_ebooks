import random
import re
import sys
import twitter
import markov
from html.entities import name2codepoint as n2c
from urllib.request import urlopen
from local_settings import *

def connect(type='twitter'):
    if type == 'twitter':
        return twitter.Api(consumer_key=MY_CONSUMER_KEY,
                       consumer_secret=MY_CONSUMER_SECRET,
                       access_token_key=MY_ACCESS_TOKEN_KEY,
                       access_token_secret=MY_ACCESS_TOKEN_SECRET,
                       tweet_mode='extended')
    return None


def entity(text):
    if text[:2] == "&#":
        try:
            if text[:3] == "&#x":
                return chr(int(text[3:-1], 16))
            else:
                return chr(int(text[2:-1]))
        except ValueError:
            pass
    else:
        guess = text[1:-1]
        if guess == "apos":
            guess = "lsquo"
        numero = n2c[guess]
        try:
            text = chr(numero)
        except KeyError:
            pass
    return text


def filter_status(text):
    text = re.sub(r'\b(RT|MT) .+', '', text)  # take out anything after RT or MT
    #text = re.sub(r'(\#|@|(h\/t)|(http))\S+', '', text)  # Take out URLs, hashtags, hts, etc.
    #text = re.sub('\s+', ' ', text)  # collaspse consecutive whitespace to single spaces.
    text = re.sub(r'\"|\(|\)', '', text)  # take out quotes.
    #text = re.sub(r'\s+\(?(via|says)\s@\w+\)?', '', text)  # remove attribution
    text = re.sub(r'<[^>]*>','', text) #strip out html tags from mastodon posts
    htmlsents = re.findall(r'&\w+;', text)
    for item in htmlsents:
        text = text.replace(item, entity(item))
    text = re.sub(r'\xe9', 'e', text)  # take out accented e
    return text

if __name__ == "__main__":
    order = ORDER
    guess = 0
    if ODDS and not DEBUG:
        guess = random.randint(0, ODDS - 1)

    if guess:
        print(str(guess) + " No, sorry, not this time.")  # message if the random number fails.
        sys.exit()
    else:
        api = connect()
        source_statuses = []
        if STATIC_TEST:
            file = TEST_SOURCE
            print(">>> Generating from {0}".format(file))
            string_list = open(file).readlines()
            for item in string_list:
                source_statuses += item.split(",")
        if len(source_statuses) == 0:
            print("No statuses found!")
            sys.exit()
        mine = markov.MarkovChainer(order)
        for status in source_statuses:
            if not re.search('([\.\!\?\"\']$)', status):
                status += "."
            mine.add_text(status)
        for x in range(0, 10):
            ebook_status = mine.generate_sentence()

        # randomly drop the last word, as Horse_ebooks appears to do.
        if random.randint(0, 4) == 0 and re.search(r'(in|to|from|for|with|by|our|of|your|around|under|beyond)\s\w+$', ebook_status) is not None:
            print("Losing last word randomly")
            ebook_status = re.sub(r'\s\w+.$', '', ebook_status)
            print(ebook_status)

        # if a tweet is very short, this will randomly add a second sentence to it.
        if ebook_status is not None and len(ebook_status) < 40:
            rando = random.randint(0, 10)
            if rando == 0 or rando == 7:
                print("Short tweet. Adding another sentence randomly")
                newer_status = mine.generate_sentence()
                if newer_status is not None:
                    ebook_status += " " + mine.generate_sentence()
                else:
                    ebook_status = ebook_status
            elif rando == 1:
                # say something crazy/prophetic in all caps
                print("IT'S HAPPENING")
                ebook_status = ebook_status.upper()

        # throw out tweets that match anything from the source account.
        if ebook_status is not None and len(ebook_status) < 210:
            for status in source_statuses:
                if ebook_status[:-1] not in status:
                    continue
                else:
                    print("TOO SIMILAR: " + ebook_status)
                    sys.exit()

            if not DEBUG:
                if ENABLE_TWITTER_POSTING:
                    status = api.PostUpdate(ebook_status)
            print(ebook_status)

        elif not ebook_status:
            print("Status is empty, sorry.")
        else:
            print("TOO LONG: " + ebook_status)
