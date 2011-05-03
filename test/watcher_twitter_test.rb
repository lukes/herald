# start tests by 'rake test' on root path

require 'herald/watchers/twitter'
describe Herald::Watcher::Twitter do
  
  after do
    Herald.clear
  end
  
  describe "initialisation" do
    it "must load Crack and URI libraries" do
      defined?(Crack).must_equal("constant")
      defined?(URI).must_equal("constant")
    end
  end
  
end