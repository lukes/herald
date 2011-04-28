# start tests by 'rake test' on root path

describe Herald::Watcher do
  
  after do
    Herald.clear
  end
  
  describe "initialisation" do
    it "must throw an acception if no 'from' param is given" do
      assert_raises(ArgumentError) do
        Herald.watch_rss { _for "example" }
      end
    end
    it "must load Crack and URI libraries" do
      defined?(Crack).must_equal("constant")
      defined?(URI).must_equal("constant")
    end
    it "must accept array of uris" do
      herald = Herald.watch_rss(:from => ["test/mocks/rss.xml", "test/mocks/rss2.xml"]) { _for "example" }
      herald.watchers.first.uris.must_be_kind_of(Array)
    end
    it "must map escape URI strings" do
      uri = "http://example.com/#character"
      herald = Herald.watch_rss(:from => uri) { _for "example" }
      herald.watchers.first.uris.first.wont_match(uri)
      herald.watchers.first.uris.first.must_match(URI.encode(uri))
    end
  end
  
  describe "activities" do
    it "must find keywords in title of rss" do
      skip("@items appears as empty because anything assigned in the process fork can't be accessed outside it")
      herald = Herald.once do
        check :rss, :from => "test/mocks/rss.xml"
        _for ["text", "title"]
      end
      herald.watchers.first.items.wont_be_empty
    end
    it "must find keywords in description of rss" do
      skip("@items appears as empty because anything assigned in the process fork can't be accessed outside it")
      herald = Herald.once do
        check :rss, :from => "test/mocks/rss.xml"
        _for ["some", "text", "description"]
      end
      herald.watchers.first.items.wont_be_empty
    end
    it "must return no results if keywords don't match" do
      skip("@items appears as empty because anything assigned in the process fork can't be accessed outside it")
      herald = Herald.once do
        check :rss, :from => "test/mocks/rss.xml"
        _for ["no such", "match"]
      end
      herald.watchers.first.items.must_be_empty
    end
  end
  
end