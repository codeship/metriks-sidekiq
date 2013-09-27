# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'metriks_sidekiq/version'

Gem::Specification.new do |spec|
  spec.name          = "metriks-sidekiq"
  spec.version       = Metriks::Sidekiq::VERSION
  spec.authors       = ["beanieboi"]
  spec.email         = ["beanie@benle.de"]
  spec.description   = %q{measure sidekiq performance with Metriks}
  spec.summary       = %q{measure sidekiq performance with Metriks}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "metriks"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rspec', '~> 2.14'
end
