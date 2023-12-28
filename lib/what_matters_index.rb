require "faker"
require_relative "patient"

class WhatMattersIndex
  attr_writer :patient, :confidence, :pain, :emotions, :meds, :adverse_effects, :created_at

  def patient
    @patient ||= Patient.new
  end

  def created_at
    @created_at ||= Time.now
  end

  def confidence
    # How confident are you that you can manage and control most of your health problems?
    @confidence ||= ["Not very confident", "Somewhat confident", "Very confident"].sample
  end

  def pain
    # During the past 4 weeks, how much bodily pain have you generally had?
    @pain ||= ["Extreme pain", "Moderate pain", "Mild pain", "Very mild pain", "No pain"].sample
  end

  def emotions
    # During the past four weeks, how much have you been bothered by emotional problems such as feeling anxious, irritable, depressed, or sad?
    @emotions ||= ["Extremely", "Quite a bit", "Somewhat", "A little", "Not at all"].sample
  end

  def meds
    # How many prescription medicines are you taking more than three days a week?
    @meds ||= [3,4,5,6,7,8].sample
  end

  def adverse_effects
    # Do you think any of your pills are making you sick?
    @adverse_effects ||= ["Yes", "Maybe", "No"].sample
  end

  def score
    result = 0
    result += 1 if ["Not very confident","Somewhat confident"].include? confidence
    result += 1 if ["Extreme pain", "Moderate pain"].include? pain
    result +=1 if ["Extremely", "Quite a bit"].include? emotions
    result +=1 if meds>5
    result +=1 if ["Yes", "Maybe"].include? adverse_effects
    result
  end
end
