require "./sayable_date/version"
require "./sayable_date/locale"
require "./sayable_date/formatter"
require "./sayable_date/locales/*"

module SayableDate
  def self.format_date(date : String?) : String?
    @@default_formatter ||= Formatter.new(Locales::EN)
    @@default_formatter.not_nil!.format_date(date)
  end

  def self.format_date_with_year(date : String?) : String?
    @@default_formatter ||= Formatter.new(Locales::EN)
    @@default_formatter.not_nil!.format_date_with_year(date)
  end

  def self.format_relative(date : String?, as_of : String?) : String?
    @@default_formatter ||= Formatter.new(Locales::EN)
    @@default_formatter.not_nil!.format_relative(date, as_of)
  end

  @@default_formatter : Formatter? = nil
end
