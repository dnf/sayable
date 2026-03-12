require "./sayable_duration/version"
require "./sayable_duration/locale"
require "./sayable_duration/formatter"
require "./sayable_duration/locales/*"

module SayableDuration
  def self.format_duration(start_or_seconds : Int32?, end_str : String? = nil) : String?
    @@default_formatter ||= Formatter.new(Locales::EN)
    @@default_formatter.not_nil!.format_duration(start_or_seconds, end_str)
  end

  def self.format_duration(start_str : String?, end_str : String?) : String?
    @@default_formatter ||= Formatter.new(Locales::EN)
    @@default_formatter.not_nil!.format_duration(start_str, end_str)
  end

  def self.format_since(start : String?, as_of : String?) : String?
    @@default_formatter ||= Formatter.new(Locales::EN)
    @@default_formatter.not_nil!.format_since(start, as_of)
  end

  def self.format_until(target : String?, as_of : String?) : String?
    @@default_formatter ||= Formatter.new(Locales::EN)
    @@default_formatter.not_nil!.format_until(target, as_of)
  end

  @@default_formatter : Formatter? = nil
end
