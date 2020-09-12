# frozen_string_literal: true

require_relative '../cfndsl-core/lib/cfndsl/version'

Gem::Specification.new do |s|
  s.name                  = 'cfndsl'
  s.version               = CfnDsl::VERSION
  s.summary               = 'AWS Cloudformation DSL'
  s.description           = 'DSL for creating AWS Cloudformation templates'
  s.authors               = ['Steven Jack', 'Chris Howe', 'Travis Dempsey', 'Greg Cockburn']
  s.email                 = ['stevenmajack@gmail.com', 'chris@howeville.com', 'dempsey.travis@gmail.com', 'gergnz@gmail.com']
  s.homepage              = 'https://github.com/cfndsl/cfndsl'
  s.files                 = Dir['lib/**/*.rb']
  s.license               = 'MIT'
  s.add_runtime_dependency 'cfndsl-aws'
  s.add_runtime_dependency 'cfndsl-core', "= #{CfnDsl::VERSION}"
  s.add_development_dependency 'bundler', '~> 2.1'
end
