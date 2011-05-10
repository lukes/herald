class Herald
  
  module Daemon

    #
    # module methods:
    #

    # TODO turn this into pid_file and initialize on extended
    @@pid_file = nil

    def self.extended(base)
      unless File.exists?(pid_file)
        require 'fileutils'
        FileUtils.touch(pid_file)
        File.chmod(0777, pid_file)
      end
    end

    # returns location of writable .herald.pids file
    # used to serialize daemons
    def self.pid_file
      unless @@pid_file.nil?
        return @@pid_file
      end
      # select lastest installed herald gem location
      dir = if herald_gem_dir = Dir["#{Gem.dir}/gems/herald*"].last
        "#{herald_gem_dir}/"
      else
        ""
      end
      @@pid_dir = "#{dir}.herald.pids"      
    end

    #
    # mixin methods:
    #

    # kill can be passed :all, a pid, or a herald
    # kill is destructive in that it won't call
    # herald.stop before terminating its process.
    def kill(obj)
      pids = case
      when obj == :all
        deserialize_daemons
      when obj.is_a?(Fixnum)
        Array(obj)
      when obj.is_a?(Herald)
        Array(obj.subprocess)
      else
        nil
      end
      if pids.nil?
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
      delete_daemons(pids)
      self
    end

    # returns serialized daemons in .herald.pids and any unserialized ones
    def running_daemons
      # map all running daemons
      # to a hash of { pid => herald_as_string }    
      daemons = deserialize_daemons
      # add all running heralds
      heralds.each do |h|
        unless daemons.keys.include?(h.subprocess)
          daemons[h.subprocess] = h.to_s
        end
      end
      # whittle out any process that no longer exist
      daemons.delete_if do |pid, herald|
        begin
          Process.getpgid(pid)
          false
        rescue Errno::ESRCH => e
          true
        end
      end
    end

    # will serialize all daemons (running in this Ruby session
    # plus any existing ones in the file). 
    def serialize_daemons
      # write file, truncating existing file to zero length
      File.open(Herald::Daemon.pid_file, 'w') do |f|
        f.write(running_daemons.to_yaml)
      end
      self
    end

    # returns pids from .herald.pids file
    # TODO make this thread safe
    def deserialize_daemons
      YAML::load(File.read(Herald::Daemon.pid_file)) || Hash.new
    end
    
    # deletes given pids from file
    def delete_daemons(pids)
      pids = Array(pids)
      daemons = deserialize_daemons
      daemons.delete_if do |pid, herald|
        pids.include?(pid)
      end
      File.open(Herald::Daemon.pid_file, 'w') do |f|
        f.write(daemons.to_yaml)
      end
      self
    end
    
  end
  
end