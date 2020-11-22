# Major version upgrades

## 1.x to 2.x

Gem Separation

* `cfndsl-core` does not include any resource types!!
* `cfndsl-generate` code to generate resources from cloudformation registry schema
* `cfndsl-aws` generated code for AWS resources (from us-east-1 schema)
* `cfndsl-aws-serverless` generated code for AWS Serverless (non registry schema in github converted to registry schema)
* `cfndsl` is a shim to include core and aws types

Types generated from registry schema as Ruby files which can be indexed by IDEs, have generated documentation etc..

* Removes options, rake tasks for updating the json spec
* Removed CfnLego options as covered by ri/rdoc on cfndsl-aws gem

The DSL Matches CloudFormation more closely with fewer shortcuts, alternate names etc
* moved Rules/Constraints to ServiceCatalogTemplate - which is a CloudFormationTemplate with Rules. 
* removed Hooks (TODO: Q for @gergnz what are Hooks?)

## 0.x to 1.x

### Deprecations

* FnFormat => FnSub
* addTag => add_tag
* checkRefs => check_refs
* Ruby versions < 2.4
* Legacy cfndsl resource specification files

### Validation

* Tighter validation including for null values and cyclic references in Resources, Outputs, Rules and Conditions
* Tighter definition of duplicates. eg. Route must be EC2_Route because another service now has a Route resource.
* Requires the specification file to exist at the time it is explicitly set with CfnDsl.specification_file=

#### Spec version 

The AWS cloudformation spec will be regularly updated on every release

