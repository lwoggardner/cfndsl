# frozen_string_literal: true

require 'yaml'
require_relative 'resources'

module CfnDsl
  # Base class for Resources
  class ResourceType < ResourceDefinition
    class << self
      def resource_type
        name.split('::')[-3..-1].join('::')
      end
    end

    def initialize
      @Type = self.class.resource_type
    end

    def Type(value = nil)
      raise Error, "Cannot set type for #{self.class.name}" unless value.nil?

      @Type
    end

    private

    # rubocop:disable Metrics/ParameterLists

    def dsl_attribute(symbol, value = nil, content_attr: :Properties, attr_class: nil, **value_hash, &block)
      super
    end

    def dsl_list_attribute(symbol, value = nil, content_attr: :Properties, **value_hash)
      super
    end

    def dsl_push_attribute(symbol, value = nil, fn_if: nil, content_attr: :Properties, attr_class: nil, **value_hash, &block)
      super
    end

    # rubocop:enable Metrics/ParameterLists
  end

  # Base class for Property Structures
  class PropertyType
    include DSLModule

    def Attribute(name, value = nil)
      dsl_attribute(name, value)
    end
  end
end
