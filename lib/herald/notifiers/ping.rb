class Herald
  class Watcher
    class Notifier

      module Ping

        attr_reader :uri

        # lazy-load net/http when this Module is used as a Notifier
        def self.extended(base)
          Herald.lazy_load('net/http')
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

        def notify(title, message)
          raise "Ping Notifier not implemented yet"
        end

      end

    end
  end  
end