module ISO8583::MKB
  class SynchronousGateway
    def initialize(config)
      if EventMachine.reactor_running?
        @loop_is_mine = false
        @gateway = Gateway.new config
        @gateway.run
      else
        @loop_is_mine = true
        @ready = Queue.new
        @thread = Thread.new(config, &method(:thread))
        e = @ready.pop
        @ready = nil

        raise e unless e.nil?
      end
    end

    def stop
      EventMachine.schedule do
        @gateway.stop
        EventMachine.stop_event_loop if @loop_is_mine
      end

      if @loop_is_mine
        @thread.join
        @thread = nil
      end
    end

    def execute(request)
      queue = Queue.new

      EventMachine.schedule do
        request.submit { queue.push nil }
      end

      queue.pop
    end

    def transaction(&block)
      queue = Queue.new

      EventMachine.schedule { queue.push @gateway.new_transaction }

      transaction = queue.pop

      begin
        yield transaction
      ensure
        EventMachine.schedule { transaction.complete }
      end
    end

    private

    def thread(config)
      begin
        @gateway = Gateway.new config

        @ready.push nil

        EventMachine.epoll
        EventMachine.run do
          EventMachine.error_handler do
            Logging.logger.error "Uncaught exception in EventMachine:"
            Logging.logger.error e.to_s
            e.backtrace.each do |line|
              Logging.logger.error line
            end
          end

          @gateway.run
        end

      rescue => e
        Logging.logger.error e.to_s
        e.backtrace.each do |line|
          Logging.logger.error line
        end

        if !@ready.nil?
          @ready.push e
        end
      end
    end
  end
end
