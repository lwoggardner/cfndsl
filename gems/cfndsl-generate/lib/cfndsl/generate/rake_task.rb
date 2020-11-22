# frozen_string_literal: true

require 'rake/tasklib'
require_relative 'generate'

module CfnDsl
  module Generate
    # Rake TaskLib
    class TaskLib < Rake::TaskLib

      # Creates Cloudformation generation tasks
      #
      # @example
      # directory 'tmp'
      #
      # namespace :myprovider do
      #
      #   CfnDsl::Generate::RakeTask.new do |t|
      #
      #     desc 'Generate CfnDsl library for MyProvider'
      #     t.lib(name: :lib, target: 'lib/myprovider' zip: 'http://myprovider.example.net/registry_schema.json')
      #   end
      # end
      def initialize(name = nil)
        yield self if block_given?
      end

      # Generate CfnDsl ruby library from provider registry specification
      #
      # @param [Symbol] name the name of the rake task
      # @param [String] target_dir location to build library files in
      # @param [String] zip url or file location of registry schema zip file
      # @param [String] dir a directory containing individual json files for each resource
      def lib(name: :lib, target_dir:, zip: nil, dir: nil)
        task name do |t|
          CfnDsl::Generate.generate_all(zip || dir, target: "#{target_dir}/lib/cfndsl")
        end
      end
    end
  end
end

