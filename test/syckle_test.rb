require 'test/unit'

$:.unshift "#{File.dirname(__FILE__)}/../lib"
require 'syckle'

# setup and load test cases
test_cases = "#{File.dirname(__FILE__)}/test_cases.rb"
system("ruby '#{test_cases}'")
require test_cases

class SyckleTest < Test::Unit::TestCase
  
  def test_case(index)
    File.read("#{File.dirname(__FILE__)}/test_cases/#{index}.yml")
  end
  
  def test_syckle_loads_basic_types_same_as_YAML
    assert !$".include?("yaml.rb")
    
    index = 0
    TEST_CASES.each do |obj|
      assert_equal obj, Syckle.load(test_case(index)), obj.inspect
      index += 1
    end
    
    assert !$".include?("yaml.rb")
  end
end