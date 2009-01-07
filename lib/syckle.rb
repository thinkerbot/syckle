if Object.const_defined?(:YAML)
  module Syckle
    module_function

    def load(io)
      YAML.load(io)
    end
  end
else
  
require 'syck'

module Syckle
  
  Parser = YAML::Syck::Parser
  DefaultResolver = YAML::Syck::DefaultResolver
  TaggedClasses = {}
  
  module_function
  
  # Returns a new default parser
  def parser
    @parser ||= Parser.new.set_resolver( resolver )
  end
  
  # Returns the default resolver
  def resolver
    resolver = DefaultResolver
    resolver.use_types_at( TaggedClasses )
    resolver
  end

  def load(str)
    begin
      raise Syckle::Error unless str.kind_of?(String)
      yp = parser.load( str )
      
    rescue(Exception)
      require 'yaml'
      Kernel.load(__FILE__)
      YAML.load(str)
    end
  end
  
  #
  # Allocate blank object
  #
  def object_maker( obj_class, val )
    if Hash === val
      o = obj_class.allocate
      val.each_pair { |k,v|
        o.instance_variable_set("@#{k}", v)
      }
      o
    else
      raise Syckle::Error
    end
  end
  
  class Error < StandardError; end
end

module YAML
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

class Module
  def yaml_as( tag, sc = true )
    Syckle::TaggedClasses[tag] = self
  end
end

class Object
  yaml_as "tag:ruby.yaml.org,2002:object"
  def to_yaml_style; end
  def to_yaml_properties; instance_variables.sort; end
end

class Hash
  yaml_as "tag:ruby.yaml.org,2002:hash"
  yaml_as "tag:yaml.org,2002:map"
  def yaml_initialize( tag, val )
    if Array === val
      update Hash.[]( *val )		# Convert the map to a sequence
    elsif Hash === val
      update val
    else
      raise Syckle::Error
    end
  end
end

class Array
  yaml_as "tag:ruby.yaml.org,2002:array"
  yaml_as "tag:yaml.org,2002:seq"
  def yaml_initialize( tag, val ); concat( val.to_a ); end
end

class String
  yaml_as "tag:ruby.yaml.org,2002:string"
  yaml_as "tag:yaml.org,2002:binary"
  yaml_as "tag:yaml.org,2002:str"
  def String.yaml_new( klass, tag, val )
    val = val.unpack("m")[0] if tag == "tag:yaml.org,2002:binary"
    val = { 'str' => val } if String === val
    if Hash === val
      s = klass.allocate
      # Thank you, NaHi
      String.instance_method(:initialize).
      bind(s).
      call( val.delete( 'str' ) )
      val.each { |k,v| s.instance_variable_set( k, v ) }
      s
    else
      raise Syckle::Error
    end
  end
end

class Symbol
  yaml_as "tag:ruby.yaml.org,2002:symbol"
  yaml_as "tag:ruby.yaml.org,2002:sym"
  def Symbol.yaml_new( klass, tag, val )
    if String === val
      val = Syckle::load( val ) if val =~ /\A(["']).*\1\z/
      val.intern
    else
      raise Syckle::Error
    end
  end
end

class Range
  yaml_as "tag:ruby.yaml.org,2002:range"
  def Range.yaml_new( klass, tag, val )
    inr = %r'(\w+|[+-]?\d+(?:\.\d+)?(?:e[+-]\d+)?|"(?:[^\\"]|\\.)*")'
    opts = {}
    if String === val and val =~ /^#{inr}(\.{2,3})#{inr}$/o
      r1, rdots, r2 = $1, $2, $3
      opts = {
        'begin' => Syckle.load( "--- #{r1}" ),
        'end' => Syckle.load( "--- #{r2}" ),
        'excl' => rdots.length == 3
      }
      val = {}
    elsif Hash === val
      opts['begin'] = val.delete('begin')
      opts['end'] = val.delete('end')
      opts['excl'] = val.delete('excl')
    end
    if Hash === opts
      r = Syckle::object_maker( klass, {} )
      # Thank you, NaHi
      Range.instance_method(:initialize).
      bind(r).
      call( opts['begin'], opts['end'], opts['excl'] )
      val.each { |k,v| r.instance_variable_set( k, v ) }
      r
    else
      raise Syckle::Error
    end
  end
end

class Regexp
  yaml_as "tag:ruby.yaml.org,2002:regexp"
  def Regexp.yaml_new( klass, tag, val )
    if String === val and val =~ /^\/(.*)\/([mix]*)$/
      val = { 'regexp' => $1, 'mods' => $2 }
    end
    if Hash === val
      mods = nil
      unless val['mods'].to_s.empty?
        mods = 0x00
        mods |= Regexp::EXTENDED if val['mods'].include?( 'x' )
        mods |= Regexp::IGNORECASE if val['mods'].include?( 'i' )
        mods |= Regexp::MULTILINE if val['mods'].include?( 'm' )
      end
      val.delete( 'mods' )
      r = Syckle::object_maker( klass, {} )
      Regexp.instance_method(:initialize).
      bind(r).
      call( val.delete( 'regexp' ), mods )
      val.each { |k,v| r.instance_variable_set( k, v ) }
      r
    else
      raise Syckle::Error
    end
  end
end

class Time
  yaml_as "tag:ruby.yaml.org,2002:time"
  yaml_as "tag:yaml.org,2002:timestamp"
  def Time.yaml_new( klass, tag, val )
    if Hash === val
      t = val.delete( 'at' )
      val.each { |k,v| t.instance_variable_set( k, v ) }
      t
    else
      raise Syckle::Error
    end
  end
end

class Integer
  yaml_as "tag:yaml.org,2002:int"
end

class Float
  yaml_as "tag:yaml.org,2002:float"
end

class TrueClass
  yaml_as "tag:yaml.org,2002:bool#yes"
end

class FalseClass
  yaml_as "tag:yaml.org,2002:bool#no"
end

class NilClass 
  yaml_as "tag:yaml.org,2002:null"
end

Object.send(:remove_const, :YAML)
$".delete('syck.bundle')
end