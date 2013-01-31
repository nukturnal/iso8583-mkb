module ISO8583::MKB
  module Logging
    class << self
      def started?
        !@logger.nil?
      end

      def start(logfile = nil)
        logfile = STDERR if logfile.nil?

        if logfile.kind_of?(Logger)
          @logger = logfile
        else
          @logger = Logger.new logfile, :daily
        end
      end

      def stop
        @logger = nil
      end

      def message(message)
        message.to_s.split("\n").each(&@logger.method(:debug))
      end

      attr_reader :logger
    end
  end
end
