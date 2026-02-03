# Env Contract

Typed ENV contracts with validation and sample generation.

## Install
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
