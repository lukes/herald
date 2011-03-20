class Herald  
  class Watcher

    module Twitter

      # lazy-load net/http when this Module is used as a Notifier
      def self.extended(base)
        Herald.lazy_load('net/http')
      end

      # TODO make new thread loop
      def start
        puts "Starting..."
        while true
          activities
          sleep 5
        end
      end

      def stop; end

      def activities
        # TODO catch URI wrongness
        begin
          response = open("http://search.twitter.com/search.json?q=#{@keywords.join('+')}&since=2010-02-28").read
          title = "Yay!"
          message = "Success"
        rescue
        end
        notify(title, message)
      end

      def parse_options(options); end

    end

  end
end