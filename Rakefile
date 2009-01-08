task :test do 
  Dir.glob("test/*_test.rb").each do |test|
    system("ruby '#{test}'")
  end
end

task :bm do 
  Dir.glob("test/*_benchmark.rb").each do |test|
    system("ruby '#{test}'")
  end
end