# frozen_string_literal: true

module Mainlayer
  # Abstract base class for all Mainlayer API resource wrappers.
  #
  # Subclasses receive a reference to the {Mainlayer::Client} instance and
  # delegate HTTP calls through it.
  #
  # @abstract Subclass and implement resource-specific methods.
  class Resource
    # @param client [Mainlayer::Client] the authenticated API client
    def initialize(client)
      @client = client
    end

    private

    # @return [Mainlayer::Client]
    attr_reader :client

    # Delegate GET requests to the client.
    #
    # @param path [String] API path (e.g. "/resources")
    # @param params [Hash] query parameters
    # @return [Hash, Array]
    def get(path, params = {})
      client.get(path, params)
    end

    # Delegate POST requests to the client.
    #
    # @param path [String] API path
    # @param body [Hash] request body
    # @return [Hash]
    def post(path, body = {})
      client.post(path, body)
    end

    # Delegate PATCH requests to the client.
    #
    # @param path [String] API path
    # @param body [Hash] request body
    # @return [Hash]
    def patch(path, body = {})
      client.patch(path, body)
    end

    # Delegate DELETE requests to the client.
    #
    # @param path [String] API path
    # @return [Hash]
    def delete(path)
      client.delete(path)
    end
  end
end
)
    end

    # Convenience aliases used by subclasses (match naming convention).
    alias get http_get
    alias post http_post
    alias patch http_patch
    alias delete http_delete
  end
end
