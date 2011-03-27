class Herald
  class Watcher
    class Notifier

      module Stdout

        def parse_options(options)
          # option to send stdout to file
          if file = options.delete(:file)
            $stdout = File.new(file, 'w')
          end
        end
        
        # is always working, so true
        def test; true; end

        # print to $stdout
        def notify(item)
          $stdout.puts item.data
          $stdout.flush
        end

      end

    end
  end  
end