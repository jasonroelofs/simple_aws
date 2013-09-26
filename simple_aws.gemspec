Gem::Specification.new do |s|
  s.name     = "simple_aws"
  s.version  = "1.2.2"
  s.platform = Gem::Platform::RUBY
  s.authors  = ["Jason Roelofs"]
  s.email    = ["jasongroelofs@gmail.com"]

  s.homepage = "http://github.com/jameskilton/simple_aws"

  s.summary     = "The simplest and easiest to use AWS communication library"
  s.description = "SimpleAWS is a clean, simple, and forward compatible library for talking to the Amazon Web Service APIs."

  s.add_dependency "nokogiri", [">= 1.5.0", "< 2.0"]
  s.add_dependency "httparty", "~> 0.11.0"

  s.add_dependency "jruby-openssl" if RUBY_PLATFORM == 'java'

  s.files         = `git ls-files`.split "\n"
  s.test_files    = `git ls-files -- test/*`.split "\n"
  s.require_paths = ['lib']
end
