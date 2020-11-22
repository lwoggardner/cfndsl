# frozen_string_literal: true

require_relative 'lib/cfndsl_aws_version'
require_relative '../../gems/cfndsl-core/lib/cfndsl/version'

Gem::Specification.new do |s|
  s.name        = 'cfndsl-aws'
  s.version     = CfnDsl::Aws::VERSION
  s.summary     = 'CfnDsl for AWS'
  s.description = 'CfnDsl Resources for AWS'
  s.authors     = ['cfndsl']
  s.email       = 'cfndsl@github.com'
  s.files       = Dir['lib/**/*.rb']
  s.homepage    = 'http://github.com/cfndsl'
  s.license     = 'MIT'
  s.add_runtime_dependency 'cfndsl-core', Gem::Version.new(CfnDsl::CORE_VERSION).approximate_recommendation
end
