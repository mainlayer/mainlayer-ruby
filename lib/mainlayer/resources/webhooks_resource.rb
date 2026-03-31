# frozen_string_literal: true

module Mainlayer
  module Resources
    # Create and list webhook endpoints for your Mainlayer account.
    #
    # Webhooks are called by Mainlayer after events such as successful payments,
    # subscription renewals, and entitlement expirations.
    #
    # Access via {Mainlayer::Client#webhooks}.
    #
    # @example Register a webhook
    #   webhook = client.webhooks.create(
    #     url:    "https://yourapp.com/mainlayer/events",
    #     events: ["payment.succeeded", "payment.failed"]
    #   )
    #   puts webhook["id"]
    class WebhooksResource < Resource
      # Register a new webhook endpoint.
      #
      # Mainlayer will send POST requests to +url+ whenever any of the
      # specified +events+ occur. Payloads are signed with your account's
      # webhook secret.
      #
      # @param url [String] publicly reachable HTTPS endpoint
      # @param events [Array<String>] list of event types to subscribe to.
      #   Pass +["*"]+ to receive all events.
      # @return [Hash] the created webhook object including +:id+ and +:secret+
      # @raise [Mainlayer::InvalidRequestError] if +url+ is not a valid HTTPS URL
      #
      # @example
      #   webhook = client.webhooks.create(
      #     url:    "https://api.example.com/hooks/mainlayer",
      #     events: ["payment.succeeded"]
      #   )
      def create(url:, events:)
        post("/webhooks", { url: url, events: events })
      end

      # List all registered webhook endpoints.
      #
      # @return [Array<Hash>] array of webhook objects
      #
      # @example
      #   client.webhooks.list.each { |w| puts w["url"] }
      def list
        get("/webhooks")
      end
    end
  end
end
