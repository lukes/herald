class Herald  
  class Watcher

    module Twitter

      attr_reader :uri, :last_tweet_id

      # lazy-load net/http when this Module is used as a Notifier
      def self.extended(base)
        Herald.lazy_load('net/http')
        Herald.lazy_load('json')
      end

      def parse_options(options); end
      
      # TODO make new thread loop
      def start
        # prepare some of the variables:
        # URI.parse() in the standard library doesn't encode "#" characters in string!
        # in the meantime ...
        @keywords.map! { |word| word.gsub!('#', '%23') }
        # initialise array, first element will be the Twitter API with search query string, 
        # the second element will be a "since_id" extra query parameter, added at close of 
        # activities() loop
        @uri = ["http://search.twitter.com/search.json?q=#{@keywords.join('+')}"]
        # begin loop, which will execute at least once (like a do-while loop)
        begin
          activities
          sleep @timer if @watching
        end while @watching
      end

      def stop; end
      
    private

      def activities
        # return response as string from Twitter
        json = Net::HTTP.get(URI.parse(@uri.join("&")))
        @last_look = Time.now
        # and parse it to JSON
        json = JSON.parse(json)['results']
        # will be nil if there are no results
        return if json.nil?
        @last_tweet_id = json.last['id_str']
        json.each do |tweet|
          title = "@#{tweet['from_user']}"
          message = tweet['text']
          notify(title, message)
          # pause between each one
          sleep 5
        end
        # TODO @last_tweet_id not having an effect
        @uri = [@uri.first, "since_id=#{@last_tweet_id}"]
        json = nil # TODO, does this help reduce memory after loop has finished?
      end

    end

  end
end