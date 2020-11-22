 
TODO: Convert the json schema below to registry schema and then generate resources
  https://github.com/aws/serverless-application-model/blob/develop/samtranslator/validator/sam_schema/schema.json
  
Resources have a property "Type" that is an enum, and/or do not contain a .
Flatten anyOf/allOf in Properties (for Resources), properties (for Types)
and inside properties we can anyOf string, object, array etc. Take the last one.
Or Function.Events is an object that can be many types.. anyOf (all refs) - treat this as Map.

support passing class in this case?
Events(Aws::Serverless::Function::S3Event) do {
   Bucket(x)
}

https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-property-function-eventsource.html

Only include defintions that are AWS::Serverless::.* CloudFormationResource  