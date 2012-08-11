SimpleAWS [![Travis CI Build Status](https://secure.travis-ci.org/jasonroelofs/simple_aws.png)](http://travis-ci.org/jasonroelofs/simple_aws)
=========

A thin, simple, forward compatible Ruby wrapper around the various Amazon Web Service APIs.

Why?
-----------

I've used almost all of the various major AWS Ruby libraries out there at one point or another, and ever one of them has left me wanting. Each time I pick a different AWS library, I end up in the same situation: the library itself is too complex with tons of abstraction, and when Amazon updates their API, it's a lot of work to update the library to include those new changes. What if there was a library that didn't suffer from either of these issues?

### Complexity

Every Ruby AWS library I've used is simply too complex and has ended up hurting my productivity. I often found myself diving into the library's code to figure out how to call a given AWS API. Instead of just working with Amazon's API, I end up fighting the library, constantly having to re-learn whatever abstraction said library is trying to provide. They all either hard-code parameters, have their own mapping from hash keys to AWS parameters, or wrap up an Object API around everything, leading to confusion and more lost productivity when that abstraction leaks (which all abstractions do). Software is supposed to be simple to use; it's supposed to make your life easier. I've yet to find an AWS library that does this.

### Forward Compatibility

Outside of the pervasive complexity of these libraries, what finally drove me to create this library is the complete lack of forward compatibility in all of them. Any time I wanted to use a new parameter, new action, or new API, I would need to jump into the library itself to implement the missing pieces. In normal OSS fashion, this is of course to be lauded, as contributing back to libraries is what makes software better. However, in the case of API wrappers, this very quickly becomes a frustration.

Amazon constantly updates their APIs, adding parameters and actions, and at times entire new APIs. An AWS library should work *with* the API in question, not fight against it. The only thing a hard-coded parameter list does is add confusion. When you have to figure out how AWS parameters map to library parameters, or hash keys, your productivity drops. When you have to figure out how an object is calling an AWS library, and how you're supposed to use that object, your productivity drops. Likewise when you finally realize that the library does not currently support the action, parameter, or API you're trying to use at the time, your productivity is now at a complete stop.

SimpleAWS simply says no, no more leaky abstractions and confusing APIs. Just use the names of the API methods and parameters as defined in Amazon's documentation! If a new parameter is added to the API you're using, just use it. The name SimpleAWS isn't a wish or hope, it is the core philosophy. SimpleAWS focuses on being a very thin communication layer between your Ruby code and the AWS APIs. Let SimpleAWS handle the messy communication details so your code can do what it needs to do.


Surely SimpleAWS isn't just `curl`?
-----------------------------------

It is well know that AWS has its share of warts and wtfs. SimpleAWS doesn't try to fix these. What SimpleAWS does do is add as little logic as possible to make you productive and to ensure it follows the Principle of Least Surprise.

### Calling

First of all, calling actions are implemented as ruby methods, handled through mainly through `method_missing` (S3 and CloudFront are the two current exceptions). You can call the AWS actions by AWSName or by ruby_name, they both work:

``` ruby
ec2 = SimpleAWS::EC2.new key, secret
ec2.describe_instances
```

or

``` ruby
ec2 = SimpleAWS::EC2.new key, secret
ec2.DescribeInstances
```

### Parameters

Adding parameters to your method calls follows similar rules, with some Quality of Life improvements. The following three are equivalent:

#### Just Call It

You can't get simpler than just using the names of the parameters as defined in the AWS docs:

``` ruby
ec2 = SimpleAWS::EC2.new key, secret
ec2.describe_instances({
  "Filter.1.Name" => "instance-state-name",
  "Filter.1.Value.1" => "running"
  "Filter.1.Value.2" => "pending"
})
```

#### Use Ruby Arrays

Ruby Arrays will automatically be built into the "Key.n" format you see in the AWS docs:

``` ruby
ec2 = SimpleAWS::EC2.new key, secret
ec2.describe_instances({
  "Filter.1.Name" => "instance-state-name",
  "Filter.1.Value" => ["running", "pending"]
})
```

#### Use Ruby Hashes even!

You can take this the next step and use a Ruby Hash to make this even cleaner:

``` ruby
ec2 = SimpleAWS::EC2.new key, secret
ec2.describe_instances({
  "Filter" => [
    {"Name" => "instance-state-name", "Value" => ["running", "pending"]}
  ]
})
```

### Response Parsing

All requests return an SimpleAWS::Response object which does a few cleanup tasks on the resulting XML to make it easier to query and to hide some of the worst warts an XML body tends to have.

First of all, wherever AWS returns a list of items, they often get wrapped up in an `<item>` or `<member>` wrapper tag. SimpleAWS::Response gets rid of those tags and gives you a flat array to work with.

Second, the resulting XML can have one or two wrapper objects that do nothing but encapsulate the information you're interested in. SimpleAWS::Response also jumps past these wrapper objects so you have direct access to the data in the response.

All response objects are infinitely deep queryable via methods or Hash access. See the samples, tests, and SimpleAWS::Response for more details and examples of usage. At all times you can easily inspect the current Response object for the entire response body, or just the rest of the body at the current depth level.

Implemented APIs
----------------

These are the Amazon APIs that SimpleAWS currently handles:

* {SimpleAWS::AutoScaling Auto Scaling}
* {SimpleAWS::CloudFormation CloudFormation}
* {SimpleAWS::CloudFront CloudFront}
* {SimpleAWS::CloudWatch CloudWatch}
* {SimpleAWS::DynamoDB DynamoDB}
* {SimpleAWS::ElasticBeanstalk Elastic Beanstalk}
* {SimpleAWS::ELB Elastic Load Balancing (ELB)}
* {SimpleAWS::MapReduce Elastic MapReduce}
* {SimpleAWS::ElastiCache ElastiCache}
* {SimpleAWS::EC2 Elastic Compute Cloud (EC2)}
* {SimpleAWS::IAM Identity and Access Management (IAM)}
* {SimpleAWS::ImportExport Import/Export}
* {SimpleAWS::MechanicalTurk Mechanical Turk}
* {SimpleAWS::RDS Relational Database Service (RDS)}
* {SimpleAWS::SimpleDB SimpleDB}
* {SimpleAWS::SES Simple Email Service (SES)}
* {SimpleAWS::SNS Simple Notification Service (SNS)}
* {SimpleAWS::SQS Simple Queue Service (SQS)}
* {SimpleAWS::S3 Simple Storage Service (S3)}
* {SimpleAWS::STS Security Token Service (STS)}

Not currently implemented
-------------------------

* Simple Workflow Service


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
* jruby
* rubinius

### Misc Info

Author: Jason Roelofs - [Github](https://github.com/jasonroelofs) [@jasonroelofs](http://twitter.com/jasonroelofs)

Source: https://github.com/jasonroelofs/simple_aws

Issues: https://github.com/jasonroelofs/simple_aws/issues

