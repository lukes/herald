require 'rubygems'
#require 'json'
gem 'crack'
require 'crack'

require 'herald/watcher'
require 'herald/notifier'
require 'herald/notifiers/stdout'
require 'herald/item'

class Herald

  @@heralds = []
  
  attr_accessor :watchers, :keep_alive, :subprocess

  def self.watch(&block)
    new(&block).start
  end
  
  def self.once(&block)
    herald = new()
    herald.keep_alive = false
    herald.send(:instance_eval, &block)
    herald.start
  end
  
  # shorthand methods
  def self.watch_twitter(&block)
    watch() { check(:twitter, &block) }
  end
  def self.watch_rss(options = {}, &block)
    watch() { check(:rss, options, &block) }
  end

  # batch methods
  def self.start
    return false if @@heralds.empty?
    @@heralds.each do |herald|
      herald.start
    end
    true
  end

  def self.stop
    return false unless Herald.alive?
    @@heralds.each do |herald|
      herald.stop
    end
    true
  end
  
  # stop all heralds, and remove them
  # from list of herald instances. mostly
  # useful for clearing @@heralds when testing
  def self.clear
    stop()
    @@heralds.clear
    true
  end
  
  # just walk away, leaving whatever strays to themselves
  def self.demonize!
    @@heralds.clear
    true
  end
    
  def self.alive?
    @@heralds.any? { |h| h.alive? }
  end
  
  def self.heralds
    @@heralds
  end
  
  #
  # instance methods:
  #
  
  def initialize(&block)
    @watchers = []
    @keep_alive = true
    if block_given?
      instance_eval(&block)
    end
    @@heralds << self
    self
  end
  
  # create a new Watcher
  def check(type, options = {}, &block)
    options[:keep_alive] = @keep_alive
    @watchers << Herald::Watcher.new(type, options, &block)
  end

  # send keywords to Watchers
  def _for(*keywords)
    @watchers.each do |watcher|
      watcher._for(*keywords)
    end
  end

  # send instructions to Watchers
  def action(type = nil, options = {}, &block)
    @watchers.each do |watcher|
      watcher.action(type, options, &block)
    end
  end
    
  # send sleep time to Watchers
  def every(time)
    @watchers.each do |watcher|
      watcher.every(time)
    end
  end
  
  # start Watchers
  def start
    if @watchers.empty?
      raise "No watchers assigned"
    end
    # if herald is already running, first stop
    stop() if alive?
    # start watching as a @subprocess
    @subprocess = fork {
      @watchers.each do |watcher|
        watcher.start
      end
      # all watchers do their tasks in a new thread.
      # join all thread in this @subprocess
      Thread.list.each do |thread| 
        thread.join unless thread == Thread.main
      end
    }
    # if herald process is persistant
    if @keep_alive
      Process.detach(@subprocess)
    else
      # wait before the end of this script
      # for all watchers to finish their jobs
      Process.waitpid(@subprocess)
      @subprocess = nil # signal unalive state
    end
    self # return instance object
  end

  # is there a gentler way of doing it?
  # or have watchers do cleanup tasks on exit?
  # look at GOD
  def stop
    if @subprocess
      begin
        Process.kill("TERM", @subprocess)
      # if @subprocess PID does not exist, 
      # this will be due to an unhandled error
      # in the subprocess
      rescue Errno::ESRCH => e
        # do nothing
        puts "Unhandled error #{e.message}"
      end
    end
    @subprocess = nil
    self
  end
  alias :end :stop
  alias :kill :stop
  
  def alive?
    !!@subprocess
  end
    
private
  
  def self.lazy_load_module(module_path)
    lazy_load("herald/#{module_path}")
  end

  def self.lazy_load(path)
    require(path)
  end

end

# queue a block to always stop all forked processes on exit
at_exit do
  Herald.stop 
end