class Herald
  class Item
    
    attr_accessor :title, :message, :data
    
    def initialize(title, message, data)
      @title = title
      @message = message
      @data = data
    end

    def self.to_json(type, item)
      send("to_json_from_#{type}", item)
    end

    def self.to_json_from_rss(item)
      item.instance_variables.sort.inject({}) do |hash, var|
        var.slice!(0) # remove '@' from string
        begin
          val = item.send(var) #
          raise if val.nil? # skip this property if it has no value
          # handle the RSS guid in a special way
          if val.is_a?(RSS::Rss::Channel::Item::Guid)
            hash[:guid] = val.content
          else
            # otherwise, add to our hash the key => val pair
            hash[var.to_sym] = val
          end
        rescue
        end
        hash
      end.to_json
    end

  end
end