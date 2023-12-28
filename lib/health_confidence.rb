require_relative "patient"

class HealthConfidence 
  attr_writer :patient, :value, :created_at

  def patient
    @patient ||= Patient.new
  end

  def value
    @value ||= Random.rand(11)
  end
  
  def created_at
    @created_at ||= Time.now
  end
end
