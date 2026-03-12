require "./sayable_time/version"
require "./sayable_time/locale"
require "./sayable_time/formatter"
require "./sayable_time/locales/*"

module SayableTime
  def self.format_time(input : String?) : String?
    @@default_formatter ||= Formatter.new(Locales::EN)
    @@default_formatter.not_nil!.format_time(input)
  end

  @@default_formatter : Formatter? = nil
end
