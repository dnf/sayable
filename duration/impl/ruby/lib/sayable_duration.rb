# frozen_string_literal: true

require_relative 'sayable_duration/version'
require_relative 'sayable_duration/locale'
require_relative 'sayable_duration/timestamp'
require_relative 'sayable_duration/formatter'

# Auto-require all locale files
Dir[File.join(__dir__, 'sayable_duration', 'locales', '*.rb')].each { |f| require f }

module SayableDuration
  # Convenience methods using the default English locale (normal compactness).

  def self.format_duration(start_or_seconds, end_str = nil)
    @default_formatter ||= Formatter.new(Locales::EN)
    @default_formatter.format_duration(start_or_seconds, end_str)
  end

  def self.format_since(start, as_of)
    @default_formatter ||= Formatter.new(Locales::EN)
    @default_formatter.format_since(start, as_of)
  end

  def self.format_until(target, as_of)
    @default_formatter ||= Formatter.new(Locales::EN)
    @default_formatter.format_until(target, as_of)
  end
end
