# require all files in lib
#Dir["#{File.dirname(__FILE__)}/../lib/**/*.rb"].each {|file| require_relative file }
require_relative "../lib/generator"

if ARGV.count==1
  output_dir = ARGV[0]
else
  output_dir = Dir.pwd
end

raise "Directory #{output_dir} does not exist." unless Dir.exist?(output_dir)

Generator.new.export(output_dir)
puts "Generation completed."


