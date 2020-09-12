# frozen_string_literal: true

require 'spec_helper'
class TestDefinition
  include CfnDsl::DSLModule
end

describe TestDefinition do
  context '.external_parameters' do
    it 'allows access to the current parameters instance' do
      expect(subject.class.external_parameters).to be_an_instance_of(CfnDsl::ExternalParameters)
    end
  end

  context '#external_parameters' do
    it 'allows access to the current parameters instance' do
      expect(subject.external_parameters).to be_an_instance_of(CfnDsl::ExternalParameters)
    end
  end
end
