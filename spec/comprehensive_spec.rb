# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Comprehensive Mainlayer SDK" do
  let(:client) { test_client }

  # ── Vendors ─────────────────────────────────────────────────────────────────

  describe Mainlayer::Resources::VendorsResource do
    subject(:vendors) { client.vendors }

    describe "#register" do
      it "POST /vendors/register with wallet signature" do
        stub_mainlayer(:post, "/vendors/register", body: {
          "id" => "vendor_abc123",
          "wallet_address" => "0x742d35Cc",
          "verified" => true
        })

        vendor = vendors.register(
          wallet_address: "0x742d35Cc",
          nonce:          "nonce_12345",
          signed_message: "0xsigned..."
        )

        expect(vendor["id"]).to eq("vendor_abc123")
        expect(vendor["verified"]).to be(true)
      end
    end
  end

  # ── Subscriptions ──────────────────────────────────────────────────────────

  describe Mainlayer::Resources::SubscriptionsResource do
    subject(:subscriptions) { client.subscriptions }

    describe "#approve" do
      it "POST /subscriptions/approve" do
        stub_mainlayer(:post, "/subscriptions/approve", body: {
          "id" => "sub_xyz789",
          "resource_id" => "res_abc123",
          "plan_id" => "plan_001",
          "status" => "active"
        })

        sub = subscriptions.approve(
          resource_id:  "res_abc123",
          plan_id:      "plan_001",
          payer_wallet: "wallet_buyer"
        )

        expect(sub["id"]).to eq("sub_xyz789")
        expect(sub["status"]).to eq("active")
      end
    end

    describe "#cancel" do
      it "POST /subscriptions/cancel" do
        stub_mainlayer(:post, "/subscriptions/cancel", body: {
          "id" => "sub_xyz789",
          "status" => "cancelled"
        })

        result = subscriptions.cancel("sub_xyz789")
        expect(result["status"]).to eq("cancelled")
      end
    end

    describe "#list" do
      it "GET /subscriptions returns array" do
        stub_mainlayer(:get, "/subscriptions", body: [{
          "id" => "sub_001",
          "status" => "active"
        }])

        subs = subscriptions.list
        expect(subs).to be_an(Array)
        expect(subs.first["id"]).to eq("sub_001")
      end
    end

    describe "#retrieve" do
      it "GET /subscriptions/{id}" do
        stub_mainlayer(:get, "/subscriptions/sub_xyz789", body: {
          "id" => "sub_xyz789",
          "status" => "active"
        })

        sub = subscriptions.retrieve("sub_xyz789")
        expect(sub["id"]).to eq("sub_xyz789")
      end
    end
  end

  # ── Resources: Extended ────────────────────────────────────────────────────

  describe Mainlayer::Resources::ResourcesResource do
    subject(:resources) { client.resources }

    describe "#activate" do
      it "PATCH /resources/{id}/activate" do
        stub_mainlayer(:patch, "/resources/res_abc123/activate", body: {
          "id" => "res_abc123",
          "status" => "active"
        })

        result = resources.activate("res_abc123")
        expect(result["status"]).to eq("active")
      end
    end

    describe "#quota" do
      it "GET /resources/{id}/quota" do
        stub_mainlayer(:get, "/resources/res_abc123/quota", body: {
          "available_credits" => 1000
        })

        quota = resources.quota("res_abc123")
        expect(quota["available_credits"]).to eq(1000)
      end

      it "PUT /resources/{id}/quota to update" do
        stub_mainlayer(:put, "/resources/res_abc123/quota", body: {
          "available_credits" => 5000
        })

        result = resources.quota("res_abc123", available_credits: 5000)
        expect(result["available_credits"]).to eq(5000)
      end
    end

    describe "#webhook_secret" do
      it "GET /resources/{id}/webhook-secret" do
        stub_mainlayer(:get, "/resources/res_abc123/webhook-secret", body: {
          "secret" => "whs_secret_long_string"
        })

        secret_info = resources.webhook_secret("res_abc123")
        expect(secret_info["secret"]).to include("whs_")
      end
    end

    describe "#plans" do
      it "GET /resources/{id}/plans" do
        stub_mainlayer(:get, "/resources/res_abc123/plans", body: [{
          "id" => "plan_001",
          "interval" => "month",
          "price_usdc" => 9.99
        }])

        plans = resources.plans("res_abc123")
        expect(plans).to be_an(Array)
        expect(plans.first["interval"]).to eq("month")
      end
    end

    describe "#create_plan" do
      it "POST /resources/{id}/plans" do
        stub_mainlayer(:post, "/resources/res_abc123/plans", body: {
          "id" => "plan_001",
          "interval" => "month",
          "interval_count" => 1,
          "price_usdc" => 9.99
        })

        plan = resources.create_plan(
          "res_abc123",
          interval:       "month",
          interval_count: 1,
          price_usdc:     9.99
        )

        expect(plan["id"]).to eq("plan_001")
        expect(plan["price_usdc"]).to eq(9.99)
      end
    end

    describe "#update_plan" do
      it "PATCH /resources/{id}/plans/{plan_id}" do
        stub_mainlayer(:patch, "/resources/res_abc123/plans/plan_001", body: {
          "id" => "plan_001",
          "price_usdc" => 11.99
        })

        plan = resources.update_plan("res_abc123", "plan_001", price_usdc: 11.99)
        expect(plan["price_usdc"]).to eq(11.99)
      end
    end

    describe "#delete_plan" do
      it "DELETE /resources/{id}/plans/{plan_id}" do
        stub_mainlayer(:delete, "/resources/res_abc123/plans/plan_001", body: {
          "deleted" => true
        })

        result = resources.delete_plan("res_abc123", "plan_001")
        expect(result["deleted"]).to be(true)
      end
    end
  end

  # ── Auth Extended ──────────────────────────────────────────────────────────

  describe Mainlayer::Resources::AuthResource do
    subject(:auth) { client.auth }

    describe "#register" do
      it "POST /auth/register" do
        stub_mainlayer(:post, "/auth/register", body: {
          "access_token" => "token_new_user",
          "user_id" => "user_123"
        })

        result = auth.register(
          email:    "newuser@example.com",
          password: "securepass123"
        )

        expect(result["access_token"]).to eq("token_new_user")
        expect(result["user_id"]).to eq("user_123")
      end
    end
  end

  # ── Payments Extended ──────────────────────────────────────────────────────

  describe Mainlayer::Resources::PaymentsResource do
    subject(:payments) { client.payments }

    describe "#retrieve" do
      it "GET /payments/{id}" do
        stub_mainlayer(:get, "/payments/payment_abc123", body: {
          "id" => "payment_abc123",
          "status" => "confirmed"
        })

        payment = payments.retrieve("payment_abc123")
        expect(payment["status"]).to eq("confirmed")
      end
    end
  end

  # ── Client HTTP Methods ────────────────────────────────────────────────────

  describe Mainlayer::Client do
    describe "#put" do
      it "sends authenticated PUT request" do
        stub_request(:put, "https://api.mainlayer.fr/test")
          .with(
            headers: { "Authorization" => "Bearer ml_test" },
            body: { "key" => "value" }.to_json
          )
          .to_return(status: 200, body: { "ok" => true }.to_json)

        result = client.put("/test", { key: "value" })
        expect(result["ok"]).to be(true)
      end
    end
  end

  # ── Error Handling ─────────────────────────────────────────────────────────

  describe "Error handling" do
    it "raises AuthenticationError for 401" do
      stub_request(:get, "https://api.mainlayer.fr/resources")
        .to_return(status: 401, body: { "error" => "Unauthorized" }.to_json)

      expect do
        client.resources.list
      end.to raise_error(Mainlayer::AuthenticationError)
    end

    it "raises PaymentRequiredError for 402" do
      stub_request(:get, "https://api.mainlayer.fr/resources")
        .to_return(status: 402, body: { "error" => "Payment required" }.to_json)

      expect do
        client.resources.list
      end.to raise_error(Mainlayer::PaymentRequiredError)
    end

    it "raises NotFoundError for 404" do
      stub_request(:get, "https://api.mainlayer.fr/resources/missing")
        .to_return(status: 404, body: { "error" => "Not found" }.to_json)

      expect do
        client.resources.retrieve("missing")
      end.to raise_error(Mainlayer::NotFoundError)
    end

    it "raises InvalidRequestError for 422" do
      stub_request(:post, "https://api.mainlayer.fr/resources")
        .to_return(status: 422, body: { "error" => "Invalid params" }.to_json)

      expect do
        client.resources.create(
          slug: "x", type: "invalid", price_usdc: 0, fee_model: "invalid"
        )
      end.to raise_error(Mainlayer::InvalidRequestError)
    end

    it "raises RateLimitError for 429" do
      stub_request(:get, "https://api.mainlayer.fr/resources")
        .to_return(status: 429, body: { "error" => "Rate limited" }.to_json)

      expect do
        client.resources.list
      end.to raise_error(Mainlayer::RateLimitError)
    end

    it "raises APIError for 5xx" do
      stub_request(:get, "https://api.mainlayer.fr/resources")
        .to_return(status: 500, body: { "error" => "Server error" }.to_json)

      expect do
        client.resources.list
      end.to raise_error(Mainlayer::APIError)
    end
  end

  # ── Integration ────────────────────────────────────────────────────────────

  describe "Full workflow integration" do
    it "completes vendor -> resource -> payment -> entitlement flow" do
      # 1. Register vendor
      stub_mainlayer(:post, "/vendors/register", body: { "id" => "vendor_1" })
      vendor = client.vendors.register(
        wallet_address: "0x123",
        nonce:          "nonce",
        signed_message: "sig"
      )
      expect(vendor["id"]).to eq("vendor_1")

      # 2. Create resource
      stub_mainlayer(:post, "/resources", body: {
        "id" => "res_1",
        "slug" => "test-api",
        "price_usdc" => 0.05
      })
      resource = client.resources.create(
        slug:        "test-api",
        type:        "api",
        price_usdc:  0.05,
        fee_model:   "pay_per_call"
      )
      expect(resource["id"]).to eq("res_1")

      # 3. Create payment
      stub_mainlayer(:post, "/payments", body: {
        "id" => "payment_1",
        "status" => "confirmed"
      })
      payment = client.payments.create(
        resource_id:  "res_1",
        payer_wallet: "wallet_buyer"
      )
      expect(payment["status"]).to eq("confirmed")

      # 4. Check entitlement
      stub_mainlayer(:get, "/entitlements/res_1/wallet_buyer", body: {
        "has_access" => true
      })
      access = client.entitlements.check(
        resource_id:  "res_1",
        payer_wallet: "wallet_buyer"
      )
      expect(access["has_access"]).to be(true)
    end

    it "completes subscription workflow" do
      # 1. Create resource
      stub_mainlayer(:post, "/resources", body: { "id" => "res_sub" })
      resource = client.resources.create(
        slug: "premium", type: "api", price_usdc: 0.01, fee_model: "subscription"
      )

      # 2. Create plan
      stub_mainlayer(:post, "/resources/res_sub/plans", body: {
        "id" => "plan_monthly"
      })
      plan = client.resources.create_plan(
        "res_sub",
        interval: "month",
        interval_count: 1,
        price_usdc: 9.99
      )
      expect(plan["id"]).to eq("plan_monthly")

      # 3. Approve subscription
      stub_mainlayer(:post, "/subscriptions/approve", body: {
        "id" => "sub_1",
        "status" => "active"
      })
      sub = client.subscriptions.approve(
        resource_id:  "res_sub",
        plan_id:      "plan_monthly",
        payer_wallet: "buyer"
      )
      expect(sub["status"]).to eq("active")

      # 4. Cancel subscription
      stub_mainlayer(:post, "/subscriptions/cancel", body: {
        "id" => "sub_1",
        "status" => "cancelled"
      })
      result = client.subscriptions.cancel("sub_1")
      expect(result["status"]).to eq("cancelled")
    end
  end
end
