# start tests by 'rake test' on root path

describe Herald do
  before do
    @herald = Herald.watch_twitter { _for "test" }
  end
  
  after do
    Herald.clear
  end

  describe "initialisation with watchers" do
    it "must throw an acception if no 'check' param is given" do
      assert_raises(RuntimeError) do
        Herald.watch {}
      end
    end
    it "must assign a watcher" do
      @herald.watchers.size.must_equal(1)
    end
    it "must allow assigning multiple watchers" do
      herald = Herald.watch { check :rss, :from => "http://example.com"; check :twitter; _for "test" }
      herald.watchers.size.must_equal(2)
    end
  end

  describe "initialisation of twitter watcher" do
    it "must assign a twitter watcher" do
      @herald.watchers.first.type.must_equal(:twitter)
    end
  end
  
  describe "initialisation of rss watcher" do
    it "must throw an error if no rss url is given" do
      assert_raises(ArgumentError) do
        Herald.watch { check :rss }
      end
    end
    it "must assign an rss watcher" do
      herald = Herald.watch { check :rss, :from => "http://example.com" }
      herald.watchers.first.type.must_equal(:rss)
    end
  end
  
  describe "initialisation with keywords" do
    it "must assign keyword when passed as a string" do
      @herald.watchers.first.keywords.must_be_kind_of(Array)
      @herald.watchers.first.keywords.size.must_equal(1)
      @herald.watchers.first.keywords.join.must_equal("test")
    end
    it "must slurp keywords when passed as a multiargument strings" do
      keywords = ["test1", "test2"]
      herald = Herald.watch { check :twitter; _for *keywords }
      herald.watchers.first.keywords.size.must_equal(2)
      herald.watchers.first.keywords.to_s.must_equal(keywords.to_s)
    end
    it "must assign keywords when passed as an array" do
      keywords = ["test1", "test2"]
      herald = Herald.watch { check :twitter; _for keywords }
      herald.watchers.first.keywords.size.must_equal(2)
      herald.watchers.first.keywords.to_s.must_equal(keywords.to_s)
    end
  end
  
  describe "delete herald" do
    it "should allow itself to be deleted" do
      @herald.delete
      Herald.size.must_equal(0)
    end
  end

  describe "initialisation with actions" do
    it "should assign stdout as the default Notifier" do
      skip("@notifiers appears as empty because anything assigned in the process fork can't be accessed outside it")
      @herald.watchers.first.notifiers.size.must_equal(1)
    end
  end
  
  describe "Herald class methods (stop, start, alive?) must allow batch operations" do
    it "must return array of heralds" do
      Herald.heralds.must_be_kind_of(Array)
      Herald.heralds.size.must_equal(1)
      Herald.heralds.first.must_be_kind_of(Herald)
      herald_2 = Herald.watch { check :twitter; _for "test" }
      herald_2.stop
      Herald.heralds.size.must_equal(2)
      Herald.heralds(:stopped).size.must_equal(1)
      Herald.heralds(:alive).size.must_equal(1)
    end
    it "must allow heralds to be deleted by passing delete and herald object" do
      Herald.heralds.size.must_equal(1)
      Herald.delete(@herald)
      Herald.size.must_equal(0)
    end
    it "must allow all stopped heralds to be deleted" do
      Herald.size.must_equal(1)
      Herald.delete(:stopped).size.must_equal(1)
      @herald.stop
      Herald.delete(:stopped).size.must_equal(0)
    end
    it "size() must return size of @@heralds" do
      Herald.heralds.size.must_equal(1)
      herald_2 = Herald.watch { check :twitter; _for "test" }
      herald_2.stop
      Herald.size.must_equal(2)
      Herald.size(:stopped).must_equal(1)
      Herald.size(:alive).must_equal(1)
    end
    it "must report on if there are any heralds alive" do
      Herald.alive?.must_equal(true)
    end
    it "must allow heralds to be stopped" do
      Herald.size(:alive).must_equal(1)
      Herald.stop.must_equal(Herald)
      Herald.size(:alive).must_equal(0)
      Herald.size(:stopped).must_equal(1)
    end
    it "must allow heralds to be restarted" do
      Herald.stop
      Herald.start
      Herald.alive?.must_equal(true)
    end
    
  end

  describe "Must allow running as a daemon, with methods to control processes" do
    it "must determine a location to write the pid file to" do
      Herald::Daemon.pid_file.must_match(/\.herald\.pids\Z/)
      File.writable?(Herald::Daemon.pid_file).must_equal(true)
    end
    it "must allow Herald to be daemonized" do
      Herald.is_daemon?.must_equal(false)      
      Herald.daemonize!.must_equal(Herald)
      Herald.is_daemon?.must_equal(true)
    end
    it "must serialize running heralds to an array of hashes" do
      Herald.deserialize_daemons.must_be_kind_of(Array)
      Herald.deserialize_daemons.first.must_be_kind_of(Hash)
      Herald.deserialize_daemons.first.keys.first.must_equal(@herald.subprocess)
      Herald.deserialize_daemons.first.values.first.must_equal(@herald.to_s)
    end
    it "must keep track of running heralds" do
      Herald.running_daemons.size.must_equal(1)
      Herald.watch_twitter { _for "test" }
      Herald.running_daemons.size.must_equal(2)
    end
    it "Herald:#clear must delete all processes" do
      Herald.clear.must_equal(Herald)
      Herald.running_daemons.size.must_equal(0)
    end
    it "must allow you to delete pids" do
      Herald.deserialize_daemons.size.must_equal(1)
      Herald.delete_daemons(@herald.subprocess).must_equal(Herald)
      Herald.deserialize_daemons.size.must_equal(0)
    end
    it "must allow you to kill Heralds by passing a herald" do
      Herald.deserialize_daemons.size.must_equal(1)
      Herald.kill(@herald).must_equal(Herald)
      Herald.deserialize_daemons.size.must_equal(0)
    end
    it "must allow you to kill Heralds by passing a pid" do
      Herald.deserialize_daemons.size.must_equal(1)
      Herald.kill(@herald.subprocess).must_equal(Herald)
      Herald.deserialize_daemons.size.must_equal(0)
    end
  end
  
end