class Herald
  class Watcher

    module Rss

      attr_reader :uri
      
      # lazy-load net/http and rss when this Module is used
      def self.extended(base)
        %w(net/http rss/0.9 rss/1.0 rss/2.0 rss/parser).each do |lib|
          Herald.lazy_load(lib)
        end
      end
      
      def parse_options(options)
        @uri = options.delete(:from).to_a
        if @uri.empty?
          raise ArgumentError, "RSS source not specified in :from Hash"
        end
      end

      def prepare; end      
      def cleanup; end    
            
    private
    
      def activites
        raise "Rss Watcher not implemented yet"
      end

    end

  end
end