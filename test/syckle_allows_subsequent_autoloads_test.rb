require 'test/unit'
$:.unshift "#{File.dirname(__FILE__)}/../lib"

require 'syckle'
1000.times { autoload(:YAML, 'yaml') }

class SyckleAllowsSubsequentAutoloadsTest < Test::Unit::TestCase
  
  def test_syckle_allows_subsequent_autoloads
    e = YAML.load("--- !ruby/exception \nmessage: Exception\n")
    assert_equal Exception, e.class
    assert_equal "Exception", e.message
  end
end