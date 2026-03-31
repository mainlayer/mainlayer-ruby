# frozen_string_literal: true

# Mainlayer Ruby SDK — Quickstart
#
# This script demonstrates the full workflow: create a resource,
# pay for it, and verify access.
#
# Usage:
#   MAINLAYER_API_KEY=ml_live_... ruby examples/quickstart.rb

require "mainlayer"

# ── Configuration ────────────────────────────────────────────────────────────

Mainlayer.configure do |config|
  config.api_key = ENV.fetch("MAINLAYER_API_KEY") do
    abort "Set MAINLAYER_API_KEY before running this example."
  end
end

client = Mainlayer::Client.new

# ── Create a resource ────────────────────────────────────────────────────────

puts "Creating resource..."
resource = client.resources.create(
  slug:        "quickstart-demo-#{Time.now.to_i}",
  type:        "api",
  price_usdc:  0.01,
  fee_model:   "pay_per_call",
  description: "A demo API created by the Mainlayer Ruby SDK quickstart"
)

puts "  Created: #{resource['id']} (#{resource['slug']})"
puts "  Price:   $#{resource['price_usdc']} per call"

# ── List resources ───────────────────────────────────────────────────────────

puts "\nListing all resources..."
all = client.resources.list
puts "  Found #{all.length} resource(s)"
all.each { |r| puts "    - #{r['slug']} [#{r['type']}]" }

# ── Pay for the resource ─────────────────────────────────────────────────────

PAYER_WALLET = "demo_wallet_address_replace_me"

puts "\nPaying for resource..."
payment = client.payments.create(
  resource_id:  resource["id"],
  payer_wallet: PAYER_WALLET
)
puts "  Payment #{payment['id']}: #{payment['status']}"

# ── Check entitlement ────────────────────────────────────────────────────────

puts "\nChecking entitlement..."
access = client.entitlements.check(
  resource_id:  resource["id"],
  payer_wallet: PAYER_WALLET
)
puts "  Has access: #{access['has_access']}"
puts "  Expires at: #{access['expires_at'] || 'never'}"
puts "  Credits remaining: #{access['credits_remaining'] || 'unlimited'}"

# ── Fetch analytics ──────────────────────────────────────────────────────────

puts "\nFetching analytics..."
stats = client.analytics.get
puts "  Total revenue: $#{stats['total_revenue_usdc']}"
puts "  Total payments: #{stats['total_payments']}"

# ── Discover ─────────────────────────────────────────────────────────────────

puts "\nSearching marketplace..."
results = client.discover.search(q: "demo", limit: 5)
puts "  Found #{results.length} public resource(s)"

# ── Clean up ─────────────────────────────────────────────────────────────────

puts "\nDeleting demo resource..."
client.resources.delete(resource["id"])
puts "  Done."
