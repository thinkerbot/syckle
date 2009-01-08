require 'test/unit'
$:.unshift "#{File.dirname(__FILE__)}/../lib"

class SyckleAllowsYamlRequireTest < Test::Unit::TestCase
  
  def test_syckle_allows_yaml_require
    require 'syckle'
    assert !$".include?("yaml.rb")
    
    require 'yaml'
    e = YAML.load("--- !ruby/exception \nmessage: Exception\n")
    assert_equal Exception, e.class
    assert_equal "Exception", e.message
    
    assert $".include?("yaml.rb")
  end
end