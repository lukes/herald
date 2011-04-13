class Herald  
  class Watcher

    # TODO, ignore retweets, if option passed
    module Twitter

      attr_accessor :uri, :last_tweet_id

      # lazy-load open-uri when this Module is used
      def self.extended(base)
        Herald.lazy_load('open-uri')
      end

      def parse_options(options); end
      
      # executed before Watcher starts
      def prepare
        # initialise array, first element will be the Twitter API with search query string, 
        # the second element will be a "since_id" extra query parameter, added at close of 
        # activities() loop
        @uri = ["http://search.twitter.com/search.json?q=#{@keywords.join('+')}"]
      end

      def cleanup; end
      
      def to_s
        "Herald Twitter Watcher, Keywords: '#{@keywords}', Timer: #{@timer}, State: #{@keep_alive ? 'Watching' : 'Stopped'}"
      end
      
    private

      def activities
        # return response as string from Twitter and parse it to JSON
        json = Crack::JSON.parse(open(@uri.join("&")).read)
        # will be nil if there are no results
        return if json["results"].nil?
        @last_tweet_id = json["max_id"]
        json["results"].each do |tweet|
          @items << tweet
          notify(Item.new("@#{tweet['from_user']}", tweet['text'], json['results']))
        end
        @uri = [@uri.first, "since_id=#{@last_tweet_id}"]
      end

    end

  end
end