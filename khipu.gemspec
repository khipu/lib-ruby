# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'khipu/version'

Gem::Specification.new do |spec|
  spec.name          = "khipu"
  spec.version       = Khipu::VERSION
  spec.authors       = ["Alex Lorca"]
  spec.email         = ["alex.lorca@khipu.com"]
  spec.description   = "A wrapper for khipu's web API"
  spec.summary       = "A wrapper for khipu's web API"
  spec.homepage      = "https://github.com/khipu/lib-ruby"
  spec.license       = "BSD"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 1.9"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
