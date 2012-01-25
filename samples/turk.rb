$: << File.expand_path("../../lib", __FILE__)

require 'simple_aws/mechanical_turk'

##
# Expects your Amazon keys to be in the environment, something like
#
# export AWS_KEY="KEY"
# export AWS_SECRET="SECRET"
##

turk = SimpleAWS::MechanicalTurk.new ENV["AWS_KEY"], ENV["AWS_SECRET"], true

p turk.SearchHITs
