class Herald
  
  class Watcher
    
    @@watcher_types = [:twitter, :rss]
  
    attr_reader :notifiers, :keywords, :last_look
    
    def initialize(type, options, &block)
      type = type.to_sym
      @keywords = []
      @notifiers = []
      # check watcher type
      unless @@watcher_types.include?(type)
        raise ArgumentError, "#{type} is not a valid Watcher type"
      end
      # extend class with module
      send(:extend, eval(type.to_s.capitalize))
      parse_options(options)
      #if block_given?
      #  instance_eval(&block)
      #end
      # set a default Notifier, unless it's been
      # set further up the initialisation chain
      if @notifiers.empty?
        @notifiers = action(Notifier::DEFAULT_NOTIFIER, {})
      end
    end
    
    def for(*keywords)
      @keywords += keywords
    end
    
    # assign the Notifiers
    def action(type, options)
      if [:off, :none, false, nil].include?(type.to_sym)
        @notifiers.clear and return
      end
      @notifiers << Herald::Watcher::Notifier.new(type, options)
    end
    
    # call the Notifier and pass it a message
    def notify(title, message)
      @notifiers.each do |notifier|
        notifier.notify(title, message)
      end
    end
    
    # (activities(), start(), stop() are defined in the individual Notifier modules)
    
  end
  
end