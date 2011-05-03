class Herald
  class Watcher
    class Notifier

      module Ping

        # lazy-load net/http when this Module is used
        def self.extended(base)
          Herald.lazy_load('net/http')
          class << base
            attr_accessor :uris
          end
        end

        # note: dupe between ping and post
        def parse_options(options)
          @uris = []
          uris = Array(options.delete(:uri) || options.delete(:url) || options.delete(:uris) || options.delete(:urls))
          if uris.empty?
            raise ArgumentError, ":uri for :ping action not specified"
          end
          uris.each do |uri|
            begin
              uri = URI.parse(uri)
              # if URI lib can't resolve a protocol (because it was missing from string)
              if uri.class == URI::Generic
                uri = URI.parse("http://#{uri.path}")
              end
              @uris << uri
            rescue URI::InvalidURIError
              raise ArgumentError, ":uri for :ping action invalid"
            end
          end
        end
        
        def test
          @uris.each do |uri|
            response = Net::HTTP.new(uri.host).head('/')
            return if response.kind_of?(Net::HTTPOK)
            # TODO raise custom error types
            raise "#{response.code} status code returned for URI #{uri}. 200 code expected"
          end
        end

        def notify(item)
          @uris.each do |uri|
            Net::HTTP.new(uri.host).head('/')
          end
        end

      end

    end
  end  
end