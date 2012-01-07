Gem::Specification.new do |s|
  s.name     = "simple_aws"
  s.version  = "0.0.1b"
  s.platform = Gem::Platform::RUBY
  s.authors  = ["Jason Roelofs"]
  s.email    = ["jameskilton@gmail.com"]

#  s.homepage = ""

  s.summary     = "The simplest and easiest to use and maintain AWS communication library"
  s.description = "The simplest and easiest to use and maintain AWS communication library"

  s.add_dependency "ox"
  s.add_dependency "httparty"
  s.add_dependency "httmultiparty"

  s.add_dependency "jruby-openssl" if RUBY_PLATFORM == 'java'

  s.files         = `git ls-files`.split "\n"
  s.test_files    = `git ls-files -- test/*`.split "\n"
  s.require_paths = ['lib']
end
