# frozen_string_literal: true

require_relative 'jsonable'
require_relative 'json_serialisable_object'
require_relative 'functions'

# Cloudformation Domain Specific Language
module CfnDsl
  # rubocop:disable Metrics/ModuleLength
  # Adds some dsl module helpers
  module DSLModule
    def self.included(klass)
      klass.include JSONable unless klass.ancestors.include?(JSONSerialisableObject)
      klass.include Functions
      klass.extend ClassMethods
    end

    def declare(&block)
      instance_eval(&block) if block_given?
      self
    end

    def external_parameters
      self.class.external_parameters
    end

    private

    # rubocop:disable Metrics/ParameterLists, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    def dsl_attribute(symbol, value = nil, content_attr: nil, attr_class: nil, **value_hash, &block)
      value = value_hash if value.nil? && !value_hash.empty?
      defined = dsl_defined?(symbol, content_attr)
      warn "Replacing previously defined value for #{symbol}" if defined && !value.nil?
      result =
        if !value.nil? || ((block || attr_class) && !defined)
          dsl_set(symbol, dsl_value(attr_class, value), content_attr)
        else
          dsl_get(symbol, content_attr)
        end
      return result unless block
      raise Error, "Cannot use block to declare #{content_attr}#{content_attr && '.'}#{symbol}" unless result.respond_to?(:declare)

      result.declare(&block)
    end

    def dsl_get(symbol, content_attr)
      if content_attr
        dsl_content(content_attr)[symbol.to_s]
      else
        instance_variable_get("@#{symbol}")
      end
    end

    def dsl_set(symbol, value, content_attr)
      if content_attr
        dsl_content(content_attr)[symbol.to_s] = value
      else
        instance_variable_set("@#{symbol}", value)
      end
    end

    def dsl_defined?(symbol, content_attr)
      if content_attr
        dsl_content(content_attr).key?(symbol.to_s)
      else
        instance_variable_defined?("@#{symbol}")
      end
    end

    def dsl_value(attr_class, value)
      if !attr_class || value.is_a?(attr_class)
        value
      elsif value.nil?
        attr_class.new
      else
        value
      end
    end

    def dsl_content(content_attr)
      content_var = "@#{content_attr}"
      instance_variable_get(content_var) || instance_variable_set(content_var, {})
    end

    def dsl_fnif(cond, value)
      return value unless cond

      if cond.to_s.start_with?('!')
        FnIf(cond, Ref('AWS::NoValue'), value)
      else
        FnIf(cond, value, Ref('AWS::NoValue'))
      end
    end

    # Get or Set a list attribute
    # @return [Array] the lazily instantiated list value
    def dsl_list_attribute(symbol, value = nil, content_attr: nil, **value_hash)
      value = value_hash if value.nil? && !value_hash.empty?
      value = [] if !dsl_defined?(symbol, content_attr) && value.nil?

      if content_attr
        dsl_content(content_attr)[symbol.to_s] = value unless value.nil?
        dsl_content(content_attr)[symbol.to_s]
      else
        dsl_attribute(symbol, value)
      end
    end

    def dsl_push_attribute(symbol, value = nil, fn_if: nil, content_attr: nil, attr_class: nil, **value_hash, &block)
      value = value_hash if value.nil? && !value_hash.empty?

      if value.is_a?(Array) && !block
        value.each do |v|
          dsl_push_attribute(symbol, v, fn_if: fn_if, content_attr: content_attr, attr_class: attr_class, &nil)
        end
        return dsl_list_attribute(symbol, nil, content_attr: content_attr)
      end
      value = attr_class.new if value.nil? && attr_class
      value = value.declare(&block) if block && value.respond_to?(:declare)
      value = dsl_fnif(fn_if, value) if fn_if

      list = dsl_list_attribute(symbol, content_attr: content_attr)

      raise Error, "Cannot append to non array value previously set for List type '#{symbol}'" unless list.respond_to?(:push)

      list.push(value)
    end

    # Used by Map properties
    def dsl_content_attribute(symbol, name, value = nil, attr_class: nil, **value_hash, &block)
      value = value_hash if value.nil? && !value_hash.empty?
      dsl_attribute(name, value, content_attr: symbol, attr_class: attr_class, &block)
    end

    # rubocop:enable Metrics/ParameterLists, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    def method_missing(symbol, *args)
      if symbol =~ /^[a-z]/ && respond_to?((alt_method = symbol.to_s.gsub(/^\w/, &:swapcase).to_sym))
        # Shim for cfndsl 1.x lowercase names
        send(alt_method, *args)
      else
        super
      end
    end

    def respond_to_missing?(symbol, include_private = false)
      symbol =~ /^[a-z]/ ? respond_to?(symbol.to_s.gsub(/^\w/, &:swapcase).to_sym) : super
    end
  end

  # rubocop:enable Metrics/ModuleLength

  # Class methods for CfnDsl
  module ClassMethods
    def external_parameters
      CfnDsl::ExternalParameters.current
    end
  end
end
