require 'base64'

require 'bitcoin_cigs/error'
require 'bitcoin_cigs/math_helper'
require 'bitcoin_cigs/base_58'
require 'bitcoin_cigs/curve_fp'
require 'bitcoin_cigs/point'
require 'bitcoin_cigs/public_key'

module BitcoinCigs
  PRIVATE_KEY_PREFIX = 0x80
  
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
    
    def sign_message!(wallet_key, message)
      private_key = convert_wallet_format_to_bytes!(wallet_key)
    end
    
    def convert_wallet_format_to_bytes!(input)
      bytes = if is_wallet_import_format?(input)
        decode_wallet_import_format(input)
      elsif is_compressed_wallet_import_format?(input)
        decode_compressed_wallet_import_format(input)
      elsif is_mini_format?(input)
        sha256(input)
      elsif is_hex_format?(input)
        [input].pack('H*')
      elsif is_base_64_format?(input)
        Base64.decode64(input)
      else
        raise ::BitcoinCigs::Error.new("Unknown Wallet Format")
      end
      
      bytes
    end
    
    private
    
    def decode_wallet_import_format(input)
      bytes = ::BitcoinCigs::Base58.decode(input)[1..-1]
      hash = bytes[0..32]
      
      checksum = sha256(sha256(hash))
      raise ::BitcoinCigs::Error.new("Wallet checksum invalid") if bytes[33..-1] != checksum[0...4]

      version, hash = hash[0], hash[1..-1]
      raise ::BitcoinCigs::Error.new("Wallet Version #{version} not supported") if version.ord != PRIVATE_KEY_PREFIX
      
      hash
    end
    
    def decode_compressed_wallet_import_format(input)
      bytes = ::BitcoinCigs::Base58.decode(input)
      hash = bytes[0...34]
      
      checksum = sha256(sha256(hash))
      raise ::BitcoinCigs::Error.new("Wallet checksum invalid") if bytes[34..-1] != checksum[0...4]

      version, hash = hash[0], hash[1..32]
      raise ::BitcoinCigs::Error.new("Wallet Version #{version} not supported") if version.ord != PRIVATE_KEY_PREFIX
      
      hash
    end
    
    # 64 characters [0-9A-F]
    def is_hex_format?(key)
      /^[A-Fa-f0-9]{64}$/ =~ key
    end
    
    # 51 characters base58 starting with 5
    def is_wallet_import_format?(key)
      /^5[123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]{50}$/ =~ key
    end
    
    # 52 characters base58 starting with L or K
    def is_compressed_wallet_import_format?(key)
      /^[LK][123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]{51}$/ =~ key
    end
    
    # 44 characters
    def is_base_64_format?(key)
      /^[ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789=+\/]{44}$/ =~ key
    end
    
    # 22, 26 or 30 characters, always starts with an 'S'
    def is_mini_format?(key)
      validChars22 = /^S[123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]{21}$/ =~ key
      validChars26 = /^S[123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]{25}$/ =~ key
      validChars30 = /^S[123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]{29}$/ =~ key
      
      bytes = sha256("#{key}?")
    
      (bytes[0].ord === 0x00 || bytes[0].ord === 0x01) && (validChars22 || validChars26 || validChars30)
    end
    
    def debug_bytes(s)
      s.chars.collect(&:ord).join(', ')
    end
    
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
