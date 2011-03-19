class Herald
  class Watcher
    class Notifier
      
      module Growl
    
        # TODO test growl on system and throw exception if fail
        def test
        end
    
        # TODO catch Errno::ECONNREFUSED when preference pane isn't set correctly
        def notify(title, message)
          begin
            `growl -H localhost -t #{title} -m #{message}`
          rescue 
          end
          true
        end
    
        # no options to parse for Growl
        def parse_options(options); end
    
      end
      
    end
  end  
end