class Herald
  
  class Watcher
    
    @@watcher_types = [:imap, :rss, :twitter]
    DEFAULT_TIMER = 60

    attr_reader :notifiers, :keep_alive#, :thread
    attr_accessor :keywords, :timer, :last_look
    
    def initialize(type, keep_alive, options, &block)
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
      @keep_alive = keep_alive
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
    
    # assign the Notifier
    def action(type = :callback, options = {}, &block)
      @notifiers << Herald::Watcher::Notifier.new(type, options, &block)
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
      # set a default Notifier for this Watcher
      action(Watcher::Notifier::DEFAULT_NOTIFIER) if @notifiers.empty?
      # prepare() is defined in the individual Watcher modules.
      # any pre-tasks are performed before
      prepare()
      # begin loop, which will execute at least once (like a do-while loop)
#      @thread = Thread.new {
        begin
          activities
          sleep @timer if @keep_alive
        end while @keep_alive
 #    }
    end
        
    def stop
      # stop looping
      @loop = false
      # cleanup() is defined in the individual Watcher modules
      cleanup()
    end
    
  end
  
end