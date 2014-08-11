module BitcoinCigs
  class CompactInt

    def initialize(value)
      @value = value
    end

    def encode()
      arr = if @value < 253
        [@value]
      elsif @value < (1 << 16)
        [253, *number_to_bytes(@value, 2)]
      elsif value < (1 << 32)
        [254, *number_to_bytes(@value, 4)]
      else
        [255, *number_to_bytes(@value, 8)]
      end

      arr.pack('C*')
    end

    private

    def number_to_bytes(number, size)
      result = []
      size.times do |n|
        result << ((number >> (8 * n)) & 255)
      end

      result
    end
  end
end
