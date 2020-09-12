# frozen_string_literal: true

require_relative 'dsl_module'

module CfnDsl
  # Handles Output objects
  class OutputDefinition
    include DSLModule

    def Value(value)
      dsl_attribute(:Value, value)
    end

    def Description(value)
      dsl_attribute(:Description, value)
    end

    def Condition(value)
      dsl_attribute(:Condition, value)
    end

    def Export(value)
      @Export = { 'Name' => value } if value
    end

    def initialize(value = nil)
      if value.is_a?(Hash)
        Value(value[:Value] || value['Value'])
        Export(value[:Export] || value['Export'])
      elsif value
        Value(value)
      end
    end

    def condition_refs
      [@Condition].flatten.compact.map(&:to_s)
    end
  end
end
