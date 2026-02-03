# frozen_string_literal: true

# :nocov:
begin
  require "rails/railtie"
rescue LoadError
end

if defined?(Rails::Railtie)
  module EnvContract
    class Railtie < Rails::Railtie
      config.env_contract = ActiveSupport::OrderedOptions.new
      config.env_contract.validate_on_boot = false

      initializer "env_contract.validate" do |app|
        if app.config.env_contract.validate_on_boot
          EnvContract.load!
        end
      end
    end
  end
end
# :nocov:
