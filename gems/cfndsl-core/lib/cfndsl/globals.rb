# frozen_string_literal: true

require_relative 'version'

# Global variables to adjust CfnDsl behavior
module CfnDsl
  class Error < StandardError
  end

  module_function

  def disable_deep_merge
    @disable_deep_merge = true
  end

  def disable_deep_merge?
    @disable_deep_merge
  end
end
