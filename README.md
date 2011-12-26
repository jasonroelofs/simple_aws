SimpleAWS
=========

A thin, simple, forward compatible Ruby wrapper around the various Amazon AWS API.

What? Why?!
-----------

Another Ruby library to talk to Amazon Web Services? Why don't you just use fog
or aws or aws-sdk or right_aws or any of the myriad of others already in existence?
Why are you creating yet another one?

There's a simple, two part answer to this:

### Complexity

It's in the name. *Simple* AWS. This library focuses on being the simplest possible way
to communicate with AWS. There's been a growing trend in the Ruby Library scene to abstract
and wrap everything possible in ActiveRecord-like objects so the library user doesn't
have to worry about the details of sending requests and parsing responses from AWS.
Some make it harder than others to get to the raw requests, but once down there you
run into the other problem these libraries have.

### Forward Compatibility

Yes, not Backward, *Forward* compatibility. SimpleAWS is completely forward compatible to
any changes AWS makes to it's various APIs. It's well known that Amazon's AWS
is constantly changing, constantly being updated and added to. Unfortunately, there isn't
a library out there that lives this truth. Either parameters are hard coded, or response
values are hard coded, and for all of them the requests themselves are hard built into
the libraries, making it very hard to work with new API requests.

It's time for a library that evolves with Amazon AWS automatically and refuses to
get in your way. AWS's API is extremely well documented, consistent, and clean. The libraries
we use to interact with the API should match these truths as well.

How Simple?
-----------

Open a connection to the interface you want to talk to, and start calling methods.

```ruby
ec2 = AWS::EC2.new(key, secret)
response = ec2.describe_instances
```

If this looks familiar to other libraries, well, it's hard to get much simpler than this. Once
you move past no parameter methods though, the differences abound. What happens when Amazon
adds another parameter to DescribeInstances? SimpleAWS doesn't care, just start using it.

SimpleAWS is as light of a Ruby wrapper around the AWS APIs as possible. There are no
hard-coded parameters, no defined response types, you work directly with what the AWS
API says you get.

What SimpleAWS does do is to hide the communication complexities, the XML parsing, and
if you want to use it, some of the odd parameter systems AWS uses (PublicIp.n and the like).
On top of this, SimpleAWS works to ensure everything possible is as Ruby as possible. Methods
are underscore, the Response object can be queried using methods or a hash structure, and
parameter keys are converted to CamelCase strings as needed.

You're trying to use Amazon AWS, don't let libraries get in your way.

Implemented APIs
----------------

These are the following Amazon APIs that SimpleAWS currently handles:

* EC2
* ELB
* IAM
* MapReduce
* Auto Scaling
* RDS
* ElastiCache
* Elastic Beanstalk
* CloudFormation
* SNS

Yet to be Implemented
---------------------

* S3
* Route53
* CloudFront
* SQS (Simple Queue Service)
* SES (Simple Email Service)
* FWS (Fulfillment Web Service)
* Mechanical Turk

Project Info
------------

Author: Jason Roelofs (https://github.com/jameskilton)

Source: https://github.com/jameskilton/simple_aws

Issues: https://github.com/jameskilton/simple_aws/issues

[![Travis CI Build Status](https://secure.travis-ci.org/jameskilton/simple_aws.png)](http://travis-ci.org/jameskilton/simple_aws)

