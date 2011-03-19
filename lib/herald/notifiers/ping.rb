class Herald
  class Watcher
    class Notifier
      
      module Ping
    
        attr_reader :uri
    
        # TODO catch exception
        def notify(title, message)
          begin
            # test response for 200 status
            Net::HTTP.new(@uri).head('/').kind_of?(Net::HTTPOK)
          rescue 
          end
          true
        end
        
        def parse_options(options)
          begin
            @uri = URI.parse(options.delete(:uri) || options.delete(:url))
          rescue URI::InvalidURIError
            raise ArgumentError, ":uri not specified for :ping action"
          end
          @uri.scheme = "http" if @uri.scheme.nil? # if missing protocol from URI
        end
    
        # TODO test ping to URL on system and throw exception if fail
        def test
          Net::HTTP.new(@uri).head('/').kind_of?(Net::HTTPOK)
        end
        
      end
      
    end
  end  
end