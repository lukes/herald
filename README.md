Herald
====

Herald is a simple Growl notifier for Twitter, RSS, or email. 

Pass Herald some keywords and sources, and you'll be notified when your keywords appear in the sources.

Installation
------------

### Rubygems

    gem install herald

### GitHub

    git clone git://github.com/lukes/herald.git
    gem build herald.gemspec
    gem install herald-<version>.gem

Usage [IN DEVELOPMENT]
----------------------

Watch for tweets containing "soundofmusic":

    Herald.watch do
      check :twitter
      for :soundofmusic
    end
    
Or an RSS feed:

    Herald.watch do
      check :rss, :from => "http://example.com/.rss"
      for :soundofmusic
    end
  
Watching multiple sources
-------------------------

    Herald.watch do
      check :rss, :from => ["http://example.com/one.rss", "http://example.com/two.rss"]
      check :twitter
      for [:sound, :music]
    end

Timer
-----

By default Herald will sleep for 1 minute after checking each of the sources independently. 
To set a different sleep time:

    Herald.watch do
      check :twitter
      for :soundofmusic
      every 300 # (seconds)
    end

Callbacks
---------

If you'd like to do something else each time a keyword appears, pass a callback

    Herald.watch_twitter do
      growl :off
      for :soundofmusic
      action do
        `say "Hello!"`
      end
    end
    
Shorthand Methods
-----------------

    # Herald.watch_twitter
    Herald.watch_twitter { hashtag :soundofmusic }

    # Herald.watch_rss
    Herald.watch_rss { :from => ["http://example.com/.rss"], for :soundofmusic }

Hashtags
--------

    # Only watch for hashtags
    Herald.watch do
      check :twitter
      for :soundofmusic, :hashtag => true
    end

  