# Mainlayer Ruby SDK

Official Ruby gem for [Mainlayer](https://mainlayer.xyz) — payment infrastructure for AI agents.

[![Gem Version](https://badge.fury.io/rb/mainlayer.svg)](https://badge.fury.io/rb/mainlayer)
[![CI](https://github.com/mainlayer/mainlayer-ruby/actions/workflows/ci.yml/badge.svg)](https://github.com/mainlayer/mainlayer-ruby/actions/workflows/ci.yml)

Mainlayer lets you monetize AI tools and agents with one API. Accept payments, gate access, and manage subscriptions — without writing any payment infrastructure yourself.

---

## Installation

```sh
gem install mainlayer
```

Or add to your `Gemfile`:

```ruby
gem "mainlayer", "~> 0.1"
```

Requires Ruby 2.7+.

---

## Quick start

```ruby
require "mainlayer"

# Configure once (e.g. in an initializer)
Mainlayer.configure do |config|
  config.api_key = ENV.fetch("MAINLAYER_API_KEY")
end

client = Mainlayer::Client.new

# Create a paid resource
resource = client.resources.create(
  slug:        "my-ai-tool",
  type:        "api",
  price_usdc:  0.10,
  fee_model:   "pay_per_call",
  description: "My AI tool"
)

# Accept a payment
payment = client.payments.create(
  resource_id:  resource["id"],
  payer_wallet: "payer_wallet_address"
)

# Verify access before serving a request
access = client.entitlements.check(
  resource_id:  resource["id"],
  payer_wallet: "payer_wallet_address"
)

puts access["has_access"] # => true
```

---

## Configuration

### Global (Stripe-style)

```ruby
Mainlayer.configure do |config|
  config.api_key     = ENV.fetch("MAINLAYER_API_KEY")
  config.timeout     = 30       # seconds (default: 30)
  config.max_retries = 3        # retries on 429/5xx (default: 3)
end

client = Mainlayer::Client.new  # uses global config
```

### Per-client

```ruby
client = Mainlayer::Client.new(
  api_key:     "ml_live_...",
  timeout:     60,
  max_retries: 5,
  base_url:    "https://api.mainlayer.xyz"  # override for staging, etc.
)
```

---

## API Reference

### Authentication

#### Login

Exchange email/password for an access token.

```ruby
result = client.auth.login(email: "you@example.com", password: "your_password")
token  = result["access_token"]
```

### API Keys

#### Create an API key

```ruby
key = client.api_keys.create(name: "production")
puts key["key"]   # ml_live_...  Store this securely — shown only once.
```

---

### Resources

Resources are the monetizable assets you publish on Mainlayer (APIs, files, endpoints, hosted pages).

| Field        | Type    | Values                                         |
|--------------|---------|------------------------------------------------|
| `slug`       | String  | URL-safe identifier, unique per account        |
| `type`       | String  | `api`, `file`, `endpoint`, `page`              |
| `price_usdc` | Float   | Price in USDC (e.g. `0.10` for $0.10)         |
| `fee_model`  | String  | `one_time`, `subscription`, `pay_per_call`     |

#### Create

```ruby
resource = client.resources.create(
  slug:         "gpt-summariser",
  type:         "api",
  price_usdc:   0.05,
  fee_model:    "pay_per_call",
  description:  "Summarise any text with GPT-4",
  callback_url: "https://yourapp.com/mainlayer/callback"  # optional
)
```

#### List

```ruby
resources = client.resources.list
resources.each { |r| puts "#{r['slug']} — $#{r['price_usdc']}" }
```

#### Retrieve

```ruby
resource = client.resources.retrieve("res_abc123")
```

#### Retrieve (public, no auth)

```ruby
info = client.resources.retrieve_public("res_abc123")
```

#### Update

```ruby
client.resources.update("res_abc123", price_usdc: 0.20, description: "Updated description")
```

#### Delete

```ruby
client.resources.delete("res_abc123")
```

---

### Payments

#### Create a payment

```ruby
payment = client.payments.create(
  resource_id:  "res_abc123",
  payer_wallet: "payer_wallet_address"
)
puts payment["status"]  # => "confirmed"
```

#### List payments

```ruby
payments = client.payments.list
```

---

### Entitlements

Check whether a wallet has valid access to a resource. Use this to gate every incoming request to your AI tool.

```ruby
access = client.entitlements.check(
  resource_id:  "res_abc123",
  payer_wallet: "payer_wallet_address"
)

# Response fields:
access["has_access"]        # => true / false
access["expires_at"]        # => "2024-12-31T23:59:59Z" or nil
access["credits_remaining"] # => 42 (pay_per_call) or nil
```

**Rack middleware example:**

```ruby
result = client.entitlements.check(
  resource_id:  "res_abc123",
  payer_wallet: request.env["HTTP_X_PAYER_WALLET"]
)

return [402, {}, ["Payment required"]] unless result["has_access"]
```

---

### Discover

Search the public Mainlayer marketplace — no authentication required.

```ruby
# Search with filters
results = client.discover.search(
  q:         "weather api",
  type:      "api",
  fee_model: "pay_per_call",
  limit:     10
)

# Browse all resources
all = client.discover.search
```

---

### Analytics

```ruby
stats = client.analytics.get
puts stats["total_revenue_usdc"]
puts stats["total_payments"]
```

---

### Webhooks

Register an endpoint to receive real-time event notifications.

```ruby
# Register
webhook = client.webhooks.create(
  url:    "https://yourapp.com/mainlayer/events",
  events: ["payment.succeeded", "payment.failed"]
)
puts webhook["id"]

# List
client.webhooks.list.each { |w| puts w["url"] }
```

---

## Error handling

All errors inherit from `Mainlayer::Error`.

```ruby
begin
  client.resources.retrieve("nonexistent_id")
rescue Mainlayer::NotFoundError => e
  puts "Not found: #{e.message}"
rescue Mainlayer::AuthenticationError => e
  puts "Auth failed — check your API key"
rescue Mainlayer::RateLimitError => e
  puts "Rate limited (HTTP #{e.http_status})"
rescue Mainlayer::PaymentRequiredError => e
  puts "Payment required"
rescue Mainlayer::InvalidRequestError => e
  puts "Bad request: #{e.message}"
rescue Mainlayer::APIError => e
  puts "Server error (#{e.http_status})"
rescue Mainlayer::ConnectionError => e
  puts "Network error: #{e.message}"
rescue Mainlayer::Error => e
  puts "Mainlayer error: #{e.message} (HTTP #{e.http_status})"
end
```

| Exception                      | HTTP status | Cause                                    |
|-------------------------------|-------------|------------------------------------------|
| `Mainlayer::AuthenticationError` | 401, 403 | Invalid or missing API key               |
| `Mainlayer::PaymentRequiredError` | 402      | Payment required to access resource      |
| `Mainlayer::NotFoundError`       | 404       | Resource not found                        |
| `Mainlayer::InvalidRequestError` | 422       | Invalid parameters                       |
| `Mainlayer::RateLimitError`      | 429       | Too many requests                        |
| `Mainlayer::APIError`            | 5xx       | Mainlayer server error                   |
| `Mainlayer::ConnectionError`     | —         | Network timeout or connection failure    |

---

## Automatic retries

The SDK automatically retries up to 3 times (with exponential back-off) on:

- `429 Too Many Requests`
- `500`, `502`, `503`, `504` server errors
- Network timeouts and connection failures

Configure the retry count:

```ruby
client = Mainlayer::Client.new(api_key: "ml_...", max_retries: 5)
```

---

## Examples

Runnable examples live in the [`examples/`](examples/) directory.

```sh
MAINLAYER_API_KEY=ml_live_... ruby examples/quickstart.rb
MAINLAYER_API_KEY=ml_live_... ruby examples/create_resource.rb
MAINLAYER_API_KEY=ml_live_... RESOURCE_ID=res_xxx ruby examples/pay_for_resource.rb
```

---

## Development

```sh
git clone https://github.com/mainlayer/mainlayer-ruby
cd mainlayer-ruby
bundle install

# Run tests
bundle exec rspec

# Lint
bundle exec rubocop

# Generate docs
bundle exec yard doc
```

---

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/mainlayer/mainlayer-ruby). Please run `rspec` and `rubocop` before opening a PR.

---

## License

MIT — see [LICENSE](LICENSE).
