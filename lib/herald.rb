#require 'net/http'
require 'open-uri'
require 'rss/0.9'
require 'rss/1.0'
require 'rss/2.0'
require 'rss/parser'

require 'rubygems'
require 'json'
require 'ruby-growl' # make this optional?
require 'ping'

require 'herald/watcher'
require 'herald/notifier'
require 'herald/watchers/twitter'
require 'herald/watchers/rss'
require 'herald/notifiers/growl'

class Herald

  attr_reader :watchers

  def self.watch(&block)
    herald = new(&block)
    herald.start
    herald
  end
  
  def self.once(&block)
    herald = new(&block)
    herald.once
    herald
  end
 
#  Shorthand methods? 
#  def self.watch_twitter(&block); end
#  def self.watch_rss(&block); end
  
  def initialize(&block)
    @watchers = []
    @notifiers = []
    if block_given?
      block.arity == 1 ? yield(self) : instance_eval(&block)
    end
  end
  
  def check(type, options = {}, &block)
    @watchers << Herald::Watcher.new(type, options, &block)
  end
  
  def _for(keywords)
    @watchers.each do |watcher|
      watcher.for(keywords)
    end
  end

  # TODO implement block
  def action(type = :growl, options = {}, &block)
    if block_given?
      raise "Callbacks not implemented yet"
    end
    @watchers.each do |watcher|
      watcher.action(type, options)
    end
  end
    
  def every(time = { 120 => "seconds" })
  end
  
#private
  
  def start
    @watchers.each do |watcher|
      watcher.start
    end
  end
  
  def stop
    @watchers.each do |watcher|
      watcher.stop
    end
  end

  def once
    @watchers.each do |watcher|
      watcher.once
    end
  end

end