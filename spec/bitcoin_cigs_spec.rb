require 'spec_helper'

describe BitcoinCigs do
  let(:address) { "13C5HZKutjMDeuc7f5mPj6XGpJCZu7xKh2"}
  let(:signature) { "H55JIuwEi4YXzINOzx2oU6VsfBcTOScpFtp10pP/M4EWV336ClH65SObwPXnRf/fMXDu8hs8nweB42CtpWgngeM=" }
  let(:message) { "aaa" }
  
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
        expect { subject }.to raise_error(::BitcoinCigs::Error, "Bad address. Signing: 13C5HZKutjMDeuc7f5mPj6XGpJCZu7xKh2, Received: invalid")
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
        expect { subject }.to raise_error(::BitcoinCigs::Error, "Bad address. Signing: 1887raouuBL3BJHMxgsGBZAWGqTjBEJP2p, Received: 13C5HZKutjMDeuc7f5mPj6XGpJCZu7xKh2")
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
