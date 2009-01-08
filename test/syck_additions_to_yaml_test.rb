require 'test/unit'
require 'syck'

module Blank
end

class SyckAdditionsToYamlTest < Test::Unit::TestCase
  
  def test_syck_additions_to_yaml
    assert_equal [], (Blank.methods - YAML.methods)
    assert_equal ["DomainType", "Object", "PrivateType", "Syck"], YAML.constants.collect {|const| const.to_s }.sort
  end
end