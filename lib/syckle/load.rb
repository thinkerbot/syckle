require 'syck'

Syckle = YAML
Object.send(:remove_const, :YAML)
autoload(:YAML, "#{File.expand_path(File.dirname(__FILE__))}/syck.rb")

module Syckle

  Syck::DefaultResolver.use_types_at(
    "tag:ruby.yaml.org,2002:symbol" => Symbol,
    "tag:ruby.yaml.org,2002:sym" => Symbol)
  SyckleParser = Syck::Parser.new.set_resolver( Syck::DefaultResolver )
  
  def Syckle.load(str)
    begin
      raise Syckle::Error unless str.kind_of?(String)
      yp = SyckleParser.load( str )
    
    rescue(Exception)
      require 'syckle/syck'
      load(str)
    end
  end

  class Error < StandardError; end
  
  class PrivateType
    def initialize( domain, type, val )
      raise Syckle::Error
    end
  end

  class DomainType
    def initialize( domain, type, val )
      raise Syckle::Error
    end
  end
end

class Symbol
  def Symbol.yaml_new( klass, tag, val )
    if String === val
      val = Syckle::load( val ) if val =~ /\A(["']).*\1\z/
      val.intern
    else
      raise Syckle::Error
    end
  end
end