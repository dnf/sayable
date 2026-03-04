defmodule SayableAge.Formatter do
  @moduledoc false

  alias SayableAge.Locale

  @version "0.5.0"
  def version, do: @version

  @max_age_months 6000

  def format_age(locale, compactness, dob, as_of) do
    case compute_age(dob, as_of) do
      {:ok, {months, diff_days}} when months <= @max_age_months ->
        {day, week, month, year, half, delim, just_born} = resolve_locale(locale, compactness)
        {:ok, format_tier(locale, day, week, month, year, half, delim, just_born, months, diff_days)}

      _ ->
        :error
    end
  end

  def format_stage(locale, dob, as_of, gender) do
    case compute_age(dob, as_of) do
      {:ok, {months, _diff_days}} ->
        stages = locale.stages
        label = stage_label(months, stages)
        {:ok, Locale.resolve_stage(label, gender)}

      :error ->
        :error
    end
  end

  # Tier dispatch

  defp format_tier(_locale, _day, _week, _month, _year, _half, _delim, just_born, _months, 0),
    do: just_born

  defp format_tier(locale, day, _week, _month, _year, _half, _delim, _just_born, _months, diff_days)
       when diff_days < 7,
       do: Locale.resolve_unit(diff_days, day, locale, "")

  defp format_tier(locale, day, week, _month, _year, _half, delim, _just_born, months, diff_days)
       when months < 3 do
    weeks = div(diff_days, 7)
    days = rem(diff_days, 7)
    w_str = Locale.resolve_unit(weeks, week, locale, "")

    if days > 0 do
      w_str <> delim <> Locale.resolve_unit(days, day, locale, "")
    else
      w_str
    end
  end

  defp format_tier(locale, _day, _week, month, _year, _half, _delim, _just_born, months, _diff_days)
       when months < 24,
       do: Locale.resolve_unit(months, month, locale, "")

  defp format_tier(locale, _day, _week, month, year, _half, delim, _just_born, months, _diff_days)
       when months < 36 do
    years = div(months, 12)
    rem_months = rem(months, 12)
    y_str = Locale.resolve_unit(years, year, locale, "")

    if rem_months == 0 do
      y_str
    else
      y_str <> delim <> Locale.resolve_unit(rem_months, month, locale, "")
    end
  end

  defp format_tier(locale, _day, _week, _month, year, half, _delim, _just_born, months, _diff_days)
       when months < 84 do
    years = div(months, 12)
    rem_months = rem(months, 12)

    if rem_months >= 6 do
      Locale.resolve_unit(years, year, locale, half)
    else
      Locale.resolve_unit(years, year, locale, "")
    end
  end

  defp format_tier(locale, _day, _week, _month, year, _half, _delim, _just_born, months, _diff_days) do
    years = div(months, 12)
    Locale.resolve_unit(years, year, locale, "")
  end

  # Locale resolution with compactness overrides

  defp resolve_locale(locale, :normal) do
    {locale.units.day, locale.units.week, locale.units.month, locale.units.year,
     locale.half, locale.delimiter, locale.just_born}
  end

  defp resolve_locale(locale, compactness) do
    ovr = Map.get(locale, compactness)

    case ovr do
      nil ->
        resolve_locale(locale, :normal)

      ovr ->
        units = Map.get(ovr, :units, %{})

        {ovr_unit(units, :day, locale.units.day),
         ovr_unit(units, :week, locale.units.week),
         ovr_unit(units, :month, locale.units.month),
         ovr_unit(units, :year, locale.units.year),
         Map.get(ovr, :half, locale.half),
         Map.get(ovr, :delimiter, locale.delimiter),
         Map.get(ovr, :just_born, locale.just_born)}
    end
  end

  defp ovr_unit(units, key, default), do: Map.get(units, key, default)

  # Stage labels

  defp stage_label(months, stages) when months < 2, do: stages.newborn
  defp stage_label(months, stages) when months < 12, do: stages.infant
  defp stage_label(months, stages) when months < 36, do: stages.toddler
  defp stage_label(months, stages) when months < 156, do: stages.child
  defp stage_label(months, stages) when months < 216, do: stages.teenager
  defp stage_label(_months, stages), do: stages.adult

  # Date computation

  defp compute_age(dob, as_of) do
    with {:ok, {dy, dm, dd}} <- parse_date(dob),
         {:ok, {ry, rm, rd}} <- parse_date(as_of) do
      diff_days = days_between({dy, dm, dd}, {ry, rm, rd})

      if diff_days < 0 do
        :error
      else
        last_day = days_in_month(ry, rm)
        clamped_birthday = min(dd, last_day)
        months0 = (ry - dy) * 12 + (rm - dm)
        months = if rd < clamped_birthday, do: months0 - 1, else: months0

        if months > @max_age_months do
          :error
        else
          {:ok, {months, diff_days}}
        end
      end
    end
  end

  defp parse_date(s) when is_binary(s) and byte_size(s) >= 10 do
    with <<y::binary-size(4), ?-, m::binary-size(2), ?-, d::binary-size(2), _rest::binary>> <- s,
         {year, ""} <- Integer.parse(y),
         {month, ""} <- Integer.parse(m),
         {day, ""} <- Integer.parse(d) do
      if year == 0 and month == 0 and day == 0 do
        :error
      else
        {:ok, {year, month, day}}
      end
    else
      _ -> :error
    end
  end

  defp parse_date(_), do: :error

  defp is_leap_year(y), do: (rem(y, 4) == 0 and rem(y, 100) != 0) or rem(y, 400) == 0

  defp days_in_month(_, m) when m in [1, 3, 5, 7, 8, 10, 12], do: 31
  defp days_in_month(_, m) when m in [4, 6, 9, 11], do: 30
  defp days_in_month(y, 2), do: if(is_leap_year(y), do: 29, else: 28)
  defp days_in_month(_, _), do: 30

  defp to_jdn(y, m, d) do
    a = div(14 - m, 12)
    yy = y + 4800 - a
    mm = m + 12 * a - 3
    d + div(153 * mm + 2, 5) + 365 * yy + div(yy, 4) - div(yy, 100) + div(yy, 400) - 32045
  end

  defp days_between({y1, m1, d1}, {y2, m2, d2}),
    do: to_jdn(y2, m2, d2) - to_jdn(y1, m1, d1)
end
