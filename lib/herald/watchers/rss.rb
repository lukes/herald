class Herald
  class Watcher

    module Rss

      attr_reader :uri
      
      # lazy-load net/http and rss when this Module is used as a Notifier
      def self.extended(base)
        %w(net/http rss/0.9 rss/1.0 rss/2.0 rss/parser).each do |lib|
          Herald.lazy_load(lib)
        end
      end
      
      # spawn thread for each uri given
      def start; puts "Starting..."; end
      def stop; end    
      def activites; end

      def parse_options(options)
        @uri = options.delete(:from).to_a
        if @uri.empty?
          raise ArgumentError, "RSS source not specified in :from Hash"
        end
      end

    end

  end
end