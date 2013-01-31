module ISO8583::MKB
  class SynchronousGateway
    def initialize(config)
      if EventMachine.reactor_running?
        @loop_is_mine = false
        @gateway = Gateway.new config
        @gateway.run
      else
        @loop_is_mine = true
        Thread.new(config, &method(:thread))
      end
    end

    def stop
      mutex = Mutex.new
      cvar = ConditionVariable.new

      EventMachine.schedule do
        @gateway.stop
        EventMachine.stop_event_loop if @loop_is_mine
        mutex.synchronize { cvar.signal }
      end

      mutex.synchronize { cvar.wait(mutex) }
    end

    def execute(request)
      mutex = Mutex.new
      cvar = ConditionVariable.new

      EventMachine.schedule do
        request.submit(@gateway) do
          mutex.synchronize { cvar.signal }
        end
      end

      mutex.synchronize { cvar.wait(mutex) }
    end

    private

    def thread(config)
      begin
        @gateway = Gateway.new config

        EventMachine.run do
          @gateway.run
        end

      rescue => e
        Logging.logger.error e
        e.backtrace.each do |line|
          Logging.logger.error line
        end
      end
    end
  end
end
