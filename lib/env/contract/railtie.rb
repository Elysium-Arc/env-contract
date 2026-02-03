# frozen_string_literal: true

require "rails/railtie"

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
