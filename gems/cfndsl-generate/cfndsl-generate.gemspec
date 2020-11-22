# frozen_string_literal: true

require_relative 'lib/cfndsl/generate/version'
require_relative '../../gems/cfndsl-core/lib/cfndsl/version'

Gem::Specification.new do |s|
  s.name          = 'cfndsl-generate'
  s.version       = Cfndsl::Generate::VERSION
  s.authors       = ['Grant Gardner']
  s.email         = ['grant@lastweekend.com.au']
  s.summary       = 'Generate cfndsl resources'
  s.description   = 'Generate cfndsl resources from CloudFormation registry schema'
  s.homepage      = 'http://github.com/cfndsl/cfndsl'
  s.license       = 'MIT'
  s.required_ruby_version = '~> 2.4'
  s.files         = Dir['lib/**/*.rb', 'bin/*', 'templates/*.mustache']
  s.bindir        = 'bin'
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ['lib']
  s.add_runtime_dependency 'cfndsl-core', Gem::Version.new(CfnDsl::CORE_VERSION).approximate_recommendation
  s.add_runtime_dependency 'mustache'
  s.add_runtime_dependency 'rubyzip'
  s.add_runtime_dependency 'rufo'
end
