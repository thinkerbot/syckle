task :test do
  fails = []
  Dir.glob("test/*_test.rb").each do |test|
    fails << test unless system("ruby '#{test}'")
  end
  
  puts "failed: #{fails.length}"
  puts fails.inspect unless fails.empty?
end

task :bm do 
  Dir.glob("test/*_benchmark.rb").each do |test|
    system("ruby '#{test}'")
  end
end