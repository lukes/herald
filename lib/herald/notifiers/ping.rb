class Herald
  class Watcher
    class Notifier

      module Ping

        attr_reader :uri

        # lazy-load net/http when this Module is used
        def self.extended(base)
          Herald.lazy_load('net/http')
        end

        # note: dupe between ping and post
        def parse_options(options)
          begin
            @uri = URI.parse(options.delete(:uri) || options.delete(:url))
            # if URI lib can't resolve a protocol (because it was missing from string)
            if @uri.class == URI::Generic
              @uri = URI.parse("http://#{@uri.path}")
            end
          rescue URI::InvalidURIError
            raise ArgumentError, ":uri for :ping action not specified or invalid"
          end
        end
        
        def test
          response = Net::HTTP.new(@uri.host).head('/')
          return if response.kind_of?(Net::HTTPOK)
          # TODO raise custom error types
          if response.kind_of?(Net::HTTPFound)
            raise "URI #{@uri} is being redirected to #{response.header['location']}"
          else
            raise "URI #{@uri} cannot be reached. Ping returned status code: #{response.code}"
          end
        end

        def notify(item)
          Net::HTTP.new(@uri.host).head('/')
        end

      end

    end
  end  
end