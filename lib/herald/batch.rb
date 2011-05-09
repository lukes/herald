class Herald

  # batch methods   
  module Batch

    def start
      heralds.each do |herald|
        herald.start
      end
      self
    end

    def stop
      heralds.each do |herald|
        herald.stop
      end
      self
    end

    # stop all heralds, and remove them
    # from list of herald instances. mostly
    # useful for clearing @@heralds when testing
    def clear
      stop()
      heralds.clear
      self
    end

    def alive?
      heralds.any? { |h| h.alive? }
    end

    # returns size of @@heralds
    # can optionally take :alive or :stopped
    def size(obj = nil)
      heralds(obj).size
    end

    # can optionally take a herald object or :stopped
    def delete(obj = nil)
      case
      when obj.is_a?(Herald)
        Array(obj)
      else
        heralds(obj)
      # with the selected array of heralds
      end.each do |h| 
        h.delete # call each herald's delete method
      end
      self
    end
    
  end
  
end