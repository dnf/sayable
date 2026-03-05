require_relative "lib/sayable_time/version"

Gem::Specification.new do |s|
  s.name        = "sayable_time"
  s.version     = SayableTime::VERSION
  s.summary     = "Human-friendly clock time formatting — how people actually say the time"
  s.description = "Human-friendly clock time formatting — how people actually say the time. " \
                  "Zero dependencies, 110 built-in locales, 3 compactness levels."
  s.authors     = ["Don Neufeld"]
  s.license     = "MIT"
  s.homepage    = "https://github.com/dnf/sayable"

  s.required_ruby_version = ">= 3.0"

  s.metadata = {
    "source_code_uri" => "https://github.com/dnf/sayable/tree/main/time/impl/ruby",
    "bug_tracker_uri" => "https://github.com/dnf/sayable/issues",
    "homepage_uri" => "https://github.com/dnf/sayable",
  }

  s.files = Dir["lib/**/*.rb"]

  s.add_development_dependency "minitest", "~> 5.0"
  s.add_development_dependency "rake", "~> 13.0"
end
