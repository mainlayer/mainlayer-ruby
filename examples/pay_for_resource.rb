# frozen_string_literal: true

# Mainlayer Ruby SDK — Pay for a resource and verify access
#
# This example shows how a consumer would pay for a resource and then
# use the entitlements API to gate access in their own application.
#
# Usage:
#   MAINLAYER_API_KEY=ml_live_... RESOURCE_ID=res_xxx ruby examples/pay_for_resource.rb

require "mainlayer"

client = Mainlayer::Client.new(
  api_key: ENV.fetch("MAINLAYER_API_KEY") do
    abort "Set MAINLAYER_API_KEY before running this example."
  end
)

resource_id  = ENV.fetch("RESOURCE_ID") { abort "Set RESOURCE_ID" }
payer_wallet = ENV.fetch("PAYER_WALLET", "demo_wallet_address")

# Look up the resource before paying
info = client.resources.retrieve(resource_id)
puts "Resource: #{info['slug']}"
puts "Price:    $#{info['price_usdc']} (#{info['fee_model']})"

# Pre-flight: check if we already have access
existing = client.entitlements.check(resource_id: resource_id, payer_wallet: payer_wallet)
if existing["has_access"]
  puts "Already have access! Expires: #{existing['expires_at'] || 'never'}"
  exit 0
end

# Initiate payment
puts "\nInitiating Mainlayer payment..."
payment = client.payments.create(resource_id: resource_id, payer_wallet: payer_wallet)
puts "Payment ID:     #{payment['id']}"
puts "Payment status: #{payment['status']}"

# Verify entitlement after payment
access = client.entitlements.check(resource_id: resource_id, payer_wallet: payer_wallet)
if access["has_access"]
  puts "\nAccess granted!"
  puts "Expires at:        #{access['expires_at'] || 'never'}"
  puts "Credits remaining: #{access['credits_remaining'] || 'unlimited'}"
else
  puts "\nPayment is pending — access will be granted once confirmed."
end

# List all payments
puts "\nPayment history:"
client.payments.list.each do |p|
  puts "  #{p['id']} — #{p['resource_id']} — #{p['status']}"
end
