class Herald  
  class Watcher

    # TODO, ignore retweets, if option passed
    module Twitter

      attr_accessor :uri, :last_tweet_id

      # lazy-load net/http when this Module is used
      def self.extended(base)
        Herald.lazy_load('net/http')
      end

      def parse_options(options); end
      
      # executed before Watcher starts
      def prepare
        # URI.parse() in the standard library doesn't encode "#" characters in string!
        # in the meantime ...
        @keywords.map! do |word| 
          word.gsub!('#', '%23') 
          word
        end
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
        # return response as string from Twitter
        json = Net::HTTP.get(URI.parse(@uri.join("&")))
        # and parse it to JSON
        json = Crack::JSON.parse(json)
        # will be nil if there are no results
        return if json["results"].nil?
        @last_tweet_id = json["max_id"]
        json["results"].each do |tweet|
          notify(Item.new("@#{tweet['from_user']}", tweet['text'], json['results']))
        end
        @uri = [@uri.first, "since_id=#{@last_tweet_id}"]
        json = nil # TODO, does this help reduce memory after loop has finished?
      end

    end

  end
end