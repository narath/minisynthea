require_relative "../lib/program"
require_relative "../lib/organization"

RSpec.describe Program do
  it "can be part of an existing organization" do
    org = Organization.new
    p1 = Program.new
    p1.organization = org
    expect(p1.organization).to eq(org)
  end
end

