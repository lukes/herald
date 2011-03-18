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


Using with Growl
----------------

[Growl](http://growl.info/) is a notification system for Mac OS X.

For Herald to use Growl, enable "Listen for incoming notifications" on the [Network tab](http://growl.info/documentation/exploring-preferences.php) of the Growl Preference Panel.

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
      action do
        `say "Viva!"`
      end
    end
    

### Timer

By default Herald will sleep for 2 minutes after checking each of the sources independently. 
To set a different sleep time:

    Herald.watch do
      check :twitter
      _for "soundofmusic"
      every 60 => "seconds"
    end
        
### Alert

Rather than watching, if you just want to get a single poll of keywords, use alert()

  Herald.alert do
    check :twitter
    for "#herald"
    # all other block parameters can be used, except "every"
  end
        
### Shorthand Methods

    # Herald.watch_twitter
    Herald.watch_twitter { _for "#herald" }
    # Herald.alert_twitter
    Herald.alert_twitter { _for "#herald" }
    
    # Herald.watch_rss
    Herald.watch_rss { :from => "http://example.com/.rss", _for "herald" }
    # Herald.alert_rss
    Herald.alert_rss { :from => "http://example.com/.rss", _for "herald" }

### herald Binary (Not implemented)

    herald -watch twitter -for #eqnz
    herald -alert twitter -for #herald
    herald -show-heralds
    herald -modify 1 -watch rss -from http://example.com/.rss
    herald -pause 1
    herald -kill 1