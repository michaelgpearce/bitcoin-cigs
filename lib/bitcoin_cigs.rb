require 'base64'

require 'bitcoin_cigs/error'
require 'bitcoin_cigs/math_helper'
require 'bitcoin_cigs/base_58'
require 'bitcoin_cigs/curve_fp'
require 'bitcoin_cigs/point'
require 'bitcoin_cigs/public_key'

module BitcoinCigs
  P = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
  R = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141
  B = 0x0000000000000000000000000000000000000000000000000000000000000007
  A = 0x0000000000000000000000000000000000000000000000000000000000000000
  Gx = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798
  Gy = 0x483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8

  CURVE_SECP256K1 = ::BitcoinCigs::CurveFp.new(P, A, B)
  GENERATOR_SECP256K1 = ::BitcoinCigs::Point.new(CURVE_SECP256K1, Gx, Gy, R)
  
  class << self
    include ::BitcoinCigs::MathHelper
    
    def verify_message(address, signature, message)
      begin
        verify_message!(address, signature, message)
        true
      rescue ::BitcoinCigs::Error
        false
      end
    end
    
    def verify_message!(address, signature, message)
      network_version = str_to_num(::BitcoinCigs::Base58.decode(address)) >> (8 * 24)

      message = calculate_hash(format_message_to_sign(message))

      curve = CURVE_SECP256K1
      g = GENERATOR_SECP256K1
      a, b, p = curve.a, curve.b, curve.p
      
      order = g.order
      
      sig = Base64.decode64(signature)
      raise ::BitcoinCigs::Error.new("Bad signature") if sig.size != 65
      
      hb = sig[0].ord
      r, s = [sig[1...33], sig[33...65]].collect { |s| str_to_num(s) }
      
      
      raise ::BitcoinCigs::Error.new("Bad first byte") if hb < 27 || hb >= 35
      
      compressed = false
      if hb >= 31
        compressed = true
        hb -= 4
      end
      
      recid = hb - 27
      x = (r + (recid / 2) * order) % p
      y2 = ((x ** 3 % p) + a * x + b) % p
      yomy = sqrt_mod(y2, p)
      if (yomy - recid) % 2 == 0
        y = yomy
      else
        y = p - yomy
      end
      
      r_point = ::BitcoinCigs::Point.new(curve, x, y, order)
      e = str_to_num(message)
      minus_e = -e % order
      
      inv_r = inverse_mod(r, order)
      q = (r_point * s + g * minus_e) * inv_r
      
    
      public_key = ::BitcoinCigs::PublicKey.new(g, q, compressed)
      addr = public_key_to_bc_address(public_key.ser(), network_version)
      raise ::BitcoinCigs::Error.new("Bad address. Signing: #{addr}, Received: #{address}") if address != addr
      
      nil
    end
  
    private
  
    def calculate_hash(d)
      sha256(sha256(d))
    end
    
    def format_message_to_sign(message)
      "\x18Bitcoin Signed Message:\n#{message.length.chr}#{message}"
    end
    
    def public_key_to_bc_address(public_key, network_version)
      h160 = hash_160(public_key)
      
      hash_160_to_bc_address(h160, network_version)
    end
    
    def hash_160_to_bc_address(h160, address_type)
      vh160 = address_type.chr + h160
      h = calculate_hash(vh160)
      addr = vh160 + h[0...4]
      
      ::BitcoinCigs::Base58.encode(addr)
    end
    
    def hash_160(public_key)
      ripemd160(sha256(public_key))
    end
    
  end
end
