module BitcoinCigs
  class Point
    include ::BitcoinCigs::CryptoHelper
    
    attr_accessor :curve, :x, :y, :order
    
    def self.infinity
      ::BitcoinCigs::Point.new(nil, nil, nil)
    end
    
    def initialize(curve, x, y, order = nil)
      self.curve = curve
      self.x = x
      self.y = y
      self.order = order
      
      return if infinite?
      
      raise ::BitcoinCigs::Error.new if curve && !curve.contains_point(x, y)
      raise ::BitcoinCigs::Error.new if order && !(self * order).infinite?
    end
    
    def infinite?
      curve.nil? && x.nil? && y.nil? && order.nil?
    end

    def +(other)
      return self if other.infinite?
      return other if infinite?
      
      raise ::BitcoinCigs::Error.new if curve != other.curve

      if x == other.x
        return (y + other.y) % curve.p == 0 ? ::BitcoinCigs::Point.infinity : double
      end

      p = curve.p
      l = ( ( other.y - y ) * inverse_mod( other.x - x, p ) ) % p
      x3 = ( l * l - x - other.x ) % p
      y3 = ( l * ( x - x3 ) - y ) % p
      
      Point.new(curve, x3, y3)
    end

    def *(other)
      e = other
      
      e = e % order if order
      
      return ::BitcoinCigs::Point.infinity if e == 0
      return ::BitcoinCigs::Point.infinity if infinite?
      
      raise ::BitcoinCigs::Error.new unless e > 0
      
      e3 = 3 * e
      negative_self = ::BitcoinCigs::Point.new(curve, x, -y, order)
      i = leftmost_bit(e3) / 2
      result = self
      
      while i > 1
        result = result.double
        result += self if (e3 & i) != 0 && (e & i) == 0
        result += negative_self if (e3 & i) == 0 && (e & i) != 0
        i = i / 2
      end
      
      result
    end

    def ==(other)
      curve == other.curve && x == other.x && y == other.y && order == other.order
    end
    
    def to_s
      infinite? ? "infinity" : "(#{x},#{y})"
    end

    def double
      return ::BitcoinCigs::Point.infinity if infinite?

      p = curve.p
      a = curve.a
      l = ( ( 3 * x * x + a ) * \
            inverse_mod( 2 * y, p ) ) % p
      x3 = ( l * l - 2 * x ) % p
      y3 = ( l * ( x - x3 ) - y ) % p
      
      ::BitcoinCigs::Point.new(curve, x3, y3)
    end
  end
end