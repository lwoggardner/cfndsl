# frozen_string_literal: true

require_relative 'ref_check'
require_relative 'external_parameters'

module CfnDsl
  # An object whose instance variables are converted to json
  module JSONable
    include RefCheck

    # Use instance variables to build a json object. Instance
    # variables that begin with a single underscore are elided.
    # Instance variables that begin with two underscores have one of
    # them removed.
    def as_json(_options = {})
      hash = {}
      instance_variables.each do |var|
        name = var[1..-1]

        if name =~ /^__/
          # if a variable starts with double underscore, strip one off
          name = name[1..-1]
        elsif name =~ /^_/
          # Hide variables that start with single underscore
          name = nil
        end

        hash[name] = instance_variable_get(var) if name
      end
      hash
    end

    def to_json(*args)
      as_json.to_json(*args)
    end

    def ref_children
      instance_variables.map { |var| instance_variable_get(var) }
    end
  end
end
