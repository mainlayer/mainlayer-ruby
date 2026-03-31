#!/usr/bin/env ruby
# frozen_string_literal: true

# Buyer Example: Discover, Pay for, and Use Resources
#
# This example demonstrates the buyer workflow:
# 1. Discover resources in the marketplace
# 2. Create a payment for a resource
# 3. Check entitlement before using
# 4. View payment history

require "mainlayer"

api_key = ENV.fetch("MAINLAYER_API_KEY")
Mainlayer.configure { |c| c.api_key = api_key }
client = Mainlayer::Client.new

buyer_wallet = "0xBuyerWalletAddress123"

# 1. Discover resources in the marketplace
puts "Discovering resources in the marketplace..."
results = client.discover.search(
  q:         "summarizer",
  type:      "api",
  fee_model: "pay_per_call",
  limit:     5
)

if results.empty?
  puts "No resources found. Creating a test resource..."
  # Create one for demonstration
  resource = client.resources.create(
    slug:        "demo-summarizer",
    type:        "api",
    price_usdc:  0.05,
    fee_model:   "pay_per_call",
    description: "Test resource for buyer example"
  )
  resource_id = resource["id"]
else
  puts "Found #{results.length} resources:"
  results.each do |res|
    puts "  - #{res['slug']}: $#{res['price_usdc']} via #{res['fee_model']}"
  end
  resource_id = results.first["id"]
end
puts

# 2. Make a payment for a resource
puts "Making payment for resource #{resource_id}..."
payment = client.payments.create(
  resource_id:  resource_id,
  payer_wallet: buyer_wallet
)
puts "Payment created!"
puts "  Payment ID: #{payment['id']}"
puts "  Status: #{payment['status']}"
puts "  Amount: $#{payment['amount_usdc']}"
puts

# 3. Check entitlement before using the resource
puts "Checking access entitlement..."
access = client.entitlements.check(
  resource_id:  resource_id,
  payer_wallet: buyer_wallet
)

if access["has_access"]
  puts "Access GRANTED!"
  puts "  Expires: #{access['expires_at'] || 'never'}"
  puts "  Credits remaining: #{access['credits_remaining'] || 'unlimited'}"
  puts "  You can now use this resource."
else
  puts "Access DENIED - payment may still be processing"
end
puts

# 4. View payment history
puts "Payment history:"
payments = client.payments.list
if payments.empty?
  puts "  No payments yet"
else
  payments.first(5).each do |p|
    puts "  - Payment #{p['id']}: $#{p['amount_usdc']} (#{p['status']})"
  end
end
