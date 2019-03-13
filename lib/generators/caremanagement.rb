require "csv"
require_relative "../custom_field"
require_relative "../encounter"
require_relative "../health_confidence"
require_relative "../need"
require_relative "../organization"
require_relative "../outreach"
require_relative "../patient"
require_relative "../person"
require_relative "../what_matters_index"

module Generator
  class CareManagement
  attr_reader :healthcare_orgs, :contacts, :social_service_orgs, :programs, :patients, :referrals, :outreaches, :custom_fields, :encounters, :health_confidences, :whatmattersindex

  def initialize(patients: 100, healthcare_orgs: 2, social_service_orgs: 3, programs_per_social_service_org: 5, referrals_per_patient: 2, care_coordinators_per_healthcare_org: 4, days: 365)
    # set params
    @days = days

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
    @health_confidences = []
    @whatmattersindex = []

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

      travels_on_a_health_journey patient
    end
  end

  def log(msg)
    $stderr.puts msg
  end

  def travels_on_a_health_journey(patient)
    start_date = Date.today.prev_day(@days)
    default_states = {
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
  
    homeless_states = {
      well: [ [0.5, :well], [0.5, :sick] ],
      sick: [ [0.3, :well], [0.4, :sick], [0.3, :ed] ],
      ed: [ [0.8, :hospitalized], [0.2, :sick] ],
      hospitalized: [ [0.9, :hospitalized], [0.1, :discharged] ],
      discharged: [ [0.5, :readmitted], [0.4, :sick], [0.1, :well] ],
      readmitted: [ [0.9, :hospitalized] , [0.1, :discharged] ]
    }

    managed_homeless_states = {
      well: [ [0.6, :well], [0.4, :sick] ],
      sick: [ [0.4, :well], [0.4, :sick], [0.2, :ed] ],
      ed: [ [0.7, :hospitalized], [0.2, :sick], [0.1, :well] ],
      hospitalized: [ [0.8, :hospitalized], [0.2, :discharged] ],
      discharged: [ [0.4, :readmitted], [0.4, :sick], [0.2, :well] ],
      readmitted: [ [0.8, :hospitalized] , [0.2, :discharged] ]
    }

    food_insecurity_states = {
      well: [ [0.6, :well], [0.4, :sick] ],
      sick: [ [0.2, :well], [0.55, :sick], [0.25, :ed] ],
      ed: [ [0.7, :hospitalized], [0.2, :sick], [0.1, :well] ],
      hospitalized: [ [0.8, :hospitalized], [0.2, :discharged] ],
      discharged: [ [0.3, :readmitted], [0.3, :sick], [0.4, :well] ],
      readmitted: [ [0.9, :hospitalized] , [0.1, :discharged] ]
    }

    managed_food_insecurity_states = {
      well: [ [0.7, :well], [0.3, :sick] ],
      sick: [ [0.25, :well], [0.55, :sick], [0.2, :ed] ],
      ed: [ [0.7, :hospitalized], [0.2, :sick], [0.1, :well] ],
      hospitalized: [ [0.8, :hospitalized], [0.2, :discharged] ],
      discharged: [ [0.3, :readmitted], [0.3, :sick], [0.4, :well] ],
      readmitted: [ [0.8, :hospitalized] , [0.2, :discharged] ]
    }

    @homelessness_rate = 0.10
    @prob_of_getting_housed_per_day = 365/100/180
    @prob_of_getting_housed_per_day_managed = 365/100/100

    @food_insecurity_rate = 0.20
    @prob_of_getting_food_support_per_day = 365/100/30
    @prob_of_getting_food_support_per_day_managed = 365/100/5

    # can we reach this patient and will they enroll
    @prob_calling_this_unenrolled_patient_each_day = 0.1
    @prob_patient_is_reachable = 0.2
    @prob_patient_enrolls = 0.65
    enrollment_complete = false
    number_of_tries = 0
    stop_after_x_tries = 3

    care_coordinator = @contacts.sample

    result = []
    state = :well
    current_date = start_date
    last_state_started_at = current_date
    is_enrolled = false
    is_homeless = Random.rand < @homelessness_rate
    is_food_insecure = Random.rand < @food_insecurity_rate
    at_risk_for_food_insecurity = is_food_insecure

    if is_homeless
      states = homeless_states
      add_custom_field(patient, "homeless", "true", current_date)
    elsif is_food_insecure
      states = food_insecurity_states
      add_custom_field(patient, "food_insecure", "true", current_date)
    else
      states = default_states
    end

    @days.times do |m|
      if !enrollment_complete and (number_of_tries<stop_after_x_tries)
        if (Random.rand < @prob_calling_this_unenrolled_patient_each_day)
          number_of_tries += 1
          enrollment_status = try_to_enroll(patient, care_coordinator, current_date)
          if is_enrolled = (enrollment_status=="enrolled")
            # on_enrollment
            if is_homeless
              states = managed_homeless_states
            elsif is_food_insecure
              states = managed_food_insecurity_states
            else
              states = managed_states
            end
          end
          enrollment_complete = ["enrolled", "declined"].include? enrollment_status
        end
      end
      result << state
      if is_enrolled
        hc = HealthConfidence.new
        hc.patient = patient
        hc.value = health_confidence_for_state(state)
        hc.created_at = current_date
        @health_confidences << hc

        if (m % 30)==0
          wmi = WhatMattersIndex.new
          wmi.patient = patient
          wmi.confidence = hc.value
          wmi.pain = pain_for_state(state)
          wmi.emotions  = emotions_for_state(state)
          wmi.meds = [4,5,6,7,8].sample
          wmi.adverse_effects = adverse_effects(wmi.meds,state)
          wmi.created_at = current_date
          @whatmattersindex << wmi
        end
      end

      # if the patient is homeless, have they found housing
      if is_homeless
        if is_enrolled
          if (Random.rand < @prob_of_getting_housed_per_day_managed)
            add_custom_field(patient, "homeless", "false", current_date)
            is_homeless = false
            if is_food_insecure
              states = managed_food_insecurity_states
            else
              states = managed_states
            end
          end
        else
          if (Random.rand < @prob_of_getting_housed_per_day)
            is_homeless = false
            add_custom_field(patient, "homeless", "false", current_date)
            if is_food_insecure
              states = food_insecurity_states
            else
              states = default_states
            end
          end
        end
      end

      # if at risk for food insecurity then they can become food insecure
      if !is_food_insecure && at_risk_for_food_insecurity
        is_food_insecure = (Random.rand < @food_insecurity_rate)
        add_custom_field(patient, "food_insecure", "true", current_date) if is_food_insecure
      end

      # if the patient is food insecure, do they have food access
      if is_food_insecure
        if is_enrolled
          if (Random.rand < @prob_of_getting_food_support_per_day_managed)
            is_food_insecure = false
            add_custom_field(patient, "food_insecure", "false", current_date)
            states = managed_states
          end
        else
          if (Random.rand < @prob_of_getting_food_support_per_day)
            is_food_insecure = false
            add_custom_field(patient, "food_insecure", "false", current_date)
            states = default_states
          end
        end
      end

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
    if is_homeless
      patient.housing_status = "Homeless" 
    else
      patient.housing_status = "Housed"
    end
    result
  end

  def health_confidence_for_state(state)
    case state
    when :well
      [5,6,7,8,9,10].sample
    when :sick
      [0,1,2,3,4,5].sample
    when :ed
      [0,1,2].sample
    when :hospitalized
      [0,1,2,3,4,5].sample
    else
      Random.rand(11)
    end
  end

  def pain_for_state(state)
    case state
    when :well
      ["Moderate pain","Mild pain", "Very mild pain", "No pain"].sample
    when :sick
      ["Extreme pain", "Moderate pain", "Mild pain"].sample
    when
      WhatMattersIndex.new.pain
    end
  end

  def emotions_for_state(state)
    case state
    when :well
      ["Somewhat", "A little", "Not at all"].sample
    when :sick
      ["Extremely","Quite a bit", "Somewhat"].sample
    else
      WhatMattersIndex.new.emotions
    end
  end

  def adverse_effects(meds, state)
    WhatMattersIndex.new.adverse_effects
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

  def add_custom_field(patient, name, value, current_date)
      cf = CustomField.new
      cf.patient = patient
      cf.created_at = current_date
      cf.name = name
      cf.value = value
      @custom_fields << cf
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
    File.open(File.join(dir,"assessments.csv"),"w") { |file| file << export_assessments }
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

  def export_assessments
    CSV.generate do |csv|
      csv << %w(id patient_id assessment name value created_at)
			@health_confidences.each do |c|
        csv << [IdStore.instance.id, c.patient.id, "HealthConfidence", "health_confidence", c.value, c.created_at]
			end
      @whatmattersindex.each do |c|
        csv << [IdStore.instance.id, c.patient.id, "What Matters Index", "confidence", c.confidence, c.created_at]
        csv << [IdStore.instance.id, c.patient.id, "What Matters Index", "pain", c.pain, c.created_at]
        csv << [IdStore.instance.id, c.patient.id, "What Matters Index", "emotions", c.emotions, c.created_at]
        csv << [IdStore.instance.id, c.patient.id, "What Matters Index", "meds", c.meds, c.created_at]
        csv << [IdStore.instance.id, c.patient.id, "What Matters Index", "adverse_effects", c.adverse_effects, c.created_at]
        csv << [IdStore.instance.id, c.patient.id, "What Matters Index", "score", c.score, c.created_at]
      end
		end
  end

  end
end

