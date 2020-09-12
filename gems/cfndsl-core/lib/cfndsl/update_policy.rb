# frozen_string_literal: true

require_relative 'json_serialisable_object'

module CfnDsl
  # Handles autoscaling group update policy objects for Resources
  #
  # Usage
  #   Resource("aaa") {
  #     UpdatePolicy("AutoScalingRollingUpdate", {
  #       "MinInstancesInService" => "1",
  #       "MaxBatchSize" => "1",
  #       "PauseTime" => "PT12M5S"
  #     })
  #   }
  #
  class UpdatePolicyDefinition < JSONSerialisableObject
  end
end
