require "faker"
require_relative "id_store"
require_relative "need"
require_relative "organization"

class Program
  attr_writer :id, :name, :organization

  def initialize(location = "Pennsylvania", need = NEEDS.sample)
    @default_prefix = "#{location} #{need.split(">").last} Support"
  end

  def id
    @id ||= IdStore.instance.id
  end

  def organization
    @organization ||= Organization.new(internal_name("Organization"))
  end

  # def organization=(organization)
  #   @organization = organization
  # end

  def name
    @name ||= internal_name("Program")
  end

  private

  def internal_name(suffix)
    "#{@default_prefix} #{suffix}"
  end
end
