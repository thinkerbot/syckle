require 'test/unit'

$:.unshift "#{File.dirname(__FILE__)}/../lib"
require 'syckle'

class SyckleThenYamlTest < Test::Unit::TestCase
  
  def test_syckle_loads_and_defers_to_YAML_on_error
    assert !Object.const_defined?(:YAML)
    
    e = Syckle.load("--- !ruby/exception \nmessage: Exception\n")
    assert_equal Exception, e.class
    assert_equal "Exception", e.message
    
    assert Object.const_defined?(:YAML)
  end
end