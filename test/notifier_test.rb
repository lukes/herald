# start tests by 'rake test' on root path


describe Herald::Watcher::Notifier do
  
  before do
    @notifier = Herald::Watcher::Notifier.new(:callback, {})
  end
  
  after do
    Herald.clear
  end
  
  describe "basic initialisation" do
    it "must have a default notifier value" do
       Herald::Watcher::Notifier::DEFAULT_NOTIFIER.must_equal(:stdout)
    end
    it "must throw an error if type of notifier unexpected" do
      assert_raises(ArgumentError) do
        Herald::Watcher::Notifier.new(:invalid, {})
      end
    end
    it "must not throw an error if type of notifier is expected" do
      @notifier.must_be_kind_of(Herald::Watcher::Notifier)
    end
  end

  describe "initialisation through Herald#watch" do
    it "must be passed variables from the Herald class" do
      notifier = Herald.watch_twitter do 
        _for "#herald"
        action {}
      end.watchers.first.notifiers.first
      notifier.must_be_kind_of(Herald::Watcher::Notifier)
    end
  end
  
end