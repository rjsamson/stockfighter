# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stockfighter/version'

Gem::Specification.new do |spec|
  spec.name          = "stockfighter"
  spec.version       = Stockfighter::VERSION
  spec.authors       = ["Robert J Samson"]
  spec.email         = ["rjsamson@me.com"]
  spec.summary       = %q{An API wrapper for Starfighter's Stockfighter}
  spec.description   = %q{An API wrapper for Starfighter's Stockfighter - see www.stockfighter.io}
  spec.homepage      = "https://github.com/rjsamson/stockfighter"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "httparty", "~> 0.13.7"
  spec.add_runtime_dependency "rufus-scheduler", "~> 3.1.10"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
