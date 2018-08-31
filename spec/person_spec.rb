require_relative "../lib/person"

RSpec.describe Person do
  it "has a name" do
    expect(Person.new.name).not_to be_nil
  end

  it "has a role" do
    expect(Person.new.role).not_to be_nil
  end
end
