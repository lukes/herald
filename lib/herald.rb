require 'net/http'

require 'rubygems'
require 'json'
require 'ruby-growl'

require 'herald/watcher'

class Herald

  attr_reader :watchers

  def self.watch(&block)
    herald = new(&block)
#    herald.start_watching
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
  
  def _for(*keywords)
    @watchers.each do |watcher|
      watcher.keywords << keywords
    end
  end
  
private
  
  def start_watching
    @watchers.each do |watcher|
      watcher.start
    end
  end

end