# frozen_string_literal: true

require_relative 'dsl_module'

module CfnDsl
  # Handles input parameter objects
  class ParameterDefinition
    include DSLModule

    def Type(value = nil)
      dsl_attribute(:Type, value)
    end

    def Default(value = nil)
      dsl_attribute(:Default, value)
    end

    def NoEcho(value = nil)
      dsl_attribute(:NoEcho, value)
    end

    def AllowedValues(value = nil)
      dsl_attribute(:AllowedValues, value)
    end

    def AllowedPattern(value = nil)
      dsl_attribute(:AllowedPattern, value)
    end

    def MaxLength(value = nil)
      dsl_attribute(:MaxLength, value)
    end

    def MinLength(value = nil)
      dsl_attribute(:MinLength, value)
    end

    def MaxValue(value = nil)
      dsl_attribute(:MaxValue, value)
    end

    def Description(value = nil)
      dsl_attribute(:Description, value)
    end

    def ConstraintDescription(value = nil)
      dsl_attribute(:ConstraintDescription, value)
    end

    # TODO: Generate above methods to avoid typos.
    # dsl_attr_setter :Type, :Default, :NoEcho, :AllowedValues, :AllowedPattern, :MaxLength, :MinLength,
    #   :MaxValue, :MinValue, :Description, :ConstraintDescription

    def initialize
      @Type = :String
    end

    def String
      @Type = :String
    end

    def Number
      @Type = :Number
    end

    def CommaDelimitedList
      @Type = :CommaDelimitedList
    end

    def to_hash
      h = {}
      h[:Type] = @Type
      h[:Default] = @Default if @Default
    end
  end
end
