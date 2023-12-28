require "faker"
require_relative "person"

class Outreach
  attr_writer :creator, :created_at, :patient, :outreached_at, :unable_to_reach, :minutes_spent, :tags

  def id
    @id ||= IdStore.instance.id
  end

  def creator
    @creator ||= Person.new
  end

  def patient
    @patient ||= Patient.new
  end

  def created_at
    @created_at ||= Faker::Time.backward(100)
  end

  alias_method :updated_at, :created_at
  alias_method :outreached_at, :created_at

  def tags
    @tags ||= ["Email", "Phone call", "Meeting"].sample
  end

  def unable_to_reach
    @unable_to_reach ||= Faker::Boolean.boolean
  end
  
  def minutes_spent
    @minutes_spent = Random.rand(15)
  end
end
