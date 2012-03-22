$: << File.expand_path("../../lib", __FILE__)

require 'simple_aws/sts'
require 'simple_aws/dynamo_db'

##
# Expects your Amazon keys to be in the environment, something like
#
# export AWS_KEY="KEY"
# export AWS_SECRET="SECRET"
##

sts = SimpleAWS::STS.new ENV["AWS_KEY"], ENV["AWS_SECRET"]

creds = sts.get_session_token.credentials
session_token = creds.session_token
new_aws_key = creds.access_key_id
new_aws_secret = creds.secret_access_key

puts "Got session token #{session_token.inspect}"
puts "New Access Key #{new_aws_key}"
puts "New Access Secret #{new_aws_secret}"

dynamo_db = SimpleAWS::DynamoDB.new new_aws_key, new_aws_secret

table_name = "SimpleAWSTestTable"

p dynamo_db.create_table(session_token, {
  "TableName" => table_name,
  "KeySchema" => {
    "HashKeyElement" => {"AttributeName" => "index","AttributeType" => "S"},
  },
  "ProvisionedThroughput" => {"ReadCapacityUnits" => 1, "WriteCapacityUnits" => 1}
})
