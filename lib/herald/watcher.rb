class Herald
  
  class Watcher
    
    @@watcher_types = [:twitter, :rss]
    DEFAULT_TIMER = 60

    attr_reader :notifiers
    attr_accessor :watching, :keywords, :timer, :last_look
    
    def initialize(type, options, &block)
      type = type.to_sym
      # check watcher type
      unless @@watcher_types.include?(type)
        raise ArgumentError, "#{type} is not a valid Watcher type"
      end
      @keywords = []
      @notifiers = []
      @timer = Watcher::DEFAULT_TIMER
      Herald.lazy_load_module("watchers/#{type}")
      # extend class with module
      send(:extend, eval(type.to_s.capitalize))
      # each individual Watcher will handle their options
      parse_options(options)
      # eval the block, if given
      if block_given?
        block.arity == 1 ? yield(self) : instance_eval(&block)
      end
      # TODO implement a Watcher::test()?
    end
    
    def _for(*keywords)
      @keywords += keywords
    end
    
    # assign the Notifiers
    def action(type = nil, options = {}, &block)
      # if a callback given
      if block_given?
        @notifiers << Herald::Watcher::Notifier.new(:callback, options, &block)
      else
        # otherwise, assign a Notifier
        @notifiers << Herald::Watcher::Notifier.new(type, options)
      end
    end
    
    # parse a hash like { 120 => "seconds" }
    def every(time); 
      quantity = time.keys.first.to_i
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
    end
    
    # call the Notifier and pass it a message
    def notify(title, message)
      @notifiers.each do |notifier|
        notifier.notify(title, message)
      end
    end
        
    # (start(), stop() are defined in the individual Notifier modules)
    
  end
  
end