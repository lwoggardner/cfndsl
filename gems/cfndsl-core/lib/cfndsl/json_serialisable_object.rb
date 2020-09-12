# frozen_string_literal: true

require_relative 'ref_check'

module CfnDsl
  # JSONSerialisableObject contains a single jsonable value
  #
  class JSONSerialisableObject
    include RefCheck

    attr_reader :value

    def initialize(value)
      @value = value
    end

    def as_json(_options = {})
      @value
    end

    def to_json(*args)
      as_json.to_json(*args)
    end

    def ref_children
      [@value]
    end
  end
end
