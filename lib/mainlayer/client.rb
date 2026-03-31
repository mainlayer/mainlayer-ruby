# frozen_string_literal: true

require "faraday"
require "faraday/net_http"
require "json"

module Mainlayer
  # The main entry point for interacting with the Mainlayer API.
  #
  # Instantiate one client per API key. The client is thread-safe and
  # should be reused across requests.
  #
  # @example Basic usage
  #   client = Mainlayer::Client.new(api_key: "ml_live_...")
  #   resources = client.resources.list
  #
  # @example Using global configuration
  #   Mainlayer.configure { |c| c.api_key = "ml_live_..." }
  #   client = Mainlayer::Client.new
  class Client
    # @return [Mainlayer::Configuration] the configuration for this client instance
    attr_reader :config

    # Initialise a new API client.
    #
    # Any option passed here overrides the corresponding value in the global
    # {Mainlayer.configuration}.
    #
    # @param api_key [String, nil] API key; falls back to global config
    # @param base_url [String, nil] override the API base URL
    # @param timeout [Integer, nil] HTTP timeout in seconds
    # @param max_retries [Integer, nil] max retry attempts on 429/5xx
    # @param logger [Logger, nil] optional logger
    def initialize(api_key: nil, base_url: nil, timeout: nil, max_retries: nil, logger: nil)
      @config = build_config(
        api_key:     api_key,
        base_url:    base_url,
        timeout:     timeout,
        max_retries: max_retries,
        logger:      logger
      )
      @config.validate!
    end

    # @!group Resource accessors

    # Access authentication operations.
    # @return [Mainlayer::Resources::AuthResource]
    def auth
      @auth ||= Resources::AuthResource.new(self)
    end

    # Access API key management operations.
    # @return [Mainlayer::Resources::ApiKeysResource]
    def api_keys
      @api_keys ||= Resources::ApiKeysResource.new(self)
    end

    # Access resource CRUD operations.
    # @return [Mainlayer::Resources::ResourcesResource]
    def resources
      @resources ||= Resources::ResourcesResource.new(self)
    end

    # Access payment operations.
    # @return [Mainlayer::Resources::PaymentsResource]
    def payments
      @payments ||= Resources::PaymentsResource.new(self)
    end

    # Access entitlement check operations.
    # @return [Mainlayer::Resources::EntitlementsResource]
    def entitlements
      @entitlements ||= Resources::EntitlementsResource.new(self)
    end

    # Access the discovery / search API.
    # @return [Mainlayer::Resources::DiscoverResource]
    def discover
      @discover ||= Resources::DiscoverResource.new(self)
    end

    # Access analytics data.
    # @return [Mainlayer::Resources::AnalyticsResource]
    def analytics
      @analytics ||= Resources::AnalyticsResource.new(self)
    end

    # Access webhook management operations.
    # @return [Mainlayer::Resources::WebhooksResource]
    def webhooks
      @webhooks ||= Resources::WebhooksResource.new(self)
    end

    # @!endgroup

    # @!group Low-level HTTP methods

    # Send an authenticated GET request.
    #
    # @param path [String] API path (e.g. "/resources")
    # @param params [Hash] URL query parameters
    # @return [Hash, Array] parsed JSON response body
    def get(path, params = {})
      request(:get, path, params: params)
    end

    # Send an authenticated POST request.
    #
    # @param path [String] API path
    # @param body [Hash] request body (serialised to JSON)
    # @return [Hash] parsed JSON response body
    def post(path, body = {})
      request(:post, path, body: body)
    end

    # Send an authenticated PATCH request.
    #
    # @param path [String] API path
    # @param body [Hash] request body (serialised to JSON)
    # @return [Hash] parsed JSON response body
    def patch(path, body = {})
      request(:patch, path, body: body)
    end

    # Send an authenticated DELETE request.
    #
    # @param path [String] API path
    # @return [Hash] parsed JSON response body
    def delete(path)
      request(:delete, path)
    end

    # @!endgroup

    private

    # Build a {Configuration} by layering instance options on top of the
    # global configuration.
    def build_config(api_key:, base_url:, timeout:, max_retries:, logger:)
      global = Mainlayer.configuration

      cfg              = Configuration.new
      cfg.api_key      = api_key     || global.api_key
      cfg.base_url     = base_url    || global.base_url
      cfg.timeout      = timeout     || global.timeout
      cfg.max_retries  = max_retries || global.max_retries
      cfg.logger       = logger      || global.logger
      cfg
    end

    # Returns a memoised Faraday connection with middleware configured.
    #
    # @return [Faraday::Connection]
    def connection
      @connection ||= Faraday.new(url: config.base_url) do |f|
        f.request  :json
        f.response :json, content_type: /\bjson$/
        f.response :logger, config.logger if config.logger

        f.request :retry,
                  max:                 config.max_retries,
                  interval:            0.5,
                  interval_randomness: 0.5,
                  backoff_factor:      2,
                  retry_statuses:      [429, 500, 502, 503, 504],
                  exceptions:          [
                    Faraday::TimeoutError,
                    Faraday::ConnectionFailed,
                    Faraday::ServerError
                  ]

        f.options.timeout      = config.timeout
        f.options.open_timeout = config.timeout

        f.adapter :net_http
      end
    end

    # Execute an HTTP request and return the parsed body.
    #
    # @raise [Mainlayer::Error] on any non-2xx response
    def request(method, path, params: {}, body: nil)
      response = connection.send(method, path) do |req|
        req.headers["Authorization"] = "Bearer #{config.api_key}"
        req.headers["Content-Type"]  = "application/json"
        req.headers["User-Agent"]    = user_agent
        req.params.merge!(params) if params && !params.empty?
        req.body = body.to_json   if body && !body.empty?
      end

      handle_response(response)
    rescue Faraday::TimeoutError, Faraday::ConnectionFailed => e
      raise ConnectionError, "Could not connect to Mainlayer API (#{e.message}). " \
                             "Please check your network and try again."
    end

    # Map HTTP status codes to appropriate error classes and raise.
    #
    # @param response [Faraday::Response]
    # @return [Hash, Array] parsed body on success
    def handle_response(response)
      return response.body if response.success?

      body    = parse_error_body(response)
      message = extract_error_message(body, response.status)

      raise error_class_for(response.status).new(
        message,
        http_status: response.status,
        code:        body.is_a?(Hash) ? body["code"] : nil,
        response:    body
      )
    end

    def parse_error_body(response)
      response.body
    rescue StandardError
      { "message" => response.body.to_s }
    end

    def extract_error_message(body, status)
      return body["message"] if body.is_a?(Hash) && body["message"]
      return body["error"]   if body.is_a?(Hash) && body["error"]

      "Mainlayer API error (HTTP #{status})"
    end

    def error_class_for(status)
      case status
      when 401, 403 then AuthenticationError
      when 402      then PaymentRequiredError
      when 404      then NotFoundError
      when 422      then InvalidRequestError
      when 429      then RateLimitError
      when 500..599 then APIError
      else               Error
      end
    end

    def user_agent
      "mainlayer-ruby/#{Mainlayer::VERSION} Ruby/#{RUBY_VERSION}"
    end
  end
end
