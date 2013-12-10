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
    
    # def self.encode(s)
    #   int_val = s.unpack('H*').first.to_i(16)
    #   
    #   var bi = BigInteger.fromByteArrayUnsigned(input);
    #   var chars = [];
    # 
    #   while (bi.compareTo(B58.base) >= 0) {
    #     var mod = bi.mod(B58.base);
    #     chars.unshift(B58.alphabet[mod.intValue()]);
    #     bi = bi.subtract(mod).divide(B58.base);
    #   }
    #   chars.unshift(B58.alphabet[bi.intValue()]);
    # 
    #   for (var i = 0; i < input.length; i++) {
    #     if (input[i] == 0x00) {
    #       chars.unshift(B58.alphabet[0]);
    #     } else break;
    #   }
    # 
    #   return chars.join('');
    # end
    
    # def self.encode(s)
    #   value = 0
    #   
    #   value = s.chars.reverse_each.each_with_index.inject(0) { |acc, (ch, i)| acc + (256 ** i) * ch.ord }
    # 
    #   result = []
    #   while value >= CHAR_SIZE
    #     div, mod = value / CHAR_SIZE, value % CHAR_SIZE
    #     result.unshift(CHARS[mod])
    #     value = div
    #   end
    #   result.unshift(CHARS[value])
    # 
    #   pad_size = s.chars.inject(0) { |acc, ch| acc + (ch == "\0" ? 1 : 0) }
    #   
    #   result.unshift(CHARS[0] * pad_size)
    # 
    #   result.join
    # end
  end
end
