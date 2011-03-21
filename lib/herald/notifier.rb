class Herald
  class Watcher
    
    class Notifier
    
      # TODO, make this dynamic? to allow people to write
      # their own and drop it into notifiers dir
      @@notifier_types = [:stdout, :growl, :ping, :post]
      DEFAULT_NOTIFIER = :stdout
    
      def initialize(type, options)
        type = type.to_sym
        # check notifier type
        unless @@notifier_types.include?(type)
          raise ArgumentError, "#{type} is not a valid Notifier type"
        end
        Herald::lazy_load_module("notifiers/#{type}")
        # extend class with module
        send(:extend, eval(type.to_s.capitalize))
        # each individual Notifier will handle their options
        parse_options(options)
        # call test() method of Notifier module
        test()
      end
    
    end

  end
end