# frozen_string_literal: true

require_relative 'cloudformation_template'
require_relative 'rules'

module CfnDsl
  # Service Catalog template extensions
  class ServiceCatalogTemplate < CloudFormationTemplate
    def Rule(name, value = nil, &block)
      dsl_content_attribute(:Rules, name, value, attr_class: RuleDefinition, &block)
    end
  end
end

# Main function to build and validate
# @return [CfnDsl::ServiceCatalogTemplate]
# @raise [CfnDsl::Error] if the block does not generate a valid template
def ServiceCatalog(description = nil, &block)
  CfnDsl::ServiceCatalogTemplate.new(description).declare(&block).validate
end
