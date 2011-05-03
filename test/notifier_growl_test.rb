# start tests by 'rake test' on root path

# only run this test on mac os
if RUBY_PLATFORM.downcase.include?("darwin")
  
  require 'herald/notifiers/growl'
  describe Herald::Watcher::Notifier::Growl do
  
    after do
      Herald.clear
    end
  
    describe "basic initialisation" do
      it "must lazy load ruby-growl" do
        notifier = Herald.watch_twitter { _for "#herald"; action :growl }
        defined?(Growl).must_equal("constant")
      end
    end
  
  end

end