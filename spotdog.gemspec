# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spotdog/version'

Gem::Specification.new do |spec|
  spec.name          = "spotdog"
  spec.version       = Spotdog::VERSION
  spec.authors       = ["Daisuke Fujita"]
  spec.email         = ["dtanshi45@gmail.com"]

  spec.summary       = %q{Send EC2 Spot Instance Price History to Datadog}
  spec.description   = %q{Send EC2 Spot Instance Price History to Datadog}
  spec.homepage      = "https://github.com/dtan4/spotdog"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-sdk", "~> 2.1.15"
  spec.add_dependency "dogapi"
  spec.add_dependency "thor"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "codeclimate-test-reporter"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "terminal-notifier-guard"
  spec.add_development_dependency "timecop"
end
