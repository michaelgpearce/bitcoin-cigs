module BitcoinCigs
  class Base58
    CHARS = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'
    CHAR_SIZE = CHARS.size

    def self.decode(s)
      value = s.chars.reverse_each.each_with_index.inject(0) { |acc, (ch, i)| acc + (CHARS.index(ch) || -1) * (CHAR_SIZE ** i) }
      
      result = []
      while value >= 256
        div = value / 256
        mod = value % 256
        result.unshift(mod.chr)
        value = div
      end
      result.unshift(value.chr)
      
      pad_size = s.chars.inject(0) { |acc, ch| acc + (CHARS[0] == ch ? 1 : 0) }
      
      result.unshift(0.chr * pad_size)
      
      result.join
    end
    
    def self.encode(s)
      value = 0
      
      value = s.chars.reverse_each.each_with_index.inject(0) { |acc, (ch, i)| acc + (256 ** i) * ch.ord }

      result = []
      while value >= CHAR_SIZE
        div, mod = value / CHAR_SIZE, value % CHAR_SIZE
        result.unshift(CHARS[mod])
        value = div
      end
      result.unshift(CHARS[value])

      pad_size = s.chars.inject(0) { |acc, ch| acc + (ch == "\0" ? 1 : 0) }
      
      result.unshift(CHARS[0] * pad_size)

      result.join
    end
  end
end
