require_relative "../lib/health_confidence"

RSpec.describe HealthConfidence do
  it "has a patient" do
    h = HealthConfidence.new
    expect(h.patient).not_to be_nil
  end

  it "has a value" do
    h = HealthConfidence.new
    expect(h.value).is_a? Integer
  end
end

