#!/usr/bin/env ruby
# frozen_string_literal: true

# Subscription Example: Recurring Billing
#
# This example demonstrates subscription management:
# 1. Create a resource with subscription plans
# 2. Approve a subscription for a buyer
# 3. List active subscriptions
# 4. Cancel a subscription

require "mainlayer"

api_key = ENV.fetch("MAINLAYER_API_KEY")
Mainlayer.configure { |c| c.api_key = api_key }
client = Mainlayer::Client.new

buyer_wallet = "0xSubscriberWallet#{Time.now.to_i}"

# 1. Create a subscription resource
puts "Creating subscription resource..."
resource = client.resources.create(
  slug:        "premium-analytics-#{Time.now.to_i}",
  type:        "api",
  price_usdc:  0.01,  # Base price (not used for subscriptions)
  fee_model:   "subscription",
  description: "Premium analytics dashboard with monthly billing"
)
puts "Resource ID: #{resource['id']}\n"

# 2. Create subscription plans
puts "Creating subscription plans..."

# Monthly plan: $29.99/month
monthly = client.resources.create_plan(
  resource["id"],
  interval:       "month",
  interval_count: 1,
  price_usdc:     29.99
)
puts "Monthly Plan: #{monthly['id']} - $29.99/month"

# Annual plan: $299.99/year (2-month discount equivalent)
annual = client.resources.create_plan(
  resource["id"],
  interval:       "year",
  interval_count: 1,
  price_usdc:     299.99
)
puts "Annual Plan: #{annual['id']} - $299.99/year\n"

# 3. Approve a subscription
puts "Approving subscription for buyer..."
subscription = client.subscriptions.approve(
  resource_id:  resource["id"],
  plan_id:      monthly["id"],
  payer_wallet: buyer_wallet
)
puts "Subscription approved!"
puts "  Subscription ID: #{subscription['id']}"
puts "  Status: #{subscription['status']}"
puts "  Next billing: #{subscription['next_billing_date']}\n"

# 4. List all subscriptions
puts "All active subscriptions:"
subscriptions = client.subscriptions.list
subscriptions.each do |sub|
  puts "  - #{sub['id']}: #{sub['status']} (renewed on #{sub['next_billing_date']})"
end
puts

# 5. Retrieve a specific subscription
puts "Getting subscription details..."
sub_details = client.subscriptions.retrieve(subscription["id"])
puts "  Resource: #{sub_details['resource_id']}"
puts "  Plan: #{sub_details['plan_id']}"
puts "  Buyer: #{sub_details['payer_wallet']}"
puts "  Created: #{sub_details['created_at']}\n"

# 6. Cancel subscription
puts "Cancelling subscription..."
client.subscriptions.cancel(subscription["id"])
puts "Subscription cancelled!"
puts "Note: Access will continue until the end of the billing period.\n"

# 7. Verify it's cancelled
puts "Verifying cancellation..."
cancelled_sub = client.subscriptions.retrieve(subscription["id"])
puts "  Status: #{cancelled_sub['status']}"
