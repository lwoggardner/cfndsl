# frozen_string_literal: true

require 'spec_helper'

# Hack to ensure order of instance variables is unique for this test.
class ConditionSpecTemplate < CfnDsl::CloudFormationTemplate
end

describe CfnDsl::ConditionDefinition do
  let(:template) { ConditionSpecTemplate.new }
  let(:target) { File.read("#{File.dirname(__FILE__)}/fixtures/condition-assertion.json") }

  context '#Condition' do
    it 'formats correctly' do
      template.declare do
        Condition(:TestConditionTwo, FnNot(Condition(:TestConditionOne)))
        Resource(:TestResource) do
          Condition(:TestConditionTwo)
        end
        Output(:TestOutput) do
          Condition(:TestConditionOne)
        end
      end
      json = template.to_json
      expect(json).to eq(target)
    end
  end
end
