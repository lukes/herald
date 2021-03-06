class Herald
  class Watcher

    module Rss

      attr_accessor :uris
    
      # lazy-load open-uri when this Module is used
      def self.included(base)
        Herald.lazy_load('open-uri')
        Herald.lazy_load('crack')
      end
      
      def parse_options(options)
        @uris = Array(options.delete(:from))
        if @uris.empty?
          raise ArgumentError, "RSS source not specified in :from Hash"
        end
        @uris.map!{ |uri| URI.escape(uri) }
      end

      def prepare; end
      def cleanup; end
      
      def to_s
        "Herald RSS Watcher, URIs: #{@uris}, Keywords: '#{@keywords}', Timer: #{@timer}, State: #{@keep_alive ? 'Watching' : 'Stopped'}"
      end
            
    private
    
      def activities
        @uris.each do |uri|
          # return response as a Hash
          begin
            rss = Crack::XML.parse(open(uri).read)
          rescue
            return
          end
          # skip if rss variable is nil, or is missing
          # rss elements in the expected nested format
          next unless defined?(rss["rss"]["channel"]["item"])
          rss = rss["rss"]["channel"]["item"]
          # if there is only 1 <item> in the rss document, 
          # rss variable at the moment will be a Hash, so
          # convert to a single element array
          rss = [rss] if rss.is_a?(Hash) 
          # ignore items that have been part of a notification round
          # or that don't contain the keywords being looked for
          items = []
          rss.each do |item|
            # if we've already seen this item, skip to next item
            if @items.include?(item)
              next
            end
            # keep this item if it contains keywords in the title or description
            if "#{item["title"]}#{item["description"]}".match(/#{@keywords.join('|')}/i)
              items << item
            end
          end
          return if items.empty?
          items.each do |item|
            notify(Item.new(item["title"], item["description"], item))
          end
          @items += items
        end
      end

    end

  end
end
