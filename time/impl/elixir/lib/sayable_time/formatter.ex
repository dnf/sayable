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

  defp parse_time(nil), do: :error
  defp parse_time(""), do: :error

  defp parse_time(s) when is_binary(s) do
    t =
      if String.contains?(s, "T") do
        s |> String.split("T") |> List.last()
      else
        s
      end

    t =
      if String.contains?(t, "+") do
        t |> String.split("+") |> List.first()
      else
        t
      end

    t =
      if String.contains?(t, "Z") do
        t |> String.split("Z") |> List.first()
      else
        t
      end

    parts = String.split(t, ":")

    if length(parts) < 2 do
      :error
    else
      with {hour, ""} <- Integer.parse(Enum.at(parts, 0)),
           min_str <- Enum.at(parts, 1) |> String.split(".") |> List.first(),
           {minute, ""} <- Integer.parse(min_str) do
        if hour < 0 or hour > 23 or minute < 0 or minute > 59 do
          :error
        else
          {:ok, {hour, minute}}
        end
      else
        _ -> :error
      end
    end
  end

  defp parse_time(_), do: :error

  defp round_to_5(minute) do
    div(minute + 2, 5) * 5
  end
end
