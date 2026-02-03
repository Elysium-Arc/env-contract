# Env Contract

Typed ENV contracts with validation and sample generation.

## About
Env Contract lets you define required and optional environment variables with types, defaults, and descriptions. It validates values at boot time and provides a `env-contract` CLI to generate `.env.sample` output.

This is useful for services that need clear, enforceable configuration contracts and easy onboarding.

## Use Cases
- Enforce required configuration at boot time
- Generate `.env.sample` files for onboarding and docs
- Prevent misconfigurations in multi-env deployments

## Compatibility
- Ruby 3.0+

## Installation
```ruby
# Gemfile

gem "env-contract"
```

## Usage
```ruby
EnvContract.define do
  required :DATABASE_URL, type: :string, desc: "Primary DB"
  optional :REDIS_URL, type: :string
  optional :RETRIES, type: :integer, default: 3
end

values = EnvContract.load!
```

## Types
- `:string`
- `:integer`
- `:float`
- `:boolean`
- `:json`

## CLI
Generate `.env.sample`:
```bash
env-contract > .env.sample
```

## Rails
```ruby
# config/application.rb
config.env_contract.validate_on_boot = true
```

## Release
```bash
bundle exec rake release
```
