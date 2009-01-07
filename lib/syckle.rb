if Object.const_defined?(:YAML)
  module Syckle
    module_function

    def load(io)
      YAML.load(io
    end
  end

  return
end

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

  def load( io )
    yp = parser.load( io )
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
      raise Syckle::Error, "Invalid object explicitly tagged !ruby/Object: " + val.inspect
    end
  end
  
  def read_type_class( type, obj_class )
    scheme, domain, type, tclass = type.split( ':', 4 )
    tclass.split( "::" ).each { |c| obj_class = obj_class.const_get( c ) } if tclass
    return [ type, obj_class ]
  end
  
  #
  # Convert a type_id to a taguri
  #
  def tagurize( val )
    resolver.tagurize( val )
  end
  
  #
  # Error messages
  #

  ERROR_NO_HEADER_NODE = "With UseHeader=false, the node Array or Hash must have elements"
  ERROR_NEED_HEADER = "With UseHeader=false, the node must be an Array or Hash"
  ERROR_BAD_EXPLICIT = "Unsupported explicit transfer: '%s'"
  ERROR_MANY_EXPLICIT = "More than one explicit transfer"
  ERROR_MANY_IMPLICIT = "More than one implicit request"
  ERROR_NO_ANCHOR = "No anchor for alias '%s'"
  ERROR_BAD_ANCHOR = "Invalid anchor: %s"
  ERROR_MANY_ANCHOR = "More than one anchor"
  ERROR_ANCHOR_ALIAS = "Can't define both an anchor and an alias"
  ERROR_BAD_ALIAS = "Invalid alias: %s"
  ERROR_MANY_ALIAS = "More than one alias"
  ERROR_ZERO_INDENT = "Can't use zero as an indentation width"
  ERROR_UNSUPPORTED_VERSION = "This release of YAML.rb does not support YAML version %s"
  ERROR_UNSUPPORTED_ENCODING = "Attempt to use unsupported encoding: %s"

  #
  # YAML Error classes
  #

  class Error < StandardError; end
  class ParseError < Error; end
  class TypeError < StandardError; end
end

class Module
  # :stopdoc:

  # Adds a taguri _tag_ to a class, used when dumping or loading the class
  # in YAML.  See YAML::tag_class for detailed information on typing and
  # taguris.
  def yaml_as( tag, sc = true )
      verbose, $VERBOSE = $VERBOSE, nil
      class_eval <<-"end;", __FILE__, __LINE__+1
          attr_writer :taguri
          def taguri
              if respond_to? :to_yaml_type
                  Syckle::tagurize( to_yaml_type[1..-1] )
              else
                  return @taguri if defined?(@taguri) and @taguri
                  tag = #{ tag.dump }
                  if self.class.yaml_tag_subclasses? and self.class != YAML::tagged_classes[tag]
                      tag = "\#{ tag }:\#{ self.class.yaml_tag_class_name }"
                  end
                  tag
              end
          end
          def self.yaml_tag_subclasses?; #{ sc ? 'true' : 'false' }; end
      end;
      Syckle::TaggedClasses[tag] = self
  ensure
      $VERBOSE = verbose
  end
  
    # # Transforms the subclass name into a name suitable for display
    # # in a subclassed tag.
    # def yaml_tag_class_name
    #     self.name
    # end
    # # Transforms the subclass name found in the tag into a Ruby
    # # constant name.
    # def yaml_tag_read_class( name )
    #     name
    # end
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
      raise Syckle::TypeError, "Invalid map explicitly tagged #{ tag }: " + val.inspect
    end
  end
end

class Struct
  yaml_as "tag:ruby.yaml.org,2002:struct"
  def self.yaml_tag_class_name; self.name.gsub( "Struct::", "" ); end
  def self.yaml_tag_read_class( name ); "Struct::#{ name }"; end
  def self.yaml_new( klass, tag, val )
    if Hash === val
      struct_type = nil

      #
      # Use existing Struct if it exists
      #
      props = {}
      val.delete_if { |k,v| props[k] = v if k =~ /^@/ }
      begin
        struct_name, struct_type = Syckle.read_type_class( tag, Struct )
      rescue NameError
      end
      if not struct_type
        struct_def = [ tag.split( ':', 4 ).last ]
        struct_type = Struct.new( *struct_def.concat( val.keys.collect { |k| k.intern } ) ) 
      end

      #
      # Set the Struct properties
      #
      st = Syckle::object_maker( struct_type, {} )
      st.members.each do |m|
        st.send( "#{m}=", val[m] )
      end
      props.each do |k,v|
        st.instance_variable_set(k, v)
      end
      st
    else
      raise Syckle::TypeError, "Invalid Ruby Struct: " + val.inspect
    end
  end
end

class Array
  yaml_as "tag:ruby.yaml.org,2002:array"
  yaml_as "tag:yaml.org,2002:seq"
  def yaml_initialize( tag, val ); concat( val.to_a ); end
end

class Exception
  yaml_as "tag:ruby.yaml.org,2002:exception"
  def Exception.yaml_new( klass, tag, val )
    o = Syckle.object_maker( klass, { 'mesg' => val.delete( 'message' ) } )
    val.each_pair do |k,v|
      o.instance_variable_set("@#{k}", v)
    end
    o
  end
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
      raise Syckle::TypeError, "Invalid String: " + val.inspect
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
      raise Syckle::TypeError, "Invalid Symbol: " + val.inspect
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
      raise Syckle::TypeError, "Invalid Range: " + val.inspect
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
      raise Syckle::TypeError, "Invalid Regular expression: " + val.inspect
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
      raise Syckle::TypeError, "Invalid Time: " + val.inspect
    end
  end
end

class Date
  yaml_as "tag:yaml.org,2002:timestamp#ymd"
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
autoload(:YAML, 'yaml')
