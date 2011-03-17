require 'net/http'

require 'rubygems'
require 'json'
require 'ruby-growl'

class Herald

  def self.watch(&block)
    herald = new(&block)
  end
  
  def initialize(&block)
    
  end

end

#Herald::Twitter.search("luke")

=begin

Herald.new(:twitter, :every => 1.minute)

or

Herald.watch do
  source :rss, :uri => "uri"
  source :rss, :uris => ["uri1", "uri2"]
  source :twitter
  for :soundofmusic
end

=end