require_relative "../lib/referral"

RSpec.describe Referral do
  it "can be created" do
    expect(Referral.new).not_to be_nil
  end
end

