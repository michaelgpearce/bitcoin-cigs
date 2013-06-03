require 'openssl'
require 'digest/sha2'
require 'base64'

module BitcoinCigs
  module CryptoHelper
    def encode64(s)
      Base64.encode64(s)
    end
    
    def decode64(s)
      Base64.decode64(s)
    end
    
    def encode58(s)
      ::BitcoinCigs::Base58.encode(s)
    end
    
    def decode58(s)
      ::BitcoinCigs::Base58.decode(s)
    end
    
    def inverse_mod(a, m)
      a = a % m if a < 0 || m <= a
      
      c, d = a, m
      
      uc, vc, ud, vd = 1, 0, 0, 1
      
      while c != 0
        q, c, d = d / c, d % c, c
        uc, vc, ud, vd = ud - q*uc, vd - q*vc, uc, vc
      end
      raise ::BitcoinCigs::Error.new unless d == 1
      
      ud > 0 ? ud : ud + m
    end
    
    def leftmost_bit(x)
      raise ::BitcoinCigs::Error.new unless x > 0
      
      result = 1
      result *= 2 while result <= x
      result / 2
    end
    
    def ripemd160(d)
      (OpenSSL::Digest::RIPEMD160.new << d).digest
    end
    
    def sha256(d)
      (Digest::SHA256.new << d).digest
    end
    
    def sqrt_mod(a, p)
      a.to_bn.mod_exp((p + 1) / 4, p).to_i
    end
    
    def str_to_num(s)
      s.chars.reverse_each.with_index.inject(0) { |acc, (ch, i)| acc + ch.ord * (256 ** i) }
    end
  end
end