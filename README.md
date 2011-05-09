Herald
====

Herald is a simple and flexible notifier for Twitter and RSS.

Pass Herald some keywords and sources to watch, and Herald will notify you using Growl, pinging or posting to a site, or running Ruby code as soon as those keywords appear.

Installation
------------

### Rubygems

    gem install herald

### GitHub

    git clone git://github.com/lukes/herald.git
    gem build herald.gemspec
    gem install herald-0.2.gem

Usage
-----

First step is to `require` Herald into your Ruby project

    require 'rubygems'
    require 'herald'

Then, to watch for tweets containing "soundofmusic"

    Herald.watch do
      check :twitter
      _for "soundofmusic"
    end

Or an RSS feed

    Herald.watch do
      check :rss, :from => "http://example.com/.rss"
      _for "soundofmusic"
    end
    
Or text in a website

    Herald.watch do
      check :website, :from => "http://example.com"
      _for "soundofmusic"
    end

### Watching multiple sources, or for multiple keywords

Watching two RSS feeds and Twitter for two keywords

    Herald.watch do
      check :rss, :from => ["http://earthquakes.gov/.rss", "http://livenews.com/.rss"]
      check :twitter
      _for "christchurch", "earthquake"
    end

Or, if sources should have different keywords

    Herald.watch do    
      check :rss, :from => "http://earthquake.usgs.gov/earthquakes/catalogs/eqs1day-M0.xml" do
        _for "christchurch"
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

To use Growl, enable "Listen for incoming notifications" and "Allow remote application registration" on the [Network tab](http://growl.info/documentation/exploring-preferences.php) of the Growl Preference Panel, and pass Herald `action :growl`

    Herald.watch_twitter do
      _for "nz", "#election"
      action :growl
    end

#### Ping

To ping a URI, pass Herald `action :ping, :uri => "http://address.to.ping"`

    Herald.watch_twitter do
      _for "#fundamentalists", "#in", "#space"
      action :ping, :uri => "http://armageddon-clock.com/+1"
    end
    
#### Post

To post information about what Herald finds to a URI, pass Herald `action :post, :uri => "http://address.to.post.to"`

    Herald.watch_twitter do
      _for "vanity", "tweeting"
      action :post, :uri => "http://twitter-loves-me.com/post"
    end

#### Callbacks

If you'd like to do your own thing entirely each time a keyword appears, pass a callback in the form of a Ruby block

    Herald.watch_twitter do
      _for "revolution"
      action do
        `say "Viva!"`
      end
    end

Pass the callback a parameter to be given a `Herald::Item` object within your block. The object makes available everything Herald could find in the source.

    Herald.watch_twitter do
      _for "revolution"
      action do |item|
        puts item.data # full Hash of all data
      end
    end

#### Stdout

To print information about what Herald finds, pass Herald `action :stdout`. To save results to a file, include the parameter `:file => "log.txt"`

    Herald.watch_twitter do
      _for "newsworthy", "topic"
      action :stdout, :file => "log.txt"
    end
        
### Timer

By default Herald will sleep for 1 minute after checking each of the sources independently. 
To set a different sleep time

    Herald.watch_twitter do
      _for "soundofmusic"
      every 30 => "seconds" # or "minutes", "hours", or "days"
    end

### For inquisitive minds

Assign the herald watcher to a variable

    herald = Herald.watch_rss :from => "http://www.reddit.com/r/pics/new/.rss" do
      _for "imgur"
    end

Edit your herald instance while it's working

    herald.watchers
    herald.watchers.to_s # in English
    herald.watchers.first.keywords << "cats"
    herald.watchers.first.action { puts "callback" }

Stop and start the herald

    herald.stop
    herald.alive? # => false
    herald.start

Start a second herald

    herald_the_second = Herald.watch_twitter { _for "#herald" }

Use the `Herald` class methods to inspect and edit your heralds as a batch

    Herald.heralds # prints all heralds (running and stopped)
    Herald.heralds(:alive) # prints all running heralds
    Herald.heralds(:stopped) # prints all stopped heralds
    Herald.stop # stop all heralds
    Herald.alive? # => true if any heralds are running
    Herald.start # all heralds restarted
    Herald.delete(herald) # remove this herald from the Herald.heralds list
    Herald.delete(:stopped) # remove stopped heralds from Herald.heralds list
    Herald.size # prints number of heralds
    Herald.size(:alive) # prints number of running heralds
    Herald.size(:stopped) # prints number of stopped heralds
                
### Look once

Rather than watching, if you just want to get a single poll of keywords, use `once()`. All the same parameters as with `watch()` can be used (`every` will be ignored)

    herald = Herald.once do
      check :twitter
      _for "#herald"
    end

As with watching, Herald will fork a new process (or one for every source you're `check`ing), but unlike with watching, Herald will block and wait for the process to finish

    herald.start # waiting ... process ends at the same time you receive your notifications
    herald.alive? # => false

### A bit about callback scope and Herald metaprogramming

Callbacks allow a great deal of reflection into the internals of Herald.

If the callback is passed with the scope of `Herald`, it will have access to the `Herald` methods and instance variables

    Herald.watch_twitter do
      _for "#breaking", "news"
      action do
        puts instance_variables
      end
    end
  
If passed in within the scope of `Herald::Watcher` (`action` agents), it will have access to the particular `Watcher`'s methods and instance variables
  
    Herald.watch do
      check :twitter do
        _for "#breaking", "news"
        action do
          puts instance_variables
        end
      end
    end
    
### Running Herald as a script

Herald cleans up after itself by killing any running herald processes on exit. 

To make Herald run forever, add this to the end of your script

    Herald.daemonize!

`daemonize!` cuts the apron strings, and once set, your heralds will run forever. 

Use the Herald binary below when you wish to stop your free-spirited heralds.

### Herald binary

Print IDs of any running heralds

    sudo herald --show-heralds
    
Pass the ID to the `kill` command
    
    sudo herald --kill 1