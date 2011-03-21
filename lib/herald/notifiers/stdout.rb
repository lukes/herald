class Herald
  class Watcher
    class Notifier

      module Stdout

        def parse_options(options);
          # option to send stdout to file
          if file = options.delete(:file)
            $stdout = File.new(file, 'w')
          end
        end
        
        # is always working, so true
        def test; true; end

        # print to $stdout
        def notify(title, message)
          $stdout.puts "#{title}:\t#{message}"
          $stdout.flush
        end

      end

    end
  end  
end