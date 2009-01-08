require 'test/unit'
$:.unshift "#{File.dirname(__FILE__)}/../lib"

class SyckleAutoloadsYamlWithoutErrorTest < Test::Unit::TestCase
  
  def test_syckle_autoloads_YAML_without_error
    require 'syckle'

    e = YAML.load("--- !ruby/exception \nmessage: Exception\n")
    assert_equal Exception, e.class
    assert_equal "Exception", e.message
  end
end