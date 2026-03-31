# frozen_string_literal: true

module Mainlayer
  # Base error class for all Mainlayer errors.
  #
  # All errors raised by the Mainlayer SDK inherit from this class,
  # making it easy to rescue any Mainlayer-specific error.
  #
  # @example Rescuing any Mainlayer error
  #   begin
  #     client.resources.retrieve("nonexistent")
  #   rescue Mainlayer::Error => e
  #     puts e.message
  #     puts e.http_status
  #   end
  class Error < StandardError
    # @return [Integer, nil] the HTTP status code from the API response
    attr_reader :http_status

    # @return [String, nil] the error code returned by the API
    attr_reader :code

    # @return [Hash, nil] the full error response body
    attr_reader :response

    # @param message [String] human-readable error description
    # @param http_status [Integer, nil] HTTP status code
    # @param code [String, nil] API error code
    # @param response [Hash, nil] full error response body
    def initialize(message = nil, http_status: nil, code: nil, response: nil)
      super(message)
      @http_status = http_status
      @code        = code
      @response    = response
    end
  end

  # Raised when the API key is missing, invalid, or has been revoked.
  #
  # @example
  #   rescue Mainlayer::AuthenticationError => e
  #     puts "Invalid API key: #{e.message}"
  #   end
  class AuthenticationError < Error; end

  # Raised when the requested resource does not exist.
  #
  # @example
  #   rescue Mainlayer::NotFoundError => e
  #     puts "Resource #{resource_id} not found"
  #   end
  class NotFoundError < Error; end

  # Raised when payment is required to access the requested resource.
  #
  # @example
  #   rescue Mainlayer::PaymentRequiredError => e
  #     puts "Payment required: #{e.message}"
  #   end
  class PaymentRequiredError < Error; end

  # Raised when the API rate limit has been exceeded.
  #
  # Retry after the number of seconds specified in the +Retry-After+ header
  # or wait a moment before trying again.
  #
  # @example
  #   rescue Mainlayer::RateLimitError => e
  #     puts "Rate limited. HTTP status: #{e.http_status}"
  #   end
  class RateLimitError < Error; end

  # Raised when the request contains invalid parameters or is malformed.
  #
  # @example
  #   rescue Mainlayer::InvalidRequestError => e
  #     puts "Bad request: #{e.message}"
  #   end
  class InvalidRequestError < Error; end

  # Raised when the Mainlayer API returns a 5xx server error.
  #
  # @example
  #   rescue Mainlayer::APIError => e
  #     puts "Server error (#{e.http_status}): #{e.message}"
  #   end
  class APIError < Error; end

  # Raised when the HTTP connection times out or cannot be established.
  class ConnectionError < Error; end
end
