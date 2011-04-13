class Herald
  class Item
    
    attr_accessor :title, :message, :data
    
    def initialize(title, message, data)
      @title = title
      @message = message
      @data = data
    end

  end
end