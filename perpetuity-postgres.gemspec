# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'perpetuity/postgres/version'

Gem::Specification.new do |spec|
  spec.name          = "perpetuity-postgres"
  spec.version       = Perpetuity::Postgres::VERSION
  spec.authors       = ["Jamie Gaskins"]
  spec.email         = ["jgaskins@gmail.com"]
  spec.description   = %q{PostgreSQL adapter for Perpetuity}
  spec.summary       = %q{PostgreSQL adapter for Perpetuity}
  spec.homepage      = "https://github.com/jgaskins/perpetuity-postgres"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rake"
  spec.add_runtime_dependency "perpetuity", "~> 1.0.0.beta5"
  spec.add_runtime_dependency "pg"
end
