# require all files in lib
#Dir["#{File.dirname(__FILE__)}/../lib/**/*.rb"].each {|file| require_relative file }
require_relative "../lib/generators/sdoh"
require_relative "../lib/generators/caremanagement"

# todo: refactor to find classes within the module that are Generators
generator = {
  sdoh: "Generator::SDOH",
  caremanagement: "Generator::CareManagement"
}

if ARGV.count<1
  puts "You must specify a script to run: #{generator.keys.join(',')}"
  exit 0
end
g = generator[ARGV[0].to_sym]
raise "Script #{ARGV[0]} not found. I only know about #{generator.keys.join(',')}" if !g

if ARGV.count==2
  output_dir = ARGV[1]
else
  output_dir = Dir.pwd
end

raise "Directory #{output_dir} does not exist." unless Dir.exist?(output_dir)

instance = Object.const_get(g)
instance.new.export(output_dir)
puts "Generation completed."


