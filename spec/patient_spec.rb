require_relative "../lib/patient"

RSpec.describe "Patient" do
  it "can create a new patient" do
    expect(Patient.new).not_to be_nil
  end

end

