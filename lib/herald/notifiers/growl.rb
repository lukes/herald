class Herald
  class Watcher
    class Notifier

      module Growl

        # no options to parse for Growl
        def parse_options(options); end
        
        # test growl on system and throw exception if fail.
        def test
          # TODO suppress output
          unless(system("growl --version"))
            # TODO throw custom exception
            raise "ruby-growl gem is not installed. Run:\n\tsudo gem install ruby-growl"
          end
        end

        # send a Growl notification
        def notify(item)
          # response will be false if system() call exits with an error.
          # presence of ruby-growl has already been tested in test(), so a false
          # return is likely to be the user's Growl settings
          # TODO escape characters in title and message
          item.title.gsub!("'", '')
          item.message.gsub!("'", '')
          if !system("growl -H localhost -t '#{item.title}' -m '#{item.message}'")
            # TODO throw custom exception
            raise "Growl settings not configured to allow remote application registration. See Growl website docs: http://growl.info/documentation/exploring-preferences.php"
          end
        end

      end

    end
  end  
end