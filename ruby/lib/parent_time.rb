# frozen_string_literal: true

require_relative 'parent_time/version'
require_relative 'parent_time/locale'
require_relative 'parent_time/formatter'
require_relative 'parent_time/locales/en'

# Auto-require all locale files
Dir[File.join(__dir__, 'parent_time', 'locales', '*.rb')].each { |f| require f }

module ParentTime
  # Convenience methods using the default English locale (normal compactness).

  def self.format_age(date_of_birth, as_of = nil)
    @default_formatter ||= Formatter.new(Locales::EN)
    @default_formatter.format_age(date_of_birth, as_of)
  end

  def self.format_stage(date_of_birth, as_of = nil)
    @default_formatter ||= Formatter.new(Locales::EN)
    @default_formatter.format_stage(date_of_birth, as_of)
  end
end
