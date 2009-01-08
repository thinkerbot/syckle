if Object.const_defined?(:YAML)
  module Syckle
    module_function

    def load(io)
      YAML.load(io)
    end
  end
else
  require 'syckle/load'
end