defmodule SayableDuration.Locale do
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
        s when is_binary(s) ->
          s

        forms when is_map(forms) ->
          category = if half != "", do: :other, else: plural_fn.(count)
          Map.get(forms, category) || Map.get(forms, :other, "")
      end

    result = String.replace(template, "{n}", n)

    if half != "" and String.contains?(half, "{0}") do
      String.replace(half, "{0}", result)
    else
      result
    end
  end
end
