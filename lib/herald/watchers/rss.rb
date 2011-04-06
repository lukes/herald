class Herald
  class Watcher

    module Rss

      attr_accessor :uris, :published_time_of_last_rss_item
      
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
          rss.items.delete_if do |item|
            delete = true
            @keywords.each do |keyword|
              delete = false if (item.title + item.description).include?(keyword)
            end
            if @published_time_of_last_rss_item && defined?(item.pubDate) && item.pubDate <= @published_time_of_last_rss_item
              delete = true
            end
            delete
          end
          return if rss.items.empty?
          @published_time_of_last_rss_item = rss.items.last.pubDate rescue nil
          puts "#{@published_time_of_last_rss_item} <- last item"
          rss.items.each do |item|
            title = item.title rescue nil
            description = item.description rescue nil
            notify(Item.new(title, description, Herald::Item.to_json(:rss, item)))
          end
        end
      end

    end

  end
end
