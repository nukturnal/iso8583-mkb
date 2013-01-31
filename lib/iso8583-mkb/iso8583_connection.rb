module ISO8583::MKB
  class ISO8583Connection < EventMachine::Connection
    attr_reader :gateway
    attr_accessor :open, :closed

    def initialize(gateway)
      super

      @gateway = gateway
      @in_air = {}
      @buffer = ""
      @state = :connecting
      @post_sign_on = []
      @ping_timer = nil
      @open = nil
      @closed = nil
    end

    def post_init
      Logging.logger.debug "Connected to DHI"
    end

    def sign_in

      transaction = @gateway.new_transaction
      request = transaction.request do |m|
        m.mti = "Network Management Request"
        m["Network Management Information Code"] = 1
      end

      @state = :ready

      request.start(30) do |response|

        transaction.complete

        if response.nil?
          Logging.logger.error "No response to Sign On"

          close_connection_after_writing
        else
          if Errors.success? response.response_code

            @state = :ready

            @post_sign_on.each do |request|
              self.request request
            end

            @post_sign_on.clear

            send_ping

            @open.call
          else
            Logging.logger.error "Sign On failed: #{Errors.error response.response_code}"

            close_connection_after_writing
          end
        end
      end

      @state = :connecting
    end

    def receive_data(data)
      @buffer << data

      until @buffer.empty?
        marker = @buffer.index "\xFF"

        if marker.nil?
          @buffer.clear
          break
        end

        if marker != 0
          @buffer.slice! 0, marker
        end

        break if @buffer.length < 6

        data_length = @buffer[1..5].to_i

        break if @buffer.length < 6 + data_length

        @buffer.slice! 0, 6
        msg = @buffer.slice! 0, data_length
        begin
          receive_message MKBMessage.parse(msg)
        rescue => e
          Logging.logger.error "receive_message failed: #{e}"
          e.backtrace.each { |line| Logging.logger.error line }
        end
      end
    end

    def unbind
      Logging.logger.debug "Disconnected from DHI"

      @state = :disconnecting

      @closed.call

      EventMachine.cancel_timer @ping_timer unless @ping_timer.nil?

      @in_air.each do |key, (request, timer)|
        Logging.logger.debug "Request #{request.request.reference} dropped"

        EventMachine.cancel_timer timer unless timer.nil?
        request.complete nil
      end

      @post_sign_on.each do |request|
        @gateway.post_request request
      end

      @in_air.clear
      @post_sign_on.clear
    end

    def request(request)
      if @state == :connecting
        @post_sign_on << request
      else

        id = request.request.reference.to_i

        Logging.logger.debug "Request #{id}: started"

        raise "duplicate request #{id}" if @in_air.include? id

        if request.timeout.nil?
          timer = nil
        else
          timer = EventMachine.add_timer(request.timeout) do
            @in_air[id][1] = nil
            forget_request id
            request.complete nil
          end
        end

        @in_air[id] = [ request, timer ]

        send_message request.request
      end
    end

    private

    def send_ping
      Logging.logger.debug "Ping"

      @ping_timer = nil

      transaction = @gateway.new_transaction
      request = transaction.request do |m|
        m.mti = "Network Management Request"
        m["Network Management Information Code"] = 301
      end

      request.start(60) do |resp|
        transaction.complete

        if resp.nil?
          Logging.logger.error "Ping timeout"

          close_connection_after_writing
        elsif !Errors.success?(resp.response_code)
          Logging.logger.error "Ping failed: #{Errors.error resp.response_code}"

          close_connection_after_writing
        else
          Logging.logger.debug "Pong"

          @ping_timer = EventMachine.add_timer(60, method(:send_ping))
        end
      end
    end

    def forget_request(id)
      Logging.logger.debug "Request #{id}: completed"

      request, timer = @in_air[id]
      EventMachine.cancel_timer timer unless timer.nil?

      @in_air.delete id
    end

    def send_message(message)
      Logging.message message

      msg = message.to_b
      msg.prepend sprintf("\xFF%05u", msg.length)

      send_data msg
    end

    def receive_message(message)
      Logging.message message

      type = (message.mti / 10) % 10
      case type
      when 0, 2, 4
        Logging.logger.warn "cannot handle type #{type} yet"

      when 1, 3
        id = message.reference.to_i

        if !@in_air.include?(id)
          Logging.logger.warn "message #{id} not in air - already timed out?"
        else
          request, = @in_air[id]

          forget_request id

          request.complete message
        end

      else
        Logging.logger.warn "unknown type in MTI: #{type}"
      end
    end
  end
end
