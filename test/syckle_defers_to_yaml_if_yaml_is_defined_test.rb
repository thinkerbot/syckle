require 'test/unit'
$:.unshift "#{File.dirname(__FILE__)}/../lib"

class SyckleDefersToYamlIfYamlIsDefinedTest < Test::Unit::TestCase
  
  def test_syckle_defers_to_YAML_if_YAML_is_defined
    require 'yaml'
    require 'syckle'

    e = Syckle.load("--- !ruby/exception \nmessage: Exception\n")
    assert_equal Exception, e.class
    assert_equal "Exception", e.message
  end
end