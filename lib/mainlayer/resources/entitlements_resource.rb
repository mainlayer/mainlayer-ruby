# frozen_string_literal: true

module Mainlayer
  module Resources
    # Check whether a payer has access to a Mainlayer resource.
    #
    # Entitlements are created automatically when a payment succeeds. Use
    # this resource to gate access to your AI tools before serving a request.
    #
    # Access via {Mainlayer::Client#entitlements}.
    #
    # @example Gate access in a Rack middleware
    #   access = client.entitlements.check(
    #     resource_id:  "res_abc123",
    #     payer_wallet: request.env["HTTP_X_PAYER_WALLET"]
    #   )
    #
    #   halt 402, "Payment required" unless access["has_access"]
    class EntitlementsResource < Resource
      # Check whether a wallet has a valid entitlement for a resource.
      #
      # @param resource_id [String] the resource ID to check
      # @param payer_wallet [String] the wallet/account identifier to check
      # @return [Hash] entitlement status with keys:
      #   - +:has_access+ [Boolean] — +true+ if access is currently valid
      #   - +:expires_at+ [String, nil] — ISO 8601 expiry (nil for lifetime)
      #   - +:credits_remaining+ [Integer, nil] — remaining calls (pay-per-call only)
      # @raise [Mainlayer::NotFoundError] if the resource does not exist
      #
      # @example
      #   result = client.entitlements.check(
      #     resource_id:  "res_abc123",
      #     payer_wallet: "wallet_xyz"
      #   )
      #   # => { "has_access" => true, "expires_at" => "2024-12-31T23:59:59Z",
      #   #       "credits_remaining" => 42 }
      def check(resource_id:, payer_wallet:)
        get("/entitlements/check", {
          resource_id:  resource_id,
          payer_wallet: payer_wallet
        })
      end
    end
  end
end
