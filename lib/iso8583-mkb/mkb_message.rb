module ISO8583::MKB
  class MKBMessage < ISO8583::Message
    include ISO8583

    mti_format N, length: 4

    mti 100, "Authorization Request"
    mti 101, "Authorization Repeat"
    mti 102, "ATM Confirmation"
    mti 110, "Authorization Response"
    mti 120, "Advice Authorization Request"
    mti 121, "Advice Repeat"
    mti 130, "Authorization Advice Response"
    mti 200, "Financial Transaction Request"  # to host only
    mti 210, "Financial Transaction Response" # from host only
    mti 220, "Financial Transaction Advice"   # to host only
    mti 230, "Financial Transaction Response" # from host only
    mti 302, "Interface Exception Request"
    mti 312, "Host Exception Response"
    mti 322, "Host Exception Advice Request"
    mti 332, "Interface Exception Advice Response"
    mti 400, "Reversal Request"
    mti 401, "Reversal Repeat"
    mti 410, "Reversal Response"
    mti 420, "Reversal Advice" # to host only
    mti 430, "Reversal Advice" # from host only
    mti 522, "Issuer Reconciliation Advice" # to host only (for future use)
    mti 532, "Issuer Reconciliation Advice" # from host only
    mti 800, "Network Management Request"
    mti 810, "Network Management Response"

    bmp  2,  "Primary Account Number (PAN)",          LLVAR_N,    max: 19
    bmp  3,  "Processing Code",                       N,          length: 6
    bmp  4,  "Amount, Transaction",                   N,          length: 12
    bmp  5,  "Amount, Settlement",                    N,          length: 12
    bmp  6,  "Amount, Cardholder Billing",            N,          length: 12
    bmp  7,  "Transmission Date and Time",            MMDDhhmmss
    bmp  9,  "Conversion Rate, Settlement",           N,          length: 8
    bmp  10, "Conversion, Cardholder Billing",        N,          length: 8
    bmp  11, "Systems Trace Audit Number",            N,          length: 6
    bmp  12, "Time, Local Transaction",               Fhhmmss
    bmp  13, "Date, Local Transaction",               MMDD
    bmp  14, "Date, Expiration",                      YYMM
    bmp  15, "Date, Settlement",                      MMDD
    bmp  16, "Date, Conversion",                      MMDD
    bmp  18, "Merchant's Type",                       N,          length: 4
    bmp  19, "Acquiring Country Code",                N,          length: 3
    bmp  22, "Point of Service Entry Mode Code",      N,          length: 4
    bmp  24, "Network International Identifier",      AN,         length: 3
    bmp  25, "Point of Service Condition Code",       N,          length: 2
    bmp  28, "Amount, Fee",                           N,          length: 9
    bmp  32, "Acquiring Institution ID code",         LLVAR_N,    max: 11
    bmp  33, "Forwarding Institution ID code",        LLVAR_N,    max: 11
    bmp  35, "Track 2 data",                          LLVAR_B,    max: 37
    bmp  37, "Retrieval Reference Number",            AN,         length: 12
    bmp  38, "Authorization Identification Response", ANP,        length: 6
    bmp  39, "Response Code",                         AN,         length: 2
    bmp  41, "Card Acceptor Terminal ID",             ANS,        length: 8
    bmp  42, "Card Acceptor ID Code",                 ANS,        length: 15
    bmp  43, "Card Acceptor Name/Location",           ANS,        length: 40
    bmp  44, "Additional Response Data",              LLVAR_ANS,  max: 25
    bmp  45, "Track 1 data",                          LLVAR_ANS,  max: 80
    bmp  48, "Additional Data-Private",               LLVAR_ANS,  max: 99
    bmp  49, "Currency Code, Transaction",            N,          length: 3
    bmp  50, "Currency Code, Settlement",             N,          length: 3
    bmp  51, "Currency Code, Cardholder Billing",     N,          length: 3
    bmp  52, "Personal Identification Number Data",   B,          length: 8
    bmp  53, "Security Related Control Information",  N,          length: 16
    bmp  54, "Additional Amounts",                    LLLVAR_ANS, max: 120
    bmp  55, "ICC Related Data",                      LLLVAR_B,   max: 255
    bmp  60, "Additional POS Information",            LLVAR_N,    max: 6
    bmp  61, "Other Amounts",                         LLVAR_N,    max: 36
    bmp  63, "Message Reason Code",                   F63,        max: 4
    bmp  66, "Settlement Code",                       A,          length: 1
    bmp  70, "Network Management Information Code",   N,          length: 3
    bmp  73, "Date, Action",                          N,          length: 6
    bmp  74, "Credits, Number",                       N,          length: 10
    bmp  75, "Credits, Reversal Number",              N,          length: 10
    bmp  76, "Debits, Number",                        N,          length: 10
    bmp  77, "Debits, Reversal Number",               N,          length: 10
    bmp  86, "Credits, Amount",                       N,          length: 16
    bmp  87, "Credits, Reversal Amount",              N,          length: 16
    bmp  88, "Debits, Amount",                        N,          length: 16
    bmp  89, "Debits, Reversal Amount",               N,          length: 16
    bmp  90, "Original Data Elements",                N,          length: 42
    bmp  91, "File Update Code",                      AN,         length: 1
    bmp  95, "Replacement Amounts",                   AN,         length: 42
    bmp 101, "File Name",                             LLVAR_AN,   max: 17
    bmp 102, "Account From",                          LLVAR_AN,   max: 28
    bmp 103, "Account To",                            LLVAR_AN,   max: 28
    bmp 118, "Intra Country",                         LLVAR_AN,   max: 99
    bmp 120, "Additional Information",                LLLVAR_ANS, max: 990
    bmp 122, "Remaining Open-To-Use",                 LLVAR_ANS,  max: 25

    # TODO: fields 126, 127 (non-ISO encoding)

    bmp_alias 37, :reference
    bmp_alias 39, :response_code
  end
end