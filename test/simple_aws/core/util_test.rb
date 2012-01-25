require 'test_helper'
require 'simple_aws/core/util'

describe SimpleAWS::Util do

  describe "#build_xml_from" do
    it "takes a hash and builds XML" do
      response = SimpleAWS::Util.build_xml_from :RootNode => { :InnerNode => "Value" }

      response.must_equal <<END
<?xml version="1.0" encoding="UTF-8"?>
<RootNode>
  <InnerNode>Value</InnerNode>
</RootNode>
END
    end

    it "will add namespace to the root node" do
      response = SimpleAWS::Util.build_xml_from(
        {:RootNode => { :InnerNode => "Value" }},
        "http://cloudfront.amazonaws.com/doc/2010-11-01/"
      )

      response.must_equal <<END
<?xml version="1.0" encoding="UTF-8"?>
<RootNode xmlns="http://cloudfront.amazonaws.com/doc/2010-11-01/">
  <InnerNode>Value</InnerNode>
</RootNode>
END
    end

    it "works with arrays of items" do
      response = SimpleAWS::Util.build_xml_from(
        {:RootNode => { :InnerNode => ["Value1", "Value2", "Value3"] }}
      )

      response.must_equal <<END
<?xml version="1.0" encoding="UTF-8"?>
<RootNode>
  <InnerNode>Value1</InnerNode>
  <InnerNode>Value2</InnerNode>
  <InnerNode>Value3</InnerNode>
</RootNode>
END
    end

    it "works at any nestedness of hashes" do
      response = SimpleAWS::Util.build_xml_from(
        :RootNode => {
          :InnerNode => [
            {:Child => "Value1"},
            {:Child => "Value2"}
          ]
        }
      )

      response.must_equal <<END
<?xml version="1.0" encoding="UTF-8"?>
<RootNode>
  <InnerNode>
    <Child>Value1</Child>
  </InnerNode>
  <InnerNode>
    <Child>Value2</Child>
  </InnerNode>
</RootNode>
END
    end

    it "auto-strings all leaf nodes" do
      response = SimpleAWS::Util.build_xml_from(
        :RootNode => { :BoolVal => true, :Number => 12, :BadBool => false }
      )

      response.must_match(%r{<BoolVal>true</BoolVal>})
      response.must_match(%r{<Number>12</Number>})
      response.must_match(%r{<BadBool>false</BadBool>})
    end
  end

end
