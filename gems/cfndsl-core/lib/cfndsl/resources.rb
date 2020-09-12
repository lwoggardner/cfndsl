# frozen_string_literal: true

require_relative 'dsl_module'

module CfnDsl
  # Handles Resource objects
  class ResourceDefinition
    include DSLModule

    def Property(name, value = nil, &block)
      dsl_content_attribute(:Properties, name, value, attr_class: JSONSerialisableObject, &block)
    end

    def CreationPolicy(name, value)
      dsl_content_attribute(:CreationPolicy, name, value, attr_class: JSONSerialisableObject)
    end

    def UpdatePolicy(name, value)
      dsl_content_attribute(:UpdatePolicy, name, value, attr_class: JSONSerialisableObject)
    end

    def Type(value = nil)
      dsl_attribute(:Type, value)
    end

    def UpdateReplacePolicy(value = nil)
      dsl_attribute(:UpdateReplacePolicy, value, attr_class: nil)
    end

    def DeletionPolicy(value = nil)
      dsl_attribute(:DeletionPolicy, value, attr_class: nil)
    end

    def Condition(value = nil)
      dsl_attribute(:Condition, value, attr_class: nil)
    end

    def Metadata(name, value = nil)
      if name.is_a?(Hash) && value.nil?
        dsl_attribute(:Metadata, name)
      else
        dsl_content_attribute(:Metadata, name, value, attr_class: nil) # avoid value treated as keyword args
      end
    end

    # @deprecated
    def add_tag(name, value, propagate = nil)
      send(:Tag) do
        Key name
        Value value
        PropagateAtLaunch propagate unless propagate.nil?
      end
    end

    # DependsOn can be a single value or a list
    def DependsOn(value)
      case @DependsOn
      when nil
        @DependsOn = value
      when Array
        @DependsOn << value
      else
        @DependsOn = [@DependsOn, value]
      end
      if @DependsOn.is_a?(Array)
        @DependsOn.flatten!
        @DependsOn.uniq!
      end
      @DependsOn
    end

    def condition_refs
      [@Condition].flatten.compact.map(&:to_s)
    end

    def all_refs
      [@DependsOn].flatten.compact.map(&:to_s)
    end
  end
end
