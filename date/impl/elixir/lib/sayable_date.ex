defmodule SayableDate do
  @moduledoc """
  Formats dates the way people talk — "today", "next Thursday", "March 15th".
  """

  def format_date(locale, compactness, date) do
    SayableDate.Formatter.format_date(locale, compactness, date)
  end

  def format_date_with_year(locale, compactness, date) do
    SayableDate.Formatter.format_date_with_year(locale, compactness, date)
  end

  def format_relative(locale, compactness, date, as_of) do
    SayableDate.Formatter.format_relative(locale, compactness, date, as_of)
  end

  def get_locale(code) do
    SayableDate.Locales.get(code)
  end
end
