require_relative "../lib/what_matters_index"

RSpec.describe WhatMattersIndex do
  let(:wmi) { WhatMattersIndex.new }
  it "has confidence" do
    expect(wmi.confidence).not_to be_nil
  end

  it "has pain" do
    expect(wmi.pain).not_to be_nil
  end
  
  it "has emotions" do
    expect(wmi.emotions).not_to be_nil
  end

  it "has meds" do
    expect(wmi.meds).not_to be_nil
  end

  it "has adverse effects" do
    expect(wmi.adverse_effects).not_to be_nil
  end

  it "has a score" do
    expect(wmi.score).not_to be_nil
  end

  context "#score" do
    subject do
      wmi = WhatMattersIndex.new
      wmi.confidence = "Very confident"
      wmi.pain = "No pain"
      wmi.emotions = "Not at all"
      wmi.meds = 0
      wmi.adverse_effects = "No"
      wmi
    end

    it "our subject has a score of 0" do
      expect(subject.score).to eq 0
    end

    it "scores insufficient health confidence" do
      subject.confidence = "Not very confident"
      expect(subject.score).to eq 1

      subject.confidence = "Somewhat confident"
      expect(subject.score).to eq 1
    end

    it "scores extreme pain" do
      subject.pain = "Extreme pain"
      expect(subject.score).to eq 1
    end

    it "scores moderate pain" do
      subject.pain = "Moderate pain"
      expect(subject.score).to eq 1
    end

    it "does not score mild or very mild pain" do
      ["Mild pain", "Very mild pain"].each do |x|
        subject.pain = x
        expect(subject.score).to eq 0
      end
    end

    it "scores extreme emotions" do
      subject.emotions = "Extremely"
      expect(subject.score).to eq 1
    end

    it "scores quite a bit emotions" do
      subject.emotions = "Quite a bit"
      expect(subject.score).to eq 1
    end

    it "does not score a little emotion" do
      subject.emotions = "Somewhat"
      expect(subject.score).to eq 0
    end
    
    it "does not score somewhat emotions" do
      subject.emotions = "A little"
      expect(subject.score).to eq 0
    end

    it "scores more than 5 meds" do 
      subject.meds = 6
      expect(subject.score).to eq 1
    end

    it "does not score 5 or less meds" do
      (0..5).each do |x|
        subject.meds = x
        expect(subject.score).to eq 0
      end
    end

    it "scores yes or maybe for adverse effects" do
      ["Yes", "Maybe"].each do |x|
        subject.adverse_effects = x
        expect(subject.score).to eq 1
      end
    end
  end 
end
