require 'spec_helper'
require 'base64'

describe BitcoinCigs::Base58 do
  describe "decode" do
    let(:base_58_encoded_data) { "13C5HZKutjMDeuc7f5mPj6XGpJCZu7xKh2" }
    
    subject { BitcoinCigs::Base58.decode(base_58_encoded_data) }
    
    context "with valid data" do
      it "decodes properly" do
        expect(subject.unpack('H*').first).to eq("001808678bea2510c902a6cc3cd28ac0734516031620933591")
      end
    end
  end
  
  describe "encode" do
    let(:data) { ["001808678bea2510c902a6cc3cd28ac0734516031620933591"].pack('H*') }
    
    subject { BitcoinCigs::Base58.encode(data) }
    
    context "with valid data" do
      it "encodes properly" do
        expect(subject).to eq("13C5HZKutjMDeuc7f5mPj6XGpJCZu7xKh2")
      end
    end
  end
end
