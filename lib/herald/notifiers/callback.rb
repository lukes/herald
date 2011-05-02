class Herald
  class Watcher
    class Notifier

      module Callback

        attr_reader :proc

        # no options for Callback
        def parse_options(options); end
        
        # we can't sandbox the proc to test it out,
        # so just return true
        def test; true; end

        def notify(item)
          if @proc.arity == 1
            @proc.call(item)
          else
            @proc.call
          end
        end

      end

    end
  end  
end