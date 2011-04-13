class Herald
  class Watcher

    module Rss

      attr_accessor :uris
      
      # lazy-load net/http and rss when this Module is used
      def self.extended(base)
        Herald.lazy_load('net/http')
#        %w(net/http rss/0.9 rss/1.0 rss/2.0 rss/parser).each do |lib|
#          Herald.lazy_load(lib)
#        end
      end
      
      def parse_options(options)
        @uris = options.delete(:from).to_a
        if @uris.empty?
          raise ArgumentError, "RSS source not specified in :from Hash"
        end
        @uris.map! { |uri| URI.parse(uri) }
      end

      def prepare; end
      def cleanup; end
      
      def to_s
        "Herald RSS Watcher, URL: #{@uris}, Keywords: '#{@keywords}', Timer: #{@timer}, State: #{@keep_alive ? 'Watching' : 'Stopped'}"
      end
            
    private
    
      def activities
        @uris.each do |uri|
          # return response as string and parse to RSS
          begin
            rss = Crack::XML.parse(Net::HTTP.get(uri))
          rescue
            return
          end
          return if rss.nil?
          # ignore items that have been part of a notification round
          # or that don't contain the keywords being looked for
          items = []
          rss["rss"]["channel"]["item"].each do |item|
            # if we've already seen this item, skip to next item
            if @latest_items.include?(item)
              next
            end
            # keep this item if it contains keywords in the title or description
            if (item["title"] + item["description"]).match(/#{@keywords.join('|')}/i)
              items << item
            end
          end
          return if items.empty?
          @latest_items = items
          @latest_items.each do |item|
            notify(Item.new(item["title"], item["description"], item))
          end
        end
      end

    end

  end
end
