# frozen_string_literal: true

require 'aruba/rspec'

if ENV['CFNDSL_COV']
  require 'simplecov'

  SimpleCov.start do
    add_group 'Code', 'lib'
    add_group 'Test', 'spec'
  end
end

require 'cfndsl/globals'
require 'cfndsl'
Dir[File.expand_path('support/**/*.rb', __dir__)].sort.each { |f| require f }
