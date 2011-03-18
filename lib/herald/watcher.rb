class Herald
  
  class Watcher
    
    @@watcher_types = [:twitter, :rss]
  
    attr_accessor :keywords, :type
    
    def initialize(type, options, &block)
      @type = type.to_sym
      @keywords = []
      # check watcher type
      unless @@watcher_types.include?(@type)
        raise ArgumentError, "#{@type} is not a valid watcher type"
      end
      # extend class with module
      send(:extend, eval(@type.to_s.capitalize))
      parse_options(options)
      #if block_given?
      #  instance_eval(&block)
      #end
    end
    
    def for(keywords)
      @keywords += keywords.to_a
    end
    
  end
  
end