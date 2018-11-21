task :rebuild do
  print "Are you sure you want to rebuild the cmm database?(y or n) "
  answer = $stdin.gets
  unless answer =~ /y|Y/ 
    puts "Aborting." 
    exit
  end
  sql_dir = File.join(Dir.pwd,"lib/tasks")
  puts "Recreating database"
  `psql -c 'DROP DATABASE cmm' -c 'CREATE DATABASE cmm'`
  puts "Adding in the datafiles"
  `psql -d cmm -c '\\i #{File.join(sql_dir, "create_table.sql")}' -c '\\i #{File.join(sql_dir, "copy.sql")}'`
end

