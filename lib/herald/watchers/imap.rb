class Herald  
  class Watcher

    module Imap

      attr_reader :user, :pass, :host, :mailbox

      # lazy-load net/imap when this Module is used
      def self.extended(base)
        Herald.lazy_load('net/imap')
      end

      def parse_options(options)
        @user = options.delete(:user)
        @pass = options.delete(:pass)
        @host = options.delete(:host)
        @mailbox = options.delete(:mailbox) || "inbox"
      end
      
      # TODO make new thread loop
      def start
        begin
          activities
          sleep @timer if @watching
        end while @watching
      end

      def stop; end
      
    private

      def activities
        puts "u: #{@user}"
        puts "p: #{@pass}"
        puts "h: #{@host}"
        imap = Net::IMAP.new(@host, "imap2")
        imap.authenticate("cram-md5", @user, @pass)
        imap.select(@mailbox)
        search_result = imap.search(["BODY", "hello"])
        imap.disconnect
      end

    end

  end
end