%w(error crypto_helper compact_int base_58 curve_fp point public_key private_key signature ec_key).each do |f|
  require File.join(File.dirname(__FILE__), 'bitcoin_cigs', f)
end

module BitcoinCigs
  PRIVATE_KEY_PREFIX = {
    :mainnet => 0x80,
    :testnet => 0xEF
  }
  NETWORK_VERSION = {
    :mainnet => 0x00,
    :testnet => 0x6F
  }
  
  P = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
  R = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141
  B = 0x0000000000000000000000000000000000000000000000000000000000000007
  A = 0x0000000000000000000000000000000000000000000000000000000000000000
  Gx = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798
  Gy = 0x483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8

  CURVE_SECP256K1 = ::BitcoinCigs::CurveFp.new(P, A, B)
  GENERATOR_SECP256K1 = ::BitcoinCigs::Point.new(CURVE_SECP256K1, Gx, Gy, R)
  
  class << self
    include ::BitcoinCigs::CryptoHelper
    
    def verify_message(address, signature, message, options = {:network => :mainnet})
      begin
        verify_message!(address, signature, message, options)
        true
      rescue ::BitcoinCigs::Error
        false
      end
    end
    
    def verify_message!(address, signature, message, options = {:network => :mainnet})

      decoded_address = decode58(address)
      raise ::BitcoinCigs::Error.new("Incorrect address or message for signature.") if decoded_address.nil?
      # network_version = str_to_num(decoded_address) >> (8 * 24)

      addr = get_signature_address!(signature, message, options)

      raise ::BitcoinCigs::Error.new("Incorrect address or message for signature.") if address != addr
      
      nil
    end

    def get_signature_address(signature, message, options = {:network => :mainnet})
      begin
        get_signature_address!(signature, message, options)
      rescue ::BitcoinCigs::Error
        false
      end 
    end

    def get_signature_address!(signature, message, options = {:network => :mainnet})

      message = calculate_hash(format_message_to_sign(message))

      curve = CURVE_SECP256K1
      g = GENERATOR_SECP256K1
      a, b, p = curve.a, curve.b, curve.p
      
      order = g.order
      
      sig = decode64(signature)
      raise ::BitcoinCigs::Error.new("Bad signature length") if sig.size != 65
      raise ::BitcoinCigs::Error.new("Bad characters in signature") if signature != encode64(sig)
      
      hb = sig[0].ord
      r, s = [sig[1...33], sig[33...65]].collect { |s| str_to_num(s) }
      
      
      raise ::BitcoinCigs::Error.new("Bad signature first byte") if hb < 27 || hb >= 35
      
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
      
      public_key_to_bc_address(public_key.ser(), NETWORK_VERSION[options[:network]])
    end
    
    def sign_message(wallet_key, message, options = {:network => :mainnet})
      begin
        sign_message!(wallet_key, message, options)
      rescue ::BitcoinCigs::Error
        nil
      end
    end
    
    def sign_message!(wallet_key, message, options = {:network => :mainnet})
      private_key = convert_wallet_format_to_bytes!(wallet_key, options[:network])
      
      msg_hash = sha256(sha256(format_message_to_sign(message)))
      
      ec_key = ::BitcoinCigs::EcKey.new(str_to_num(private_key))
      private_key = ec_key.private_key
      public_key = ec_key.public_key
      addr = public_key_to_bc_address(get_pub_key(ec_key, ec_key.public_key.compressed), NETWORK_VERSION[options[:network]])
      
      sig = private_key.sign(msg_hash, random_k)
      raise ::BitcoinCigs::Error.new("Unable to sign message") unless public_key.verify(msg_hash, sig)
      
      4.times do |i|
        hb = 27 + i
        
        sign = "#{hb.chr}#{sig.ser}"
        sign_64 = encode64(sign)
        
        begin
          verify_message!(addr, sign_64, message, options)
          return sign_64
        rescue ::BitcoinCigs::Error
          next
        end
      end
      
      raise ::BitcoinCigs::Error, "Unable to construct recoverable key"
    end
    
    def convert_wallet_format_to_bytes!(input, network)
      bytes = if is_wallet_import_format?(input, network)
        decode_wallet_import_format(input, network)
      elsif is_compressed_wallet_import_format?(input, network)
        decode_compressed_wallet_import_format(input, network)
      elsif is_mini_format?(input)
        sha256(input)
      elsif is_hex_format?(input)
        decode_hex(input)
      elsif is_base_64_format?(input)
        decode64(input)
      else
        raise ::BitcoinCigs::Error.new("Unknown Wallet Format")
      end
      
      bytes
    end
    
    private
    
    def format_message_to_sign(message)
      "\x18Bitcoin Signed Message:\n#{::BitcoinCigs::CompactInt.new(message.size).encode}#{message}"
    end
    
    def random_k
      k = 0
      8.times do |i|
        k |= (rand * 0xffffffff).to_i << (32 * i)
      end
      
      k
    end
        
    def get_pub_key(public_key, compressed)
      i2o_ec_public_key(public_key, compressed)
    end
    
    def i2o_ec_public_key(public_key, compressed)
      key = if compressed
        "#{public_key.public_key.point.y & 1 > 0 ? '03' : '02'}%064x" % public_key.public_key.point.x
      else
        "04%064x%064x" % [public_key.public_key.point.x, public_key.public_key.point.y]
      end

      decode_hex(key)
    end

    def decode_wallet_import_format(input, network)
      bytes = decode58(input)#[1..-1]
      #puts "ASDF #{bytes.unpack('H*')}"
      #puts bytes.bytes.collect {|e| e.to_i}.join(" ")
      hash = bytes[0..32]
      
      checksum = sha256(sha256(hash))
      raise ::BitcoinCigs::Error.new("Wallet checksum invalid") if bytes[33..37] != checksum[0..3]

      version, hash = hash[0], hash[1..-1]
      raise ::BitcoinCigs::Error.new("Wallet Version #{version} not supported") if version.ord != PRIVATE_KEY_PREFIX[network]
      
      hash
    end
    
    def decode_compressed_wallet_import_format(input, network)
      bytes = decode58(input)
      hash = bytes[0...34]
      
      checksum = sha256(sha256(hash))
      raise ::BitcoinCigs::Error.new("Wallet checksum invalid") if bytes[34..37] != checksum[0..3]

      version, hash = hash[0], hash[1..32]
      raise ::BitcoinCigs::Error.new("Wallet Version #{version} not supported") if version.ord != PRIVATE_KEY_PREFIX[network]
      
      hash
    end
    
    # 64 characters [0-9A-F]
    def is_hex_format?(key)
      /^[A-Fa-f0-9]{64}$/ =~ key
    end
    
    # 51 characters base58 starting with 5
    def is_wallet_import_format?(key, network)
      /^#{network == :mainnet ? '5' : '9'}[123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]{50}$/ =~ key
    end
    
    # 52 characters base58 starting with L or K
    def is_compressed_wallet_import_format?(key, network)
      /^[network == :mainnet ? 'LK' : 'c'][123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]{51}$/ =~ key
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
    
    def public_key_to_bc_address(public_key, network_version)
      h160 = hash_160(public_key)
      
      hash_160_to_bc_address(h160, network_version)
    end
    
    def hash_160_to_bc_address(h160, address_type)
      vh160 = address_type.chr + h160
      h = calculate_hash(vh160)
      addr = vh160 + h[0...4]
      
      encode58(addr)
    end
    
    def hash_160(public_key)
      ripemd160(sha256(public_key))
    end
    
  end
end
