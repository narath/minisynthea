require "csv"
require_relative "../custom_field"
require_relative "../encounter"
require_relative "../need"
require_relative "../organization"
require_relative "../outreach"
require_relative "../patient"
require_relative "../person"

module Generator
  class CareManagement
  attr_reader :healthcare_orgs, :contacts, :social_service_orgs, :programs, :patients, :referrals, :outreaches, :custom_fields, :encounters

  def initialize(patients: 100, healthcare_orgs: 2, social_service_orgs: 3, programs_per_social_service_org: 5, referrals_per_patient: 2, care_coordinators_per_healthcare_org: 4)
    # build a program
    @healthcare_orgs = []
    @contacts = []
    @programs = []
    @patients = []
    @referrals = []
    @social_service_orgs = []
    @outreaches = []
    @custom_fields = []
    @encounters = []

    # care coordinators in healthcare orgnizations
    # working for patients
    # within specific programs <- have status within them
    # have particular journeys
    # chf, dm, cad, stroke, hip fracture
    # satisfaction, health confidence
    # encounters pcp, ed, hospitalization
    # costs
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

    patients.times do
      patient = Patient.new
      @patients << patient
      travels_on_a_health_journey patient
    end
  end

  def travels_on_a_health_journey(patient)
    days = 30
    start_date = Date.today.prev_day(days)
    states = {
      well: [ [0.8, :well], [0.2, :sick] ],
      sick: [ [0.4, :well], [0.4, :sick], [0.2, :ed] ],
      ed: [ [0.7, :hospitalized], [0.2, :sick], [0.1, :well] ],
      hospitalized: [ [0.8, :hospitalized], [0.2, :discharged] ],
      discharged: [ [0.3, :readmitted], [0.3, :sick], [0.4, :well] ],
      readmitted: [ [0.9, :hospitalized] , [0.1, :discharged] ]
    }

    managed_states = {
      well: [ [0.8, :well], [0.2, :sick] ],
      sick: [ [0.45, :well], [0.4, :sick], [0.15, :ed] ],
      ed: [ [0.6, :hospitalized], [0.25, :sick], [0.15, :well] ],
      hospitalized: [ [0.7, :hospitalized], [0.3, :discharged] ],
      discharged: [ [0.2, :readmitted], [0.35, :sick], [0.45, :well] ],
      readmitted: [ [0.9, :hospitalized] , [0.1, :discharged] ]
    }
  
    # can we reach this patient and will they enroll
    @prob_calling_this_unenrolled_patient_each_day = 0.1
    @prob_patient_is_reachable = 0.7
    @prob_patient_enrolls = 0.6
    enrollment_complete = false
    number_of_tries = 0
    stop_after_x_tries = 3

    care_coordinator = @contacts.sample

    result = []
    state = :well
    current_date = start_date
    last_state_started_at = current_date
    days.times do |m|
      if !enrollment_complete and (number_of_tries<stop_after_x_tries)
        if (Random.rand < @prob_calling_this_unenrolled_patient_each_day)
          number_of_tries += 1
          enrollment_status = try_to_enroll(patient, care_coordinator, current_date)
          states = managed_states if enrollment_status=="enrolled"
          enrollment_complete = ["enrolled", "declined"].include? enrollment_status
        end
      end
      result << state
      transitions = states[state]
      if transitions
        prob_offset = 0
        choice = Random.rand
        next_state = transitions.detect do |prob, move_to_state| 
          if choice<(prob+prob_offset) 
            move_to_state
          else
            prob_offset += prob
            nil
          end
        end
        if next_state
          next_state = next_state[1]
          if next_state!=state
            # transitioning to new state
            case state
              when :hospitalized
                e = Encounter.new
                e.patient = patient
                e.type = "hospitalized"
                e.start = last_state_started_at
                e.stop = current_date
                @encounters << e
              when :ed
                e = Encounter.new
                e.patient = patient
                e.type = "ed"
                e.start = last_state_started_at
                e.stop = current_date
                @encounters << e
             end
          last_state_started_at = current_date
          end

          state = next_state
        else
          $stderr.puts "Could not find next state transition for #{state} in transition #{transitions.inspect}"
        end
      else
        $stderr.puts "Unknown state #{state}"
        break
      end
      current_date = current_date.next_day
    end
    result
  end

  def try_to_enroll(patient, care_coordinator, current_date)
    outreach = Outreach.new
    outreach.patient = patient
    outreach.creator = care_coordinator
    outreach.created_at = current_date
    able_to_reach = Random.rand<@prob_patient_is_reachable
    outreach.unable_to_reach = !able_to_reach
    @outreaches << outreach

    result = "unable to reach"
    if able_to_reach
      cf = CustomField.new
      cf.patient = patient
      cf.created_at = current_date
      cf.name = "enrollment"

      cf.value = (Random.rand<@prob_patient_enrolls ? "enrolled" : "declined")
      @custom_fields << cf
      result = cf.value
    end
    result
  end

  # export these to csv delimited files
  def export(dir = Dir.pwd)
    raise RuntimeError.new("The directory #{dir} does not exist!") unless Dir.exist?(dir)
    File.open(File.join(dir,"patients.csv"),"w") { |file| file << export_patients }
    File.open(File.join(dir,"referrals.csv"),"w") { |file| file << export_referrals }
    File.open(File.join(dir,"programs.csv"),"w") { |file| file << export_programs }
    File.open(File.join(dir,"contacts.csv"),"w") { |file| file << export_contacts }
    File.open(File.join(dir,"custom_fields.csv"),"w") { |file| file << export_custom_fields }
    File.open(File.join(dir,"encounters.csv"),"w") { |file| file << export_encounters }
    File.open(File.join(dir,"outreaches.csv"),"w") { |file| file << export_outreaches }
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

  def export_custom_fields
    CSV.generate do |csv|
      csv << %w(id patient_id name value created_at)
			@custom_fields.each do |c|
        csv << [c.id, c.patient.id, c.name, c.value, c.created_at]
			end
		end
  end

  def export_encounters
    CSV.generate do |csv|
      csv << %w(id patient_id type start stop)
			@encounters.each do |c|
        csv << [c.id, c.patient.id, c.type, c.start, c.stop]
			end
		end
  end

  def export_outreaches
    CSV.generate do |csv|
      csv << %w(id patient_id created_by created_at tags unable_to_reach minutes_spent)
			@outreaches.each do |c|
        csv << [c.id, c.patient.id, c.creator.id, c.created_at, c.tags, c.unable_to_reach, c.minutes_spent]
			end
		end
  end
  end
end

