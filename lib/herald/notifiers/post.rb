class Herald
  class Watcher
    class Notifier

      # note most of this code is duplicated between ping and post
      module Post

        attr_reader :uri

        # lazy-load net/http when this Module is used
        def self.extended(base)
          Herald.lazy_load('net/http')
        end

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

        # test by pinging to URI throw exception if fail
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

        def notify(title, message)
          Net::HTTP.post_form(@uri.to_s, { "title" => title, "message" => message })
        end

      end

    end
  end  
end