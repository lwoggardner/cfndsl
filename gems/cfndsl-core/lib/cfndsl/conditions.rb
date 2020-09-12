# frozen_string_literal: true

require_relative 'json_serialisable_object'

module CfnDsl
  # Handles condition objects
  #
  # Usage:
  #     Condition :ConditionName, FnEquals(Ref(:ParameterName), 'helloworld')
  class ConditionDefinition < JSONSerialisableObject
    # For when Condition is used inside Fn::And, Fn::Or, Fn::Not
    def condition_refs
      case @value
      when String, Symbol
        [@value.to_s]
      else
        []
      end
    end
  end
end
