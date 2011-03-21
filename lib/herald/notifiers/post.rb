class Herald
 class Watcher
   class Notifier

     module Post

       attr_reader :uri

       # lazy-load net/http when this Module is used
       def self.extended(base)
         Herald.lazy_load('net/http')
       end

       # note dupe between ping and post
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

       # TODO test ping to URL on system and throw exception if fail
       def test
         Net::HTTP.new(@uri.path).head('/').kind_of?(Net::HTTPOK)
       end

       def notify(title, message)
         Net::HTTP.post_form(@uri.to_s, { "title" => title, "message" => message })
       end

     end

   end
 end  
end