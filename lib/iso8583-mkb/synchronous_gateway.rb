module ISO8583::MKB
  class SynchronousGateway
    def initialize(config)
      @mutex = Mutex.new
      @cvar = ConditionVariable.new
      Thread.new(config, &method(:thread))

      puts "okay"
    end

    def execute(request)
      EventMachine.schedule do
        request.submit(@gateway) do
          @mutex.synchronize { @cvar.signal }
        end
      end

      @mutex.synchronize { @cvar.wait(@mutex) }
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
