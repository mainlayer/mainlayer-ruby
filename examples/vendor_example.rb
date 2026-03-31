#!/usr/bin/env ruby
# frozen_string_literal: true

# Vendor Example: Create and Monetize Resources
#
# This example demonstrates the vendor workflow:
# 1. Register a vendor with wallet signature
# 2. Create a monetizable resource
# 3. Activate the resource
# 4. Manage subscription plans
# 5. Configure webhooks
# 6. View analytics

require "mainlayer"

# Initialize client
api_key = ENV.fetch("MAINLAYER_API_KEY")
Mainlayer.configure { |c| c.api_key = api_key }
client = Mainlayer::Client.new

# 1. Register vendor (optional, if not already registered)
puts "Registering vendor..."
vendor = client.vendors.register(
  wallet_address: "0x742d35Cc6634C0532925a3b844Bc9e7595f42bE",
  nonce:          "unique_nonce_#{Time.now.to_i}",
  signed_message: "0xSignedMessageHere"
)
puts "Vendor ID: #{vendor['id']}\n"

# 2. Create a resource
puts "Creating resource..."
resource = client.resources.create(
  slug:        "ai-text-summarizer",
  type:        "api",
  price_usdc:  0.05,
  fee_model:   "pay_per_call",
  description: "Summarize any text using GPT-4 with configurable length"
)
puts "Resource ID: #{resource['id']}"
puts "Price: $#{resource['price_usdc']} per call\n"

# 3. Activate the resource
puts "Activating resource..."
client.resources.activate(resource["id"])
puts "Resource activated!\n"

# 4. Get webhook secret
puts "Getting webhook secret..."
secret_info = client.resources.webhook_secret(resource["id"])
puts "Webhook Secret: #{secret_info['secret']} (store securely!)\n"

# 5. Create subscription plans
puts "Creating subscription plans..."

# Monthly plan ($9.99/month)
monthly_plan = client.resources.create_plan(
  resource["id"],
  interval:       "month",
  interval_count: 1,
  price_usdc:     9.99
)
puts "Monthly Plan ID: #{monthly_plan['id']}"

# Quarterly plan ($24.99/quarter)
quarterly_plan = client.resources.create_plan(
  resource["id"],
  interval:       "month",
  interval_count: 3,
  price_usdc:     24.99
)
puts "Quarterly Plan ID: #{quarterly_plan['id']}\n"

# 6. List all plans
puts "All subscription plans for this resource:"
plans = client.resources.plans(resource["id"])
plans.each do |plan|
  puts "  - Plan #{plan['id']}: $#{plan['price_usdc']}/#{plan['interval']}"
end
puts

# 7. View analytics
puts "Getting analytics..."
analytics = client.analytics.get
puts "Total Revenue: $#{analytics['total_revenue_usdc']}"
puts "Total Payments: #{analytics['total_payments']}"
puts "Active Resources: #{analytics['total_resources']}\n"

# 8. List all resources
puts "Your resources:"
resources = client.resources.list
resources.each do |res|
  puts "  - #{res['slug']} (#{res['type']}): $#{res['price_usdc']} via #{res['fee_model']}"
end
