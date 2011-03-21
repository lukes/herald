class Herald
  class Watcher
    class Notifier

      module Callback

        attr_reader :proc

        def parse_options(options); end
        
        # TODO test block? or not?
        def test; true; end

        # 
        def notify(title, message)
          @proc.call
#          $stdout.puts "#{title}: #{message}"
#          $stdout.flush
        end

      end

    end
  end  
end