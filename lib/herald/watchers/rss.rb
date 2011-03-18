class Herald
  class Watcher

   module Rss

     attr_reader :uri

     # spawn thread for each uri given
     def start; puts "Starting..."; end

     def parse_options(options)
       @uri = options.delete(:from).to_a
       if @uri.empty?
         raise ArgumentError, "RSS source not specified in :from Hash"
       end
     end
   
   end
 
 end
end