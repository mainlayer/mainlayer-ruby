# frozen_string_literal: true

module Mainlayer
  module Resources
    # Search and discover public Mainlayer resources.
    #
    # The discovery API is public — no authentication required to browse
    # available AI tools and services.
    #
    # Access via {Mainlayer::Client#discover}.
    #
    # @example Find weather APIs
    #   results = client.discover.search(q: "weather", type: "api", limit: 10)
    #   results.each { |r| puts "#{r['slug']} — $#{r['price_usdc']}" }
    class DiscoverResource < Resource
      # Search for public resources in the Mainlayer marketplace.
      #
      # All parameters are optional — omit them to browse all available resources.
      #
      # @param q [String, nil] full-text search query
      # @param type [String, nil] filter by type (+api+, +file+, +endpoint+, +page+)
      # @param fee_model [String, nil] filter by fee model
      #   (+one_time+, +subscription+, +pay_per_call+)
      # @param limit [Integer] maximum number of results (default: 20, max: 100)
      # @return [Array<Hash>] matching resource objects
      #
      # @example Search with filters
      #   client.discover.search(q: "image generation", fee_model: "pay_per_call", limit: 5)
      def search(q: nil, type: nil, fee_model: nil, limit: 20)
        params = { limit: limit }
        params[:q]         = q         if q
        params[:type]      = type      if type
        params[:fee_model] = fee_model if fee_model

        get("/discover", params)
      end
    end
  end
end
