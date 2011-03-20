Herald
====

Herald is a simple notifier for Twitter, RSS, or email. 

Pass Herald some keywords and sources to watch, and Herald will notify you using Growl, email, pinging a site, or running Ruby code as soon as those keywords appear.

Installation
------------

### Rubygems

    gem install herald

### GitHub

    git clone git://github.com/lukes/herald.git
    gem build herald.gemspec
    gem install herald-<version>.gem

Usage
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
      _for "christchurch", "earthquake"
    end

Or, if sources should have different keywords

    Herald.watch do
      check :rss, :from => ["http://example.com/one.rss", "http://example.com/two.rss"] {
        _for "christchurch", "earthquake"
      }
      check :twitter {
        _for "#eqnz", "#chch", "#quake"
      }
    end

### Actions

By default Herald will use Ruby's `$stdout` and simply prints what it finds.

You can swap in another action by passing Herald one of the following `action` parameters:

#### Growl

[Growl](http://growl.info/) is a notification system for Mac OS X.

To use Growl, enable "Listen for incoming notifications" and "Allow remote application registration" on the [Network tab](http://growl.info/documentation/exploring-preferences.php) of the Growl Preference Panel, and pass Herald `action :growl`:

    Herald.watch_twitter do
      _for "herald", "ruby"
      action :growl
    end

#### Ping

To ping a URI, pass Herald `action :ping, :uri => "http://address.to.ping"`:

    Herald.watch_twitter do
      _for "#yaks", "#in", "#space"
      action :ping, :uri => "http://mycounter.com/+1"
    end
    
#### Post [Not Implemented]

To post information about what Herald finds to a URI, pass Herald `action :post, :uri => "http://address.to.post.to"`:

    Herald.watch_twitter do
      _for "#yaks", "#in", "#space"
      action :post, :uri => "http://yakdb.com/post"
    end
    
#### Callbacks [Not Implemented]

If you'd like to do your own thing entirely each time a keyword appears, pass a callback in the form of a Ruby block:

    Herald.watch_twitter do
      _for "revolution"
      action do
        `say "Viva!"`
      end
    end

### Timer [Not Implemented]

By default Herald will sleep for 2 minutes after checking each of the sources independently. 
To set a different sleep time:

    Herald.watch do
      check :twitter
      _for "soundofmusic"
      every 60 => "seconds"
    end
        
### Look Once

Rather than watching, if you just want to get a single poll of keywords, use `once()`. All the same parameters as with `watch()` can be used (except `:every`).

    Herald.once do
      check :twitter
      for "#herald"
    end

### Herald Binary [Not Implemented]

    herald -watch twitter -for #eqnz
    herald -alert twitter -for #herald
    herald -show-heralds
    herald -modify 1 -watch rss -from http://example.com/.rss
    herald -pause 1
    herald -kill 1