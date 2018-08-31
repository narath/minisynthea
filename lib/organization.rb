require "faker"

class Organization
  def initialize(name=nil)
    @name = name if name
  end

  def name
    @name ||= new_org_name
  end

  def new_org_name
    Faker::Company.name 
  end
end


class HealthcareOrganization < Organization

  def new_org_name
   "#{super} Healthcare"
  end 

end

class SocialServicesOrganization < Organization
  def new_org_name
    "#{super} Social Services"
  end
end
