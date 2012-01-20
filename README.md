SimpleAWS [![Travis CI Build Status](https://secure.travis-ci.org/jameskilton/simple_aws.png)](http://travis-ci.org/jameskilton/simple_aws)
=========

A thin, simple, forward compatible Ruby wrapper around the various Amazon AWS APIs. Unless otherwise mentioned below, this library will wrap every API available service listed on this page: http://aws.amazon.com/documentation/

What?! Why?
-----------

Do we really need another Ruby library to talk to Amazon Web Services? Aren't there enough libraries out there that could just use some more help to make them better? What about [fog](http://fog.io), or [aws-sdk](http://rubygems.org/gems/aws-sdk), or [aws](http://rubygems.org/gems/aws), or [right_aws](http://rubygems.org/gems/right_aws)?

While there are a number of well used libraries, I feel they have all fallen prey to the same two problems: complexity and forward incompatibility.

### Complexity

Every Ruby AWS library in use today is simply too complex. Every library I've tried to use has ended up hurting my productivity as I often have to dive into the code to find out what the parameter list is, what object I need to work with, or what hash keys map to the actual AWS API parameters. Every library that tries to build an Object Abstraction wrapper on top of AWS's APIs suffers from leaky abstractions, which results in yet more time lost trying to figure out what needs to be called, with what, and what gets returned. Software is supposed to be simple, it's supposed to make your life easier. I've yet to find an AWS library that does this.

### Forward Compatibility

Ignoring the complexity argument above, what finally drove me to create this library is the complete lack of forward compatibility in all existing Ruby AWS libraries. Any time I wanted to use a new parameter, new action, or new API, I would need to jump into the library itself and implement the missing pieces. In the usual OSS circles this doesn't sound that bad, and is in fact praised, but when you're dealing with an API library, this requirement quickly becomes a frustration.

Amazon constantly updates AWS APIs, adding parameters and actions, and at times entire new APIs. An AWS library should work *with* the API in question, not fight against it. The only thing a hard-coded parameter list does is add confusion as you have to keep two things in your mind: what you want to call, and how the library lets you call it. SimpleAWS simply says no, it won't force anything on the user. Use the names of the API methods and parameters and them alone. If a new parameter is added to the API you're using, just use it; SimpleAWS doesn't care, it will just work.

The name SimpleAWS isn't a wish or hope, it's the core philosophy. This library focuses on being a very thin communication layer between your Ruby code and Amazon's AWS APIs. Let SimpleAWS handle the messy communication details so your code can do what it needs to do letting you be more productive.

In short, it's the Unix philosophy, SimpleAWS does one thing and does it well and nothing else.


Surely SimpleAWS isn't just `curl`?
-----------------------------------

It's well know that AWS has its share of warts and wtfs. SimpleAWS doesn't try to fix these, as that's the path towards being yet another over-complicated and rigid library that SimpleAWS is trying to solve.

What SimpleAWS does do is add some logic to ensure it follows the Principle of Least Surprise.

### Calling

First of all, calling actions are implemented as ruby methods, handled through mainly through `method_missing` (S3 and CloudFront are the two exceptions). You can call the AWS actions by AWSName or by ruby_name, they both work:

```ruby
ec2 = AWS::EC2.new key, secret
ec2.describe_instances
```

or

```ruby
ec2 = AWS::EC2.new key, secret
ec2.DescribeInstances
```

### Parameters

With that in mind, here's what SimpleAWS allows. The following three are equivalent:

#### Just Call It

You can't get simpler than just using the names of the parameters as defined in the AWS docs:

```ruby
ec2 = AWS::EC2.new key, secret
ec2.describe_instances({
  "Filter.1.Name" => "instance-state-name",
  "Filter.1.Value.1" => "running"
  "Filter.1.Value.2" => "pending"
})
```

#### Use Ruby Arrays

Ruby Arrays will automatically be built into the "Key.n" format you see in the AWS docs:

```ruby
ec2 = AWS::EC2.new key, secret
ec2.describe_instances({
  "Filter.1.Name" => "instance-state-name",
  "Filter.1.Value" => ["running", "pending"]
})
```

#### Use Ruby Hashes even!

You can take this the next step and use a Ruby Hash to make this even cleaner:

```ruby
ec2 = AWS::EC2.new key, secret
ec2.describe_instances({
  "Filter" => [
    {"Name" => "instance-state-name", "Value" => ["running", "pending"]}
  ]
})
```

### Response Parsing

All requests return an AWS::Response which does a few cleanup tasks on the resulting XML to make it easier to query and to hide some of the worst warts an XML body tends to have.

First of all, wherever AWS returns a list of items, they almost always get wrapped up in an `<item>` or `<member>` wrapper tag. AWS::Response gets rid of those tags and gives you a flat array to work with.

Second, the resulting XML can have one or two wrapper objects that do nothing but encapsulate the information you're interested in. AWS::Response also jumps past these wrapper objects so you have direct access to the data in the response.

All response objects are infinitely deep queryable via methods or Hash access. See the samples, tests, and AWS::Response for more details and examples of usage. At all times you can easily inspect the current Response object for the entire response body, or just the rest of the body at the current depth level.

Implemented APIs
----------------

These are the Amazon APIs that SimpleAWS currently handles:

* {AWS::S3 S3}
* {AWS::EC2 EC2}
* {AWS::ELB ELB}
* {AWS::IAM IAM}
* {AWS::MapReduce MapReduce}
* {AWS::AutoScaling Auto Scaling}
* {AWS::RDS RDS}
* {AWS::ElastiCache ElastiCache}
* {AWS::ElasticBeanstalk Elastic Beanstalk}
* {AWS::CloudFormation CloudFormation}
* {AWS::SNS SNS}
* {AWS::CloudWatch CloudWatch}
* {AWS::ImportExport ImportExport}
* {AWS::MechanicalTurk MechanicalTurk}
* {AWS::SQS SQS}
* {AWS::SES SES}
* {AWS::CloudFront CloudFront}

Currently Out-Of-Scope
----------------------

The following API endpoints will not currently be handled in SimpleAWS. These libraries are much more complicated than just a query-and-response API and are related to systems that will most likely need a lot more work than SimpleAWS wants to give. That said if you need these APIs implemented in this library, open an Issue or a Pull Request and we'll work from there.

* FWS (Fulfillment Web Service)
* FPS & ASP (Flexible Payments Service)
* Route53

Project Info
------------

### Rubies

SimpleAWS is built to work under all major Ruby versions:

* 1.8.7
* 1.9.2
* 1.9.3
* ree
* HEAD

The following are waiting on a release of Nokogiri to fix some issues:

* jruby
* rubinius

### Misc Info

Author: Jason Roelofs (https://github.com/jameskilton)

Source: https://github.com/jameskilton/simple_aws

Issues: https://github.com/jameskilton/simple_aws/issues

