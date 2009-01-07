require 'test/unit'

module YAML
  module_function
  def load(io)
    "yaml loaded #{io}"
  end
end

$:.unshift "#{File.dirname(__FILE__)}/../lib"
require 'syckle'

class SyckleAfterYamlTest < Test::Unit::TestCase
  
  def test_syckle_defers_to_YAML_if_YAML_is_defined
    assert_equal "yaml loaded str", Syckle.load("str")
  end
end