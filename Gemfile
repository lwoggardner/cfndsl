# frozen_string_literal: true

source 'https://rubygems.org'

gem 'cfndsl', path: 'gems/cfndsl'
gem 'cfndsl-aws', path: 'gems/cfndsl-aws'
gem 'cfndsl-core', path: 'gems/cfndsl-core'
gem 'cfndsl-generate', path: 'gems/cfndsl-generate'
# gem 'cfndsl-aws-serverless', path: 'gems/cfndsl-aws-serverless'

group :development, :test, optional: true do
  gem 'github_changelog_generator'
  gem 'rubocop'
  gem 'yamllint'
end

group :test do
  gem 'aruba'
  gem 'rake'
  gem 'rspec'
  gem 'simplecov'
end
