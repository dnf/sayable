defmodule ParentTime.Locale do
  @moduledoc false

  def resolve_unit(count, unit_forms, locale, half) do
    base_n = Integer.to_string(count)

    n =
      if half != "" and String.contains?(half, "{n}") do
        String.replace(half, "{n}", base_n)
      else
        base_n
      end

    plural_fn = locale.plural
    template =
      case unit_forms do
        s when is_binary(s) -> s
        forms when is_map(forms) -> lookup_form(plural_fn.(count), forms)
      end

    result = String.replace(template, "{n}", n)

    if half != "" and String.contains?(half, "{0}") do
      String.replace(half, "{0}", result)
    else
      result
    end
  end

  def resolve_stage(label, gender) do
    case label do
      s when is_binary(s) -> s
      %{m: m, f: f} -> if gender == :female, do: f, else: m
    end
  end

  defp lookup_form(category, forms) do
    Map.get(forms, category) || Map.get(forms, :other, "")
  end
end
