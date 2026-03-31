# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Resource wrappers" do
  let(:client) { test_client }

  # ── Resources ────────────────────────────────────────────────────────────────

  describe Mainlayer::Resources::ResourcesResource do
    subject(:resources) { client.resources }

    describe "#list" do
      it "GET /resources and returns an array" do
        stub_mainlayer(:get, "/resources", body: [RESOURCE_FIXTURE])
        result = resources.list
        expect(result).to be_an(Array)
        expect(result.first["id"]).to eq("res_abc123")
      end
    end

    describe "#create" do
      let(:stub) do
        stub_mainlayer(:post, "/resources", body: RESOURCE_FIXTURE)
      end

      before { stub }

      it "POST /resources with required params" do
        resources.create(
          slug:       "my-api",
          type:       "api",
          price_usdc: 0.10,
          fee_model:  "pay_per_call"
        )
        expect(stub).to have_been_requested
      end

      it "returns the created resource" do
        result = resources.create(
          slug: "my-api", type: "api", price_usdc: 0.10, fee_model: "pay_per_call"
        )
        expect(result["id"]).to eq("res_abc123")
      end

      it "includes optional description when provided" do
        stub_request(:post, "https://api.mainlayer.xyz/resources")
          .with(body: hash_including("description" => "My AI tool"))
          .to_return(status: 200, body: RESOURCE_FIXTURE.to_json,
                     headers: { "Content-Type" => "application/json" })

        resources.create(
          slug: "x", type: "api", price_usdc: 0.01,
          fee_model: "pay_per_call", description: "My AI tool"
        )
      end

      it "includes optional callback_url when provided" do
        stub_request(:post, "https://api.mainlayer.xyz/resources")
          .with(body: hash_including("callback_url" => "https://example.com/hook"))
          .to_return(status: 200, body: RESOURCE_FIXTURE.to_json,
                     headers: { "Content-Type" => "application/json" })

        resources.create(
          slug: "x", type: "api", price_usdc: 0.01,
          fee_model: "pay_per_call", callback_url: "https://example.com/hook"
        )
      end

      it "raises InvalidRequestError for unknown type" do
        expect do
          resources.create(
            slug: "x", type: "invalid_type", price_usdc: 0.01, fee_model: "pay_per_call"
          )
        end.to raise_error(Mainlayer::InvalidRequestError, /Invalid type/)
      end

      it "raises InvalidRequestError for unknown fee_model" do
        expect do
          resources.create(
            slug: "x", type: "api", price_usdc: 0.01, fee_model: "invalid_model"
          )
        end.to raise_error(Mainlayer::InvalidRequestError, /Invalid fee_model/)
      end

      it "accepts all valid types" do
        %w[api file endpoint page].each do |type|
          stub_mainlayer(:post, "/resources", body: RESOURCE_FIXTURE)
          expect do
            resources.create(slug: "x", type: type, price_usdc: 0.01, fee_model: "one_time")
          end.not_to raise_error
        end
      end

      it "accepts all valid fee_models" do
        %w[one_time subscription pay_per_call].each do |fm|
          stub_mainlayer(:post, "/resources", body: RESOURCE_FIXTURE)
          expect do
            resources.create(slug: "x", type: "api", price_usdc: 0.01, fee_model: fm)
          end.not_to raise_error
        end
      end
    end

    describe "#retrieve" do
      it "GET /resources/:id" do
        stub = stub_mainlayer(:get, "/resources/res_abc123", body: RESOURCE_FIXTURE)
        result = resources.retrieve("res_abc123")
        expect(stub).to have_been_requested
        expect(result["id"]).to eq("res_abc123")
      end
    end

    describe "#retrieve_public" do
      it "GET /resources/public/:id without auth requirement" do
        stub = stub_mainlayer(:get, "/resources/public/res_abc123", body: RESOURCE_FIXTURE)
        result = resources.retrieve_public("res_abc123")
        expect(stub).to have_been_requested
        expect(result["id"]).to eq("res_abc123")
      end
    end

    describe "#update" do
      it "PATCH /resources/:id with given params" do
        stub = stub_request(:patch, "https://api.mainlayer.xyz/resources/res_abc123")
          .with(body: hash_including("price_usdc" => 0.20))
          .to_return(status: 200, body: RESOURCE_FIXTURE.to_json,
                     headers: { "Content-Type" => "application/json" })

        resources.update("res_abc123", price_usdc: 0.20)
        expect(stub).to have_been_requested
      end

      it "validates type if provided" do
        expect do
          resources.update("res_abc123", type: "bad_type")
        end.to raise_error(Mainlayer::InvalidRequestError)
      end

      it "validates fee_model if provided" do
        expect do
          resources.update("res_abc123", fee_model: "bad_model")
        end.to raise_error(Mainlayer::InvalidRequestError)
      end
    end

    describe "#delete" do
      it "DELETE /resources/:id" do
        stub = stub_mainlayer(:delete, "/resources/res_abc123", body: { "deleted" => true })
        resources.delete("res_abc123")
        expect(stub).to have_been_requested
      end
    end
  end

  # ── Payments ─────────────────────────────────────────────────────────────────

  describe Mainlayer::Resources::PaymentsResource do
    subject(:payments) { client.payments }

    describe "#create" do
      it "POST /pay with resource_id and payer_wallet" do
        stub = stub_request(:post, "https://api.mainlayer.xyz/pay")
          .with(body: hash_including("resource_id" => "res_abc123", "payer_wallet" => "wallet_addr"))
          .to_return(status: 200, body: PAYMENT_FIXTURE.to_json,
                     headers: { "Content-Type" => "application/json" })

        result = payments.create(resource_id: "res_abc123", payer_wallet: "wallet_addr")
        expect(stub).to have_been_requested
        expect(result["id"]).to eq("pay_xyz789")
        expect(result["status"]).to eq("confirmed")
      end
    end

    describe "#list" do
      it "GET /payments and returns an array" do
        stub_mainlayer(:get, "/payments", body: [PAYMENT_FIXTURE])
        result = payments.list
        expect(result).to be_an(Array)
        expect(result.first["id"]).to eq("pay_xyz789")
      end
    end
  end

  # ── Entitlements ─────────────────────────────────────────────────────────────

  describe Mainlayer::Resources::EntitlementsResource do
    subject(:entitlements) { client.entitlements }

    describe "#check" do
      it "GET /entitlements/check with correct params" do
        stub = stub_request(:get, "https://api.mainlayer.xyz/entitlements/check")
          .with(query: { "resource_id" => "res_abc123", "payer_wallet" => "wallet_addr" })
          .to_return(status: 200, body: ENTITLEMENT_FIXTURE.to_json,
                     headers: { "Content-Type" => "application/json" })

        result = entitlements.check(resource_id: "res_abc123", payer_wallet: "wallet_addr")
        expect(stub).to have_been_requested
        expect(result["has_access"]).to be(true)
        expect(result["credits_remaining"]).to eq(10)
      end
    end
  end

  # ── Discover ─────────────────────────────────────────────────────────────────

  describe Mainlayer::Resources::DiscoverResource do
    subject(:discover) { client.discover }

    describe "#search" do
      it "GET /discover with default limit" do
        stub = stub_request(:get, "https://api.mainlayer.xyz/discover")
          .with(query: hash_including("limit" => "20"))
          .to_return(status: 200, body: [RESOURCE_FIXTURE].to_json,
                     headers: { "Content-Type" => "application/json" })

        discover.search
        expect(stub).to have_been_requested
      end

      it "passes query params to /discover" do
        stub = stub_request(:get, "https://api.mainlayer.xyz/discover")
          .with(query: hash_including("q" => "weather", "type" => "api", "limit" => "5"))
          .to_return(status: 200, body: [RESOURCE_FIXTURE].to_json,
                     headers: { "Content-Type" => "application/json" })

        discover.search(q: "weather", type: "api", limit: 5)
        expect(stub).to have_been_requested
      end

      it "omits blank optional params" do
        stub = stub_request(:get, "https://api.mainlayer.xyz/discover")
          .with(query: { "limit" => "20" })
          .to_return(status: 200, body: [].to_json,
                     headers: { "Content-Type" => "application/json" })

        discover.search
        expect(stub).to have_been_requested
      end
    end
  end

  # ── Analytics ────────────────────────────────────────────────────────────────

  describe Mainlayer::Resources::AnalyticsResource do
    subject(:analytics) { client.analytics }

    describe "#get" do
      it "GET /analytics" do
        body = { "total_revenue_usdc" => 12.50, "total_payments" => 125 }
        stub = stub_mainlayer(:get, "/analytics", body: body)
        result = analytics.get
        expect(stub).to have_been_requested
        expect(result["total_payments"]).to eq(125)
      end
    end
  end

  # ── Webhooks ─────────────────────────────────────────────────────────────────

  describe Mainlayer::Resources::WebhooksResource do
    subject(:webhooks) { client.webhooks }

    describe "#create" do
      it "POST /webhooks with url and events" do
        body = { "id" => "wh_001", "url" => "https://example.com/hook", "events" => ["payment.succeeded"] }
        stub = stub_request(:post, "https://api.mainlayer.xyz/webhooks")
          .with(body: hash_including("url" => "https://example.com/hook"))
          .to_return(status: 200, body: body.to_json,
                     headers: { "Content-Type" => "application/json" })

        result = webhooks.create(url: "https://example.com/hook", events: ["payment.succeeded"])
        expect(stub).to have_been_requested
        expect(result["id"]).to eq("wh_001")
      end
    end

    describe "#list" do
      it "GET /webhooks" do
        stub = stub_mainlayer(:get, "/webhooks", body: [{ "id" => "wh_001" }])
        result = webhooks.list
        expect(stub).to have_been_requested
        expect(result).to be_an(Array)
      end
    end
  end

  # ── Auth ─────────────────────────────────────────────────────────────────────

  describe Mainlayer::Resources::AuthResource do
    subject(:auth) { client.auth }

    describe "#login" do
      it "POST /auth/login and returns access_token" do
        body = { "access_token" => "token_abc" }
        stub = stub_request(:post, "https://api.mainlayer.xyz/auth/login")
          .with(body: hash_including("email" => "me@example.com", "password" => "s3cr3t"))
          .to_return(status: 200, body: body.to_json,
                     headers: { "Content-Type" => "application/json" })

        result = auth.login(email: "me@example.com", password: "s3cr3t")
        expect(stub).to have_been_requested
        expect(result["access_token"]).to eq("token_abc")
      end
    end
  end

  # ── API Keys ─────────────────────────────────────────────────────────────────

  describe Mainlayer::Resources::ApiKeysResource do
    subject(:api_keys) { client.api_keys }

    describe "#create" do
      it "POST /api-keys with name" do
        body = { "id" => "key_001", "name" => "production", "key" => "ml_live_abc" }
        stub = stub_request(:post, "https://api.mainlayer.xyz/api-keys")
          .with(body: hash_including("name" => "production"))
          .to_return(status: 200, body: body.to_json,
                     headers: { "Content-Type" => "application/json" })

        result = api_keys.create(name: "production")
        expect(stub).to have_been_requested
        expect(result["key"]).to eq("ml_live_abc")
      end
    end
  end
end
