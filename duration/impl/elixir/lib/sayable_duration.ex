defmodule SayableDuration do
  @moduledoc """
  Formats durations the way people talk — "just now", "3 minutes", "2½ hours".
  """

  def format_duration(locale, compactness, start_or_seconds, the_end \\ nil) do
    SayableDuration.Formatter.format_duration(locale, compactness, start_or_seconds, the_end)
  end

  def format_since(locale, compactness, start, as_of) do
    SayableDuration.Formatter.format_since(locale, compactness, start, as_of)
  end

  def format_until(locale, compactness, target, as_of) do
    SayableDuration.Formatter.format_until(locale, compactness, target, as_of)
  end

  def get_locale(code) do
    SayableDuration.Locales.get(code)
  end
end
