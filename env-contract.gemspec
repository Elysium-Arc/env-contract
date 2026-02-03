# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "env/contract/version"

Gem::Specification.new do |spec|
  spec.name = "env-contract"
  spec.version = EnvContract::VERSION
  spec.authors = ["MounirGaiby"]
  spec.email = ["mounirgaiby@gmail.com"]

  spec.summary = "Typed ENV contracts with validation and sample generation."
  spec.description = "Define required/optional ENV variables with type casting and validation."
  spec.homepage = "https://github.com/elysium-arc/env-contract"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/elysium-arc/env-contract"
  spec.metadata["changelog_uri"] = "https://github.com/elysium-arc/env-contract/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = "bin"
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]



  spec.add_development_dependency "bundler", ">= 1.17"
  spec.add_development_dependency "rake", ">= 13.0"
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "simplecov", "~> 0.22"
end
