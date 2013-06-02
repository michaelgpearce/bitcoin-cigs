require 'spec_helper'
require 'base64'

describe BitcoinCigs::Base58 do
  describe "decode" do
    let(:base_58_encoded_data) { "13C5HZKutjMDeuc7f5mPj6XGpJCZu7xKh2" }
    
    subject { BitcoinCigs::Base58.decode(base_58_encoded_data) }
    
    context "with valid data" do
      it "decodes properly" do
        expect(Base64.encode64(subject).strip).to eq("ABgIZ4vqJRDJAqbMPNKKwHNFFgMWIJM1kQ==")
      end
    end
  end
  
  describe "encode" do
    let(:data) { Base64.decode64("ABgIZ4vqJRDJAqbMPNKKwHNFFgMWIJM1kQ==") }
    
    subject { BitcoinCigs::Base58.encode(data) }
    
    context "with valid data" do
      it "encodes properly" do
        expect(subject).to eq("13C5HZKutjMDeuc7f5mPj6XGpJCZu7xKh2")
      end
    end
  end
end
