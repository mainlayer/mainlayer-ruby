# frozen_string_literal: true

module Mainlayer
  module Resources
    # Provides authentication operations against the Mainlayer API.
    #
    # Access via {Mainlayer::Client#auth}.
    #
    # @example Exchange credentials for an access token
    #   response = client.auth.login(email: "me@example.com", password: "s3cr3t")
    #   puts response["access_token"]
    class AuthResource < Resource
      # Register a new account.
      #
      # @param email [String] account email address
      # @param password [String] account password (minimum 8 characters)
      # @return [Hash] response containing +:access_token+ and +:user_id+
      # @raise [Mainlayer::InvalidRequestError] if email or password is invalid
      #
      # @example
      #   result = client.auth.register(email: "newuser@example.com", password: "securepass123")
      #   token  = result["access_token"]
      #   user_id = result["user_id"]
      def register(email:, password:)
        post("/auth/register", { email: email, password: password })
      end

      # Authenticate with email and password, returning an access token.
      #
      # The returned token can be used as the +api_key+ for subsequent requests.
      # Store it securely and treat it like a password.
      #
      # @param email [String] account email address
      # @param password [String] account password
      # @return [Hash] response containing +:access_token+
      # @raise [Mainlayer::AuthenticationError] if credentials are invalid
      #
      # @example
      #   result = client.auth.login(email: "you@example.com", password: "hunter2")
      #   token  = result["access_token"]
      def login(email:, password:)
        post("/auth/login", { email: email, password: password })
      end
    end
  end
end
