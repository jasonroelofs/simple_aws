SimpleAWS Changelog
===================

1.2.2
-----

* HTTParty 0.11 and Nokogiri > 1.5
* Handle parsing empty bodies
* Fix response body xml check to look at start of string

1.2.1
-----

* Improve handling of S3 post body sizes and content-types
* Update S3 sample to work with 0 and 1 files in the bucket
* Add S3#post
* Fix iso8601 Date parsing for 1.8.7
* Convert Time and Date objects to ISO 8601 format
* Add debug capabilities to API
* Fix handling of empty sring responses

1.2
---

* SimpleDB
* JRuby support via Nokogiri
* STS
* DynamoDB

1.1
---

* Change AWS:: to SimpleAWS:: and require 'aws/...' to require 'simple_aws/...'

1.0
---

* Initial release!
