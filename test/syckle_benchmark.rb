require 'benchmark'
$:.unshift "#{File.dirname(__FILE__)}/../lib"

Benchmark.bm(20) do |x|
  x.report("syckle") do
    require 'syckle'
    raise "load error" unless {:key => 'value'} == Syckle.load(':key: value')
  end
  
  x.report("after loading") do
    raise "load error" unless {:key => 'value'} == Syckle.load(':key: value')
  end
  
  x.report("then yaml") do
    require 'yaml'
    raise "load error" unless {:key => 'value'} == YAML.load(':key: value')
  end
  
  x.report("after loading") do
    raise "load error" unless {:key => 'value'} == YAML.load(':key: value')
  end
end