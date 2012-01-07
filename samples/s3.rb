$: << File.expand_path("../../lib", __FILE__)

require 'aws/s3'

##
# Expects your Amazon keys to be in the environment, something like
#
# export AWS_KEY="KEY"
# export AWS_SECRET="SECRET"
#
# Usage:
#   ruby sample/s3.rb [bucket name] [file to use]
#
# This script will upload the file, show that the file is up, then remove the file
##

def bad_usage
  puts ""
  puts "Usage:"
  puts "  ruby sample/s3.rb [bucket name] [file to use]"
  exit 1
end

s3 = AWS::S3.new ENV["AWS_KEY"], ENV["AWS_SECRET"]

bucket_name = ARGV[0]
file_name = ARGV[1]

puts "All buckets in this account:", ""

s3.get("/").buckets.bucket.each do |bucket|
  puts bucket.name
end

puts "", "First 10 files in #{bucket_name}:", ""

bad_usage unless bucket_name

s3.get("/", :bucket => bucket_name, :params => {"max-keys" => 10}).contents.each do |entry|
  puts entry.key
end

puts "", "Uploading #{file_name} to #{bucket_name}:", ""

bad_usage unless file_name

p s3.put("/#{File.basename file_name}", :bucket => bucket_name, :body => {:file => File.open(file_name)})
