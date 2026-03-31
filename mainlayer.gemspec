# frozen_string_literal: true

require_relative "lib/mainlayer/version"

Gem::Specification.new do |spec|
  spec.name          = "mainlayer"
  spec.version       = Mainlayer::VERSION
  spec.authors       = ["Mainlayer"]
  spec.email         = ["support@mainlayer.xyz"]

  spec.summary       = "Official Ruby SDK for Mainlayer — payment infrastructure for AI agents"
  spec.description   = "Mainlayer is payment infrastructure for AI agents. Accept payments, " \
                       "manage subscriptions, and monetize your AI tools with a simple API."
  spec.homepage      = "https://mainlayer.xyz"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/mainlayer/mainlayer-ruby"
  spec.metadata["changelog_uri"]   = "https://github.com/mainlayer/mainlayer-ruby/blob/main/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://docs.mainlayer.xyz"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir[
    "lib/**/*.rb",
    "LICENSE",
    "README.md",
    "CHANGELOG.md"
  ]

  spec.require_paths = ["lib"]

  spec.add_dependency "faraday",          "~> 2.0"
  spec.add_dependency "faraday-net_http", "~> 3.0"

  spec.add_development_dependency "rspec",   "~> 3.12"
  spec.add_development_dependency "webmock", "~> 3.18"
  spec.add_development_dependency "rubocop", "~> 1.50"
  spec.add_development_dependency "rubocop-rspec", "~> 2.20"
  spec.add_development_dependency "yard",    "~> 0.9"
  spec.add_development_dependency "rake",    "~> 13.0"
end
