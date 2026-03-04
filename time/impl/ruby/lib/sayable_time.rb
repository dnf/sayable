# frozen_string_literal: true

require_relative 'sayable_time/version'
require_relative 'sayable_time/locale'
require_relative 'sayable_time/formatter'
require_relative 'sayable_time/locales/en'

# Auto-require all locale files
Dir[File.join(__dir__, 'sayable_time', 'locales', '*.rb')].each { |f| require f }

module SayableTime
  # Convenience method using the default English locale (normal compactness).
  def self.format_time(input)
    @default_formatter ||= Formatter.new(Locales::EN)
    @default_formatter.format_time(input)
  end
end
