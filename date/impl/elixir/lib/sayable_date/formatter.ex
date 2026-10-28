defmodule SayableDate.Formatter do
  @moduledoc false

  @version "0.5.0"
  def version, do: @version

  def format_date(locale, compactness, date) do
    case parse_date(date) do
      {:ok, {y, m, d}} ->
        resolved = resolve_locale(locale, compactness)
        {:ok, format_absolute(y, m, d, false, resolved)}

      :error ->
        nil
    end
  end

  def format_date_with_year(locale, compactness, date) do
    case parse_date(date) do
      {:ok, {y, m, d}} ->
        resolved = resolve_locale(locale, compactness)
        {:ok, format_absolute(y, m, d, true, resolved)}

      :error ->
        nil
    end
  end

  def format_relative(locale, compactness, date, as_of) do
    with {:ok, {dy, dm, dd}} <- parse_date(date),
         {:ok, {ay, am, ad}} <- parse_date(as_of) do
      date_jdn = to_jdn(dy, dm, dd)
      asof_jdn = to_jdn(ay, am, ad)
      diff = date_jdn - asof_jdn
      resolved = resolve_locale(locale, compactness)
      is_compact = compactness == :compact

      {:ok, format_relative_diff(locale, resolved, is_compact, diff, dy, dm, dd, ay)}
    else
      :error -> nil
    end
  end

  defp format_relative_diff(_locale, resolved, _is_compact, 0, _dy, _dm, _dd, _ay) do
    resolved.today
  end

  defp format_relative_diff(_locale, resolved, _is_compact, 1, _dy, _dm, _dd, _ay) do
    resolved.tomorrow
  end

  defp format_relative_diff(_locale, resolved, _is_compact, -1, _dy, _dm, _dd, _ay) do
    resolved.yesterday
  end

  defp format_relative_diff(locale, resolved, is_compact, diff, dy, dm, dd, ay) do
    cond do
      diff == 2 and locale.day_after_tomorrow != nil and not is_compact ->
        locale.day_after_tomorrow

      diff == -2 and locale.day_before_yesterday != nil and not is_compact ->
        locale.day_before_yesterday

      is_compact ->
        include_year = dy != ay
        format_absolute(dy, dm, dd, include_year, resolved)

      diff >= 2 and diff <= 6 and locale.this_weekday != nil ->
        dow = weekday(dy, dm, dd)
        weekday_name = Enum.at(resolved.weekdays, dow)
        String.replace(locale.this_weekday, "{weekday}", weekday_name)

      diff >= -6 and diff <= -2 and locale.last_weekday != nil ->
        dow = weekday(dy, dm, dd)
        weekday_name = Enum.at(resolved.weekdays, dow)
        String.replace(locale.last_weekday, "{weekday}", weekday_name)

      diff >= 7 and diff <= 13 and locale.next_weekday != nil ->
        dow = weekday(dy, dm, dd)
        weekday_name = Enum.at(resolved.weekdays, dow)
        String.replace(locale.next_weekday, "{weekday}", weekday_name)

      true ->
        include_year = dy != ay
        format_absolute(dy, dm, dd, include_year, resolved)
    end
  end

  defp format_absolute(year, month, day, include_year, resolved) do
    day_str = Integer.to_string(day)
    fmt = Map.get(resolved.day_format_exceptions, day_str, resolved.day_format)
    formatted_day = String.replace(fmt, "{n}", day_str)

    month_names =
      if resolved.months_in_date != nil do
        resolved.months_in_date
      else
        resolved.months
      end

    month_name = Enum.at(month_names, month - 1)

    pattern =
      if include_year do
        resolved.date_pattern_with_year
      else
        resolved.date_pattern
      end

    result =
      pattern
      |> String.replace("{month}", month_name)
      |> String.replace("{day}", formatted_day)
      |> String.replace("{d}", Integer.to_string(day))
      |> String.replace("{m}", Integer.to_string(month))

    if include_year do
      yy = rem(year, 100) |> Integer.to_string() |> String.pad_leading(2, "0")

      result
      |> String.replace("{year}", Integer.to_string(year))
      |> String.replace("{yy}", yy)
    else
      result
    end
  end

  defp resolve_locale(locale, :normal) do
    %{
      months: locale.months,
      months_in_date: locale.months_in_date,
      weekdays: locale.weekdays,
      day_format: locale.day_format,
      day_format_exceptions: locale.day_format_exceptions,
      date_pattern: locale.date_pattern,
      date_pattern_with_year: locale.date_pattern_with_year,
      today: locale.today,
      tomorrow: locale.tomorrow,
      yesterday: locale.yesterday
    }
  end

  defp resolve_locale(locale, compactness) do
    ovr = Map.get(locale, compactness)

    case ovr do
      nil ->
        resolve_locale(locale, :normal)

      ovr ->
        day_format = Map.get(ovr, :day_format, locale.day_format)

        day_format_exceptions =
          if Map.has_key?(ovr, :day_format) and not Map.has_key?(ovr, :day_format_exceptions) do
            %{}
          else
            Map.get(ovr, :day_format_exceptions, locale.day_format_exceptions)
          end

        %{
          months: Map.get(ovr, :months, locale.months),
          months_in_date: Map.get(ovr, :months_in_date, locale.months_in_date),
          weekdays: Map.get(ovr, :weekdays, locale.weekdays),
          day_format: day_format,
          day_format_exceptions: day_format_exceptions,
          date_pattern: Map.get(ovr, :date_pattern, locale.date_pattern),
          date_pattern_with_year:
            Map.get(ovr, :date_pattern_with_year, locale.date_pattern_with_year),
          today: Map.get(ovr, :today, locale.today),
          tomorrow: Map.get(ovr, :tomorrow, locale.tomorrow),
          yesterday: Map.get(ovr, :yesterday, locale.yesterday)
        }
    end
  end

  defp parse_date(<<date::binary-size(10)>>), do: parse_calendar_date(date)
  defp parse_date(<<date::binary-size(10), ?T, _time::binary>>), do: parse_calendar_date(date)
  defp parse_date(_), do: :error

  defp parse_calendar_date(<<y::binary-size(4), ?-, m::binary-size(2), ?-, d::binary-size(2)>>) do
    with true <- all_digits?(y <> m <> d),
         {year, month, day} = {String.to_integer(y), String.to_integer(m), String.to_integer(d)},
         true <- month in 1..12 and day in 1..days_in_month(year, month) do
      {:ok, {year, month, day}}
    else
      _ -> :error
    end
  end

  defp parse_calendar_date(_), do: :error

  defp all_digits?(s), do: s |> String.to_charlist() |> Enum.all?(&(&1 in ?0..?9))

  defp leap_year?(y), do: (rem(y, 4) == 0 and rem(y, 100) != 0) or rem(y, 400) == 0

  defp days_in_month(y, 2), do: if(leap_year?(y), do: 29, else: 28)
  defp days_in_month(_, m) when m in [4, 6, 9, 11], do: 30
  defp days_in_month(_, _), do: 31

  defp to_jdn(y, m, d) do
    a = div(14 - m, 12)
    yy = y + 4800 - a
    mm = m + 12 * a - 3
    d + div(153 * mm + 2, 5) + 365 * yy + div(yy, 4) - div(yy, 100) + div(yy, 400) - 32045
  end

  defp weekday(y, m, d) do
    jdn = to_jdn(y, m, d)
    rem(jdn + 1, 7)
  end
end
