require 'test/unit'
$:.unshift "#{File.dirname(__FILE__)}/../lib"

# Note that for reasons unknown, if this is in the test
# itself, the whole thing hangs on ruby 1.9.1  This is
# not an issue under ruby 1.8
#
# Testing was performed on an iMac, using this ruby:
# ftp://ftp.ruby-lang.org/pub/ruby/ruby-1.9.1-rc1.tar.gz
#
require 'syckle'
1000.times { autoload(:YAML, 'yaml') }

class SyckleAllowsSubsequentAutoloadsTest < Test::Unit::TestCase
  
  def test_syckle_allows_subsequent_autoloads
    # require 'syckle'
    # 1000.times { autoload(:YAML, 'yaml') }
    
    e = YAML.load("--- !ruby/exception \nmessage: Exception\n")
    assert_equal Exception, e.class
    assert_equal "Exception", e.message
  end
end