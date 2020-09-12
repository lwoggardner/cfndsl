# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'cfndsl-aws'
  s.version     = '0.0.1'
  s.summary     = 'CfnDsl for AWS'
  s.description = 'CfnDsl Resources for AWS'
  s.authors     = ['cfndsl']
  s.email       = 'cfndsl@github.com'
  s.files       = Dir['lib/**/*.rb']
  s.homepage    = 'http://github.com/cfndsl'
  s.license     = 'MIT'
  s.add_runtime_dependency 'cfndsl-core', '~> 2.0.0pre'
end
