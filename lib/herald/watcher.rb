class Herald
  
  class Watcher
    
    @@watcher_types = [:twitter, :rss]
    DEFAULT_TIMER = 5 # seconds

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
      # TODO call a Watcher::test()?
      # eval the block, if given
      if block_given?
        block.arity == 1 ? yield(self) : instance_eval(&block)
      end
      # set a default Notifier for this Watcher, unless it's been
      # set further up the initialisation chain
      if @notifiers.empty?
        Herald.lazy_load_module("notifiers/#{Notifier::DEFAULT_NOTIFIER}")
        @notifiers = action(Notifier::DEFAULT_NOTIFIER, {})
      end
    end
    
    def for(*keywords)
      @keywords += keywords
    end
    
    # assign the Notifiers
    def action(type, options)
      @notifiers << Herald::Watcher::Notifier.new(type, options)
    end
    
    # TODO parse a hash like { 120 => "seconds" }
    def every(time); end
    
    # call the Notifier and pass it a message
    def notify(title, message)
      @notifiers.each do |notifier|
        puts "Notifying something..."
        notifier.notify(title, message)
      end
    end
        
    # (start(), stop() are defined in the individual Notifier modules)
    
  end
  
end