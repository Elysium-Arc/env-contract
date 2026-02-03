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
