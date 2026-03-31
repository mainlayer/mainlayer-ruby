# frozen_string_literal: true

module Mainlayer
  module Resources
    # Manage API keys associated with your Mainlayer account.
    #
    # Access via {Mainlayer::Client#api_keys}.
    #
    # @example Create a new API key
    #   key = client.api_keys.create(name: "production")
    #   puts key["key"]   # ml_live_...  — store this securely, it won't be shown again
    class ApiKeysResource < Resource
      # Create a new API key.
      #
      # The raw key value is only returned once in the response. Store it
      # immediately in a secrets manager — subsequent calls return only the
      # key ID and name.
      #
      # @param name [String] a human-readable label for the key
      # @return [Hash] containing +:key+, +:id+, and +:name+
      # @raise [Mainlayer::InvalidRequestError] if +name+ is blank
      #
      # @example
      #   key = client.api_keys.create(name: "ci-bot")
      #   ENV["MAINLAYER_API_KEY"] = key["key"]
      def create(name:)
        post("/api-keys", { name: name })
      end
    end
  end
end
