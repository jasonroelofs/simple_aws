$: << File.expand_path("../../lib", __FILE__)

require 'aws/s3'

##
# Expects your Amazon keys to be in the environment, something like
#
# export AWS_KEY="KEY"
# export AWS_SECRET="SECRET"
#
# Usage:
#   ruby sample/s3.rb [resource path] [file to save to]
#
# This script shows one way to work with batch downloading big files from S3.
# Ensure the resource path starts with the bucket in question.
##

def bad_usage
  puts ""
  puts "Usage:"
  puts "  ruby sample/s3_batch_download.rb [bucket name] [file to use]"
  exit 1
end

s3 = AWS::S3.new ENV["AWS_KEY"], ENV["AWS_SECRET"]

s3_resource = ARGV[0]
save_to = ARGV[1]
batch_size = 1_000_000


# First, get the full size of the file in question
file_size = s3.head(s3_resource).headers["content-length"].to_i

puts "File is #{file_size} bytes"
puts "Now downloading in batches of #{batch_size} bytes"

chunk_count = 0
bytes_start = 0
bytes_to = batch_size

File.open save_to, "w+" do |file|
  while bytes_start < file_size
    puts "Chunk #{chunk_count} : #{bytes_start} - #{bytes_to}"
    file.write s3.get(s3_resource, :headers => {"Range" => "bytes=#{bytes_start}-#{bytes_to}" }).body

    bytes_start = bytes_to + 1
    bytes_to += batch_size
    chunk_count += 1
  end
end

puts "Done"
