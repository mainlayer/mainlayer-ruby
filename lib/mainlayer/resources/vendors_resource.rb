# frozen_string_literal: true

module Mainlayer
  module Resources
    # Provides vendor registration and management operations.
    #
    # Access via {Mainlayer::Client#vendors}.
    #
    # @example Register a vendor with wallet signature
    #   vendor = client.vendors.register(
    #     wallet_address: "0x...",
    #     nonce:          "unique_nonce",
    #     signed_message: "0x..."
    #   )
    #   puts vendor["id"]
    class VendorsResource < Resource
      # Register a new vendor using wallet signature authentication.
      #
      # @param wallet_address [String] the vendor's wallet address
      # @param nonce [String] unique nonce for signature verification
      # @param signed_message [String] wallet-signed message containing the nonce
      # @return [Hash] the registered vendor object
      # @raise [Mainlayer::InvalidRequestError] if registration fails
      #
      # @example
      #   vendor = client.vendors.register(
      #     wallet_address: "0x1234567890abcdef",
      #     nonce:          "nonce_12345",
      #     signed_message: "0xabcdef1234567890"
      #   )
      def register(wallet_address:, nonce:, signed_message:)
        post("/vendors/register", {
          wallet_address: wallet_address,
          nonce:          nonce,
          signed_message: signed_message
        })
      end
    end
  end
end
