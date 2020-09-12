# frozen_string_literal: true

require_relative 'lib/cfndsl/version'

Gem::Specification.new do |s|
  s.name                  = 'cfndsl-core'
  s.version               = CfnDsl::VERSION
  s.summary               = 'AWS Cloudformation DSL'
  s.description           = 'DSL for creating AWS Cloudformation templates'
  s.authors               = ['Steven Jack', 'Chris Howe', 'Travis Dempsey', 'Greg Cockburn']
  s.email                 = ['stevenmajack@gmail.com', 'chris@howeville.com', 'dempsey.travis@gmail.com', 'gergnz@gmail.com']
  s.files                 = Dir['bin/*', 'lib/**/*.rb']
  s.homepage              = 'https://github.com/cfndsl/cfndsl'
  s.license               = 'MIT'
  s.test_files            = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths         = ['lib']
  s.bindir                = 'bin'
  s.required_ruby_version = '~> 2.4'
  s.executables           = s.files.grep(%r{^bin/}) { |f| File.basename(f) }

  s.add_development_dependency 'bundler', '~> 2.1'
end
