module ISO8583
  MMDDCodec      = _date_codec("%m%d")
  FhhmmssCodec   = _date_codec("%H%M%S")

  MMDD           = Field.new
  MMDD.codec     = MMDDCodec
  MMDD.length    = 4

  Fhhmmss        = Field.new
  Fhhmmss.codec  = FhhmmssCodec
  Fhhmmss.length = 6

  F63Length = Field.new
  F63Length.name = "F63"
  F63Length.length = 6
  F63Length.codec = ASCII_Number
  F63Length.padding = ->(value) do
    sprintf("\x20\x00\x00%03d", value)
  end

  F63 = Field.new
  F63.length = F63Length
  F63.codec = ASCII_Number

  class Message
    def self.parse(str)
      message = self.new
      message.mti, rest = _mti_format.parse(str)
      bmp,rest = Bitmap.parse(rest)
      bmp.each {|bit|
               next if bit < 2
               bmp_def = _definitions[bit]
               value, rest = bmp_def.field.parse(rest)
               message[bit] = value
      }
      message
    end
  end
end
