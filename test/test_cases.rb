TEST_CASES = [
  nil, true, false,
  1, 1.2,
  "true", "false", "yes", "no", "",
  "string", :symbol, {:key => 'value'}, [1,2,3], 
  { 'string' => "a long\n string with \t\nnewlines and whitespace",
    'array' => [{:key => 'value'}, 'str', :sym, 1],
    'hash' => {:hash => {:key => 'value'}},
    :sym => :symbol,
    1 => 1.2},
  ['a', :b, 3, {'key' => 'value'}, [:x, 'y', false]]
]

if __FILE__ == $0
  require 'yaml'
  require 'fileutils'
  
  root = __FILE__.chomp('.rb')
  FileUtils.rm_r(root) if File.exists?(root)
  FileUtils.mkdir_p(root)
  
  index = 0
  TEST_CASES.each do |obj|
    File.open("#{root}/#{index}.yml", "w") do |file|
      unless YAML.load(YAML.dump(obj)) == obj
        raise "test case error: #{index}"
      end
      
      YAML.dump(obj, file)
    end
    index += 1
  end
end