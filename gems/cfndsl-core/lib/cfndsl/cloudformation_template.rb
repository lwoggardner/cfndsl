# frozen_string_literal: true

require_relative 'conditions'
require_relative 'parameters'
require_relative 'outputs'
require_relative 'resources'

module CfnDsl
  # rubocop:disable Metrics/ClassLength

  # Cloud Formation Templates
  class CloudFormationTemplate
    GLOBAL_REFS = {
      'AWS::NotificationARNs' => 1,
      'AWS::Region' => 1,
      'AWS::StackId' => 1,
      'AWS::StackName' => 1,
      'AWS::AccountId' => 1,
      'AWS::NoValue' => 1,
      'AWS::URLSuffix' => 1,
      'AWS::Partition' => 1
    }.freeze

    def initialize(description = nil, &block)
      @AWSTemplateFormatVersion = '2010-09-09'
      @Description = description if description
      declare(&block) if block_given?
    end

    include DSLModule

    def AWSTemplateFormatVersion(value = nil)
      dsl_attribute(:AWSTemplateFormatVersion, value)
    end

    def Description(value = nil)
      dsl_attribute(:Description, value)
    end

    def Metadata(value = nil)
      dsl_attribute(:Metadata, value, attr_class: nil) # avoid value being treated as keyword args
    end

    def Transform(value = nil)
      dsl_list_attribute(:Transform, value)
    end

    # @overload Condition(name,expression)
    #    define a Condition for the template
    # @overload Condition(name)
    #   referencing a previously defined condition in a condition expression
    def Condition(name, expression = nil)
      if expression
        dsl_content_attribute(:Conditions, name, ConditionDefinition.new(expression))
      else
        { Condition: ConditionDefinition.new(name) }
      end
    end

    def Mapping(name, value)
      dsl_content_attribute(:Mappings, name, value)
    end

    def Parameter(name, value = nil, &block)
      dsl_content_attribute(:Parameters, name, value, attr_class: ParameterDefinition, &block)
    end

    def Output(name, value = nil, &block)
      dsl_content_attribute(:Outputs, name, value, attr_class: OutputDefinition, &block)
    end

    def Resource(name, value = nil, attr_class: ResourceDefinition, &block)
      dsl_content_attribute(:Resources, name, value, attr_class: attr_class, &block)
    end

    def check_names
      (@Resources || {}).each_key.with_object([]) do |name, invalids|
        next unless name !~ /\A\p{Alnum}+\z/

        invalids << "Resource name: #{name} is invalid logical id"
      end
    end

    def check_refs
      invalids = check_condition_refs + check_resource_refs + check_output_refs + check_rule_refs
      invalids unless invalids.empty?
    end

    def valid_ref?(ref, ref_containers = [GLOBAL_REFS, @Resources, @Parameters])
      ref = ref.to_s
      ref_containers.any? { |c| c && c.key?(ref) }
    end

    def check_condition_refs
      invalids = []

      # Conditions can refer to other conditions in Fn::And, Fn::Or and Fn::Not
      invalids.concat(_check_refs(:Condition, :condition_refs, [@Conditions]))

      # They can also Ref Globals and Parameters (but not Resources))
      invalids.concat(_check_refs(:Condition, :all_refs, [GLOBAL_REFS, @Parameters]))
    end

    def check_resource_refs
      invalids = []
      invalids.concat(_check_refs(:Resource, :all_refs, [@Resources, GLOBAL_REFS, @Parameters]))

      # DependsOn and conditions in Fn::If expressions
      invalids.concat(_check_refs(:Resource, :condition_refs, [@Conditions]))
    end

    def check_output_refs
      invalids = []
      invalids.concat(_check_refs(:Output, :all_refs, [@Resources, GLOBAL_REFS, @Parameters]))
      invalids.concat(_check_refs(:Output, :condition_refs, [@Conditions]))
    end

    def check_rule_refs
      invalids = []
      invalids.concat(_check_refs(:Rule, :all_refs, [@Resources, GLOBAL_REFS, @Parameters]))
      invalids.concat(_check_refs(:Rule, :condition_refs, [@Conditions]))
      invalids
    end

    # For testing for cycles
    class RefHash < Hash
      include TSort

      alias tsort_each_node each_key
      def tsort_each_child(node, &block)
        fetch(node, []).each(&block)
      end
    end

    # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
    def _check_refs(container_name, method, source_containers)
      container = instance_variable_get("@#{container_name}s")
      return [] unless container

      invalids = []
      referred_by = RefHash.new { |h, k| h[k] = [] }
      self_check = source_containers.first.eql?(container)

      container.each_pair do |name, entry|
        name = name.to_s
        begin
          refs = entry.build_references([], self_check && name, method)
          refs.each { |r| referred_by[r.to_s] << name }
        rescue RefCheck::SelfReference, RefCheck::NullReference => e
          # Topological sort will not detect self or null references
          invalids.push("#{container_name} #{e.message}")
        end
      end

      referred_by.each_pair do |ref, names|
        unless valid_ref?(ref, source_containers)
          invalids.push "Invalid Reference: #{container_name}s #{names} refer to unknown #{method == :condition_refs ? 'Condition' : 'Reference'} #{ref}"
        end
      end

      begin
        referred_by.tsort if self_check && invalids.empty? # Check for cycles
      rescue TSort::Cyclic => e
        invalids.push "Cyclic references found in #{container_name}s #{referred_by} - #{e.message}"
      end

      invalids
    end
    # rubocop:enable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

    def validate
      errors = (check_refs || []) | check_names
      raise CfnDsl::Error, "#{errors.size} errors in template\n#{errors.join("\n")}" unless errors.empty?

      self
    end

    private

    # Shim for cfndsl 1.x AWS as default Organization,  and type only methods without Organization or Service
    def method_missing(method, *args, &block)
      if respond_to?("AWS_#{method}")
        send("AWS_#{method}", *args, &block)
      elsif (matching = public_methods(false).select { |m| m.to_s.end_with?("_#{method}") }).size == 1
        send(matching.first, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(method, include_private = false)
      return false if method.to_s.start_with?('AWS_')
      return true if respond_to?("AWS_#{method}", include_private)
      return true if public_methods.select { |m| m.to_s.end_with?("_#{method}") }.size == 1

      false
    end
  end

  # rubocop:enable Metrics/ClassLength
end
