require 'cfndsl/generate'
require 'open-uri'
#Convert the json schema below to registry schema and then generate resources
#https://github.com/aws/serverless-application-model/blob/develop/samtranslator/validator/sam_schema/schema.json
#
#     https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-property-function-eventsource.html
#
#     Only include defintions that are AWS::Serverless::.* CloudFormationResource
module CfnDsl
  module Generate
    module ServerlessAppModelSpecification

      module_function

      def invoke!(argv = ARGV)
        generate_aws_serverless(argv[0])
      end

      def generate_aws_serverless(schema_file, target_path = ".")
        service_path = "#{target_path}/aws/serverless"
        FileUtils.mkdir_p service_path unless File.directory?(service_path)
        resource_specs = registry_specs(URI.open(schema_file) { |f| JSON.parse(f.read) })
        resource_specs.each do |rs|
          target = "#{service_path}/#{rs.resource.underscore}.rb"
          puts "Generating #{target}"
          File.write(target, rs.render)
        end

        puts "Generating #{service_path}.rb"
        File.write("#{service_path}.rb", Service.new("serverless", resource_specs.map { |r| r.resource.underscore }).render)
      end

      def extract_definitions(property_definitions)
        property_definitions.map do |(type_name,type_def)|
          type_spec = {type: 'object', properties: extract_properties(type_def), required: type_def['required'] || []}.transform_keys(&:to_s)
          [ type_name.split('.').last, type_spec]
        end.to_h
      end

      def extract_properties(properties_spec)
        # collapse anyOf,allOf (arrays of maps)  type or $ref
        #Flatten anyOf/allOf in Properties (for Resources), properties (for Types)
        #and inside properties we can anyOf string, object, array etc. Take the last one.
        #        Or Function.Events is an object that can be many types.. anyOf (all refs) - treat this as Map.
        #
        #     support passing class in this case?
        #     Events(Aws::Serverless::Function::S3Event) do {
        #         Bucket(x)
        #     }
        #
        # prefer order ruby_type, object, single_ref, Map (multiple refs), array<ruby_type>, array<singleRef>, array<Map multiple array refs>
        # but in practice we can just take the last one in the list as this seems to be the convention
        # UNLESS they are all $refs in which case > Map
        # collapse anyOf/allOf to find list of properties
        # for each property collapse anyOf/allOf to find "type" or "$ref"
        #
        # possible keys are "anyOf","allOf","properties" - with anyOf, allOf being recursive
        properties = collapse(properties_spec) do |key, old_value, new_value|
          if key == 'properties'
            old_value.merge(new_value)
          else
            raise "Unexpected duplicate property #{key}(#{old_value},#{new_value})"
          end
        end['properties']
        properties.transform_values! do |v|
          property_type = collapse(v) do |key, old_value, new_value|
            case key
            when 'type'
              if [old_value, new_value].include?('array')
                'array'
              elsif [old_value, new_value].include?('object')
                'object'
              else
                new_value
              end
            when 'items'
              new_value # later items type wins
            when '$ref'
              # duplicate ref => type Map
              'Map'
            end
          end

          next {'type' => 'Map'} if property_type['$ref'] == 'Map'
          next {'$ref' => property_type['$ref'].split('.').last} if property_type.key?('$ref')
          next {'type' => 'Map'} if  property_type['type'] == 'object'
          if property_type['type'] == 'array' && !property_type.key?('items')
            property_type['items'] = { 'type' => 'string' } # some list types don't have item type
          end
          property_type
        end
      end

      def collapse(spec, &block)
        return spec unless spec.is_a?(Hash)
        spec.each.with_object({}) do |(k, v), collapsed|
          case k
          when 'anyOf', 'allOf'
            v.each { |item| collapsed.merge!(collapse(item, &block), &block) }
          else
            collapsed.merge!({k => v}, &block)
          end
        end
      end


      def to_registry_spec(resource, resource_spec, property_definitions)
        registry_spec = {
            typeName: resource,
            definitions: extract_definitions(property_definitions),
            properties: extract_properties(resource_spec.dig('properties', 'Properties')),
            required: resource_spec.dig('properties', 'Properties', 'required') || []
        }
        registry_spec.transform_keys(&:to_s)
      end

      def registry_specs(serverless_spec)
        definitions = serverless_spec['definitions'].select { |k, _v| k.start_with?('AWS::Serverless::') }

        #Resource definitions have a property "Type" that is an enum, and/or do not contain a .
        resource_types, property_types = definitions.partition { |(k, _v)| !k.index('.') }.map(&:to_h)
        property_types_by_resource = property_types.group_by { |k, v| k.split('.', 2).first }.transform_values(&:to_h)

        resource_types.map do |resource, serverless_resource_spec|
          CfnDsl::Generate::RegistrySpecification.new(to_registry_spec(resource, serverless_resource_spec, property_types_by_resource[resource]))
        end
      end
    end
  end
end

if __FILE__ == $0
  CfnDsl::Generate::ServerlessAppModelSpecification.invoke!
end