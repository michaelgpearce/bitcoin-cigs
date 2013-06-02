module BitcoinCigs
  class PublicKey
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
      
      [key].pack('H*')
    end
  end
end
  