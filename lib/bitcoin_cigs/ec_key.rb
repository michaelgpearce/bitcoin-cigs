module BitcoinCigs
  class EcKey
    attr_accessor :public_key, :private_key, :secret
    
    def initialize(secret, compressed = false)
      curve = ::BitcoinCigs::CurveFp.new(BitcoinCigs::P, BitcoinCigs::A, BitcoinCigs::B)
      generator = Point.new(curve, BitcoinCigs::Gx, BitcoinCigs::Gy, BitcoinCigs::R)
      self.public_key = PublicKey.new(generator, generator * secret, compressed)
      self.private_key = PrivateKey.new(public_key, secret)
      self.secret = secret
    end
  end
end
