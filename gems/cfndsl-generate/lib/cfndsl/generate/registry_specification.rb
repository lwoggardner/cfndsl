# frozen_string_literal: true

require 'json'
require 'rufo'
require_relative 'plurals'
require_relative 'version'
require_relative 'mustache'

module CfnDsl
  module Generate
    # The Cloudformation Registry Specification for a single resource
    class RegistrySpecification < Mustache
      self.template_file = "#{__dir__}/../../../templates/resource.rb.mustache"

      # Object structure type definition
      class ObjectType
        attr_reader :properties, :ruby_type

        def initialize(name, spec, defs)
          @ruby_type = name
          @spec = spec
          @properties = RegistrySpecification.build_properties(spec, defs, type: name)
        end

        def object_type?
          true
        end

        def description
          (@spec['description'] || "Property Definition #{@ruby_type}").chomp.split("\n")
        end

        def source_url
          @spec['sourceUrl']
        end
      end

      # Primitive type definition
      class PrimitiveType
        def initialize(tspec)
          @spec = tspec
        end

        def object_type?
          false
        end

        def ruby_type
          if @spec['type'].is_a?(Array)
            # ['object','string'] is used to refer to items that are typically JSONObject or string
            @spec['type'].map(&:capitalize).join('|')
          else
            @spec['type']&.capitalize
          end
        end
      end

      # Array property type
      class ListType
        def initialize(tspec, defs)
          @item_spec = tspec['items']
          @defs = defs
        end

        def object_type?
          item_type.object_type?
        end

        def ruby_type
          item_type.ruby_type
        end

        private

        def item_type
          # Lazy assign to avoid recursion
          @item_type ||=
            if @item_spec.key?('$ref')
              @defs[RegistrySpecification.dereference(@item_spec)]
            else
              PrimitiveType.new(@item_spec)
            end
        end
      end

      # Property Definition
      class Property
        attr_reader :property_name, :all_names

        def initialize(name, type, desc, all_names)
          @property_name = name
          @type = type
          @desc = desc
          @all_names = all_names
        end

        def list_type?
          @type.is_a?(ListType)
        end

        # is the underlying type an object or a primitive type?
        def object_type?
          @type.object_type?
        end

        def ruby_type
          @type.ruby_type
        end

        def description
          # TODO: Include required, mutability, constraints etc
          (@desc || "The #{list_type? ? 'List of values' : 'value'} to use for #{property_name}").chomp.split("\n")
        end

        def singular?
          list_type? # always have singular method - can use Property or Attribute to explicitly set a property to a list or fn that returns a list.
        end

        def singular_name
          @singular_name ||=
            begin
              singular = Plurals.singularize(property_name)
              if other_name?(singular)
                warn "Using Property name '#{property_name}' as singular list method since preferred name '#{singular}' is itself a property"
                singular = property_name
              end
              singular
            end
        end

        def plural?
          list_type? && (plural_name != singular_name) && !other_name?(plural_name)
        end

        def plural_name
          @plural_name ||= Plurals.pluralize(property_name)
        end

        private

        def other_name?(name)
          name != property_name && all_names.include?(name)
        end
      end

      class << self
        def read(file)
          new(JSON.parse(File.read(file)))
        end

        def build_properties(spec, definitions, type: nil)
          all_names = []
          (spec['properties'] || {}).map do |pname, pspec|
            unless pname =~ /^[A-Z]/
              new_pname = pname.dup
              new_pname[0] = new_pname[0].upcase
              warn "Fixing bad case for #{type}.##{pname} => #{new_pname}"
              pname = new_pname
            end
            all_names << pname
            ptype =
              if pspec.key?('$ref')
                definitions[dereference(pspec)]
              elsif pspec['type'] == 'array'
                ListType.new(pspec, definitions)
              else
                PrimitiveType.new(pspec)
              end
            Property.new(pname, ptype, pspec['description'], all_names)
          end
        end

        def dereference(spec)
          spec['$ref'].split('/').last
        end
      end

      attr_reader :organization, :service, :resource, :properties, :classes

      def initialize(spec)
        @spec = spec
        @organization, @service, @resource = @spec['typeName'].split('::')
        definitions = Hash.new do |map, dname|
          dspec = @spec.dig('definitions', dname)
          map[dname] =
            case dspec['type']
            when 'object'
              ObjectType.new(dname, dspec, map)
            when 'array'
              ListType.new(dspec, map)
            else
              PrimitiveType.new(dspec)
            end
        end
        @properties = RegistrySpecification.build_properties(spec, definitions, type: @spec['typeName'])
        @classes = ((spec['definitions'] || {}).keys || []).map { |dname| definitions[dname] }.select { |d| d.is_a?(ObjectType) }
      end

      def type
        @spec['typeName']
      end

      def description
        (@spec['description'] || "CloudFormation resource #{type}").chomp.split("\n")
      end

      def source_url
        @spec['sourceUrl']
      end

      def render
        code = super
        Rufo.format(code)
      rescue StandardError
        warn JSON.pretty_generate(@spec)
        warn code if code
        raise
      end
    end
  end
end
