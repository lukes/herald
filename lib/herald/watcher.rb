class Herald
  
  class Watcher
    
    attr_accessor :keywords, :type
    
    def initialize(type, options, &block)
      @type = type.to_sym
      @keywords = []
    end
    
    def for(*keywords)
      @keywords << keywords
    end
    
    def start
      # make new thread loop
    end
    
  end
  
end