require 'test/unit'
require 'benchmark'

$:.unshift "#{File.dirname(__FILE__)}/../lib"

class BenchmarkTest < Test::Unit::TestCase
  include Benchmark
  
  def test_syckle_vs_yaml_loading
    bm do |x|
      x.report do
        require 'syckle'
        assert_equal({:key => 'value'}, Syckle.load(':key: value'))
      end
      
      x.report do
        require 'yaml'
        assert_equal({:key => 'value'}, YAML.load(':key: value'))
      end
    end  
  end
end