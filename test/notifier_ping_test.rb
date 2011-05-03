# start tests by 'rake test' on root path


require 'herald/notifiers/ping'
describe Herald::Watcher::Notifier::Ping do
  
  after do
    Herald.clear
  end
  
  describe "basic initialisation" do
    it "must throw an acception if no 'uri' param is given" do
      assert_raises(ArgumentError) do
        Herald.watch_twitter { _for "example"; action :ping }
      end
    end
    it "must allow uri, uris, url and urls" do
      Herald.watch_twitter { _for "example"; action(:ping, :uri => "test.com") }.must_be_kind_of(Herald)
      Herald.watch_twitter { _for "example"; action(:ping, :uris => ["test.com", "example.com"]) }.must_be_kind_of(Herald)
      Herald.watch_twitter { _for "example"; action(:ping, :url => "test.com") }.must_be_kind_of(Herald)
      Herald.watch_twitter { _for "example"; action(:ping, :urls => ["test.com", "example.com"]) }.must_be_kind_of(Herald)
    end
    it "must be able to resolve various non-perfect uris" do
      Herald.watch_twitter { _for "example"; action(:ping, :uri => "test.com") }.must_be_kind_of(Herald)
      Herald.watch_twitter { _for "example"; action(:ping, :uri => "http://test.com") }.must_be_kind_of(Herald)
      Herald.watch_twitter { _for "example"; action(:ping, :uri => "http://test.com/resource") }.must_be_kind_of(Herald)
    end
  end
  
end