class Herald
  
  class Watcher
    
    @@watcher_types = [:twitter, :rss]
  
    attr_reader :keywords, :type, :last_look, :notifier
    
    def initialize(type, options, &block)
      @type = type.to_sym
      @keywords = []
      # check watcher type
      unless @@watcher_types.include?(@type)
        raise ArgumentError, "#{@type} is not a valid Watcher type"
      end
      # extend class with module
      send(:extend, eval(@type.to_s.capitalize))
      parse_options(options)
      #if block_given?
      #  instance_eval(&block)
      #end
    end
    
    def for(keywords)
      @keywords += Array(keywords.to_s)
    end
    
    def action(type, options)
      if [:off, :none, false, nil].include?(type.to_sym)
        @notifier = nil and return
      end
      @notifier << Herald::Watcher::Notifier.new(type, options)
    end
    
    def notify(title, message)
      return unless @notifier
      @notifier.notify(title, message)
    end
    
    def once
      activities
    end
    
  end
  
end