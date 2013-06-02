module BitcoinCigs
  class CurveFp
    attr_accessor :p, :a, :b
    
    def initialize(p, a, b)
      self.p = p
      self.a = a
      self.b = b
    end
  
    def contains_point(x, y)
      return (y * y - (x * x * x + a * x + b)) % p == 0
    end
  end
end
