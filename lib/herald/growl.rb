class Herald
  
  class Growl
    
    # TODO catch Errno::ECONNREFUSED when preference pane isn't set correctly
    def self.growl(title, message)
      begin
        `growl -H localhost -t #{title} -m #{message}`
      rescue 
      end
      true
    end
    
  end
  
end