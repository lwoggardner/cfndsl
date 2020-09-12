# frozen_string_literal: true

require 'cfndsl/version'
require 'mustache'
require 'zip'
require 'open-uri'
require 'digest-xxhash'

module CfnDsl
  module Generate
    # Generator for gem specification
    class GemSpec < Mustache
      self.template_file = "#{__dir__}/templates/organization.rb.mustache"
      attr_reader :spec

      def initialize(path:, resources:)
        @resources = resources.sort
        @spec =
          if File.exist?(path)
            Gem::Specification.load(path)
          else
            Gem::Specification.new do |s|
              s.name = File.basename(path) # TODO: strip .gemspec
              s.summary = 'CfnDsl generated resources'
              s.description = "CfnDsl resources for #{providers.keys.join(',')}"
              s.authors = ['CfnDsl::Generate']
              s.email = ['cfndsl@github.com']
              s.version = '0.0.0'
              s.metadata = {
                'cfndsl_digest' => 'TODO',
                'cfndsl_resource_digest' => 'TODO',
                'cfndsl_generate_version' => VERSION,
                'cfndsl_version' => CfnDsl::VERSION
              }
            end
          end
      end

      def cfndsl_requirement
        Gem::Version.new(CfnDsl::VERSION).approximate_recommendation
      end

      def version
        @spec.version.version
      end

      def rb_digest
        # Calculate the digest of the ruby files for each resource
        @rb_digest ||= resources.each.with_object(Digest.new) { |r, d| d << File.read(r.file) }.base64digest
      end

      def resource_digest
        @resource_digest ||= resources.each_with_object(Digest.new) { |r, d| d << r.type }.base64digest
      end
    end
  end
end
