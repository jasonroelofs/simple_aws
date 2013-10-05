source "https://rubygems.org"

# Nokogiri 1.6 deprecated Ruby 1.8 support, so explicitly set
# it here for Travis.
gem "nokogiri", "~> 1.5.0", :platforms => :ruby_18

gemspec

group :development do
  gem "rake"
end

group :test do
  gem "minitest", :require => false
  gem "mocha",    :require => false
end
