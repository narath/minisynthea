require "tmpdir"
require "pry"

require_relative "../../lib/generators/caremanagement"

RSpec.describe Generator::CareManagement do
  it "can generate orgs, patients" do
    g = Generator::CareManagement.new(patients:100, healthcare_orgs:2, care_coordinators_per_healthcare_org: 2)
    expect(g.patients.count).to eq(100) 
    expect(g.contacts.count).to eq(4)
    expect(g.healthcare_orgs.count).to eq(2)
  end

  it "can export patients" do
    g = Generator::CareManagement.new
    str = g.export_patients
    expect(str).to match /#{g.patients.first.name}/
    expect(str).to match /#{g.patients.last.name}/
  end

  it "can export contacts" do
    g = Generator::CareManagement.new
    str = g.export_contacts
    expect(str).to match /#{g.contacts.first.name}/
    expect(str).to match /#{g.contacts.last.name}/
  end

  it "can export all files" do
    Dir.mktmpdir do |dir|
      g = Generator::CareManagement.new
      g.export(dir)
      expect(File.exist?(File.join(dir,"patients.csv"))).to be true
      expect(File.exist?(File.join(dir,"contacts.csv"))).to be true
      expect(File.exist?(File.join(dir,"custom_fields.csv"))).to be true
      expect(File.exist?(File.join(dir,"encounters.csv"))).to be true
      expect(File.exist?(File.join(dir,"outreaches.csv"))).to be true
    end
  end

  it "travels_on_a_health_journey" do
    g = Generator::CareManagement.new
    r = g.travels_on_a_health_journey(g.patients.first)
    expect(r.to_s).to match /well/
  end

  it "has health confidence measures" do
    g = Generator::CareManagement.new
    expect(g.health_confidences.count).to be > 0
  end

  it "has what matters" do
    g = Generator::CareManagement.new
    expect(g.whatmattersindex.count).to be > 2
  end
end

