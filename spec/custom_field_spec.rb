require_relative "../lib/custom_field"

RSpec.describe CustomField do
  it "can be created" do
    expect(CustomField.new).not_to be_nil
  end

  it "has a name and value" do
    c = CustomField.new
    c.name = "hello"
    expect(c.name).to eq "hello"
    
    c.value = "world"
    expect(c.value).to eq "world"
  end

end

