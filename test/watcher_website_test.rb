# start tests by 'rake test' on root path

require 'herald/watchers/website'
describe Herald::Watcher::Website do
  
  after do
    Herald.clear
  end
  
  describe "initialisation" do
    it "must throw an acception if no 'from' param is given" do
      assert_raises(ArgumentError) do
        Herald.watch_website { _for "example" }
      end
    end
    it "must load open-uri hpricot and Crack libraries" do
      defined?(Crack).must_equal("constant")
      defined?(URI).must_equal("constant")
      defined?(Hpricot).must_equal("constant")
    end
    it "must accept array of uris" do
      herald = Herald.watch_website(:from => ["test/mocks/web.html", "test/mocks/web.html"]) { _for "example" }
      herald.watchers.first.uris.must_be_kind_of(Array)
    end
    it "must map escape URI strings" do
      uri = "http://example.com/#character"
      herald = Herald.watch_website(:from => uri) { _for "example" }
      herald.watchers.first.uris.first.wont_match(uri)
      herald.watchers.first.uris.first.must_match(URI.encode(uri))
    end
  end
  
end