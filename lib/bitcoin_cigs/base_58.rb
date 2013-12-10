module BitcoinCigs
  class Base58
    CHARS = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'
    CHAR_SIZE = CHARS.size

    def self.decode(s)
      int_val = 0
      s.reverse.split('').each_with_index do |char, index|
        char_index = CHARS.index(char)
        return nil if char_index.nil?
        int_val += char_index * (CHAR_SIZE ** index)
      end
      
      leading_zeros = /^#{CHARS[0]}*/.match(s).to_s.size
      
      ["#{"\x00\x00" * leading_zeros}#{int_val.to_s(16)}"].pack('H*')
    end
    
    def self.encode(s)
      int_val = s.unpack('H*').first.to_i(16)
      
      base58_val = ''
      while int_val >= CHAR_SIZE
        mod = int_val % CHAR_SIZE
        base58_val = CHARS[mod,1] + base58_val
        int_val = (int_val - mod) / CHAR_SIZE
      end
      
      result = CHARS[int_val, 1] + base58_val
      
      s.chars.each do |char|
        if char == "\x00"
          result = CHARS[0] + result
        else
          break
        end
      end
      
      result
    end
  end
end
