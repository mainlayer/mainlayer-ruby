# frozen_string_literal: true

module Mainlayer
  module Resources
    # CRUD operations for Mainlayer resources (APIs, files, endpoints, pages).
    #
    # A *resource* is any monetizable asset you publish on Mainlayer. Callers
    # can pay for access using {PaymentsResource} and check entitlements via
    # {EntitlementsResource}.
    #
    # Access via {Mainlayer::Client#resources}.
    #
    # @example Full lifecycle
    #   # Create
    #   res = client.resources.create(
    #     slug:        "my-weather-api",
    #     type:        "api",
    #     price_usdc:  0.01,
    #     fee_model:   "pay_per_call",
    #     description: "Real-time weather data"
    #   )
    #
    #   # List all
    #   all = client.resources.list
    #
    #   # Retrieve one
    #   res = client.resources.retrieve(res["id"])
    #
    #   # Update price
    #   client.resources.update(res["id"], price_usdc: 0.02)
    #
    #   # Delete
    #   client.resources.delete(res["id"])
    class ResourcesResource < Resource
      # Valid resource types accepted by the API.
      TYPES = %w[api file endpoint page].freeze

      # Valid fee models accepted by the API.
      FEE_MODELS = %w[one_time subscription pay_per_call].freeze

      # List all resources belonging to the authenticated account.
      #
      # @return [Array<Hash>] array of resource objects
      #
      # @example
      #   resources = client.resources.list
      #   resources.each { |r| puts "#{r['slug']} — $#{r['price_usdc']}" }
      def list
        get("/resources")
      end

      # Create a new resource.
      #
      # @param slug [String] URL-safe identifier (unique per account)
      # @param type [String] one of +"api"+, +"file"+, +"endpoint"+, +"page"+
      # @param price_usdc [Float] price in USDC (e.g. +0.10+ for $0.10)
      # @param fee_model [String] one of +"one_time"+, +"subscription"+, +"pay_per_call"+
      # @param description [String, nil] optional human-readable description
      # @param callback_url [String, nil] optional webhook URL called after payment
      # @return [Hash] the created resource object
      # @raise [Mainlayer::InvalidRequestError] if required params are missing or invalid
      #
      # @example
      #   resource = client.resources.create(
      #     slug:        "gpt-summariser",
      #     type:        "api",
      #     price_usdc:  0.05,
      #     fee_model:   "pay_per_call",
      #     description: "Summarise any text with GPT-4"
      #   )
      def create(slug:, type:, price_usdc:, fee_model:, description: nil, callback_url: nil)
        validate_type!(type)
        validate_fee_model!(fee_model)

        body = {
          slug:       slug,
          type:       type,
          price_usdc: price_usdc,
          fee_model:  fee_model
        }
        body[:description]  = description  if description
        body[:callback_url] = callback_url if callback_url

        post("/resources", body)
      end

      # Retrieve a single resource by ID (authenticated).
      #
      # @param id [String] the resource ID
      # @return [Hash] the resource object
      # @raise [Mainlayer::NotFoundError] if the resource does not exist
      #
      # @example
      #   resource = client.resources.retrieve("res_abc123")
      def retrieve(id)
        get("/resources/#{id}")
      end

      # Retrieve a resource's public metadata without authentication.
      #
      # Useful for displaying resource information to unauthenticated callers.
      #
      # @param id [String] the resource ID
      # @return [Hash] public resource metadata
      # @raise [Mainlayer::NotFoundError] if the resource does not exist
      #
      # @example
      #   info = client.resources.retrieve_public("res_abc123")
      #   puts info["description"]
      def retrieve_public(id)
        get("/resources/public/#{id}")
      end

      # Update an existing resource.
      #
      # Only the fields you provide will be changed (partial update).
      #
      # @param id [String] the resource ID
      # @param params [Hash] fields to update (same keys as {#create})
      # @option params [String]  :slug
      # @option params [Float]   :price_usdc
      # @option params [String]  :description
      # @option params [String]  :callback_url
      # @return [Hash] the updated resource object
      # @raise [Mainlayer::NotFoundError] if the resource does not exist
      #
      # @example
      #   client.resources.update("res_abc123", price_usdc: 0.20)
      def update(id, **params)
        validate_type!(params[:type])      if params.key?(:type)
        validate_fee_model!(params[:fee_model]) if params.key?(:fee_model)

        patch("/resources/#{id}", params)
      end

      # Delete a resource permanently.
      #
      # This action is irreversible. Any outstanding entitlements associated
      # with the resource will be unaffected.
      #
      # @param id [String] the resource ID
      # @return [Hash] a confirmation object
      # @raise [Mainlayer::NotFoundError] if the resource does not exist
      #
      # @example
      #   client.resources.delete("res_abc123")
      def delete(id)
        client.delete("/resources/#{id}")
      end

      private

      def validate_type!(type)
        return if TYPES.include?(type.to_s)

        raise InvalidRequestError,
              "Invalid type #{type.inspect}. Must be one of: #{TYPES.join(', ')}"
      end

      def validate_fee_model!(fee_model)
        return if FEE_MODELS.include?(fee_model.to_s)

        raise InvalidRequestError,
              "Invalid fee_model #{fee_model.inspect}. Must be one of: #{FEE_MODELS.join(', ')}"
      end
    end
  end
end
