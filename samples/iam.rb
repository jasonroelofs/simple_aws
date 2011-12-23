$: << File.expand_path("../../lib", __FILE__)

require 'aws/iam'

##
# Expects your Amazon keys to be in the environment, something like
#
# export AWS_KEY="KEY"
# export AWS_SECRET="SECRET"
##

$iam = AWS::IAM.new ENV["AWS_KEY"], ENV["AWS_SECRET"]

puts "", "You are", ""

user = $iam.get_user.user
puts "Id: #{user.user_id}"
puts "Name: #{user.user_name}"
puts "Arn: #{user.arn}"
puts "Create Date: #{Time.parse user.create_date}"

puts "", "Your SSL Certificates", ""

$iam.list_server_certificates.server_certificate_metadata_list.each do |cert|
  puts "Id: #{cert.server_certificate_id}"
  puts "Path: #{cert.path}"
  puts "Arn: #{cert.arn}"
  puts "UploadDate: #{cert.upload_date}"
  puts ""
end
