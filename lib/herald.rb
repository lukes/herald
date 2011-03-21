require 'rubygems'

require 'herald/watcher'
require 'herald/notifier'

class Herald

  attr_reader :watchers, :watching

  def self.watch(&block)
    herald = new(:watching => true, &block)
    herald.start
    herald
  end
  
  def self.once(&block)
    herald = new(&block)
    herald.start
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
  
  def initialize(options = {}, &block)
    @watchers = []
    @watching = options.delete(:watching)
    if block_given?
      block.arity == 1 ? yield(self) : instance_eval(&block)
    end
    # TODO does it matter if @watchers.empty? at this point
  end
  
  # create a new Watcher
  def check(type, options = {}, &block)
    @watchers << Herald::Watcher.new(type, options, &block)
  end

  # send keywords to Watchers
  def _for(*keywords)
    @watchers.each do |watcher|
      watcher.for(*keywords)
    end
  end

  # send instructions to Watchers
  def action(type, options = {}, &block)
    if block_given?
      raise "Callbacks not implemented yet"
    end
    @watchers.each do |watcher|
      watcher.action(type, options)
    end
  end
    
  # send sleep time to Watchers
  def every(time)
    @watchers.each do |watcher|
      watcher.every(time)
    end
  end
  
#private
  
  # stop Watchers
  def stop
    @watchers.each do |watcher|
      watcher.watching = false
    end
  end

  # start Watchers
  def start
    @watchers.each do |watcher|
      # Watcher will loop for as long as its watching property is true
      watcher.watching = true if @watching
      watcher.start
    end
  end

end