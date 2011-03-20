class Herald
  class Watcher
    class Notifier

      module Growl

#        # lazy-load ruby-growl when this Module is used as a Notifier
#        def self.extended(base)
#          begin
#            Herald.lazy_load('ruby-growl')
#          rescue LoadError
#            raise LoadError, "ruby-growl is not installed"
#          end
#        end

        # TODO test growl on system and throw exception if fail.
        def test
          unless(system("growl --version"))
            # TODO throw custom exception
            raise "ruby-growl gem is not installed. Run:\n\tsudo gem install ruby-growl"
          end
        end

        # send a Growl notification
        def notify(title, message)
          # response will be false if command exits with an error
          response = system("growl -H localhost -t #{title} -m #{message}")
          # presence of ruby-growl has already been tested in test(), so a false
          # return is likely to be the user's Growl settings
          if !response
            # TODO throw custom exception
            raise "Growl settings not configured to allow remote application registration. See Growl website docs: http://growl.info/documentation/exploring-preferences.php"
          end
        end

        # no options to parse for Growl
        def parse_options(options); end

      end

    end
  end  
end