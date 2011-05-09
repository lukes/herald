class Herald
  
  class Command
    
    def self.run(opts)
      # show running heralds and exit
      if opts[:"show-heralds"]
        puts Herald.running_daemons
        exit
      end
      # kill a herald and exit
      if pid = opts[:kill]
        Herald.kill(pid)
        puts "Herald #{pid} killed"
        exit
      end
    end
    
  end
  
end