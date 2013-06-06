module BitcoinCigs
  class PrivateKey
    include ::BitcoinCigs::CryptoHelper
    
    attr_accessor :public_key, :secret_multiplier
    
    def initialize(public_key, secret_multiplier)
      self.public_key = public_key
      self.secret_multiplier = secret_multiplier
    end

    def sign(hash, random_k)
      hash = str_to_num(hash) if hash.is_a?(String)

      g = public_key.generator
      n = g.order
      k = random_k % n
      p1 = g * k
      r = p1.x
      raise raise ::BitcoinCigs::Error, "Random number r is 0" if r == 0
      
      s = (inverse_mod(k, n) * (hash + (secret_multiplier * r) % n)) % n
      raise raise ::BitcoinCigs::Error, "Random number s is 0" if s == 0
      
      Signature.new(r, s)
    end
  end
end
