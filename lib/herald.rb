require 'rubygems'

require 'herald/watcher'
require 'herald/notifier'
require 'herald/notifiers/stdout'
require 'herald/item'
require 'herald/batch'
require 'herald/daemon'

require 'yaml'

class Herald

  @@heralds = []
  @@daemon = false
  
  attr_accessor :watchers, :keep_alive, :subprocess
  extend Herald::Batch
  extend Herald::Daemon

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
  def self.watch_website(options = {}, &block)
    watch() { check(:website, options, &block) }
  end
  
  # returns @@heralds
  # can optionally take :alive or :stopped
  def self.heralds(obj = nil)
    if !obj.nil? && obj.respond_to?(:to_sym)
      case obj.to_sym
      when :stopped 
        return @@heralds.select { |h| !h.alive? }
      when :alive 
        return @@heralds.select { |h| h.alive? }
      end
      # if obj is not :stopped or :alive
      raise ArgumentError.new("Unknown parameter #{obj}")
    end
    @@heralds
  end

  def self.daemonize!
    @@daemon = true
    serialize_daemons()
    puts "(Herald is now running in the background)\n"
    self
  end
  
  def self.is_daemon?
    @@daemon
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
    options[:keep_alive] ||= @keep_alive
    @watchers << Herald::Watcher.new(type, options, &block)
    self
  end

  # send keywords to Watchers
  def _for(*keywords)
    @watchers.each do |watcher|
      watcher._for(*keywords)
    end
    self
  end

  # send instructions to Watchers
  def action(type = :callback, options = {}, &block)
    @watchers.each do |watcher|
      watcher.action(type, options, &block)
    end
    self
  end
    
  # send sleep time to Watchers
  def every(time)
    @watchers.each do |watcher|
      watcher.every(time)
    end
    self
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
      # give this process a name
      $0 = "ruby herald"
    }
    # if herald process is persistant
    if @keep_alive
      Process.detach(@subprocess)
    else
      begin
        # wait before the end of this script
        # for all watchers to finish their jobs
        Process.waitpid(@subprocess)
      # if @subprocess PID does not exist, it will
      # be due to an error in the subprocess
      # which has terminated it and waitpid()
      # will throw an exception
      rescue Errno::ECHILD => e
        # do nothing
      end
      @subprocess = nil # signal unalive state
    end
    Herald.serialize_daemons
    self # return instance object
  end

  # is there a gentler way of doing it?
  # or have watchers do cleanup tasks on exit?
  # look at GOD
  def stop
    if @subprocess
      Herald.kill(@subprocess)
    end
    @subprocess = nil
    self
  end
  alias :end :stop
  
  def delete
    stop if alive?
    @@heralds.delete(self)
    true
  end
  
  def alive?
    !!@subprocess
  end
  
  def to_s
    "Watchers: #{@watchers}, Notifiers: #{@watchers.map{|w| w.notifiers }.flatten}, State: #{@subprocess ? 'Alive' : 'Stopped'}"
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
  Herald.stop unless Herald.is_daemon?
end