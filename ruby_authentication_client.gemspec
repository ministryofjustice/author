# -*- encoding: utf-8 -*-
require './lib/ruby_authentication_client.rb'

Gem::Specification.new do |gem|
  gem.name          = "ruby_authentication_client"
  gem.version       = 1.0
  gem.authors       = ["Tom Gladhill"]
  gem.email         = ["whoojemaflip@gmail.com"]
  gem.description   = %q{Simple proxy class for devise authentication service.}
  gem.summary       = %q{Provides a common standard for authenticating in Rails-land.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(spec)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = '>= 2.0.0'
  gem.add_runtime_dependency 'httparty',   ">= 0.12.0"
  gem.add_development_dependency 'rspec', ">= 2.14.0"
end
