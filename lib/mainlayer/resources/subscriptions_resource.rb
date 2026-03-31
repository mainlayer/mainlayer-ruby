# frozen_string_literal: true

module Mainlayer
  module Resources
    # Subscription management for recurring billing.
    #
    # Access via {Mainlayer::Client#subscriptions}.
    #
    # @example Approve and manage subscriptions
    #   subscription = client.subscriptions.approve(
    #     resource_id:   "res_abc123",
    #     plan_id:       "plan_xyz789",
    #     payer_wallet:  "payer_wallet_address"
    #   )
    #   puts subscription["status"]  # => "active"
    #
    #   client.subscriptions.cancel("sub_abc123")
    class SubscriptionsResource < Resource
      # Approve a subscription for a buyer.
      #
      # @param resource_id [String] the resource ID
      # @param plan_id [String] the subscription plan ID
      # @param payer_wallet [String] the buyer's wallet address
      # @return [Hash] the created subscription object
      # @raise [Mainlayer::InvalidRequestError] if approval fails
      #
      # @example
      #   sub = client.subscriptions.approve(
      #     resource_id: "res_abc123",
      #     plan_id: "plan_xyz789",
      #     payer_wallet: "buyer_wallet"
      #   )
      def approve(resource_id:, plan_id:, payer_wallet:)
        post("/subscriptions/approve", {
          resource_id:  resource_id,
          plan_id:      plan_id,
          payer_wallet: payer_wallet
        })
      end

      # Cancel an active subscription.
      #
      # @param subscription_id [String] the subscription ID
      # @return [Hash] confirmation object
      # @raise [Mainlayer::NotFoundError] if subscription does not exist
      #
      # @example
      #   client.subscriptions.cancel("sub_abc123")
      def cancel(subscription_id)
        post("/subscriptions/cancel", { subscription_id: subscription_id })
      end

      # List all subscriptions.
      #
      # @return [Array<Hash>] array of subscription objects
      #
      # @example
      #   subscriptions = client.subscriptions.list
      #   subscriptions.each { |s| puts "#{s['id']}: #{s['status']}" }
      def list
        get("/subscriptions")
      end

      # Retrieve a single subscription.
      #
      # @param subscription_id [String] the subscription ID
      # @return [Hash] the subscription object
      # @raise [Mainlayer::NotFoundError] if subscription does not exist
      #
      # @example
      #   sub = client.subscriptions.retrieve("sub_abc123")
      #   puts sub["status"]
      def retrieve(subscription_id)
        get("/subscriptions/#{subscription_id}")
      end
    end
  end
end
