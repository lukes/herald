# start tests by 'rake test' on root path


require 'herald/notifiers/callback'
describe Herald::Watcher::Notifier::Callback do
  
  after do
    Herald.clear
  end
  
  describe "basic initialisation" do
    it "action() must take a block" do
      Herald.watch_twitter do
         _for "#herald"
         action {}
       end
    end
    it "must make Herald::Item available if block contains a parameter" do
      Herald.watch_twitter do
         _for "#herald"
         action do |p|
           p.must_be_kind_of(Herald::Item)
           p.data.must_be_kind_of(Hash)
         end
       end
    end
  end
  
end