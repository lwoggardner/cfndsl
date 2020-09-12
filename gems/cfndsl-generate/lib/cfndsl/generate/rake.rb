# frozen_string_literal: true

require_relative 'generate'

module CfnDsl
  # Provide options for Generate
  module Generate
    class << self
      attr_accessor :default_zip
    end
  end
end

namespace :cfndsl do
  desc 'Generate provider gem'
  task :generate_gem, [:zip, :target] do |_task, rake_args|
    rake_args.with_defaults(zip: CfnDsl::Generate.default_zip)
    CfnDsl::Generate.generate_gem(rake_args[:zip])
  end

  desc 'Generate'
  task :generate, [:zip] do |_task, rake_args|
    rake_args.with_defaults(zip: CfnDsl::Generate.default_zip)
    CfnDsl::Generate.generate_all(rake_args[:zip], target: './lib/cfndsl')
  end
end
