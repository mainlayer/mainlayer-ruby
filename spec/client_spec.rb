# frozen_string_literal: true

require "spec_helper"

RSpec.describe Mainlayer::Client do
  describe "#initialize" do
    context "with explicit api_key" do
      it "creates a client successfully" do
        client = described_class.new(api_key: "ml_test")
        expect(client.config.api_key).to eq("ml_test")
      end
    end

    context "with global configuration" do
      before { Mainlayer.configure { |c| c.api_key = "ml_global" } }

      it "uses the global api_key" do
        client = described_class.new
        expect(client.config.api_key).to eq("ml_global")
      end
    end

    context "with instance key overriding global key" do
      before { Mainlayer.configure { |c| c.api_key = "ml_global" } }

      it "prefers the instance api_key" do
        client = described_class.new(api_key: "ml_instance")
        expect(client.config.api_key).to eq("ml_instance")
      end
    end

    context "without an api_key" do
      it "raises AuthenticationError" do
        expect { described_class.new }.to raise_error(Mainlayer::AuthenticationError)
      end
    end

    it "applies custom timeout" do
      client = described_class.new(api_key: "ml_test", timeout: 60)
      expect(client.config.timeout).to eq(60)
    end

    it "applies custom max_retries" do
      client = described_class.new(api_key: "ml_test", max_retries: 5)
      expect(client.config.max_retries).to eq(5)
    end

    it "applies custom base_url" do
      client = described_class.new(api_key: "ml_test", base_url: "https://staging.mainlayer.fr")
      expect(client.config.base_url).to eq("https://staging.mainlayer.fr")
    end
  end

  describe "resource accessors" do
    let(:client) { test_client }

    it "returns a ResourcesResource" do
      expect(client.resources).to be_a(Mainlayer::Resources::ResourcesResource)
    end

    it "returns a PaymentsResource" do
      expect(client.payments).to be_a(Mainlayer::Resources::PaymentsResource)
    end

    it "returns an EntitlementsResource" do
      expect(client.entitlements).to be_a(Mainlayer::Resources::EntitlementsResource)
    end

    it "returns an AnalyticsResource" do
      expect(client.analytics).to be_a(Mainlayer::Resources::AnalyticsResource)
    end

    it "returns a WebhooksResource" do
      expect(client.webhooks).to be_a(Mainlayer::Resources::WebhooksResource)
    end

    it "returns a DiscoverResource" do
      expect(client.discover).to be_a(Mainlayer::Resources::DiscoverResource)
    end

    it "returns an AuthResource" do
      expect(client.auth).to be_a(Mainlayer::Resources::AuthResource)
    end

    it "returns an ApiKeysResource" do
      expect(client.api_keys).to be_a(Mainlayer::Resources::ApiKeysResource)
    end

    it "memoises resource instances" do
      expect(client.resources).to be(client.resources)
    end
  end

  describe "error handling" do
    let(:client) { test_client }

    it "raises AuthenticationError on 401" do
      stub_mainlayer(:get, "/resources", body: { "message" => "Unauthorized" }, status: 401)
      expect { client.resources.list }.to raise_error(Mainlayer::AuthenticationError)
    end

    it "raises AuthenticationError on 403" do
      stub_mainlayer(:get, "/resources", body: { "message" => "Forbidden" }, status: 403)
      expect { client.resources.list }.to raise_error(Mainlayer::AuthenticationError)
    end

    it "raises PaymentRequiredError on 402" do
      stub_mainlayer(:get, "/resources", body: { "message" => "Payment required" }, status: 402)
      expect { client.resources.list }.to raise_error(Mainlayer::PaymentRequiredError)
    end

    it "raises NotFoundError on 404" do
      stub_mainlayer(:get, "/resources/nonexistent", body: { "message" => "Not found" }, status: 404)
      expect { client.resources.retrieve("nonexistent") }.to raise_error(Mainlayer::NotFoundError)
    end

    it "raises RateLimitError on 429" do
      stub_mainlayer(:get, "/resources", body: { "message" => "Rate limited" }, status: 429)

      # Disable retry middleware so we don't retry in tests
      allow_any_instance_of(Faraday::Connection).to receive(:get).and_call_original
      stub_request(:get, "https://api.mainlayer.fr/resources")
        .to_return(status: 429, body: { "message" => "Rate limited" }.to_json,
                   headers: { "Content-Type" => "application/json" })
        .times(4) # initial + 3 retries

      expect { client.resources.list }.to raise_error(Mainlayer::RateLimitError)
    end

    it "raises APIError on 500" do
      stub_mainlayer(:get, "/resources", body: { "message" => "Server error" }, status: 500)
      stub_request(:get, "https://api.mainlayer.fr/resources")
        .to_return(status: 500, body: { "message" => "Server error" }.to_json,
                   headers: { "Content-Type" => "application/json" })
        .times(4) # initial + 3 retries

      expect { client.resources.list }.to raise_error(Mainlayer::APIError)
    end

    it "raises InvalidRequestError on 422" do
      stub_mainlayer(:post, "/resources", body: { "message" => "Invalid params" }, status: 422)
      expect do
        client.post("/resources", { bad: "data" })
      end.to raise_error(Mainlayer::InvalidRequestError)
    end

    it "includes http_status in the error" do
      stub_mainlayer(:get, "/resources/bad", body: { "message" => "Not found" }, status: 404)
      error = begin
        client.resources.retrieve("bad")
      rescue Mainlayer::NotFoundError => e
        e
      end
      expect(error.http_status).to eq(404)
    end

    it "includes the error message" do
      stub_mainlayer(:get, "/resources/bad", body: { "message" => "Not found" }, status: 404)
      expect { client.resources.retrieve("bad") }
        .to raise_error(Mainlayer::NotFoundError, /Not found/)
    end

    it "raises ConnectionError on network failure" do
      stub_request(:get, "https://api.mainlayer.fr/resources")
        .to_raise(Faraday::ConnectionFailed.new("Connection refused"))

      expect { client.resources.list }.to raise_error(Mainlayer::ConnectionError)
    end
  end

  describe "request headers" do
    let(:client) { test_client }

    it "sends the Authorization header" do
      stub = stub_mainlayer(:get, "/resources", body: [])
      client.resources.list
      expect(stub).to have_been_requested
    end

    it "sends the correct User-Agent" do
      stub_mainlayer(:get, "/resources", body: [])
      stub_with_ua = stub_request(:get, "https://api.mainlayer.fr/resources")
        .with(headers: { "User-Agent" => /mainlayer-ruby\/#{Mainlayer::VERSION}/ })
        .to_return(status: 200, body: [].to_json,
                   headers: { "Content-Type" => "application/json" })

      client.resources.list
      expect(stub_with_ua).to have_been_requested
    end
  end
end
