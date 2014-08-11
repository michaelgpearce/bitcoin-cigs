require 'spec_helper'

describe BitcoinCigs do
  def self.use_mainnet
    let(:wallet_key) { "5JFZuDkLgbEXK4CUEiXyyz4fUqzAsQ5QUqufdJy8MoLA9S1RdNX" }
    let(:address) { "11o51X3ciSjoLWFN3sbg3yzCM8RSuD2q9" }
    let(:original_address) { "11o51X3ciSjoLWFN3sbg3yzCM8RSuD2q9" }
    let(:private_key) { ["39678A14ECA8479B3C58DCD25A5C94BE768389E823435C4DDFCAEB13519AB10E"].pack('H*') }
    let(:signature) { "HIBYi2g3yFimzD/YSD9j+PYwtsdCuHR2xwIQ6n0AN6RPUVDGttgOmlnsiwx90ZSjmaWrH1/HwrINJbaP7eMA6V4=" }
    let(:network) { :mainnet }
  end
  
  def self.use_testnet
    let(:wallet_key) { "92FqDytA43K8unrrZgpzMddhmEbMMRNhBJAU59a3MkYfsUgH8st" }
    let(:address) { "mh9nRF1ZSqLJB3hbUjPLmfDHdnGUURdYdK" }
    let(:original_address) { "mh9nRF1ZSqLJB3hbUjPLmfDHdnGUURdYdK" }
    let(:private_key) { ["585C660C887913E5F40B8E34D99C62766443F9D043B1DE1DFDCC94E386BC6DF6"].pack('H*') }
    let(:signature) { "HIZQbBLAGJLhSZ310FCQMAo9l1X2ysxyt0kXkf6KcBN3znl2iClC6V9wz9Nkn6mMDUaq4kRlgYQDUUlsm29Bl0o=" }
    let(:network) { :testnet }
  end
  
  use_mainnet
  let(:message) { "this is a message" }
  
  describe "sign_message!" do
    subject { BitcoinCigs.sign_message!(wallet_key, message, :network => network) }
    
    context "with valid data" do
      it "generates the correct signature" do
        expect(BitcoinCigs.verify_message(address, subject, message, :network => network)).to be_true
      end

      context "with a message > 252 characters" do
        let(:message) { "a" * 253 }

        it "generates the correct signature" do
          expect(BitcoinCigs.verify_message(address, subject, message, :network => network)).to be_true
        end

      end
    end
    
    context "invalid wallet key" do
      let(:wallet_key) { "invalid wallet key" }
      
      it "raises an error" do
        expect { subject }.to raise_error(::BitcoinCigs::Error, "Unknown Wallet Format")
      end
    end
    
    context "with testnet" do
      use_testnet
      
      context "with valid data" do
        it "generates the correct signature" do
          expect(BitcoinCigs.verify_message(address, subject, message, :network => network)).to be_true
        end
      end
    end
  end
  
  describe "sign_message" do
    subject { BitcoinCigs.sign_message(wallet_key, message) }
    
    context "with valid data" do
      it "generates the correct signature" do
        expect(BitcoinCigs.verify_message(address, subject, message)).to be_true
      end
    end
    
    context "invalid wallet key" do
      let(:wallet_key) { "invalid wallet key" }
      
      it "returns nil" do
        expect(subject).to be_nil
      end
    end
  end
  
  describe "convert_wallet_format_to_bytes!" do
    subject { BitcoinCigs.convert_wallet_format_to_bytes!(wallet_key, network) }
    
    context "with wallet import format" do
      let(:wallet_key) { "5JFZuDkLgbEXK4CUEiXyyz4fUqzAsQ5QUqufdJy8MoLA9S1RdNX" }
      
      it "converts to correct bytes" do
        expect(subject).to eq(private_key)
      end
      
      context "with testnet" do
        use_testnet
        
        let(:wallet_key) { "92FqDytA43K8unrrZgpzMddhmEbMMRNhBJAU59a3MkYfsUgH8st" }
        
        it "converts to correct bytes" do
          expect(subject).to eq(private_key)
        end
      end
    end
    
    context "with compressed wallet import format" do
      let(:wallet_key) { "Ky9JDVGHsk6gnh7dDYKkWWsAquDLZSrSdtsTVGJjUoVZN7sYjyyP" }
      
      it "converts to correct bytes" do
        expect(subject).to eq(private_key)
      end

      context "with testnet" do
        use_testnet
        
        let(:wallet_key) { "cQYTrJ4nxRD3v1R3mGnpA4gzvEzcq8akLSknVJpqQbCnZeD6WfNC" }
        
        it "converts to correct bytes" do
          expect(subject).to eq(private_key)
        end
      end
    end
    
    context "with mini format" do
      let(:wallet_key) { "S6c56bnXQiBjk9mqSYE7ykVQ7NzrRy" }
      let(:private_key) { ["4C7A9640C72DC2099F23715D0C8A0D8A35F8906E3CAB61DD3F78B67BF887C9AB"].pack('H*') }
      
      it "converts to correct bytes" do
        expect(subject).to eq(private_key)
      end
    end
    
    context "with hex format" do
      let(:wallet_key) { "39678A14ECA8479B3C58DCD25A5C94BE768389E823435C4DDFCAEB13519AB10E" }
      
      it "converts to correct bytes" do
        expect(subject).to eq(private_key)
      end
    end
    
    context "with base 64 format" do
      let(:wallet_key) { "OWeKFOyoR5s8WNzSWlyUvnaDiegjQ1xN38rrE1GasQ4=" }
      
      it "converts to correct bytes" do
        expect(subject).to eq(private_key)
      end
    end
  end
  
  describe "verify_message!" do
    subject { BitcoinCigs.verify_message!(address, signature, message, :network => network) }
    
    context "with valid data" do
      it "verifies valid message" do
        expect(subject).to be_nil
      end
    end
    
    context "with invalid address" do
      let(:address) { "invalid" }
      
      it "raises ::BitcoinCigs::Error" do
        expect { subject }.to raise_error(::BitcoinCigs::Error, "Incorrect address or message for signature.")
      end
    end
    
    context "with invalid signature" do
      let(:signature) { "invalid" }
      
      it "raises ::BitcoinCigs::Error" do
        expect { subject }.to raise_error(::BitcoinCigs::Error, "Bad signature length")
      end
    end
    
    context "with invalid message" do
      let(:message) { "invalid" }
      
      it "raises ::BitcoinCigs::Error" do
        expect { subject }.to raise_error(::BitcoinCigs::Error, "Incorrect address or message for signature.")
      end
    end
    
    context "with testnet" do
      use_testnet
      
      context "with valid data" do
        it "verifies valid message" do
          expect(subject).to be_nil
        end
      end
    end
  end
  
  describe "verify_message" do
    subject { BitcoinCigs.verify_message(address, signature, message) }
    
    context "with valid data" do
      it "returns true" do
        expect(subject).to be_true
      end
    end
    
    context "with invalid data" do
      let(:address) { "invalid" }
      
      it "returns false" do
        expect(subject).to be_false
      end
    end
  end

  describe "get_signature_address!" do
    subject { BitcoinCigs.get_signature_address!(signature, message, :network => network) }
    
    context "with valid data" do
      it "returns correct address" do
        expect(subject).to eq(address)
      end
    end
    
    context "with invalid signature" do
      let(:signature) { "invalid" }
      
      it "raises ::BitcoinCigs::Error" do
        expect { subject }.to raise_error(::BitcoinCigs::Error, "Bad signature length")
      end
    end
    
    context "with invalid message" do
      let(:message) { "invalid" }
      
      it "returns wrong address" do
        expect(subject).not_to eq(address)
      end
    end
    
    context "with testnet" do
      use_testnet
      
      context "with valid data" do
        it "returns valid address" do
          expect(subject).to eq(address)
        end
      end
    end
  end

  describe "get_signature_address" do
    subject { BitcoinCigs.get_signature_address(signature, message) }
    
    context "with valid data" do
      it "returns true" do
        expect(subject).to eq(address)
      end
    end
  end

    
end
