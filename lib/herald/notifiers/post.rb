class Herald
  class Watcher
    class Notifier

      # note most of this code is duplicated between ping and post
      module Post

        # lazy-load net/http when this Module is used
        def self.extended(base)
          Herald.lazy_load('net/http')
          class << base
            attr_accessor :uri
          end
        end

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
              # add trailing slash if nil path. path() will return nil
              # if uri passed was a domain missing a trailing slash. net/http's post
              # methods require the trailing slash to be present otherwise they fail
              uri.path = "/" if uri.path.empty?
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
            Net::HTTP.post_form(uri, { "title" => item.title, "message" => item.message }.merge(item.data))
          end
        end

      end

    end
  end  
end