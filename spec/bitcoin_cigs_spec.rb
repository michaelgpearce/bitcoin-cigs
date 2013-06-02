require 'spec_helper'

describe BitcoinCigs do
  describe "verify_message" do
    let(:address) { "13C5HZKutjMDeuc7f5mPj6XGpJCZu7xKh2"}
    let(:signature) { "H55JIuwEi4YXzINOzx2oU6VsfBcTOScpFtp10pP/M4EWV336ClH65SObwPXnRf/fMXDu8hs8nweB42CtpWgngeM=" }
    let(:message) { "aaa" }
    
    subject { BitcoinCigs.verify_message }
    
    context "with valid data" do
      it "verifies valid message" do
        expect(subject).to be_true
      end
    end
  end
end
