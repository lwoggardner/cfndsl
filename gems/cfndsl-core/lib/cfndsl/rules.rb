# frozen_string_literal: true

require_relative 'jsonable'

module CfnDsl
  # Handles Rule objects
  class RuleDefinition
    include DSLModule

    def RuleCondition(value = nil)
      dsl_attribute(:RuleCondition, value)
    end

    def Assertions(values)
      dsl_list_attribute(:Assertion, values)
    end

    def Assertion(value, fn_if: nil)
      dsl_push_attribute(:Assertions, value, fn_if: fn_if)
    end

    # Shortcut
    def Assert(arg_desc = nil, arg_struct = nil, desc: arg_desc, struct: arg_struct)
      Assertion(Assert: struct, AssertDescription: desc)
    end

    def FnContains(list_of_strings, string)
      Fn.new('Contains', [list_of_strings, string])
    end

    def FnEachMemberEquals(list_of_strings, string)
      Fn.new('EachMemberEquals', [list_of_strings, string])
    end

    def FnEachMemberIn(strings_to_check, strings_to_match)
      Fn.new('EachMemberIn', [strings_to_check, strings_to_match])
    end

    def FnRefAll(parameter_type)
      Fn.new('RefAll', parameter_type)
    end

    def FnValueOf(parameter_logical_id, attribute)
      raise 'Cannot use functions within FnValueOf' unless parameter_logical_id.is_a?(String) && attribute.is_a?(String)

      Fn.new('ValueOf', [parameter_logical_id, attribute])
    end

    def FnValueOfAll(parameter_logical_id, attribute)
      raise 'Cannot use functions within FnValueOfAll' unless parameter_logical_id.is_a?(String) && attribute.is_a?(String)

      Fn.new('ValueOfAll', [parameter_logical_id, attribute])
    end
  end
end
