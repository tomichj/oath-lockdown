lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'oath/lockdown/version'

Gem::Specification.new do |spec|
  spec.name          = 'oath-lockdown'
  spec.version       = Oath::Lockdown::VERSION
  spec.authors       = ['Justin Tomich']
  spec.email         = ['tomichj@gmail.com']

  spec.summary       = 'Enhancements to Oath, an authentication toolset'
  spec.description   = 'Enhancements to Oath, an authentication toolset'
  spec.homepage      = 'https://github.com/tomichj/oath-lockdown'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'oath', '~> 1.1.0'
  spec.add_dependency 'rails'
  spec.add_dependency 'warden'

  spec.add_development_dependency 'active_hash'
  spec.add_development_dependency 'capybara'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'timecop'
end
