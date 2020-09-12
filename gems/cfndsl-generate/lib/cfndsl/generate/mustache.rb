# frozen_string_literal: true

require 'mustache'

module CfnDsl
  module Generate
    # Default options for Mustache
    class Mustache < ::Mustache
      self.template_path = "#{__dir__}/../../../templates"
      self.raise_on_context_miss = true
    end
  end
end
