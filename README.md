Outcasts
========

**Words that people on Twitter don't think are words.**

Outcasts is a little ruby script that runs on heroku every ten minutes. It searches the Twitter API for tweets containing the words, "is not a word". Each (non)word is then looked up using the Wordnik API. If we don't have any definitions for the word, it makes the cut and ends up on a list on wordnik: 

[wordnik.com/lists/outcasts](http://www.wordnik.com/lists/outcasts)