require 'spec_helper'

describe BitcoinCigs do
  let(:wallet_key) { "5JFZuDkLgbEXK4CUEiXyyz4fUqzAsQ5QUqufdJy8MoLA9S1RdNX" }
  let(:address) { "11o51X3ciSjoLWFN3sbg3yzCM8RSuD2q9" }
  let(:original_address) { "11o51X3ciSjoLWFN3sbg3yzCM8RSuD2q9" }
  let(:private_key) { ["39678A14ECA8479B3C58DCD25A5C94BE768389E823435C4DDFCAEB13519AB10E"].pack('H*') }
  let(:signature) { "HIBYi2g3yFimzD/YSD9j+PYwtsdCuHR2xwIQ6n0AN6RPUVDGttgOmlnsiwx90ZSjmaWrH1/HwrINJbaP7eMA6V4=" }
  
  let(:message) { "this is a message" }
  
  describe "sign_message!" do
    subject { BitcoinCigs.sign_message!(wallet_key, message) }
    
    context "with valid data" do
      it "generates the correct signature" do
        expect(BitcoinCigs.verify_message(address, subject, message)).to be_true
      end
    end
    
    context "invalid wallet key" do
      let(:wallet_key) { "invalid wallet key" }
      
      it "raises an error" do
        expect { subject }.to raise_error(::BitcoinCigs::Error, "Unknown Wallet Format")
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
    subject { BitcoinCigs.convert_wallet_format_to_bytes!(wallet_key) }
    
    context "with wallet import format" do
      let(:wallet_key) { "5JFZuDkLgbEXK4CUEiXyyz4fUqzAsQ5QUqufdJy8MoLA9S1RdNX" }
      
      it "converts to correct bytes" do
        expect(subject).to eq(private_key)
      end
    end
    
    context "with compressed wallet import format" do
      let(:wallet_key) { "Ky9JDVGHsk6gnh7dDYKkWWsAquDLZSrSdtsTVGJjUoVZN7sYjyyP" }
      
      it "converts to correct bytes" do
        expect(subject).to eq(private_key)
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
    subject { BitcoinCigs.verify_message!(address, signature, message) }
    
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
  end
  
  describe "verify_message!" do
    subject { BitcoinCigs.verify_message(address, signature, message) }
    
    context "with valid data" do
      it "verifies valid message" do
        expect(subject).to be_true
      end
    end
    
    context "with invalid data" do
      let(:address) { "invalid" }
      
      it "raises ::BitcoinCigs::Error" do
        expect(subject).to be_false
      end
    end
  end
    
end
