class Herald  
  class Watcher

    module Imap

      attr_reader :user, :pass, :host, :mailbox, :last_uid

      # lazy-load net/imap when this Module is used
      def self.extended(base)
        Herald.lazy_load('net/imap')
        Herald.lazy_load('date')
      end

      def parse_options(options)
        @user = options.delete(:user)
        @pass = options.delete(:pass)
        @host = options.delete(:host)
        @mailbox = options.delete(:mailbox) || "INBOX"
        @mailbox.upcase!
        # start looking a week ago unless option given
        @start_date = options.delete(:start_date) || (Date.today - 7).strftime("%d-%b-%Y")
      end

      def prepare; end
      def cleanup; end
      
    private

      def activities
        puts "u: #{@user}"
        puts "p: #{@pass}"
        puts "h: #{@host}"
        imap = Net::IMAP.new(@host)
        imap.login("LOGIN", @user, @pass)
        imap.select(@mailbox)
        @last_look = Time.now
        # if we have the id of the last email looked at
        if @last_uid
          search_result = imap.search(["BODY", @keywords, "SINCE", @start_date])
        else
          search_result = imap.search(["BODY", @keywords, "SINCE", @start_date])
        end  
        puts search_result.inspect
        imap.logout
        imap.disconnect
      end

    end

  end
end