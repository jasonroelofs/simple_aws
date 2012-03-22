$: << File.expand_path("../../lib", __FILE__)

require 'simple_aws/sts'

##
# Expects your Amazon keys to be in the environment, something like
#
# export AWS_KEY="KEY"
# export AWS_SECRET="SECRET"
##

sts = SimpleAWS::STS.new ENV["AWS_KEY"], ENV["AWS_SECRET"]

p sts.get_session_token "DurationSeconds" => 3600
