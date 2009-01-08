if Object.const_defined?(:YAML)
  require 'syckle/syck'
else
  require 'syckle/setup'
end