# start tests by 'rake test' on root path


require 'herald/notifiers/post'
describe Herald::Watcher::Notifier::Post do
  
  after do
    Herald.clear
  end
  
  describe "basic initialisation" do
    it "must throw an acception if no 'uri' param is given" do
      assert_raises(ArgumentError) do
        Herald.watch_twitter { _for "example"; action :post }
      end
    end
    it "must allow uri, uris, url and urls" do
      Herald.watch_twitter { _for "example"; action(:post, :uri => "test.com") }.must_be_kind_of(Herald)
      Herald.watch_twitter { _for "example"; action(:post, :uris => ["test.com", "example.com"]) }.must_be_kind_of(Herald)
      Herald.watch_twitter { _for "example"; action(:post, :url => "test.com") }.must_be_kind_of(Herald)
      Herald.watch_twitter { _for "example"; action(:post, :urls => ["test.com", "example.com"]) }.must_be_kind_of(Herald)
    end
    it "must be able to resolve various non-perfect uris" do
      Herald.watch_twitter { _for "example"; action(:post, :uri => "test.com") }.must_be_kind_of(Herald)
      Herald.watch_twitter { _for "example"; action(:post, :uri => "http://test.com") }.must_be_kind_of(Herald)
      Herald.watch_twitter { _for "example"; action(:post, :uri => "http://test.com/resource") }.must_be_kind_of(Herald)
    end
  end
  
end