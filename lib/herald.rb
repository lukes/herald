#require 'net/http'
require 'open-uri'

require 'rubygems'
require 'json'

require 'herald/watcher'
require 'herald/notifier'

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
  
  def self.lazy_load_module(module_path)
    lazy_load("herald/#{module_path}")
  end
  
  # TODO test whether this can be made private
  def self.lazy_load(path)
    require(path)
  end
 
#  Shorthand methods? 
#  def self.watch_twitter(&block); end
#  def self.watch_rss(&block); end
  
  def initialize(&block)
    @watchers = []
    if block_given?
      block.arity == 1 ? yield(self) : instance_eval(&block)
    end
    # TODO does it matter if @watchers.empty? at this point
  end
  
  # create a new Watcher
  def check(type, options = {}, &block)
    @watchers << Herald::Watcher.new(type, options, &block)
  end

  # send keywords to each Watcher  
  def _for(*keywords)
    @watchers.each do |watcher|
      watcher.for(*keywords)
    end
  end

  # send instructions on what to do to each Watcher
  def action(type, options = {}, &block)
    if block_given?
      raise "Callbacks not implemented yet"
    end
    @watchers.each do |watcher|
      watcher.action(type, options)
    end
  end
    
  # TODO
  def every(time = { 120 => "seconds" }); end
  
#private
  
  # start Watchers
  def start
    @watchers.each do |watcher|
      watcher.start
    end
  end
  
  # stop Watchers
  def stop
    @watchers.each do |watcher|
      watcher.stop
    end
  end

  # call each Watcher's activities once
  def once
    @watchers.each do |watcher|
      watcher.activities
    end
  end

end