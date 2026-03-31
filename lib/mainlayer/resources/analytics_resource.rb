# frozen_string_literal: true

module Mainlayer
  module Resources
    # Retrieve analytics and revenue data for your Mainlayer account.
    #
    # Access via {Mainlayer::Client#analytics}.
    #
    # @example Fetch account analytics
    #   stats = client.analytics.get
    #   puts "Total revenue: $#{stats['total_revenue_usdc']}"
    #   puts "Total payments: #{stats['total_payments']}"
    class AnalyticsResource < Resource
      # Retrieve analytics for the authenticated account.
      #
      # Returns aggregate metrics including revenue, payment counts, and
      # per-resource breakdowns.
      #
      # @return [Hash] analytics data with keys such as:
      #   - +:total_revenue_usdc+ [Float]
      #   - +:total_payments+ [Integer]
      #   - +:resources+ [Array<Hash>] per-resource breakdown
      #
      # @example
      #   stats = client.analytics.get
      #   puts stats["total_payments"]
      def get
        client.get("/analytics")
      end
    end
  end
end
d
