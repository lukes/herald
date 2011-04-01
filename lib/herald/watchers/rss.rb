class Herald
  class Watcher

    module Rss

      attr_reader :uris, :last_item
      
      # lazy-load net/http and rss when this Module is used
      def self.extended(base)
        %w(net/http rss/0.9 rss/1.0 rss/2.0 rss/parser).each do |lib|
          Herald.lazy_load(lib)
        end
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
            
    private
    
      def activities
        @uris.each do |uri|
          # return response as string and parse to RSS
          begin
            rss = RSS::Parser.parse(Net::HTTP.get(uri), false)
          rescue
            return
          end
          return if rss.nil?
          # remove items that are older than the last item found
          # and don't contain the keywords being looked for
          rss.items.delete_if { |item|
            return true if @last_item && defined?(item.pubDate) && item.pubDate < @last_item
            @keywords.each do |keyword|
              return true if !(item.title + item.description).include?(keyword)
            end
            false        
          }
          return if rss.items.empty?
          @last_item = rss.items.last.pubDate rescue nil
          rss.items.each do |item|
            title = self.title rescue nil
            description = self.description rescue nil
            notify(Item.new(title, description, Herald::Item.to_json(:rss, item)))
          end
        end
      end

    end

  end
end
