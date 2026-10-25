defmodule SayableTime.Formatter do
  @moduledoc false

  @version "0.5.0"
  def version, do: @version

  def format_time(locale, compactness, input) do
    case parse_time(input) do
      {:ok, {hour, minute}} ->
        short_clock = resolve_short_clock(locale, compactness)

        if compactness != :normal and short_clock != nil do
          {:ok, format_digital(hour, minute, short_clock)}
        else
          {:ok, format_natural(hour, minute, locale.clock)}
        end

      :error ->
        nil
    end
  end

  defp format_natural(hour, minute, clock) do
    rounded = round_to_5(minute)
    h = hour

    {rounded, h} =
      if rounded == 60 do
        {0, rem(h + 1, 24)}
      else
        {rounded, h}
      end

    if rounded == 0 do
      cond do
        h == 0 -> clock.midnight
        h == 12 -> clock.noon
        true -> apply_pattern(h, clock)
      end
    else
      apply_pattern_with_rounded(h, rounded, clock)
    end
  end

  defp apply_pattern(h, clock) do
    h12 = rem(h, 12)
    h_name = Enum.at(clock.hours, h12)
    pattern = Map.get(clock.patterns, 0, "{h}")
    String.replace(pattern, "{h}", h_name)
  end

  defp apply_pattern_with_rounded(h, rounded, clock) do
    h12 = rem(h, 12)
    next_h12 = rem(h + 1, 12)
    h_name = Enum.at(clock.hours, h12)
    next_h_name = Enum.at(clock.hours, next_h12)
    pattern = Map.get(clock.patterns, rounded, Map.get(clock.patterns, 0, "{h}"))

    pattern
    |> String.replace("{h}", h_name)
    |> String.replace("{next_h}", next_h_name)
  end

  defp format_digital(hour, minute, short_clock) do
    fmt = short_clock.format
    mm = minute |> Integer.to_string() |> String.pad_leading(2, "0")

    if short_clock.use24h do
      fmt
      |> String.replace("{h}", Integer.to_string(hour))
      |> String.replace("{mm}", mm)
    else
      h12 = rem(hour, 12)
      h12 = if h12 == 0, do: 12, else: h12

      {am, pm} =
        case short_clock.am_pm do
          {a, p} -> {a, p}
          nil -> {"AM", "PM"}
        end

      ampm_str = if hour < 12, do: am, else: pm

      fmt
      |> String.replace("{h}", Integer.to_string(h12))
      |> String.replace("{mm}", mm)
      |> String.replace("{ampm}", ampm_str)
    end
  end

  defp resolve_short_clock(locale, compactness) do
    ovr =
      case compactness do
        :short -> Map.get(locale, :short)
        :compact -> Map.get(locale, :compact)
        _ -> nil
      end

    case ovr do
      nil -> nil
      ovr -> Map.get(ovr, :clock)
    end
  end

  # A clock time (H:MM or HH:MM, optional :SS and fraction, optional zone
  # suffix, which is ignored), alone or after the T of an ISO datetime.
  @clock ~r/\A([0-9]{1,2}):([0-9]{2})(?::([0-9]{2})(?:\.[0-9]+)?)?(?:Z|[+-][0-9]{2}:[0-9]{2})?\z/
  @date ~r/\A([0-9]{4})-([0-9]{2})-([0-9]{2})\z/

  defp parse_time(s) when is_binary(s) do
    case String.split(s, "T", parts: 2) do
      [clock] -> parse_clock(clock)
      [date, clock] -> if real_date?(date), do: parse_clock(clock), else: :error
    end
  end

  defp parse_time(_), do: :error

  defp parse_clock(clock) do
    case Regex.run(@clock, clock, capture: :all_but_first) do
      [h, m | rest] ->
        {hour, minute, second} = {String.to_integer(h), String.to_integer(m), seconds(rest)}

        if hour > 23 or minute > 59 or second > 59, do: :error, else: {:ok, {hour, minute}}

      nil ->
        :error
    end
  end

  defp seconds([s | _]) when s != "", do: String.to_integer(s)
  defp seconds(_), do: 0

  defp real_date?(date) do
    case Regex.run(@date, date, capture: :all_but_first) do
      [y, m, d] ->
        {year, month, day} = {String.to_integer(y), String.to_integer(m), String.to_integer(d)}
        month in 1..12 and day in 1..days_in_month(year, month)

      nil ->
        false
    end
  end

  defp leap_year?(y), do: (rem(y, 4) == 0 and rem(y, 100) != 0) or rem(y, 400) == 0

  defp days_in_month(y, 2), do: if(leap_year?(y), do: 29, else: 28)
  defp days_in_month(_, m) when m in [4, 6, 9, 11], do: 30
  defp days_in_month(_, _), do: 31

  defp round_to_5(minute) do
    div(minute + 2, 5) * 5
  end
end
