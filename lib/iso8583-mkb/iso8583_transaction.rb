module ISO8583::MKB
  class ISO8583Transaction
    attr_reader :id, :trace, :gateway

    @@trace_counter = 0

    def initialize(gateway)
      @gateway = gateway

      now = Time.now
      @id = (now.year % 100) * 1_00_0000_0000 +
            (now.mday)       *    1_0000_0000 +
            now.hour         *       3600_000 +
            now.min          *         60_000 +
            now.sec          *          1_000 +
            now.usec         /          1_000

      @trace = @@trace_counter += 1
      @started_at = now

      Logging.logger.debug "Transaction #{id} started"
    end

    def request(&block)
      message = MKBMessage.new
      message["Transmission Date and Time"] = Time.now.utc
      message["Systems Trace Audit Number"] = @trace
      message["Time, Local Transaction"] = @started_at
      message["Date, Local Transaction"] = @started_at
      message.reference = @id.to_s

      yield message

      ISO8583Request.new self, message
    end

    def complete
      # TODO: track transactions

      Logging.logger.debug "Transaction #{@id} completed"
    end
  end
end
