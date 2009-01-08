module YAML
  Syck = Syckle::Syck
  PrivateType = Syckle::PrivateType
  DomainType = Syckle::DomainType
  Object = Syckle::Object
end if Object.const_defined?(:Syckle)

module Syckle
  module_function

  def load(io)
    YAML.load(io)
  end
end

require 'yaml'
