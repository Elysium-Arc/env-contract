# frozen_string_literal: true

RSpec.describe EnvContract do
  before do
    EnvContract.reset!
  end

  it "loads required variables with casting" do
    EnvContract.define do
      required :API_TOKEN, type: :string
      optional :RETRIES, type: :integer, default: 3
    end

    ENV["API_TOKEN"] = "abc"

    values = EnvContract.load!
    expect(values["API_TOKEN"]).to eq("abc")
    expect(values["RETRIES"]).to eq(3)
  ensure
    ENV.delete("API_TOKEN")
  end

  it "casts booleans and json" do
    EnvContract.define do
      required :ENABLED, type: :boolean
      required :CONFIG, type: :json
      required :RATIO, type: :float
    end

    ENV["ENABLED"] = "true"
    ENV["CONFIG"] = '{"a":1}'
    ENV["RATIO"] = "1.25"

    values = EnvContract.load!
    expect(values["ENABLED"]).to eq(true)
    expect(values["CONFIG"]["a"]).to eq(1)
    expect(values["RATIO"]).to eq(1.25)
  ensure
    ENV.delete("ENABLED")
    ENV.delete("CONFIG")
    ENV.delete("RATIO")
  end

  it "casts boolean variants" do
    EnvContract.define do
      required :ENABLED, type: :boolean
      required :DISABLED, type: :boolean
    end

    ENV["ENABLED"] = "yes"
    ENV["DISABLED"] = "0"

    values = EnvContract.load!
    expect(values["ENABLED"]).to eq(true)
    expect(values["DISABLED"]).to eq(false)
  ensure
    ENV.delete("ENABLED")
    ENV.delete("DISABLED")
  end

  it "raises for invalid boolean" do
    EnvContract.define do
      required :ENABLED, type: :boolean
    end

    ENV["ENABLED"] = "nope"
    expect { EnvContract.load! }.to raise_error(EnvContract::InvalidType)
  ensure
    ENV.delete("ENABLED")
  end

  it "returns nil for missing optional values without defaults" do
    EnvContract.define do
      optional :MAYBE_SET, type: :string
    end

    values = EnvContract.load!
    expect(values["MAYBE_SET"]).to be_nil
  end

  it "casts false boolean values" do
    EnvContract.define do
      required :ENABLED, type: :boolean
    end

    ENV["ENABLED"] = "false"
    values = EnvContract.load!
    expect(values["ENABLED"]).to eq(false)
  ensure
    ENV.delete("ENABLED")
  end

  it "casts arrays with default separators" do
    EnvContract.define do
      required :HOSTS, type: :array
    end

    ENV["HOSTS"] = "a,b, c"

    values = EnvContract.load!
    expect(values["HOSTS"]).to eq(%w[a b c])
  ensure
    ENV.delete("HOSTS")
  end

  it "casts arrays with custom separators and array defaults" do
    EnvContract.define do
      optional :HOSTS, type: :array, separator: ";", default: ["a", "b"]
    end

    values = EnvContract.load!
    expect(values["HOSTS"]).to eq(%w[a b])
  end

  it "casts enums and rejects invalid values" do
    EnvContract.define do
      required :REGION, type: :enum, values: %w[us eu]
    end

    ENV["REGION"] = "us"
    expect(EnvContract.load!["REGION"]).to eq("us")

    ENV["REGION"] = "apac"
    expect { EnvContract.load! }.to raise_error(EnvContract::InvalidType)
  ensure
    ENV.delete("REGION")
  end

  it "raises when enum values are missing" do
    EnvContract.define do
      required :REGION, type: :enum
    end

    ENV["REGION"] = "us"
    expect { EnvContract.load! }.to raise_error(EnvContract::InvalidType)
  ensure
    ENV.delete("REGION")
  end

  it "supports callable types" do
    EnvContract.define do
      required :PORT, type: ->(value) { Integer(value) + 1 }
    end

    ENV["PORT"] = "2999"
    values = EnvContract.load!
    expect(values["PORT"]).to eq(3000)
  ensure
    ENV.delete("PORT")
  end

  it "raises for invalid integer" do
    EnvContract.define do
      required :COUNT, type: :integer
    end

    ENV["COUNT"] = "nope"
    expect { EnvContract.load! }.to raise_error(EnvContract::InvalidType)
  ensure
    ENV.delete("COUNT")
  end

  it "raises for unknown type" do
    EnvContract.define do
      required :FOO, type: :mystery
    end

    ENV["FOO"] = "bar"
    expect { EnvContract.load! }.to raise_error(EnvContract::InvalidType)
  ensure
    ENV.delete("FOO")
  end

  it "raises for missing required variables" do
    EnvContract.define do
      required :MISSING_VAR, type: :string
    end

    expect { EnvContract.load! }.to raise_error(EnvContract::MissingVariable)
  end

  it "generates sample output" do
    EnvContract.define do
      required :DATABASE_URL, type: :string, desc: "Primary DB"
      optional :RETRIES, type: :integer, default: 3
    end

    sample = EnvContract.sample
    expect(sample).to include("# Primary DB")
    expect(sample).to include("DATABASE_URL=")
    expect(sample).to include("RETRIES=3")
  end
end
