class Herald
  class Watcher
    class Notifier

      module Ping

        # lazy-load net/http when this Module is used
        def self.extended(base)
          Herald.lazy_load('net/http')
          class << base
            attr_accessor :uri
          end
        end

        # note: dupe between ping and post
        def parse_options(options)
          uri = options.delete(:uri) || options.delete(:url)
          unless uri
            raise ArgumentError, ":uri for :ping action not specified"
          end
          begin
            @uri = URI.parse(uri)
            # if URI lib can't resolve a protocol (because it was missing from string)
            if @uri.class == URI::Generic
              @uri = URI.parse("http://#{@uri.path}")
            end
          rescue URI::InvalidURIError
            raise ArgumentError, ":uri for :ping action invalid"
          end
        end
        
        def test
          response = Net::HTTP.new(@uri.host).head('/')
          return if response.kind_of?(Net::HTTPOK)
          # TODO raise custom error types
          raise "#{response.code} status code returned for URI #{@uri}. 200 code expected"
        end

        def notify(item)
          Net::HTTP.new(@uri.host).head('/')
        end

      end

    end
  end  
end