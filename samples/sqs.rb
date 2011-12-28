$: << File.expand_path("../../lib", __FILE__)

require 'aws/sqs'

##
# Expects your Amazon keys to be in the environment, something like
#
# export AWS_KEY="KEY"
# export AWS_SECRET="SECRET"
##

sqs = AWS::SQS.new ENV["AWS_KEY"], ENV["AWS_SECRET"]

queue_name = "SimpleAWSTest"

puts "Creating queue #{queue_name}"
response = sqs.create_queue "QueueName" => queue_name
queue_url = response.queue_url

puts "Sending message to #{queue_url}"
sent = sqs.send_message queue_url, "MessageBody" => "This is a new message in the queue"

puts ""
p sent
puts ""

puts "Receiving message from #{queue_url}"
received = sqs.receive_message queue_url

puts ""
p received
puts ""

puts "Deleting queue #{queue_url}"
p sqs.delete_queue queue_url
