module ISO8583::MKB
  class Authorization < Request
    MTI = "Authorization Request"
    REPEAT_MTI = "Authorization Repeat"

    MANDATORY = {
      "pan"              => "Primary Account Number (PAN)",
      "processing_code"  => "Processing Code",
      "amount"           => "Amount, Transaction",
      "expiry"           => "Date, Expiration",
      "merchant_type"    => "Merchant's Type",
      "acquirer_country" => "Acquiring Country Code",
      "entry_mode"       => "Point of Service Entry Mode Code",
      "condition_code"   => "Point of Service Condition Code",
      "acquirer"         => "Acquiring Institution ID code",
      "track2"           => "Track 2 data",
      "currency"         => "Currency Code, Transaction",
    }

    OPTIONAL = {
      "conversion_date"     => "Date, Conversion",

      "billing_amount"      => "Amount, Cardholder Billing",
      "billing_convrate"    => "Conversion, Cardholder Billing",
      "billing_currency"    => "Currency Code, Cardholder Billing",

      "terminal_id"      => "Card Acceptor Terminal ID",
      "acceptor_id"      => "Card Acceptor ID Code",
      "acceptor_name"    => "Card Acceptor Name/Location",

      "additional" => "Additional Information"
    }

    RESPONSE = {
      "Authorization Identification Response" => "auth_id",
      "Additional Response Data" => "additional_resp"
    }

    build_class

    def reverse
      reversal = Reversal.new(@transaction)

      [
        :pan, :processing_code, :amount, :expiry, :merchant_type,
        :acquirer_country, :entry_mode, :condition_code, :acquirer,
        :currency, :additional , :terminal_id, :acceptor_id, :acceptor_name
      ].each do |key|
        reversal.send :"#{key}=", instance_variable_get(:"@#{key}")
      end

      reversal.response_code = @status

      reversal
    end
  end
end
