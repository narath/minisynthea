require "faker"
require_relative "id_store"
require_relative "patient"

class Encounter
  attr_writer :patient, :type, :start, :stop

  def id
    @id ||= IdStore.instance.id
  end

  def patient
    @patient ||= Patient.new
  end

  def type
    @type ||= ["ED", "Hospital", "PCP", "Specialist"]
  end

  def start
    @start ||= Faker::Time.backwards(100)
  end

  def stop
    @stop ||= Faker::Time.between(start, Time.now)
  end
end


