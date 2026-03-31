# frozen_string_literal: true

# Mainlayer Ruby SDK — Create a resource
#
# Demonstrates creating resources of each type with each fee model.
#
# Usage:
#   MAINLAYER_API_KEY=ml_live_... ruby examples/create_resource.rb

require "mainlayer"

client = Mainlayer::Client.new(
  api_key: ENV.fetch("MAINLAYER_API_KEY") do
    abort "Set MAINLAYER_API_KEY before running this example."
  end
)

# Pay-per-call API
api_resource = client.resources.create(
  slug:        "weather-api-#{Time.now.to_i}",
  type:        "api",
  price_usdc:  0.005,
  fee_model:   "pay_per_call",
  description: "Real-time weather data for any city",
  callback_url: "https://yourapp.com/mainlayer/callback"
)
puts "Created API resource: #{api_resource['id']}"

# One-time file download
file_resource = client.resources.create(
  slug:        "ml-model-weights-#{Time.now.to_i}",
  type:        "file",
  price_usdc:  9.99,
  fee_model:   "one_time",
  description: "Fine-tuned model weights (2.4 GB)"
)
puts "Created file resource: #{file_resource['id']}"

# Subscription endpoint
subscription_resource = client.resources.create(
  slug:        "realtime-feed-#{Time.now.to_i}",
  type:        "endpoint",
  price_usdc:  4.99,
  fee_model:   "subscription",
  description: "Real-time data feed — monthly subscription"
)
puts "Created subscription resource: #{subscription_resource['id']}"

# Update price
client.resources.update(api_resource["id"], price_usdc: 0.01)
puts "Updated price to $0.01/call"

# Clean up
[api_resource, file_resource, subscription_resource].each do |r|
  client.resources.delete(r["id"])
  puts "Deleted #{r['id']}"
end
