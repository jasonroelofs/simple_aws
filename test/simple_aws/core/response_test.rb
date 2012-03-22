require 'test_helper'
require 'simple_aws/core/response'

describe SimpleAWS::Response do

  def response_stub(success = true, code = 200)
    http_response = stub
    http_response.stubs(:headers).returns(nil)
    http_response.stubs(:success?).returns(success)
    http_response.stubs(:code).returns(code)
    http_response
  end

  describe "errors" do

    before do
      @error_response = {}
      @http_response = response_stub false, 401
    end

    it "raises if the response is not a success" do
      @error_response = {
        "Response" => {
          "Errors" => {
            "Error" => {"Code" => "AuthFailure",
              "Message" => "Message about failing to authenticate"
        }}}
      }
      @http_response.stubs(:parsed_response).returns(@error_response)

      error =
        lambda {
          SimpleAWS::Response.new @http_response
        }.must_raise SimpleAWS::UnsuccessfulResponse

      error.code.must_equal 401
      error.error_type.must_equal "AuthFailure"
      error.error_message.must_equal "Message about failing to authenticate"

      error.message.must_equal "AuthFailure (401): Message about failing to authenticate"
    end

    it "handles ErrorResponse objects" do
      @error_response = {
        "ErrorResponse" => {
          "Error" => {"Code" => "AuthFailure",
            "Message" => "Message about failing to authenticate"
        }}
      }
      @http_response.stubs(:parsed_response).returns(@error_response)

      error =
        lambda {
          SimpleAWS::Response.new @http_response
        }.must_raise SimpleAWS::UnsuccessfulResponse

      error.code.must_equal 401
      error.error_type.must_equal "AuthFailure"
      error.error_message.must_equal "Message about failing to authenticate"

      error.message.must_equal "AuthFailure (401): Message about failing to authenticate"
    end

    it "handles S3 errors" do
      @error_response = { "Error" => {
        "Code" => "AuthFailure", "Message" => "OH snap!",
        "StringToSign" => "SOME STRING"
      } }
      @http_response.stubs(:parsed_response).returns(@error_response)

      error =
        lambda {
          SimpleAWS::Response.new @http_response
        }.must_raise SimpleAWS::UnsuccessfulResponse

      error.code.must_equal 401
      error.error_type.must_equal "AuthFailure"
      error.error_message.must_equal "OH snap! String to Sign: \"SOME STRING\""

      error.message.must_equal "AuthFailure (401): OH snap! String to Sign: \"SOME STRING\""
    end

    it "handles JSON errors (e.g. DynamoDB)" do
      @error_response = { "__type" => "com.amazon.something.broke#OhNoesError",
        "Message" => "This is a failure message!"
      }
      @http_response.stubs(:parsed_response).returns(@error_response)

      error =
        lambda {
          SimpleAWS::Response.new @http_response
        }.must_raise SimpleAWS::UnsuccessfulResponse

      error.code.must_equal 401
      error.error_type.must_equal "com.amazon.something.broke#OhNoesError"
      error.error_message.must_equal "This is a failure message!"

      error.message.must_equal "com.amazon.something.broke#OhNoesError (401): " +
        "This is a failure message!"
    end

    it "handles JSON errors with bad casing" do
      @error_response = { "__type" => "com.amazon.something.broke#OhNoesError",
        "message" => "This is a failure message!"
      }
      @http_response.stubs(:parsed_response).returns(@error_response)

      error =
        lambda {
          SimpleAWS::Response.new @http_response
        }.must_raise SimpleAWS::UnsuccessfulResponse

      error.code.must_equal 401
      error.error_type.must_equal "com.amazon.something.broke#OhNoesError"
      error.error_message.must_equal "This is a failure message!"

      error.message.must_equal "com.amazon.something.broke#OhNoesError (401): " +
        "This is a failure message!"
    end

    it "raises if it can't parse the error message" do
      @error_response = { "Erroring" => "This is an error message" }
      @http_response.stubs(:parsed_response).returns(@error_response)

      error =
        lambda {
          SimpleAWS::Response.new @http_response
        }.must_raise SimpleAWS::UnknownErrorResponse

      error.message.must_match /Unable to parse error code from/
    end

    it "handles errors that have no body to parse" do
      @http_response.stubs(:code).returns(404)
      @http_response.stubs(:parsed_response).returns(nil)
      @http_response.stubs(:response).returns("This is a response ok?")

      error = lambda {
        response = SimpleAWS::Response.new @http_response
      }.must_raise SimpleAWS::UnsuccessfulResponse

      error.code.must_equal 404
      error.message.must_equal " (404): This is a response ok?"
    end
  end

  describe "successful response parsing and mapping" do
    before do
      @response_hash = {
        "CommandResponse" => {
          "xmlns" => "some url",
          "volumeId" => "v-12345",
          "domain" => "vpc"
        }
      }

      @http_response = response_stub
      @http_response.stubs(:parsed_response).returns(@response_hash)

      @response = SimpleAWS::Response.new @http_response
    end

    it "saves the parsed response" do
      @response.body.must_equal @response_hash
    end

    it "allows querying response body with ruby methods" do
      @response.volume_id.must_equal "v-12345"
      @response.domain.must_equal "vpc"

      lambda {
        @response.unknown_key
      }.must_raise NoMethodError
    end

    it "allows accessing the request through Hash format" do
      @response["volumeId"].must_equal "v-12345"
      @response["domain"].must_equal "vpc"
      @response["unknownKey"].must_be_nil
    end

    it "handles responses with no body" do
      @http_response.stubs(:parsed_response).returns(nil)
      response = SimpleAWS::Response.new @http_response
      response.body.must_be_nil
    end

    it "knows the status code of the response" do
      @response.code.must_equal 200
    end

    it "pulls out any response headers" do
      @http_response.stubs(:headers).returns({"Header1" => "Value2"})
      response = SimpleAWS::Response.new @http_response

      response.headers.must_equal "Header1" => "Value2"
    end

  end

  describe "deeply nested response/results objects" do
    it "starts inside the Result object level" do
      response_hash = {
        "CommandResponse" => {
          "xmlns" => "some url",
          "CommandResult" => {
            "volumeId" => "v-12345",
            "domain" => "vpc"
          }
        }
      }

      http_response = response_stub true, 202
      http_response.stubs(:parsed_response).returns(response_hash)

      response = SimpleAWS::Response.new http_response

      response.volume_id.must_equal "v-12345"
      response["volumeId"].must_equal "v-12345"
    end

    it "properly handles nil bodies" do
      response_hash = {
        "CommandResponse" => { "CommandResult" => nil }
      }

      http_response = response_stub true, 202
      http_response.stubs(:parsed_response).returns(response_hash)

      response = SimpleAWS::Response.new http_response
      response.wont_be_nil
    end

  end

  describe "nested responses and arrays" do
    before do
      @response_hash = {
        "CommandResponse" => {
          "xmlns" => "some url",
          "requestId" => "1234-Request-Id",
          "nothing" => nil,
          "simpleNestedObject" => {
            "name" => "Here's something deeper"
          },
          "singleItemResultsSet" => {
            "item" => {"keyId" => "1234", "domain" => "vpc"},
          },
          "multipleItemsSet" => {
            "item" => [
              {"keyId" => "1234"},
              {"keyId" => "5678"},
              {"keyId" => "9012"}
            ]
          },
          "multipleDepthSet" => {
            "key" => "value",
            "simpleInnerSet" => {
              "item" => {"range" => "14"}
            },
            "complexInnerSet" => {
              "item" => [
                {"range" => "12"},
                {"range" => "274", "deeperSet" => { "item" => {"hiddenItem" => "42"}}}
              ]
            }
          },
          "withMemberSet" => {
            "member" => {"keyId" => "4567"}
          },
          "UpperCamelKey" => "purple dog",
          "Buckets" => {
            "Bucket" => [
              {"Name" => "bucket1"},
              {"Name" => "bucket2"},
              {"Name" => "bucket3"}
            ]
          }
        }
      }

      @http_response = response_stub true, 202
      @http_response.stubs(:parsed_response).returns(@response_hash)

      @response = SimpleAWS::Response.new @http_response
    end

    describe "#keys" do
      it "lets one introspect the current depth for keys" do
        @response.simple_nested_object.keys.must_equal ["name"]
      end

      it "raises if current depth is an array" do
        lambda {
          @response.multiple_items_set.keys
        }.must_raise NoMethodError
      end
    end

    describe "method calls" do

      it "finds keys who's values are nil" do
        @response.nothing.must_be_nil
      end

      it "allows querying multiple objects deep" do
        @response.simple_nested_object.name.must_equal "Here's something deeper"
      end

      it "allows querying of a result set with one item, squashing 'item'" do
        @response.single_item_results_set.length.must_equal 1
        @response.single_item_results_set.first.key_id.must_equal "1234"
        @response.single_item_results_set.first.domain.must_equal "vpc"
      end

      it "allows enumerating through a result set with lots of items" do
        @response.multiple_items_set.length.must_equal 3
        @response.multiple_items_set[0].key_id.must_equal "1234"
        @response.multiple_items_set[1].key_id.must_equal "5678"
        @response.multiple_items_set[2].key_id.must_equal "9012"
      end

      it "allows diving into a nested result set" do
        @response.multiple_depth_set.simple_inner_set.first.range.must_equal "14"
        @response.multiple_depth_set.complex_inner_set[1].deeper_set[0].hidden_item.must_equal "42"
      end

      it "also squashes the 'member' tag" do
        @response.with_member_set[0].key_id.must_equal "4567"
      end

      it "can work with lowerCamel and UpperCamel when doing method lookup" do
        @response.upper_camel_key.must_equal "purple dog"
      end

      it "works with straight array responses" do
        @response.buckets.bucket[0].name.must_equal "bucket1"
        @response.buckets.bucket[1].name.must_equal "bucket2"
        @response.buckets.bucket[2].name.must_equal "bucket3"
      end

    end

    describe "hash keys" do

      it "finds keys who's values are nil" do
        @response["nothing"].must_be_nil
      end

      it "allows querying multiple objects deep" do
        @response["simpleNestedObject"]["name"].must_equal "Here's something deeper"
      end

      it "allows querying of a result set with one item, squashing the 'item' tag" do
        @response["singleItemResultsSet"].length.must_equal 1
        @response["singleItemResultsSet"][0]["keyId"].must_equal "1234"
        @response["singleItemResultsSet"][0]["domain"].must_equal "vpc"
      end

      it "allows enumerating through a result set with lots of items" do
        @response["multipleItemsSet"].length.must_equal 3
        @response["multipleItemsSet"][0]["keyId"].must_equal "1234"
        @response["multipleItemsSet"][1]["keyId"].must_equal "5678"
        @response["multipleItemsSet"][2]["keyId"].must_equal "9012"
      end

      it "allows diving into a nested result set" do
        @response["multipleDepthSet"]["simpleInnerSet"][0]["range"].must_equal "14"
        @response["multipleDepthSet"]["complexInnerSet"][1]["deeperSet"][0]["hiddenItem"].must_equal "42"
      end

      it "also squashes the 'member' tag" do
        @response["withMemberSet"][0]["keyId"].must_equal "4567"
      end

      it "works with straight array responses" do
        @response["Buckets"]["Bucket"][0]["Name"].must_equal "bucket1"
        @response["Buckets"]["Bucket"][1]["Name"].must_equal "bucket2"
        @response["Buckets"]["Bucket"][2]["Name"].must_equal "bucket3"
      end
    end

  end

  describe "raw body data" do

    before do
      @http_response = response_stub true, 200
      @http_response.stubs(:parsed_response).returns("raw string body")

      @response = SimpleAWS::Response.new @http_response
    end

    it "doesn't try to parse raw body data" do
      @response.body.must_equal "raw string body"
    end

    it "gives a clear error message on unknown method calls" do
      error = lambda {
        @response.some_value
      }.must_raise NoMethodError

      error.message.must_match /SimpleAWS::Response/
    end

  end

  describe "#request_id" do
    before do
      @http_response = response_stub true, 200
    end

    it "finds the top level response id" do
      response_hash = {
        "CommandResponse" => {
          "xmlns" => "some url",
          "requestId" => "1234-Request-Id"
        }
      }
      @http_response.stubs(:parsed_response).returns(response_hash)

      response = SimpleAWS::Response.new @http_response

      response.request_id.must_equal "1234-Request-Id"
    end

    it "finds response id nested" do
      response_hash = {
        "CommandResponse" => {
          "CommandResult" => {
          },
          "ResponseMetadata" => {
            "RequestId" => "1234-Request-Id"
          }
        }
      }
      @http_response.stubs(:parsed_response).returns(response_hash)

      response = SimpleAWS::Response.new @http_response

      response.request_id.must_equal "1234-Request-Id"
    end

    it "returns nil if no request id found" do
      response_hash = {
        "CommandResponse" => {
          "CommandResult" => {
          }
        }
      }
      @http_response.stubs(:parsed_response).returns(response_hash)

      response = SimpleAWS::Response.new @http_response

      response.request_id.must_be_nil
    end
  end

end
