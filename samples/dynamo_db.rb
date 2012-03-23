$: << File.expand_path("../../lib", __FILE__)

require 'simple_aws/dynamo_db'

##
# Expects your Amazon keys to be in the environment, something like
#
# export AWS_KEY="KEY"
# export AWS_SECRET="SECRET"
##

dynamo_db = SimpleAWS::DynamoDB.new ENV["AWS_KEY"], ENV["AWS_SECRET"]

##
# This call will fail with a LimitExceededException on ReadCapacityUnits
# If you get any other error then there's something wrong either with your credentials
# or with the library
##
p dynamo_db.create_table "TableName" => "SimpleAWSTestTable",
  "KeySchema" => {
    "HashKeyElement" => {"AttributeName" => "index","AttributeType" => "S"},
  },
  "ProvisionedThroughput" => {"ReadCapacityUnits" => 1, "WriteCapacityUnits" => 1}
