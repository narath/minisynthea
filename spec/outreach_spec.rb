require_relative "../lib/outreach"

RSpec.describe Outreach do
  it "can be created" do
    expect(Outreach.new).not_to be_nil
  end

  it "has a creator" do
    expect(Outreach.new.creator).not_to be_nil
  end

  it "can set a creator" do
    o = Outreach.new
    p = Person.new
    o.creator = p
    expect(o.creator).to be p
  end
end
