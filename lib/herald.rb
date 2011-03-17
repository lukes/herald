require 'net/http'

require 'rubygems'
require 'json'
require 'ruby-growl'

class Herald

 def cryHera
   "hi"
 end

end

class Herald

 module Twitter

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

 end

end

#Herald::Twitter.search("luke")

=begin

Herald.cry {
 from :rss, :source => "uri"
 from :twitter
 check_for "luke"
 every 1.minutes
}

=end