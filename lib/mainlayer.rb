# frozen_string_literal: true

require_relative "mainlayer/version"
require_relative "mainlayer/error"
require_relative "mainlayer/configuration"
require_relative "mainlayer/resource"
require_relative "mainlayer/resources/auth_resource"
require_relative "mainlayer/resources/api_keys_resource"
require_relative "mainlayer/resources/resources_resource"
require_relative "mainlayer/resources/payments_resource"
require_relative "mainlayer/resources/entitlements_resource"
require_relative "mainlayer/resources/discover_resource"
require_relative "mainlayer/resources/analytics_resource"
require_relative "mainlayer/resources/webhooks_resource"
require_relative "mainlayer/client"

# The Mainlayer Ruby SDK.
#
# Mainlayer is payment infrastructure for AI agents. Use this gem to create
# paid resources, accept payments, manage subscriptions, and verify access
# entitlements — all with a simple Ruby API.
#
# == Quick start
#
#   require 'mainlayer'
#
#   Mainlayer.configure do |config|
#     config.api_key = ENV.fetch('MAINLAYER_API_KEY')
#   end
#
#   client = Mainlayer::Client.new
#
#   resource = client.resources.create(
#     slug:        'my-ai-tool',
#     type:        'api',
#     price_usdc:  0.10,
#     fee_model:   'pay_per_call',
#     description: 'My AI tool'
#   )
#
# == Per-client configuration
#
#   client = Mainlayer::Client.new(api_key: 'ml_live_...')
#
# @see Mainlayer::Client
# @see https://docs.mainlayer.xyz Mainlayer API documentation
module Mainlayer
  class << self
    # The global SDK configuration.
    #
    # @return [Mainlayer::Configuration]
    def configuration
      @configuration ||= Configuration.new
    end

    # Configure the SDK globally using a block.
    #
    # Settings applied here are used by all {Client} instances that do not
    # explicitly override them.
    #
    # @yield [config] the global {Mainlayer::Configuration} object
    # @yieldparam config [Mainlayer::Configuration]
    # @return [void]
    #
    # @example
    #   Mainlayer.configure do |config|
    #     config.api_key     = ENV.fetch('MAINLAYER_API_KEY')
    #     config.max_retries = 5
    #     config.timeout     = 60
    #   end
    def configure
      yield(configuration)
    end

    # Reset the global configuration to defaults.
    #
    # Primarily useful in test suites.
    #
    # @return [void]
    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end
