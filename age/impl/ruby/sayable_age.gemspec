# frozen_string_literal: true

require_relative "lib/sayable_age/version"

Gem::Specification.new do |s|
  s.name        = "sayable_age"
  s.version     = SayableAge::VERSION
  s.summary     = "Human-friendly age formatting — how parents actually talk about little ones"
  s.description = "Human-friendly age formatting — how parents actually talk about little ones. " \
                  "Zero dependencies, 168 built-in locales, 3 compactness levels."
  s.authors     = ["Don Neufeld"]
  s.license     = "MIT"
  s.homepage    = "https://github.com/dnf/sayable"

  s.required_ruby_version = ">= 3.0"

  s.metadata = {
    "source_code_uri" => "https://github.com/dnf/sayable/tree/main/age/impl/ruby",
    "bug_tracker_uri" => "https://github.com/dnf/sayable/issues",
    "homepage_uri" => "https://github.com/dnf/sayable",
    "rubygems_mfa_required" => "true",
  }

  s.files = Dir["lib/**/*.rb"]
end
