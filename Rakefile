task :build, [:db_name] do |t, args|
  puts args
  db_name = args[:db_name] || "cmm"
  print "Are you sure you want to rebuild the #{db_name} database?(y or n) "
  answer = $stdin.gets
  unless answer =~ /y|Y/ 
    puts "Aborting." 
    exit
  end
  sql_dir = File.join(Dir.pwd,"lib/tasks")
  puts "Recreating database"
  `psql -c 'DROP DATABASE #{db_name}' -c 'CREATE DATABASE #{db_name}'`
  puts "Adding in the datafiles"
  `psql -d #{db_name} -c '\\i #{File.join(sql_dir, "create_table.sql")}' -c '\\i #{File.join(sql_dir, "copy.sql")}'`
end

