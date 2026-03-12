defmodule SayableDuration.Formatter do
  @moduledoc false

  alias SayableDuration.Locale

  @version "0.5.0"
  def version, do: @version

  def format_duration(_locale, _compactness, nil, _the_end), do: nil

  def format_duration(locale, compactness, seconds, _the_end) when is_integer(seconds) do
    if seconds < 0 do
      nil
    else
      {units, half, delimiter, just_now, _ago, _in_future} = resolve_locale(locale, compactness)
      {:ok, format_duration_seconds(locale, units, half, delimiter, just_now, seconds)}
    end
  end

  def format_duration(locale, compactness, start, the_end)
      when is_binary(start) and is_binary(the_end) do
    with {:ok, s} <- parse_iso_to_seconds(start),
         {:ok, e} <- parse_iso_to_seconds(the_end) do
      total = abs(e - s)
      {units, half, delimiter, just_now, _ago, _in_future} = resolve_locale(locale, compactness)
      {:ok, format_duration_seconds(locale, units, half, delimiter, just_now, total)}
    else
      :error -> nil
    end
  end

  def format_duration(_locale, _compactness, _start, _the_end), do: nil

  def format_since(_locale, _compactness, nil, _as_of), do: nil
  def format_since(_locale, _compactness, "", _as_of), do: nil
  def format_since(_locale, _compactness, _start, nil), do: nil
  def format_since(_locale, _compactness, _start, ""), do: nil

  def format_since(locale, compactness, start, as_of)
      when is_binary(start) and is_binary(as_of) do
    with {:ok, s} <- parse_iso_to_seconds(start),
         {:ok, a} <- parse_iso_to_seconds(as_of) do
      diff = a - s

      if diff < 0 do
        nil
      else
        {units, half, delimiter, just_now, ago, _in_future} = resolve_locale(locale, compactness)

        if diff == 0 do
          {:ok, just_now}
        else
          dur = format_duration_seconds(locale, units, half, delimiter, just_now, diff)
          {:ok, String.replace(ago, "{0}", dur)}
        end
      end
    else
      :error -> nil
    end
  end

  def format_until(_locale, _compactness, nil, _as_of), do: nil
  def format_until(_locale, _compactness, "", _as_of), do: nil
  def format_until(_locale, _compactness, _target, nil), do: nil
  def format_until(_locale, _compactness, _target, ""), do: nil

  def format_until(locale, compactness, target, as_of)
      when is_binary(target) and is_binary(as_of) do
    with {:ok, t} <- parse_iso_to_seconds(target),
         {:ok, a} <- parse_iso_to_seconds(as_of) do
      diff = t - a

      if diff < 0 do
        nil
      else
        {units, half, delimiter, just_now, _ago, in_future} = resolve_locale(locale, compactness)

        if diff == 0 do
          {:ok, just_now}
        else
          dur = format_duration_seconds(locale, units, half, delimiter, just_now, diff)
          {:ok, String.replace(in_future, "{0}", dur)}
        end
      end
    else
      :error -> nil
    end
  end

  # Duration formatting tiers

  defp format_duration_seconds(_locale, _units, _half, _delimiter, just_now, 0), do: just_now

  defp format_duration_seconds(locale, units, _half, _delimiter, _just_now, total)
       when total < 60 do
    Locale.resolve_unit(total, units.second, locale, "")
  end

  defp format_duration_seconds(locale, units, _half, delimiter, _just_now, total)
       when total < 300 do
    total_minutes = div(total, 60)
    remainder_seconds = rem(total, 60)
    result = Locale.resolve_unit(total_minutes, units.minute, locale, "")

    if remainder_seconds > 0 do
      result <> delimiter <> Locale.resolve_unit(remainder_seconds, units.second, locale, "")
    else
      result
    end
  end

  defp format_duration_seconds(locale, units, _half, _delimiter, _just_now, total)
       when total < 3600 do
    total_minutes = div(total, 60)
    Locale.resolve_unit(total_minutes, units.minute, locale, "")
  end

  defp format_duration_seconds(locale, units, half, delimiter, _just_now, total)
       when total < 21600 do
    total_hours = div(total, 3600)
    remainder_minutes = div(rem(total, 3600), 60)

    if remainder_minutes == 30 do
      Locale.resolve_unit(total_hours, units.hour, locale, half)
    else
      result = Locale.resolve_unit(total_hours, units.hour, locale, "")

      if remainder_minutes > 0 do
        result <> delimiter <> Locale.resolve_unit(remainder_minutes, units.minute, locale, "")
      else
        result
      end
    end
  end

  defp format_duration_seconds(locale, units, _half, _delimiter, _just_now, total)
       when total < 86400 do
    total_hours = div(total, 3600)
    Locale.resolve_unit(total_hours, units.hour, locale, "")
  end

  defp format_duration_seconds(locale, units, half, delimiter, _just_now, total)
       when total < 172_800 do
    total_days = div(total, 86400)
    remainder_hours = div(rem(total, 86400), 3600)

    if remainder_hours == 12 do
      Locale.resolve_unit(total_days, units.day, locale, half)
    else
      result = Locale.resolve_unit(total_days, units.day, locale, "")

      if remainder_hours > 0 do
        result <> delimiter <> Locale.resolve_unit(remainder_hours, units.hour, locale, "")
      else
        result
      end
    end
  end

  defp format_duration_seconds(locale, units, _half, _delimiter, _just_now, total)
       when total < 604_800 do
    total_days = div(total, 86400)
    Locale.resolve_unit(total_days, units.day, locale, "")
  end

  defp format_duration_seconds(locale, units, _half, delimiter, _just_now, total)
       when div(total, 86400) < 30 do
    total_days = div(total, 86400)
    total_weeks = div(total_days, 7)
    remainder_days = rem(total_days, 7)
    result = Locale.resolve_unit(total_weeks, units.week, locale, "")

    if remainder_days > 0 do
      result <> delimiter <> Locale.resolve_unit(remainder_days, units.day, locale, "")
    else
      result
    end
  end

  defp format_duration_seconds(locale, units, _half, delimiter, _just_now, total) do
    total_days = div(total, 86400)
    total_months = round(total_days / 30.44)

    if total_months < 12 do
      months = if total_months == 0, do: 1, else: total_months
      Locale.resolve_unit(months, units.month, locale, "")
    else
      total_years = div(total_months, 12)
      remainder_months = rem(total_months, 12)
      result = Locale.resolve_unit(total_years, units.year, locale, "")

      if remainder_months > 0 do
        result <> delimiter <> Locale.resolve_unit(remainder_months, units.month, locale, "")
      else
        result
      end
    end
  end

  # Locale resolution with compactness overrides

  defp resolve_locale(locale, :normal) do
    {
      %{
        second: locale.units.second,
        minute: locale.units.minute,
        hour: locale.units.hour,
        day: locale.units.day,
        week: locale.units.week,
        month: locale.units.month,
        year: locale.units.year
      },
      locale.half,
      locale.delimiter,
      locale.just_now,
      locale.ago,
      locale.in_future
    }
  end

  defp resolve_locale(locale, compactness) do
    ovr = Map.get(locale, compactness)

    case ovr do
      nil ->
        resolve_locale(locale, :normal)

      ovr ->
        ovr_units = Map.get(ovr, :units, %{})

        {
          %{
            second: Map.get(ovr_units, :second, locale.units.second),
            minute: Map.get(ovr_units, :minute, locale.units.minute),
            hour: Map.get(ovr_units, :hour, locale.units.hour),
            day: Map.get(ovr_units, :day, locale.units.day),
            week: Map.get(ovr_units, :week, locale.units.week),
            month: Map.get(ovr_units, :month, locale.units.month),
            year: Map.get(ovr_units, :year, locale.units.year)
          },
          Map.get(ovr, :half, locale.half),
          Map.get(ovr, :delimiter, locale.delimiter),
          locale.just_now,
          Map.get(ovr, :ago, locale.ago),
          Map.get(ovr, :in_future, locale.in_future)
        }
    end
  end

  # ISO datetime parsing

  defp parse_iso_to_seconds(s) when is_binary(s) do
    case String.split(s, "T") do
      [date_part, time_part] ->
        with {:ok, days} <- parse_date_to_days(date_part),
             {:ok, secs} <- parse_time_to_seconds(time_part) do
          {:ok, days * 86400 + secs}
        end

      _ ->
        :error
    end
  end

  defp parse_iso_to_seconds(_), do: :error

  defp parse_date_to_days(date_str) do
    parts = String.split(date_str, "-")

    if length(parts) != 3 do
      :error
    else
      with {year, ""} <- Integer.parse(Enum.at(parts, 0)),
           {month, ""} <- Integer.parse(Enum.at(parts, 1)),
           {day, ""} <- Integer.parse(Enum.at(parts, 2)) do
        {:ok, days_since_epoch(year, month, day)}
      else
        _ -> :error
      end
    end
  end

  defp parse_time_to_seconds(time_str) do
    t =
      time_str
      |> strip_after("+")
      |> strip_after("Z")

    parts = String.split(t, ":")

    with {hour, ""} <- Integer.parse(Enum.at(parts, 0)),
         minute_str <- if(length(parts) > 1, do: Enum.at(parts, 1), else: "0"),
         {minute, ""} <- Integer.parse(minute_str),
         second_str <-
           if(length(parts) > 2,
             do: Enum.at(parts, 2) |> String.split(".") |> List.first(),
             else: "0"
           ),
         {second, ""} <- Integer.parse(second_str) do
      {:ok, hour * 3600 + minute * 60 + second}
    else
      _ -> :error
    end
  end

  defp strip_after(s, char) do
    if String.contains?(s, char) do
      s |> String.split(char) |> List.first()
    else
      s
    end
  end

  defp days_since_epoch(year, month, day) do
    year_days =
      if year >= 2000 do
        Enum.reduce(2000..(year - 1)//1, 0, fn y, acc ->
          acc + if(is_leap_year(y), do: 366, else: 365)
        end)
      else
        Enum.reduce(year..1999//1, 0, fn y, acc ->
          acc - if(is_leap_year(y), do: 366, else: 365)
        end)
      end

    month_days =
      Enum.reduce(1..(month - 1)//1, 0, fn m, acc ->
        acc + days_in_month(year, m)
      end)

    year_days + month_days + day - 1
  end

  defp is_leap_year(y), do: (rem(y, 4) == 0 and rem(y, 100) != 0) or rem(y, 400) == 0

  defp days_in_month(_, m) when m in [1, 3, 5, 7, 8, 10, 12], do: 31
  defp days_in_month(_, m) when m in [4, 6, 9, 11], do: 30
  defp days_in_month(y, 2), do: if(is_leap_year(y), do: 29, else: 28)
  defp days_in_month(_, _), do: 30
end
