require 'test/unit'

$:.unshift "#{File.dirname(__FILE__)}/../lib"
require 'syckle'

class SyckleAutoloadsYamlWithoutErrorTest < Test::Unit::TestCase
  
  def test_syckle_autoloads_YAML_without_error
    assert !$".include?("yaml.rb")
    
    e = YAML.load("--- !ruby/exception \nmessage: Exception\n")
    assert_equal Exception, e.class
    assert_equal "Exception", e.message
    
    assert $".include?("yaml.rb")
  end
end