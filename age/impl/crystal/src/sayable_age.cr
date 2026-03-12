require "./sayable_age/version"
require "./sayable_age/locale"
require "./sayable_age/formatter"
require "./sayable_age/locales/*"

module SayableAge
  def self.format_age(date_of_birth : String?, as_of : String? = nil) : String?
    @@default_formatter ||= Formatter.new(Locales::EN)
    @@default_formatter.not_nil!.format_age(date_of_birth, as_of)
  end

  def self.format_stage(date_of_birth : String?, as_of : String? = nil, gender : String? = nil) : String?
    @@default_formatter ||= Formatter.new(Locales::EN)
    @@default_formatter.not_nil!.format_stage(date_of_birth, as_of, gender: gender)
  end

  @@default_formatter : Formatter? = nil
end
