defmodule SayableTime do
  @moduledoc """
  Formats clock time the way people talk — "a quarter past three", "half past seven".
  """

  def format_time(locale, compactness, input) do
    SayableTime.Formatter.format_time(locale, compactness, input)
  end

  def get_locale(code) do
    SayableTime.Locales.get(code)
  end
end
