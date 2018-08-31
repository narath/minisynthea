require "faker"
require_relative "id_store"
require_relative "organization"

class Person
  attr_writer :id, :name, :role, :organization

  def id
    @id ||= IdStore.instance.id
  end

  def name
    @name ||= Faker::Name.unique.name
  end

  def role
    @role ||= "Care coordinator"
  end

  def organization
    @organization ||= Organization.new
  end
end

