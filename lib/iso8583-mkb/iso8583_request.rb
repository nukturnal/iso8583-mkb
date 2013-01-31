module ISO8583::MKB
  class ISO8583Request
    attr_reader :transaction, :request, :timeout

    def initialize(transaction, request)
      @transaction = transaction
      @request = request
      @timeout = nil
      @completion = nil
    end

    def start(timeout = nil, &completion)
      @completion = completion
      @timeout = timeout

      @transaction.gateway.post_request self
    end

    def complete(result)
      block = @completion
      @completion = nil

      block.call result
    end
  end
end