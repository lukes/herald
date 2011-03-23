class Herald
  
  class Watcher
    
    @@watcher_types = [:imap, :rss, :twitter]
    DEFAULT_TIMER = 60

    attr_reader :notifiers
    attr_accessor :watching, :keywords, :timer, :last_look
    
    def initialize(type, options, &block)
      type = type.to_sym
      # TODO this is prepared to handle other protocols, but might not be necessary
      if type == :inbox
        if options.key?(:imap)
          type = :imap
          options[:host] = options[:imap]
        end
      end
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
    
    def start
      # prepare() is defined in the individual Watcher modules.
      # any pre-tasks are performed before
      prepare()
      # TODO make new thread loop
      # begin loop, which will execute at least once (like a do-while loop)
      begin
        activities
        sleep @timer if @watching
      end while @watching
    end
        
    # (stop() is defined in the individual Watcher modules)
    
  end
  
end