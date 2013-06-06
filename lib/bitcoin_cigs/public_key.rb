module BitcoinCigs
  class PublicKey
    include ::BitcoinCigs::CryptoHelper
    
    attr_accessor :curve, :generator, :point, :compressed
    
    def initialize(generator, point, compressed)
      self.curve = generator.curve
      self.generator = generator
      self.point = point
      self.compressed = compressed
      
      n = generator.order
      
      raise ::BitcoinCigs::Error.new("Generator point must have order.") if n.nil?
      raise ::BitcoinCigs::Error.new("Generator point order is bad.") unless (point * n).infinite?
      if point.x < 0 || n <= point.x || point.y < 0 || n <= point.y
        raise ::BitcoinCigs::Error, "Generator point has x or y out of range."
      end
    end

    def verify(hash, signature)
      hash = str_to_num(hash) if hash.is_a?(String)
      
      g = generator
      n = g.order
      r = signature.r
      s = signature.s
      
      return false if r < 1 || r > n-1
      return false if s < 1 || s > n-1
        
      c = inverse_mod(s, n)
      u1 = (hash * c) % n
      u2 = (r * c) % n
      xy = g * u1 + point * u2
      v = xy.x % n
      
      v == r
    end
    
    def ser
      if compressed
        if point.y & 1 > 0
          key = '03%064x' % point.x
        else
          key = '02%064x' % point.x
        end
      else
        key = '04%064x%064x' % [point.x, point.y]
      end
      
      decode_hex(key)
    end
  end
end
  