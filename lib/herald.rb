require 'net/http'

require 'rubygems'
require 'json'
require 'ruby-growl'

require 'herald/watcher'
require 'herald/watchers/twitter'
require 'herald/watchers/rss'

class Herald

  attr_reader :watchers, :growl

  def self.watch(&block)
    herald = new(&block)
    herald.start_watching
    herald
  end
  
  def self.watch_twitter(&block)
    
  end
    
  def initialize(&block)
    @watchers = []
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

  def growl(switch = true)
    @growl = [true, :on].include?(switch)
  end
    
  def every(time = { 120 => "seconds" })
  end
  
  def action(&block); end
  
#private
  
  def start_watching
    @watchers.each do |watcher|
      watcher.start
    end
  end

end