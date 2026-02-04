# Env Contract

[![Gem Version](https://img.shields.io/gem/v/env-contract.svg)](https://rubygems.org/gems/env-contract)
[![Gem Downloads](https://img.shields.io/gem/dt/env-contract.svg)](https://rubygems.org/gems/env-contract)
[![Ruby](https://img.shields.io/badge/ruby-3.0%2B-cc0000.svg)](https://www.ruby-lang.org)
[![CI](https://github.com/Elysium-Arc/env-contract/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/Elysium-Arc/env-contract/actions/workflows/ci.yml)
[![GitHub Release](https://img.shields.io/github/v/release/Elysium-Arc/env-contract.svg)](https://github.com/Elysium-Arc/env-contract/releases)
[![Rails](https://img.shields.io/badge/rails-6.x%20%7C%207.x%20%7C%208.x-cc0000.svg)](https://rubyonrails.org)
[![Elysium Arc](https://img.shields.io/badge/Elysium%20Arc-Reliability%20Toolkit-0b3d91.svg)](https://github.com/Elysium-Arc)

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

## Elysium Arc Reliability Toolkit
Also check out these related gems:
- Cache Coalescer: https://github.com/Elysium-Arc/cache-coalescer
- Cache SWR: https://github.com/Elysium-Arc/cache-swr
- Faraday Hedge: https://github.com/Elysium-Arc/faraday-hedge
- Rack Idempotency Kit: https://github.com/Elysium-Arc/rack-idempotency-kit

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
  optional :REGION, type: :enum, values: %w[us eu]
  optional :ALLOWED_HOSTS, type: :array, separator: ";"
end

values = EnvContract.load!
```

## Types
- `:string`
- `:integer`
- `:float`
- `:boolean`
- `:json`
- `:array`
- `:enum`

Boolean values accept `true/false`, `1/0`, and `yes/no` (case-insensitive).

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
