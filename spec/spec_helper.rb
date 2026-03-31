# frozen_string_literal: true

require "webmock/rspec"
require "mainlayer"

# Disable real HTTP connections in the test suite.
WebMock.disable_net_connect!

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.warnings = true
  config.order = :random
  Kernel.srand config.seed

  # Reset global Mainlayer configuration between tests.
  config.before do
    Mainlayer.reset_configuration!
  end
end

# ── Shared helpers ───────────────────────────────────────────────────────────

# Stub a Mainlayer API endpoint.
#
# @param method [:get, :post, :patch, :delete] HTTP method
# @param path [String] path relative to the API base (e.g. "/resources")
# @param body [Hash] response body to return
# @param status [Integer] HTTP status code
def stub_mainlayer(method, path, body: {}, status: 200)
  stub_request(method, "https://api.mainlayer.xyz#{path}")
    .to_return(
      status:  status,
      body:    body.to_json,
      headers: { "Content-Type" => "application/json" }
    )
end

# Build a test client with a known API key.
#
# @return [Mainlayer::Client]
def test_client
  Mainlayer::Client.new(api_key: "ml_test_key")
end

# ── Shared fixture data ──────────────────────────────────────────────────────

RESOURCE_FIXTURE = {
  "id"          => "res_abc123",
  "slug"        => "my-api",
  "type"        => "api",
  "price_usdc"  => 0.10,
  "fee_model"   => "pay_per_call",
  "description" => "My AI tool",
  "created_at"  => "2024-01-01T00:00:00Z"
}.freeze

PAYMENT_FIXTURE = {
  "id"           => "pay_xyz789",
  "resource_id"  => "res_abc123",
  "payer_wallet" => "wallet_addr",
  "status"       => "confirmed",
  "created_at"   => "2024-01-01T00:00:00Z"
}.freeze

ENTITLEMENT_FIXTURE = {
  "has_access"        => true,
  "expires_at"        => "2025-01-01T00:00:00Z",
  "credits_remaining" => 10
}.freeze
