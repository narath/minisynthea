require "csv"
require_relative "../need"
require_relative "../organization"
require_relative "../patient"
require_relative "../person"
require_relative "../program"
require_relative "../referral"

module Generator
  class SDOH
  attr_reader :healthcare_orgs, :contacts, :social_service_orgs, :programs, :patients, :referrals

  def initialize(patients: 100, healthcare_orgs: 2, social_service_orgs: 3, programs_per_social_service_org: 5, referrals_per_patient: 2, care_coordinators_per_healthcare_org: 4)
    # build a program
    @healthcare_orgs = []
    @contacts = []
    @programs = []
    @patients = []
    @referrals = []
    @social_service_orgs = []

    # ["Family Health care", "Southwest Behavioral Health Center", "Southwest Utah Public Health Department", "Washington County", "Intermountain Healthcare", "Select Health", "Weber Human Services", "Weber County", "Intermountain Healthcare", "Select Health", "Midtown Community Health Center", "Odgen CAN", "Utah Head Start","Logisticare","Utah Association of Family Support","YServe"].sample
    healthcare_orgs.times do 
      org = HealthcareOrganization.new
      @healthcare_orgs << org

      # create the contacts
      care_coordinators_per_healthcare_org.times do
        person = Person.new
        person.organization = org
        @contacts << person
      end
    end

    social_service_orgs.times do
      org = SocialServicesOrganization.new
      @social_service_orgs << org

      programs_per_social_service_org.times do
        program = Program.new
        program.organization = org
        @programs << program
      end
    end

    patients.times do
      patient = Patient.new
      @patients << patient

      referrals_per_patient.times do
        referral = Referral.new
        referral.patient = patient
        referral.program = @programs.sample
        referral.created_by = @contacts.sample
        @referrals << referral
      end
    end
  end

  # export these to csv delimited files
  def export(dir = Dir.pwd)
    raise RuntimeError.new("The directory #{dir} does not exist!") unless Dir.exist?(dir)
    File.open(File.join(dir,"patients.csv"),"w") { |file| file << export_patients }
    File.open(File.join(dir,"referrals.csv"),"w") { |file| file << export_referrals }
    File.open(File.join(dir,"programs.csv"),"w") { |file| file << export_programs }
    File.open(File.join(dir,"contacts.csv"),"w") { |file| file << export_contacts }
  end

  def export_patients
    CSV.generate do |csv|
      csv << %w(id name dob mrn plan_state created_at updated_at gender language zip_code housing_status emotional_support behavioural_health_issues waiver_program_participant)
			@patients.each do |p|
				csv << [p.id, p.name, p.dob, p.mrn, p.plan_state, p.created_at, p.updated_at, p.gender, p.language, p.zip_code, p.housing_status, p.emotional_support, p.behavioural_health_issues, p.waiver_program_participant]
			end
		end
  end

  def export_referrals
    CSV.generate do |csv|
      csv << %w(id patient_id need program_id status created_at created_by updated_at updated_by accepted_at declined_at withdrawn_at)
			@referrals.each do |r|
				csv << [r.id, r.patient.id, r.need, r.program.id, r.status, r.created_at, r.created_by.id, r.updated_at, r.updated_by.id, r.accepted_at, r.declined_at, r.withdrawn_at]
			end
		end
  end

  def export_programs
    CSV.generate do |csv|
      csv << %w(id name organization)
			@programs.each do |p|
				csv << [p.id, p.name, p.organization.name]
			end
		end
  end
  
  def export_contacts
    CSV.generate do |csv|
      csv << %w(id name role organization)
			@contacts.each do |c|
        csv << [c.id, c.name, c.role, c.organization.name]
			end
		end
  end
  end
end

