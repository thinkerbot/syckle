require 'benchmark'

Benchmark.bm(20) do |x|
  x.report("yaml") do
    require 'yaml'
    raise "load error" unless {:key => 'value'} == YAML.load(':key: value')
  end
  
  x.report("after loading") do
    raise "load error" unless {:key => 'value'} == YAML.load(':key: value')
  end
end  