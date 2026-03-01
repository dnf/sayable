require_relative "lib/parent_time/version"

Gem::Specification.new do |s|
  s.name        = "parent_time"
  s.version     = ParentTime::VERSION
  s.summary     = "A thoughtful time formatting library that reflects how we think about little ones"
  s.description = "A thoughtful time formatting library that reflects how we think about little ones. " \
                  "Zero dependencies, 71 built-in locales, 3 compactness levels."
  s.authors     = ["Don Neufeld"]
  s.license     = "MIT"
  s.homepage    = "https://github.com/dnf/parent-time"

  s.required_ruby_version = ">= 3.0"

  s.metadata = {
    "source_code_uri" => "https://github.com/dnf/parent-time/tree/main/src/ruby",
    "bug_tracker_uri" => "https://github.com/dnf/parent-time/issues",
    "homepage_uri" => "https://github.com/dnf/parent-time",
  }

  s.files = Dir["lib/**/*.rb"]

  s.add_development_dependency "minitest", "~> 5.0"
  s.add_development_dependency "rake", "~> 13.0"
end
