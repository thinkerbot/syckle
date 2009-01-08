require 'syck'

# unassign YAML
Syckle = YAML
Object.send(:remove_const, :YAML)

# setup the load cycle
$:.unshift File.expand_path(File.dirname(__FILE__))
autoload(:YAML, "yaml")

# === The cyclical syckle load cycle
# 
# Syckle has a tricky require cycle to load syck without affecting YAML
# autoloading. Normally requiring 'syck' loads the 'syck.bundle'; this 
# is what happens during the require cycle of YAML itself.  
# 
# Syckle requires 'syck' then unshifts the syckle directory to the top of the 
# load path, so that any subsequent requires of 'syck' will load 'syckle/sick'
# and not 'syck.bundle' (which has already been loaded).  The result is that 
# the normal load cycle for yaml, invoked directly or through an autoload,
# will cause 'syckle/syck' to be required.
# 
# Syckle is designed so that 'syckle/syck' tears down Syckle and effectively
# replaces Syckle.load with YAML.load.  If YAML is loaded before Syckle, the
# syckle load cycle directly calls 'syckle/syck' and the replacement occurs
# immediately.
module Syckle
  Syck::DefaultResolver.use_types_at(
    "tag:ruby.yaml.org,2002:symbol" => Symbol,
    "tag:ruby.yaml.org,2002:sym" => Symbol)
  SyckleParser = Syck::Parser.new.set_resolver( Syck::DefaultResolver )
  
  # Loads the input string as YAML.  If the string has YAML that
  # is too complex for Syckle, YAML itself is loaded and will be
  # used to load the string.
  #
  # Note that only strings are allowed, IO objects will immediately
  # trigger YAML loading.
  def Syckle.load(str)
    begin
      raise Syckle::Error unless str.kind_of?(String)
      yp = SyckleParser.load( str )
    
    rescue(Exception)
      require 'yaml'
      load(str)
    end
  end
  
  # Raised to trigger YAML loading for a string that is too complex for Syckle.
  class Error < StandardError; end
  
  class PrivateType
    
    # Raises a Syckle::Error on initialization, and thereby triggers YAML
    # loading.  When YAML is loaded, this method is overridden.
    def initialize( domain, type, val )
      raise Syckle::Error
    end
  end

  class DomainType
    
    # Raises a Syckle::Error on initialization, and thereby triggers YAML
    # loading.  When YAML is loaded, this method is overridden.
    def initialize( domain, type, val )
      raise Syckle::Error
    end
  end
end

class Symbol
  
  # Raises a Syckle::Error on errors, and thereby triggers YAML loading.
  # Otherwise the same as the Symbol.yaml_new defined by YAML itself.  
  # When YAML is loaded, this method is overridden.
  def Symbol.yaml_new( klass, tag, val )
    if String === val
      val = Syckle::load( val ) if val =~ /\A(["']).*\1\z/
      val.intern
    else
      raise Syckle::Error
    end
  end
end