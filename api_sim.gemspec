# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'api_sim/version'

Gem::Specification.new do |spec|
  spec.name          = "api_sim"
  spec.version       = ApiSim::VERSION
  spec.authors       = ["TJ Taylor"]
  spec.email         = ["dugancathal@gmail.com"]
  spec.licenses      = ['MIT']

  spec.summary       = %q{A DSL on top of sinatra for building application simulators}
  spec.description   = %q{A DSL on top of sinatra for building application simulators}
  spec.homepage      = "https://github.com/dugancathal/api_sim"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "sinatra", '~> 1.4'
  spec.add_dependency "nokogiri", '~> 1.6'
  spec.add_dependency "json-schema", '>= 2.5'
  spec.add_dependency "mustermann", '~> 1.0.0.beta2'
  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "capybara", "~> 2.7"
end
