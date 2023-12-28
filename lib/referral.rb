require "faker"

require_relative "patient"
require_relative "organization"
require_relative "need"
require_relative "id_store"
require_relative "program"

class Referral
  attr_writer :id, :patient, :need, :program, :status, :created_at, :created_by, :updated_at, :updated_by, :accepted_at, :declined_at, :withdrawn_at

  def id
    @id ||= IdStore.instance.id
  end

  def patient
    @patient ||= Patient.new
  end

  def need
    @need ||= NEEDS.sample
  end

  def program
    @program ||= Program.new
  end

  def status
    @status ||= ["Pending", "Pending", "Pending", "Pending", "Accepted", "Accepted", "Declined", "Withdrawn"].sample
  end

  def created_at
    @created_at ||= Faker::Time.backward(100)
  end

  def created_by
    @created_by ||= Person.new
  end

  def updated_at
    @updated_at ||= Faker::Time.between(created_at,Time.now)
  end

  def updated_by
    created_by
  end

  def accepted_at
    @accepted_at ||= Faker::Time.between(created_at,Time.now) if @status=="Accepted"
  end

  def declined_at
    @declined_at ||= Faker::Time.between(created_at,Time.now) if @status=="Declined"
  end

  def withdrawn_at
    @withdrawn_at ||= Faker::Time.between(created_at,Time.now) if @status=="Withdrawn"
  end
end
