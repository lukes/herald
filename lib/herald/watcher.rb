class Herald
  
  class Watcher
    
    @@watcher_types = [:rss, :twitter, :website]
    DEFAULT_TIMER = 60

    attr_reader :type, :keep_alive, :thread
    attr_accessor :notifiers, :keywords, :timer, :items

    def initialize(type, options, &block)
      @type = type.to_sym
      # check watcher type
      unless @@watcher_types.include?(@type)
        raise ArgumentError, "#{@type} is not a valid Watcher type"
      end
      @keywords = []
      @notifiers = []
      @items = []
      @keep_alive = options.delete(:keep_alive)
      @timer = Watcher::DEFAULT_TIMER
      Herald.lazy_load_module("watchers/#{@type}")
      # include module
      @@type = @type
      class << self
        send(:include, eval(@@type.to_s.capitalize))
      end
      # each individual Watcher will handle their options
      parse_options(options)
      # eval the block, if given
      if block_given?
        instance_eval(&block)
      end
      # TODO implement a Watcher::test()?
    end
    
    def _for(*keywords)
      @keywords += keywords.flatten
      self
    end
    
    # assign the Notifier
    def action(type = :callback, options = {}, &block)
      @notifiers << Herald::Watcher::Notifier.new(type, options, &block)
      self
    end
    
    # parse a hash like { 120 => "seconds" }
    def every(time); 
      quantity = time.keys.first.to_i
      if quantity < 1
        raise ArgumentError.new("Quantity must be greater than 0")
      end
      unit = case time.values.first
      when /^second/
        1
      when /^minute/
        60
      when /^hour/
        3600
      when /^day/
        86400
      else
        raise ArgumentError, "Invalid time unit for every. (Use seconds, minutes, hours or days)"
      end
      @timer = quantity * unit
      self
    end
    
    # call the Notifier and pass it a message
    def notify(item)
      @notifiers.each do |notifier|
        notifier.notify(item)
      end
      self
    end
    
    def start
      # set a default Notifier for this Watcher
      action(Watcher::Notifier::DEFAULT_NOTIFIER) if @notifiers.empty?
      # prepare() is defined in the individual Watcher modules.
      # any pre-tasks are performed before
      prepare()
      # begin loop, which will execute at least once (like a do-while loop)
      @thread = Thread.new {
        begin
          activities
          sleep @timer if @keep_alive
        end while @keep_alive
      }
      self
    end
        
    def stop
      # stop looping
      @keep_alive = false
      # cleanup() is defined in the individual Watcher modules
      cleanup()
      self
    end
    
  end
  
end