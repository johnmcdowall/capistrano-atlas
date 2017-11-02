# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "capistrano/atlas/version"

Gem::Specification.new do |spec|
  spec.name          = "capistrano-atlas"
  spec.version       = Capistrano::Atlas::VERSION
  spec.author        = "John McDowall"
  spec.email         = "john@kantan.io"
  spec.description   = \
    "Does all the heavy lifting for production-ready provisioning "\
    "and deployment for the full Rails 5.1 stack. Installs and "\
    "configures Ruby, Nginx, Puma, PostgreSQL, dotenv, Let's Encrypt and "\
    "more onto Ubuntu 14.04 LTS using Capistrano. "
    
  spec.summary       = "Additional Capistrano 3 recipes"
  spec.homepage      = "https://github.com/johnmcdowall/capistrano-atlas"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "capistrano", ">= 3.3.5"
  spec.add_dependency "sshkit", ">= 1.6.1"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "chandler"
  spec.add_development_dependency "rake"
end
