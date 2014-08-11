require 'spec_helper'

describe BitcoinCigs::CompactInt do
  describe "decode" do
    subject do
      BitcoinCigs::CompactInt.new(value).encode
    end

    context "with a value <= 252" do
      let(:value) { 252 }
      
      it "should encode to a single byte" do
        expect(subject).to eq("\xFC")
      end
    end

    context "with a value > 252" do
      let(:value) { 253 }
      
      it "should encode to a three bytes" do
        expect(subject).to eq("\xFD\xFD\x00")
      end
    end
  end
end
