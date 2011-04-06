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
-----

First step is `require` Herald into your Ruby project:

    require 'rubygems'
    require 'herald'

Then, to watch for tweets containing "soundofmusic":

    Herald.watch do
      check :twitter
      _for "soundofmusic"
    end

Or an RSS feed:

    Herald.watch do
      check :rss, :from => "http://example.com/.rss"
      _for "soundofmusic"
    end

Or an email inbox: [Not Implemented]

    Herald.watch do
      check :inbox, :imap => "imap.server.com", :user => "username", :pass => "supersecret"
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
      check :rss, :from => ["http://example.com/one.rss", "http://example.com/two.rss"] do
        _for "christchurch", "earthquake"
      end
      check :twitter do
        _for "#eqnz", "#chch", "#quake"
      end
    end

### Actions

By default Herald will use Ruby's `$stdout` and simply prints what it finds.

Swap in another action by passing Herald one of the following `action` parameters:

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
    
#### Post

To post information about what Herald finds to a URI, pass Herald `action :post, :uri => "http://address.to.post.to"`:

    Herald.watch_twitter do
      _for "#yaks", "#in", "#space"
      action :post, :uri => "http://yakdb.com/post"
    end
    
#### Callbacks

If you'd like to do your own thing entirely each time a keyword appears, pass a callback in the form of a Ruby block:

    Herald.watch_twitter do
      _for "revolution"
      action do
        `say "Viva!"`
      end
    end

### Timer

By default Herald will sleep for 1 minute after checking each of the sources independently. 
To set a different sleep time:

    Herald.watch do
      check :twitter
      _for "soundofmusic"
      every 30 => "seconds" # or "minutes", "hours", or "days"
    end
        
### Look Once

Rather than watching, if you just want to get a single poll of keywords, use `once()`. All the same parameters as with `watch()` can be used (except `every`).

    Herald.once do
      check :twitter
      _for "#herald"
    end
    
### Callback Scope and Herald Metaprogramming

Callbacks allow a great deal of reflection into the internals of Herald.

If the callback is passed with the scope of `Herald`, it will have access to the `Herald` instance variables:

    Herald.watch_twitter do
      _for "#breaking", "news"
      action do
        puts instance_variables
      end
    end
  
If passed in within the scope of `Herald::Watcher`, it will have access to the particular `Watcher`'s instance variables:
  
    Herald.watch do
      check :twitter do
        _for "#breaking", "news"
        action do
          puts instance_variables
        end
      end
    end

### For inquisitive minds

    herald = Herald.watch_rss :from => "http://www.reddit.com/r/pics/.rss?sort=new" do
      _for "imgur"
    end
    # return Array of Herald::Watcher objects
    herald.watchers
    # which can be edited
    herald.watchers.first.keywords << "cats"
    herald.watchers.first.action { puts "callback" }
    # stop herald from watching
    herald.stop
    herald.alive? # => false
    # begin watching again
    herald.start

### Herald Binary [Not Implemented]

    herald -watch twitter -for #eqnz
    herald -once twitter -for #herald
    herald -show-heralds
    herald -modify 1 -watch rss -from http://example.com/.rss
    herald -pause 1
    herald -kill 1