# frozen_string_literal: true

module Mainlayer
  module Resources
    # Create and list Mainlayer payments.
    #
    # A payment grants a payer access to a resource according to that
    # resource's fee model (one-time, subscription, or pay-per-call).
    #
    # Access via {Mainlayer::Client#payments}.
    #
    # @example Pay for a resource
    #   payment = client.payments.create(
    #     resource_id:  "res_abc123",
    #     payer_wallet: "payer_wallet_address"
    #   )
    #   puts payment["status"]
    class PaymentsResource < Resource
      # Initiate a Mainlayer payment for a resource.
      #
      # @param resource_id [String] the ID of the resource to pay for
      # @param payer_wallet [String] the payer's wallet or account identifier
      # @return [Hash] the payment object including +:id+, +:status+, +:resource_id+
      # @raise [Mainlayer::PaymentRequiredError] if the payment cannot be processed
      # @raise [Mainlayer::NotFoundError] if the resource does not exist
      #
      # @example
      #   payment = client.payments.create(
      #     resource_id:  "res_abc123",
      #     payer_wallet: "wallet_xyz"
      #   )
      def create(resource_id:, payer_wallet:)
        post("/pay", { resource_id: resource_id, payer_wallet: payer_wallet })
      end

      # List all payments for the authenticated account.
      #
      # Returns payments received for resources you own as well as payments
      # you have made.
      #
      # @return [Array<Hash>] array of payment objects
      #
      # @example
      #   payments = client.payments.list
      #   payments.each { |p| puts "#{p['resource_id']}: #{p['status']}" }
      def list
        get("/payments")
      end
    end
  end
end
