# frozen_string_literal: true

source 'https://rubygems.org'

path 'gems' do
  gem 'cfndsl-core'
  gem 'cfndsl-generate'
  gem 'cfndsl-aws'
  gem 'cfndsl-aws-serverless'
  gem 'cfndsl'
end

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
