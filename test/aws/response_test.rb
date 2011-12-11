require 'test_helper'
require 'aws/response'

describe AWS::Response do

  describe "errors" do

    it "raises if the response is not a success" do
      http_response = stub
      http_response.stubs(:success?).returns(false)
      http_response.stubs(:code).returns(401)
      http_response.stubs(:parsed_response).returns({
        "Response" => {
          "Errors" => {
            "Error" => {"Code" => "AuthFailure",
              "Message" => "Message about failing to authenticate"
        }}}
      })

      error =
        lambda {
          AWS::Response.new http_response
        }.must_raise AWS::UnsuccessfulResponse

      error.code.must_equal 401
      error.error_type.must_equal "AuthFailure"
      error.error_message.must_equal "Message about failing to authenticate"

      error.message.must_equal "AuthFailure (401): Message about failing to authenticate"
    end

  end

  describe "successful response parsing and mapping" do
    before do
      @response_hash = {
        "CommandResponse" => {
          "xmlns" => "some url",
          "requestId" => "1234-Request-Id",
          "volumeId" => "v-12345",
          "domain" => "vpc"
        }
      }

      @http_response = stub
      @http_response.stubs(:success?).returns(true)
      @http_response.stubs(:code).returns(200)
      @http_response.stubs(:parsed_response).returns(@response_hash)

      @response = AWS::Response.new @http_response
    end

    it "saves the parsed response" do
      @response.body.must_equal @response_hash
    end

    it "allows querying response body with ruby methods" do
      @response.request_id.must_equal "1234-Request-Id"
      @response.volume_id.must_equal "v-12345"
      @response.domain.must_equal "vpc"

      lambda {
        @response.unknown_key
      }.must_raise NoMethodError
    end

    it "allows accessing the request through Hash format" do
      @response["requestId"].must_equal "1234-Request-Id"
      @response["volumeId"].must_equal "v-12345"
      @response["domain"].must_equal "vpc"
      @response["unknownKey"].must_be_nil
    end

  end

end
