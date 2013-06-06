module BitcoinCigs
  class Signature
    include ::BitcoinCigs::CryptoHelper
    
    attr_accessor :r, :s
    
    def initialize(r, s)
      self.r = r
      self.s = s
    end

    def ser
      decode_hex("%064x%064x" % [r, s])
    end
  end
end
