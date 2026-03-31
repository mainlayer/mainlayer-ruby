# frozen_string_literal: true

module Mainlayer
  # Configuration object for the Mainlayer SDK.
  #
  # Configure globally via {Mainlayer.configure} or pass options directly
  # to {Mainlayer::Client#initialize}.
  #
  # @example Global configuration
  #   Mainlayer.configure do |config|
  #     config.api_key     = "ml_live_..."
  #     config.base_url    = "https://api.mainlayer.xyz"
  #     config.timeout     = 30
  #     config.max_retries = 3
  #   end
  class Configuration
    # Default API base URL.
    DEFAULT_BASE_URL    = "https://api.mainlayer.xyz"

    # Default open/read timeout in seconds.
    DEFAULT_TIMEOUT     = 30

    # Default maximum number of retries on transient errors.
    DEFAULT_MAX_RETRIES = 3

    # @return [String, nil] the Mainlayer API key (begins with +ml_+)
    attr_accessor :api_key

    # @return [String] the base URL for the Mainlayer API
    attr_accessor :base_url

    # @return [Integer] HTTP open/read timeout in seconds
    attr_accessor :timeout

    # @return [Integer] maximum number of automatic retries (on 429/5xx)
    attr_accessor :max_retries

    # @return [Logger, nil] a custom logger; +nil+ disables logging
    attr_accessor :logger

    def initialize
      @api_key     = nil
      @base_url    = DEFAULT_BASE_URL
      @timeout     = DEFAULT_TIMEOUT
      @max_retries = DEFAULT_MAX_RETRIES
      @logger      = nil
    end

    # Validate that the configuration has the required fields set.
    #
    # @raise [Mainlayer::AuthenticationError] if +api_key+ is blank
    # @return [void]
    def validate!
      return unless api_key.nil? || api_key.to_s.strip.empty?

      raise AuthenticationError,
            "No API key provided. Set your API key via `Mainlayer.configure` " \
            "or pass `api_key:` to Mainlayer::Client.new. " \
            "Your API key is available at https://mainlayer.xyz/dashboard."
    end
  end
end
