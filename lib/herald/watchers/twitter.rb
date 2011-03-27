class Herald  
  class Watcher

    # TODO, ignore retweets, if option passed
    module Twitter

      attr_reader :uri, :last_tweet_id

      # lazy-load net/http when this Module is used
      def self.extended(base)
        Herald.lazy_load('net/http')
        Herald.lazy_load('json')
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
      
    private

      def activities
        # return response as string from Twitter
        json = Net::HTTP.get(URI.parse(@uri.join("&")))
        @last_look = Time.now
        # and parse it to JSON
        json = JSON.parse(json)
        # will be nil if there are no results
        return if json['results'].nil?
        @last_tweet_id = json["max_id"]
        json['results'].each do |tweet|
          title = "@#{tweet['from_user']}"
          message = tweet['text']
          notify(title, message)
        end
        @uri = [@uri.first, "since_id=#{@last_tweet_id}"]
        json = nil # TODO, does this help reduce memory after loop has finished?
      end

    end

  end
end