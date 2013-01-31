module ISO8583::MKB
  class Gateway
    def initialize(config)
      uri = URI(config[:dhi])

      raise "expected tcp scheme for DHI" if uri.scheme != "tcp"
      @dhi_host = uri.host
      @dhi_port = uri.port
      @dhi_open = false
      @reopen_timer = nil

      @deferred = []
      Logging.logger.info "Gateway started"
    end

    def run
      EventMachine.run do
        reopen_dhi
      end
    end

    def stop
      if !@reopen_timer.nil?
        EventMachine.cancel_timer @reopen_timer
        @reopen_timer = nil
      end

      if !@dhi.nil?
        @dhi_open = false
        @dhi.closed = ->() {}

        @dhi.close_connection
        @dhi = nil
      end

      @deferred.clear
    end

    def new_transaction
      ISO8583Transaction.new self
    end

    def post_request(request)

      if @dhi_open ||
         ((request.request.mti == 800 || request.request.mti == 810) && !@dhi.nil?)
        @dhi.request request
      else
        @deferred << request
      end
    end

    private

    def dhi_open
      @dhi_open = true

      @deferred.each do |request|
        @dhi.request request
      end

      @deferred.clear
    end

    def dhi_closed
      @dhi_open = false
      @dhi = nil

      @reopen_timer = EventMachine.add_timer 15, method(:reopen_dhi)
    end

    def reopen_dhi
      @reopen_timer = nil

      Logging.logger.debug "Opening connection to DHI"

      @dhi = EventMachine.connect @dhi_host, @dhi_port, ISO8583Connection, self
      @dhi.open = method :dhi_open
      @dhi.closed = method :dhi_closed
      @dhi.sign_in
    end

  end
end
