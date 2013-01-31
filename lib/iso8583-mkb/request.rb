module ISO8583::MKB
  class Request
    class << self
      def build_class
        [ const_get(:MANDATORY), const_get(:OPTIONAL) ].each do |hash|
          hash.each do |key, iso8583_name|
            attr_accessor key.intern
          end
        end

        const_get(:RESPONSE).each do |iso8583_name, key|
          attr_reader key.intern
        end
      end
    end

    attr_reader :request, :status

    attr_accessor :retries
    attr_accessor :timeout

    def initialize
      @retries = 4
      @timeout = 60
      @retry_with = nil
      @complete = nil
      @request = nil
    end

    def success?
      Errors.success? @status
    end

    def status_description
      Errors.error @status
    end

    def submit(gateway, &complete)
      @transaction = gateway.new_transaction

      translated_fields = {}

      self.class.const_get(:MANDATORY).each do |key, iso8583_name|
        value = instance_variable_get :"@#{key}"
        if value.nil?
          raise "required attribute #{key} (#{iso8583_name}) is not specified"
        end

        translated_fields[iso8583_name] = value
      end


      self.class.const_get(:OPTIONAL).each do |key, iso8583_name|
        value = instance_variable_get :"@#{key}"
        unless value.nil?
          translated_fields[iso8583_name] = value
        end
      end

      @request = @transaction.request do |message|
        message.mti = self.class.const_get(:MTI)

        translated_fields.each do |key, value|
          message[key] = value
        end

        message.to_b # to validate encoding of the fields
      end

      @retry_with = [
        self.class.const_get(:REPEAT_MTI),
        translated_fields
      ]

      @complete = complete
      @request.start @timeout, &method(:request_completed)
    end

    private

    def request_completed(response)
      if response.nil?
        Logging.logger.warn "Request timed out"

        if @retries == 0
          Logging.logger.warn "Out of retries"

          complete_request 'C0'
        else
          @retries -= 1

          Logging.logger.warn "Repeating, #{@retries} more tries"

          @request = @transaction.request do |message|
            message.mti, fields = @retry_with

            fields.each do |key, value|
              message[key] = value
            end

            @request.start @timeout, &method(:request_completed)
          end
        end
      else
        self.class.const_get(:RESPONSE).each do |iso8583_name, key|
          instance_variable_set :"@#{key}", response[iso8583_name]
        end

        complete_request response.response_code
      end
    end

    def complete_request(status)
      @status = status
      @transaction.complete

      complete, @complete = @complete, nil
      complete.call self
    end
  end
end
