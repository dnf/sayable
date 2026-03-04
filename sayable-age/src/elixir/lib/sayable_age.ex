defmodule SayableAge do
  @moduledoc """
  Formats ages the way parents talk — "6 weeks", "14 months", "3½ years".
  """

  def format_age(locale, compactness, dob, as_of) do
    SayableAge.Formatter.format_age(locale, compactness, dob, as_of)
  end

  def format_stage(locale, dob, as_of, gender) do
    SayableAge.Formatter.format_stage(locale, dob, as_of, gender)
  end

  def get_locale(code) do
    SayableAge.Locales.get(code)
  end
end
