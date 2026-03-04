# frozen_string_literal: true

require_relative 'sayable_age/version'
require_relative 'sayable_age/locale'
require_relative 'sayable_age/formatter'
require_relative 'sayable_age/locales/en'

# Auto-require all locale files
Dir[File.join(__dir__, 'sayable_age', 'locales', '*.rb')].each { |f| require f }

module SayableAge
  # Convenience methods using the default English locale (normal compactness).

  def self.format_age(date_of_birth, as_of = nil)
    @default_formatter ||= Formatter.new(Locales::EN)
    @default_formatter.format_age(date_of_birth, as_of)
  end

  def self.format_stage(date_of_birth, as_of = nil, gender: nil)
    @default_formatter ||= Formatter.new(Locales::EN)
    @default_formatter.format_stage(date_of_birth, as_of, gender: gender)
  end
end
