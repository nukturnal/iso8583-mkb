module ISO8583::MKB
  class Reversal < Request
    MTI = "Reversal Request"
    REPEAT_MTI = "Reversal Repeat"

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
      "currency"         => "Currency Code, Transaction",
      "auth_id"          => "Authorization Identification Response",
      "response_code"    => "Response Code",
      "reason"           => "Message Reason Code",
      "original_data"    => "Original Data Elements"
    }

    OPTIONAL = {
      "billing_amount"      => "Amount, Cardholder Billing",
      "billing_convrate"    => "Conversion, Cardholder Billing",
      "billing_currency"    => "Currency Code, Cardholder Billing",

      "terminal_id"      => "Card Acceptor Terminal ID",
      "acceptor_id"      => "Card Acceptor ID Code",
      "acceptor_name"    => "Card Acceptor Name/Location",

      "replacement_amount" => "Replacement Amounts",
      "additional" => "Additional Information"
    }

    RESPONSE = {

    }

    build_class
  end
end
