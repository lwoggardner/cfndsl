# frozen_string_literal: true

require_relative 'registry_specification'
require_relative 'mustache'
require 'open-uri'
require 'zip'

# Monkey patch string with underscore (snake_case)
class String
  def underscore
    gsub(/::/, '/')
      .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      .gsub(/([a-z\d])([A-Z])/, '\1_\2')
      .tr('-', '_')
      .downcase
  end
end

module CfnDsl
  # Generate classes from json registry specification
  module Generate

    Resource = Struct.new(:type, :organization, :service, :resource, :file)

    # Generator for an organization
    class Organization < Mustache
      self.template_file = "#{__dir__}/../../../templates/organization.rb.mustache"
      attr_reader :organization, :services

      def initialize(organization, services)
        @organization = organization
        @services = services
      end
    end

    # Generator for a service
    class Service < Mustache
      self.template_file = "#{__dir__}/../../../templates/service.rb.mustache"
      attr_reader :service, :resources

      def initialize(service, resources)
        @service = service
        @resources = resources
      end
    end

    module_function

    def each_zip_entry(uri)
      return enum_for(:each_zip_entry, uri) unless block_given?

      URI.open(uri) { |f| Zip::File.open(f) { |zf| zf.each { |entry| yield entry.get_input_stream.read } } }
    end

    def each_dir_entry(dir)
      return enum_for(:each_dir_entry, dir) unless block_given?

      Dir.glob("#{@dir}/**/*.json") { |f| yield f.read }
    end

    def generate_resource(spec_json, target:)
      rs = RegistrySpecification.new(JSON.parse(spec_json))
      rb_path = "#{target}/#{rs.organization.underscore}/#{rs.service.underscore}"
      rb_file = "#{rb_path}/#{rs.resource.underscore}.rb"
      puts "Generating #{rs.type} to #{rb_file}"
      FileUtils.mkdir_p(rb_path)
      File.write(rb_file, Rufo.format(rs.render, quote_style: :single))
      Resource.new(rs.type, rs.organization, rs.service, rs.resource, rb_file)
    end

    def generate_organization(resources, target:)
      resources.group_by(&:organization).each_pair do |provider, provider_resources|
        provider_path = "#{target}/#{provider.underscore}"
        services = provider_resources.group_by(&:service)
        services.each_pair do |service, service_resources|
          service_path = "#{provider_path}/#{service.underscore}"
          puts "Generating #{service_path}.rb"
          File.write("#{service_path}.rb", Service.new(service.underscore, service_resources.map { |r| r.resource.underscore }).render)
        end
        puts "Generating #{provider_path}.rb"
        File.write("#{provider_path}.rb", Organization.new(provider.underscore, services.keys.map(&:underscore)).render)
      end
    end

    def generate_all(zip_or_dir, target: Dir.pwd)
      yielder = zip_or_dir.end_with?('.zip') ? each_zip_entry(zip_or_dir) : each_dir_entry(zip_or_dir)
      resources = yielder.map { |spec_json| generate_resource(spec_json, target: target) }
      generate_organization(resources, target: target)
      resources
    end

    def generate_gem(zip_or_dir, target: Dir.pwd, gem_name: File.basename(target), gemspec_path: "#{target}/#{gem_name}.gemspec")
      resources = generate_all(zip_or_dir, target: "#{target}/lib/cfndsl")
      gemspec = GemSpec.new(path: gemspec_path, resources: resources)
      puts "Writing Gem #{gemspec.spec.name} to #{gemspec_path}"
      File.write(gemspec_path, gemspec.render)
      warn "  gem version changed from #{gemspec.spec.version} -> #{gemspec.version}" if gemspec.spec.version != gemspec.version
    end

    def generate(file, target: "#{file.sub(/\.json$/, '')}.rb")
      puts "Generating #{target} from registry spec #{file}"
      File.write(target, RegistrySpecification.read(file).render)
    end

    def invoke!(argv = ARGV)
      file = argv[0]
      if File.directory?(file) || file.end_with?('.zip')
        generate_all(file)
      else
        generate_file(file)
      end
    end
  end
end
