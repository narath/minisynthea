require_relative "patient"

class HealthConfidence 
  attr_writer :patient, :value

  def patient
    @patient ||= Patient.new
  end

  def value
    @value ||= Random.rand(11)
  end
end
