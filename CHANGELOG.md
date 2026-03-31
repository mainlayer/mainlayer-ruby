# Changelog

All notable changes to `mainlayer` will be documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] — 2024-01-01

### Added
- Initial release of the official Mainlayer Ruby SDK.
- `Mainlayer::Client` with global and per-client configuration.
- `client.resources` — full CRUD for monetizable resources.
- `client.payments` — create payments and list payment history.
- `client.entitlements` — check payer access in real time.
- `client.discover` — search the public Mainlayer marketplace.
- `client.analytics` — retrieve account revenue and usage stats.
- `client.webhooks` — register and list webhook endpoints.
- `client.auth` — exchange credentials for an access token.
- `client.api_keys` — programmatic API key creation.
- Automatic retries (3 attempts, exponential back-off) on 429 / 5xx.
- Structured error hierarchy: `AuthenticationError`, `NotFoundError`,
  `PaymentRequiredError`, `RateLimitError`, `InvalidRequestError`,
  `APIError`, `ConnectionError`.
- Full YARD documentation on all public classes and methods.
- RSpec test suite with WebMock stubs.
- RuboCop configuration and CI via GitHub Actions.
