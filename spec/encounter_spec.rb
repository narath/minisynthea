require_relative "../lib/encounter"

RSpec.describe Encounter do
  it "can be created" do
    expect(Encounter.new).not_to be_nil
  end
  it "has a type"  do
    e = Encounter.new
    e.type = "ED"
    expect(e.type).to eq "ED"
  end
end

