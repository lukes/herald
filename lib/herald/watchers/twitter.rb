class Herald  
  class Watcher

   module Twitter

     def parse_options(options); end
    
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
          # TODO, can i put notify call in Watcher class, and 
          # call something like super() for a module?
          notify(title, message)
        rescue
        end
      end
   
    end

  end
end