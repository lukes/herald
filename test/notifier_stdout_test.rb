# start tests by 'rake test' on root path

require 'herald/notifiers/stdout'
describe Herald::Watcher::Notifier::Stdout do

  after do
    Herald.clear
  end

  describe "basic initialisation" do
    it "must accept a file parameter" do
      file = File.join(File.dirname(__FILE__), "mocks" "stdout.txt")
      # clean up any previous test
      begin
        File.delete(file)
      rescue Errno::ENOENT => e
        # do nothing
      end
      File.exists?(file).must_equal(false)
      Herald.watch_twitter { _for "#herald"; action(:stdout, :file => file) }
      File.exists?(file).must_equal(true)
      File.delete(file)      
    end
  end

end