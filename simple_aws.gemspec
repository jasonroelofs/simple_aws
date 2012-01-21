Gem::Specification.new do |s|
  s.name     = "simple_aws"
  s.version  = "1.0.0.pre2"
  s.platform = Gem::Platform::RUBY
  s.authors  = ["Jason Roelofs"]
  s.email    = ["jameskilton@gmail.com"]

  s.homepage = "http://github.com/jameskilton/simple_aws"

  s.summary     = "The simplest and easiest to use and maintain AWS communication library"
  s.description = "SimpleAWS is a clean, simple, and forward compatible library for talking to Amazon's AWS APIs."

  s.add_dependency "nokogiri", "~> 1.5.0"
  s.add_dependency "httparty", "~> 0.8.0"

  s.add_dependency "jruby-openssl" if RUBY_PLATFORM == 'java'

  s.files         = `git ls-files`.split "\n"
  s.test_files    = `git ls-files -- test/*`.split "\n"
  s.require_paths = ['lib']
end
