module ISO8583::MKB
  class Replenishment < Request
    MTI = "Financial Transaction Advice"
    REPEAT_MTI = "Financial Transaction Response"

    MANDATORY = {
      "pan"              => "Primary Account Number (PAN)",
      "processing_code"  => "Processing Code",
      "amount"           => "Amount, Transaction",
      "transmited_at"    => "Transmission Date and Time",
      "trace_number"     => "Systems Trace Audit Number",
      "local_time"       => "Time, Local Transaction",
      "local_date"       => "Date, Local Transaction",
      "expiry"           => "Date, Expiration",
      "merchant_type"    => "Merchant's Type",
      "acquirer_country" => "Acquiring Country Code",
      "entry_mode"       => "Point of Service Entry Mode Code",
      "condition_code"   => "Point of Service Condition Code",
      "acquirer"         => "Acquiring Institution ID code",
      "track2"           => "Track 2 data",
      "currency"         => "Currency Code, Transaction"
    }

    OPTIONAL = {
      "terminal_id"      => "Card Acceptor Terminal ID",
      "acceptor_id"      => "Card Acceptor ID Code",
      "acceptor_name"    => "Card Acceptor Name/Location",

      "additional"       => "Additional Information",
      "security_control" => "Security Related Control Information",
      "pin_block"        => "Personal Identification Number Data"
    }

    RESPONSE = {

    }

    build_class
  end
end
