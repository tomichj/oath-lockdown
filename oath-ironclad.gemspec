# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'oath/ironclad/version'

Gem::Specification.new do |spec|
  spec.name          = "oath-ironclad"
  spec.version       = Oath::Ironclad::VERSION
  spec.authors       = ["Justin Tomich"]
  spec.email         = ["tomichj@gmail.com"]

  spec.summary       = %q{Enhancements to Oath, an authentication toolset}
  spec.description   = %q{Enhancements to Oath, an authentication toolset}
  spec.homepage      = "https://github.com/tomichj/oath-ironclad"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency "rails", "~> 5.2"
  spec.add_dependency "oath", "~> 1.1.0"
end
