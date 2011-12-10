require 'rubygems'
gem 'minitest'
require 'minitest/autorun'

require 'mocha_standalone'

class MiniTest::Unit::TestCase
  include Mocha::API

  def teardown
    mocha_verify
    mocha_teardown
  end
end
