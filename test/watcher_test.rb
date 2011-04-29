# start tests by 'rake test' on root path


describe Herald::Watcher do
  before do
    @watcher = Herald::Watcher.new(:twitter, {})
  end
  
  after do
    Herald.clear
  end
  
  describe "basic initialisation" do
    it "must have a default timer value" do
       Herald::Watcher::DEFAULT_TIMER.must_equal(60)
    end
    it "must throw an error if no options are passed in" do
      assert_raises(ArgumentError) do
        Herald::Watcher.new(:twitter)
      end
    end
    it "must throw an error if type of watcher unexpected" do
      assert_raises(ArgumentError) do
        Herald::Watcher.new(:invalid, {})
      end
    end
    it "must not throw an error if type of watcher is expected" do
      @watcher.must_be_kind_of(Herald::Watcher)
    end
    it "must make some variables available" do
      @watcher.type.must_equal(:twitter)
      @watcher.timer.must_equal(Herald::Watcher::DEFAULT_TIMER)
    end
  end

  describe "initialisation through Herald#watch" do
    it "must be passed variables from the Herald class" do
      watcher = Herald.watch_twitter { _for "test"; every 2 =>  "minutes" }.watchers.first
      watcher.keep_alive.must_equal(true)
      watcher.timer.must_equal(120)
    end
  end
  
  describe "test every() method" do
    it "must convert seconds, minutes, hours and days into quantities of seconds" do
      @watcher.every(2 => "seconds").timer.must_equal(2)
      @watcher.every(2 => "minutes").timer.must_equal(2*60)
      @watcher.every(2 => "hours").timer.must_equal(2*60*60)
      @watcher.every(2 => "days").timer.must_equal(2*60*60*24)
    end
    it "must allow non-pluralised variations" do
      @watcher.every(2 => "second").timer.must_equal(2)
      @watcher.every(2 => "minute").timer.must_equal(2*60)
      @watcher.every(2 => "hour").timer.must_equal(2*60*60)
      @watcher.every(2 => "day").timer.must_equal(2*60*60*24)
    end
  end
  
  describe " every() method" do
    it "must convert seconds, minutes, hours and days into quantities of seconds" do
      @watcher.every(2 => "seconds").timer.must_equal(2)
      @watcher.every(2 => "minutes").timer.must_equal(2*60)
      @watcher.every(2 => "hours").timer.must_equal(2*60*60)
      @watcher.every(2 => "days").timer.must_equal(2*60*60*24)
    end
    it "must allow non-pluralised variations" do
      @watcher.every(2 => "second").timer.must_equal(2)
      @watcher.every(2 => "minute").timer.must_equal(2*60)
      @watcher.every(2 => "hour").timer.must_equal(2*60*60)
      @watcher.every(2 => "day").timer.must_equal(2*60*60*24)
    end
  end
  
end