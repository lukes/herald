class Herald
  class Watcher

    module Website

      attr_accessor :uris, :selectors, :traverse

      # lazy-load open-uri when this Module is used
      def self.included(base)
        %w(open-uri hpricot crack).each do |lib|
          Herald.lazy_load(lib)
        end
      end

      def parse_options(options)
        # assign an array of selectors
        # user can pass in either :only_in_tag[s], or :within_tag[s].
        # :only_in_tag will limit hpricot to search for text
        # in that particular tag only, whereas :within_tag will
        # include all children of the tag in the search
        # find the option param that matches "tag"
        options.find do |k, v|
          if k.to_s.match(/tag/)
            @selectors = Array(v) # coerce to Array
            # if the key is :only_tag[s]
            @traverse = false if k.to_s.match(/only/)
          end
        end
        # default selector if no relevant option passed
        @selectors ||= ["body"]
        # if we should traverse, append a * (css for "every child") to all selectors
        if @traverse
          @selectors.map!{|s|"#{s} *"}
        end
        # parse uri Strings to URI objects
        @uris = Array(options.delete(:from))
        if @uris.empty?
          raise ArgumentError, "Website source not specified in :from Hash"
        end
        @uris.map!{ |uri| URI.escape(uri) }
      end

      def prepare; end
      def cleanup; end
      
      def to_s
        "Herald Website Watcher, URIs: #{@uris}, Elements #{@selectors}, Keywords: '#{@keywords}', Timer: #{@timer}, State: #{@keep_alive ? 'Watching' : 'Stopped'}"
      end
            
    private

      def activities
        @uris.each do |uri|
#          hpricot = Hpricot(open(uri).read, :fixup_tags => true)
          hpricot = Hpricot(open(uri).read, :xhtml_strict => true)
          hpricot.search("script").remove
          if title = hpricot.search("title").inner_html
            title.strip!
          end
          title ||= "Website"
          # for every selector given
          @selectors.each do |selector|
            # and for every keyword given
            @keywords.each do |keyword|
              # return response as string and parse to RSS
              begin
                # search for elements in the page that match the
                # selector, and contain the keyword as text
                # TODO - keywords should be parsed and validated
                # TODO - keywords at the moment are case-sensitive
                # get the second to last element
                elements = hpricot.search("#{selector} [text()*=#{keyword}]")
                element = elements[elements.size - 2]
                if text = element.inner_html
                  text.strip!
                end
                html = element.to_html
                tag = element.name
                data = {:title => title, :text => text, :tag => tag, :html => html}
                # ignore items that have been part of a notification round
                next if @items.include?(data)
                # notify!
                notify(Item.new(title, text, data))
                @items << data
              rescue
                # TODO handle errors
              end # end begin
            end # end each keyword
          end # end each selector
        end # end each uri
      end # end method

    end
  end
end
