defmodule ParentTime do
  @moduledoc """
  Formats ages the way parents talk — "6 weeks", "14 months", "3½ years".
  """

  def format_age(locale, compactness, dob, as_of) do
    ParentTime.Formatter.format_age(locale, compactness, dob, as_of)
  end

  def format_stage(locale, dob, as_of, gender) do
    ParentTime.Formatter.format_stage(locale, dob, as_of, gender)
  end

  def get_locale(code) do
    ParentTime.Locales.get(code)
  end
end
