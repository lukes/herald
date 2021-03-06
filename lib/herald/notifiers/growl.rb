class Herald
  class Watcher
    class Notifier

      module Growl

        @@notification_type = "Herald Notification"
        
        def self.extended(base)
          Herald.lazy_load('ruby-growl')
          class << base
            attr_accessor :growl, :sticky
          end
        end

        def parse_options(options)
          @sticky = options.delete(:sticky) || false
          @priority = options.delete(:priority) || 1
          host = options.delete(:host) || "localhost"
          pass = options.delete(:pass) || nil
          @growl = ::Growl.new(host, "Herald", [@@notification_type], [@@notification_type], pass)
        end

        # no tests for Growl
        def test; end

        # send a Growl notification
        def notify(item)
          begin
            @growl.notify(@@notification_type, item.title, item.message, @priority, @sticky)
          rescue Errno::ECONNREFUSED => e
            # TODO throw custom exception
            raise "Growl settings not configured to allow remote application registration. See Growl website docs: http://growl.info/documentation/exploring-preferences.php"
          end
        end

        def to_s
          "Herald Growl Notifier"
        end
        
      end

    end
  end  
end