require 'test/unit'
$:.unshift "#{File.dirname(__FILE__)}/../lib"

# setup and load test cases
test_cases = "#{File.dirname(__FILE__)}/test_cases.rb"
system("ruby '#{test_cases}'")
require test_cases

class SyckleLoadsBasicTypesAsYamlTest < Test::Unit::TestCase
  
  def syckle_case(index)
    File.read("#{File.dirname(__FILE__)}/test_cases/#{index}.yml")
  end
  
  def test_syckle_loads_basic_types_same_as_YAML
    require 'syckle'

    index = 0
    TEST_CASES.each do |obj|
      assert_equal obj, Syckle.load(syckle_case(index)), obj.inspect
      index += 1
    end
  end
end