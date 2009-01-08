require 'test/unit'
$:.unshift "#{File.dirname(__FILE__)}/../lib"

class SyckleAllowsSubsequentAutoloadsTest < Test::Unit::TestCase
  
  def test_syckle_allows_subsequent_autoloads
    require 'syckle'
    autoload(:YAML, 'yaml')
    
    assert !$".include?("yaml.rb")
    
    e = YAML.load("--- !ruby/exception \nmessage: Exception\n")
    assert_equal Exception, e.class
    assert_equal "Exception", e.message
    
    assert $".include?("yaml.rb")
  end
end