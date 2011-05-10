class Herald
  class Watcher
    class Notifier

      module Ping

        # Ping and Post share a lot of code, so
        # when Ping is extended, extend the calling class
        # with the Post module
        def self.extended(base)
          Herald::lazy_load_module("notifiers/post")
          base.send(:extend, Post)
          class << base
            # redefine notify() to ping instead of post data
            def notify(item)
              @uris.each do |uri| 
                Net::HTTP.new(uri.host).head('/')
              end
              # redefine to_s
              def to_s
                "Herald Ping Notifier, URIs: #{@uris}"
              end
            end
          end # end
        end # end method
        
      end # end module

    end
  end  
end