
# Reassign unassigned YAML constants.  Note that even though
# PrivateType and DomainType are modified in setup, the changes
# are effectively rolled back when the rest of YAML is loaded.
module YAML # :nodoc:
  unless const_defined?(:Syck)
    Syck = Syckle::Syck
    PrivateType = Syckle::PrivateType
    DomainType = Syckle::DomainType
    Object = Syckle::Object
  end
end if Object.const_defined?(:Syckle)

module Syckle
  def Syckle.load(io)
    YAML.load(io)
  end
end

# teardown the load cycle
$:.delete File.expand_path(File.dirname(__FILE__))

# ensure yaml is loaded
require 'yaml'