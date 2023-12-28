require "faker"
require_relative "id_store"
require_relative "zipcodes"

class Patient
  attr_writer :housing_status

  def id
    @id ||= IdStore.instance.id
  end

  def name
    @name ||= Faker::Name.unique.name
  end

  def dob
    @dob ||= Faker::Date.birthday(18,99)
  end

  def mrn
    @mrn ||= 1000 + id
  end

  def plan_state
    "active"
  end

  def created_at
    @created_at ||= Faker::Time.backward(100)
  end

  def updated_at
    @updated_at ||= Faker::Time.between(@created_at, Date.today)
  end

  def gender
    @gender ||= Faker::Gender.binary_type
  end

  def language
    @language ||= %w(English Spanish Chinese).sample
  end

  def zip_code
    # @zip_code ||= Faker::Address.zip_code
    @zip_code ||= Zipcodes::Pennsylvania.sample
  end

  def housing_status
    @housing_status ||= ["Housed","At risk", "Homeless"].sample
  end

  def emotional_support
    @emotional_support ||= ["None", "Family", "Friends", "Spouse", "Children"].sample
  end

  def behavioural_health_issues
    @behavioural_health_issues ||= ["None", "None", "None", "None","Schizophrenia", "Depression", "Anxiety"].sample
  end

  def waiver_program_participant
    @waiver_program_participant ||= Faker::Boolean.boolean(0.6)
  end
end
