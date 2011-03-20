class Herald
  class Watcher
    class Notifier
      
      module Growl
    
        # TODO test growl on system and throw exception if fail
        def test
        end
        
        # send a Growl notification
        def notify(title, message)
          begin
            `growl -H localhost -t #{title} -m #{message}`
          rescue Errno::ECONNREFUSED => e
            # TODO raise a custom Error
            raise "Growl not installed, or not configured correctly to allow remote application\n
                  registration. See http://growl.info/documentation/exploring-preferences.php"
          end
          true
        end
    
        # no options to parse for Growl
        def parse_options(options); end
    
      end
      
    end
  end  
end