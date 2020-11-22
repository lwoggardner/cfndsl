# frozen_string_literal: true

require_relative 'lib/cfndsl/version'
require_relative '../../gems/cfndsl-aws/lib/cfndsl_aws_version'
require_relative '../../gems/cfndsl-aws-serverless/lib/cfndsl_aws_serverless_version'

Gem::Specification.new do |s|
  s.name                  = 'cfndsl'
  s.version               = CfnDsl::VERSION
  s.summary               = 'AWS Cloudformation DSL'
  s.description           = 'DSL for creating AWS Cloudformation templates'
  s.authors               = ['Steven Jack', 'Chris Howe', 'Travis Dempsey', 'Greg Cockburn','Grant Gardner']
  s.email                 = ['stevenmajack@gmail.com', 'chris@howeville.com', 'dempsey.travis@gmail.com', 'gergnz@gmail.com','grant@lastweekend.com.au']
  s.homepage              = 'https://github.com/cfndsl/cfndsl'
  s.files                 = Dir['lib/**/*.rb']
  s.license               = 'MIT'
  s.add_runtime_dependency 'cfndsl-aws', Gem::Version.new(CfnDsl::Aws::VERSION).approximate_recommendation
  s.add_runtime_dependency 'cfndsl-aws-serverless', Gem::Version.new(CfnDsl::Aws::Serverless::VERSION).approximate_recommendation
end
