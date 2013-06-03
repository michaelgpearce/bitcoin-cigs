require 'spec_helper'

describe BitcoinCigs do
  let(:address) { "11o51X3ciSjoLWFN3sbg3yzCM8RSuD2q9" }
  let(:original_address) { "11o51X3ciSjoLWFN3sbg3yzCM8RSuD2q9" }
  let(:signature) { "HIBYi2g3yFimzD/YSD9j+PYwtsdCuHR2xwIQ6n0AN6RPUVDGttgOmlnsiwx90ZSjmaWrH1/HwrINJbaP7eMA6V4=" }
  let(:message) { "this is a message" }
  
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
        # TODO: improve message
        expect { subject }.to raise_error(::BitcoinCigs::Error, "Bad address. Signing: #{original_address}, Received: #{address}")
      end
    end
    
    context "with invalid signature" do
      let(:signature) { "invalid" }
      
      it "raises ::BitcoinCigs::Error" do
        expect { subject }.to raise_error(::BitcoinCigs::Error, "Bad signature")
      end
    end
    
    context "with invalid message" do
      let(:message) { "invalid" }
      
      it "raises ::BitcoinCigs::Error" do
        # TODO: wrong message, also occurs in python version
        expect { subject }.to raise_error(::BitcoinCigs::Error, "Bad address. Signing: 1Es3JV8zYTMtbg7rPMizYZYPc8rcvsJ21m, Received: #{address}")
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
