class Herald
  
  module Daemon

    #
    # module methods:
    #

    # TODO turn this into pid_file and initialize on extended
    @@pid_dir = nil

    def self.extended(base)
      unless File.exists?(pid_file)
        require 'fileutils'
        FileUtils.touch(pid_file)
        File.chmod(0777, pid_file)
      end
    end

    def self.pid_file
      @@pid_dir ||= begin
        # select lastest installed herald gem location
        if herald_gem_dir = Dir["#{Gem.dir}/gems/herald*"].last
          "#{herald_gem_dir}/"
        else
          ""
        end
      end
      "#{@@pid_dir}.herald.pids"
    end

    #
    # mixin methods:
    #

    # kill can be passed :all, a pid, an array of pids, or a herald
    def kill(obj)
      pids = case
      when obj == :all
        serialized_daemons
      when obj.is_a?(String) || obj.is_a?(Fixnum)
        pids = Array(obj)
      when obj.is_a?(Array)
        pids = obj
      when obj.is_a?(Herald)
        pids = Array(obj.subprocess)
      else
        raise ArgumentError.new("Unknown parameter #{obj}")
      end
      pids.each do |pid|
        begin
          Process.kill("TERM", pid.to_i)
        # if @subprocess PID does not exist, 
        # this will be due to an error in the subprocess
        # which has terminated it
        rescue Errno::ESRCH => e
          # do nothing
        end
      end
      File.truncate(Herald::Daemon.pid_file, 0)
      self
    end

    def running_daemons
      daemons = (heralds.map{ |h| h.subprocess } + serialized_daemons).uniq
      # whittle out any process that no longer exists
      daemons.delete_if do |pid|
        begin
          Process.getpgid(pid.to_i)
          false
        rescue Errno::ESRCH => e
          true
        end
      end
    end

    def serialize_daemons
      # write file, truncating existing file to zero length
      string = running_daemons.join("\n")
      File.open(Herald::Daemon.pid_file, 'w') do |f|
        f.write(string)
      end
    end

    # TODO make this thread safe
    def serialized_daemons
      # open pid_file
      File.open(Herald::Daemon.pid_file, 'r') do |f|
        # read file, and map to an array of integers
        f.read.split("\n").map { |d| d.to_i }
      end
    end
    
  end
  
end