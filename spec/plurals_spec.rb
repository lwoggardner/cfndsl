# frozen_string_literal: true

require_relative '../gems/cfndsl-generate/lib/cfndsl/generate/plurals'
require 'spec_helper'

describe CfnDsl::Generate::Plurals do
  context '.pluralize' do
    it 'pluralizes methods from the list' do
      expect(described_class.pluralize(:SecurityGroupIngress)).to eq('SecurityGroupIngressRules')
    end

    it 'pluralizes other methods' do
      expect(described_class.pluralize(:StageKey)).to eq('StageKeys')
    end
  end

  context '.singularize' do
    it 'singularizes methods from the list' do
      expect(described_class.singularize(:SecurityGroupIngress)).to eq('SecurityGroupIngress')
    end

    it 'singularizes other methods' do
      expect(described_class.singularize(:StageKeys)).to eq('StageKey')
    end

    { AvailabilityZones: 'AvailabilityZone' }.each_pair do |plural, singular|
      it "singularizes #{plural}" do
        expect(described_class.singularize(plural)).to eq(singular)
      end
    end
  end
end
