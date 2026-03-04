# frozen_string_literal: true

require_relative 'sayable_date/version'
require_relative 'sayable_date/locale'
require_relative 'sayable_date/formatter'

# Auto-require all locale files
Dir[File.join(__dir__, 'sayable_date', 'locales', '*.rb')].each { |f| require f }

module SayableDate
  # Convenience methods using the default English locale (normal compactness).

  def self.format_date(date)
    @default_formatter ||= Formatter.new(Locales::EN)
    @default_formatter.format_date(date)
  end

  def self.format_date_with_year(date)
    @default_formatter ||= Formatter.new(Locales::EN)
    @default_formatter.format_date_with_year(date)
  end

  def self.format_relative(date, as_of)
    @default_formatter ||= Formatter.new(Locales::EN)
    @default_formatter.format_relative(date, as_of)
  end
end
