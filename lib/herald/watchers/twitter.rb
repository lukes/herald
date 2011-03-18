class Herald  
  class Watcher

   module Twitter

=begin
   def self.search
     growl = Growl.new("localhost", "Simple twitter client", ["Message", "Error"])
     response = Net::HTTP.get(URI.parse("http://search.twitter.com/search.json?q=twitter&since=2010-02-28"))
     if response.code == '200'
       result = JSON.parser.new(res.body).parse()
       result.length.times do |i|
         exit 0 if i >= max_count
         puts screen_name = result[i]["user"]["screen_name"]
         puts text = result[i]["text"]
         growl.notify "Message", "#{screen_name}", "#{text}"
         sleep 1
       end
     else
       growl.notify "Error", "Error occurd", "Can not get messages"
     end
   end
=end

    # TODO make new thread loop
    def start
      puts "Starting..."
      while true
        # TODO catch URI wrongness, and Grown wrongness
        begin
          response = open("http://search.twitter.com/search.json?q=twitter&since=2010-02-28").read
          Herald::Growl.growl("Yay!", "Success")
        rescue
        end
        sleep 5
      end
    end

    def parse_options(options); end
   
  end

 end
end