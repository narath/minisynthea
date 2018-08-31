require_relative "../lib/organization"

RSpec.describe Organization do
  it "has a name" do
    expect(Organization.new.name).not_to be_nil
  end

  it "can have a name that is preset" do
    expect(Organization.new("hello world").name).to eq("hello world")
  end
end

