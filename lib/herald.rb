require 'rubygems'

require 'herald/watcher'
require 'herald/notifier'
require 'herald/notifiers/stdout'

class Herald

  attr_accessor :watchers, :keep_alive, :subprocess

  def self.watch(&block)
    herald = new(&block)
    herald.start
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
    watch() { check(:twitter, options, &block) }
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
  end
  
  # create a new Watcher
  def check(type, options = {}, &block)
    @watchers << Herald::Watcher.new(type, @keep_alive, options, &block)
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
    # start watching as a subprocess
    @subprocess = fork {
      @watchers.each do |watcher|
        watcher.start
      end
      # all watchers do their tasks in a new thread.
      # join all thread in this subprocess
      Thread.list.each do |thread| 
        thread.join unless thread == Thread.main
      end
    }
    # if process is not persistant, then
    # wait before the end of this script
    # for all watchers to finish their jobs
    Process.waitpid(@subprocess) unless @keep_alive
    self # return instance object
  end

  def stop
    # is there a gentler way of doing it?
    # or have watchers do cleanup tasks on exit?
    # look at GOD
    Process.kill("TERM", @subprocess) if @subprocess
    @subprocess = nil
    self
  end
  
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