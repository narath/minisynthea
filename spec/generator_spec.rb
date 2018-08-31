require "tmpdir"
require "pry"

require_relative "../lib/generator"

RSpec.describe Generator do
  it "can generate orgs, patients and referrals" do
    g = Generator.new(patients:100, healthcare_orgs:2, care_coordinators_per_healthcare_org: 2)
    expect(g.patients.count).to eq(100) 
    expect(g.contacts.count).to eq(4)
    expect(g.healthcare_orgs.count).to eq(2)
  end

  it "can export patients" do
    g = Generator.new
    str = g.export_patients
    expect(str).to match /#{g.patients.first.name}/
    expect(str).to match /#{g.patients.last.name}/
  end

  it "can export referrals" do
    g = Generator.new
    str = g.export_referrals
    expect(str).to match /#{g.referrals.first.created_at}/
    expect(str).to match /#{g.referrals.last.created_at}/
  end

  it "can export programs" do
    g = Generator.new
    str = g.export_programs
    expect(str).to match /#{g.programs.first.name}/
    expect(str).to match /#{g.programs.last.name}/
  end

  it "can export contacts" do
    g = Generator.new
    str = g.export_contacts
    expect(str).to match /#{g.contacts.first.name}/
    expect(str).to match /#{g.contacts.last.name}/
  end

  it "can export all files" do
    Dir.mktmpdir do |dir|
      g = Generator.new
      g.export(dir)
      expect(File.exist?(File.join(dir,"patients.csv"))).to be true
      expect(File.exist?(File.join(dir,"referrals.csv"))).to be true
      expect(File.exist?(File.join(dir,"programs.csv"))).to be true
      expect(File.exist?(File.join(dir,"contacts.csv"))).to be true
    end
  end
end

