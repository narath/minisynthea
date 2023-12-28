require "faker"
require_relative "id_store"
require_relative "patient"

class CustomField 
  attr_writer :patient, :created_at
  attr_accessor :name, :value

  def id
    @id ||= IdStore.instance.id
  end

  def patient
    @patient ||= Patient.new
  end

  def created_at
    @created_at ||= Faker::Time.backward(100)
  end

end

