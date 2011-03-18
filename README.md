Herald
====

Herald is a simple Growl notifier for Twitter, RSS, or email. 

Pass Herald some keywords and sources, and you'll be notified when your keywords appear.

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
      _for "soundofmusic"
    end
    
Or an RSS feed:

    Herald.watch do
      check :rss, :from => "http://example.com/.rss"
      _for "soundofmusic"
    end
  
### Watching multiple sources, or for multiple keywords

Watching two RSS feeds and Twitter for two keywords

    Herald.watch do
      check :rss, :from => ["http://example.com/one.rss", "http://example.com/two.rss"]
      check :twitter
      _for ["christchurch", "earthquake"]
    end

Or, if sources should have different keywords

    Herald.watch do
      check :rss, :from => ["http://example.com/one.rss", "http://example.com/two.rss"] {
        _for ["christchurch", "earthquake"]
      }
      check :twitter {
        _for ["#eqnz", "#chch", "#quake"] 
      }
    end
    

### Callbacks

If you'd like to do something else each time a keyword appears, pass a callback

    Herald.watch_twitter do
      _for "revolution"
      growl :off
      notify do
        `say "Viva!"`
      end
    end
    

### Timer

By default Herald will sleep for 2 minutes after checking each of the sources independently. 
To set a different sleep time:

    Herald.watch do
      check :twitter
      _for :soundofmusic
      every 60 => "seconds"
    end
        
### Shorthand Methods

    # Herald.watch_twitter
    Herald.watch_twitter { _for "#herald" }

    # Herald.watch_rss
    Herald.watch_rss { :from => "http://example.com/.rss", _for "herald" }

  