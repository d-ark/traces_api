# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'traces_api/version'

Gem::Specification.new do |spec|
  spec.name          = "traces_api"
  spec.version       = TracesApi::VERSION
  spec.authors       = ["Anton Priadko"]
  spec.email         = ["anton.pr@randrmusic.com"]

  spec.summary       = %q{Small gem with REST API for traces}
  spec.description   = %q{Full REST API for resource :trace (set of GPS points). Based on web-framework nyny (http://alisnic.github.io/nyny/). Uses mongodb as as database}
  spec.homepage      = "https://github.com/d-ark/traces_api"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_runtime_dependency "nyny"
  spec.add_runtime_dependency "mongoid"
  spec.add_runtime_dependency "geo-distance"
  spec.add_runtime_dependency "rest-client"
end
