defmodule SayableCli do
  @moduledoc false

  @version "0.5.0"

  @help """
  Usage: sayable <command> [arguments] [options]

  Commands:
    age <dob>              Format an age
    stage <dob>            Get developmental stage
    date <date>            Format a calendar date
    relative <date>        Format a relative date
    time <time>            Format a clock time
    duration <value> [end] Format a duration
    since <start>          Format elapsed time
    until <target>         Format remaining time
    locales                List available locale codes
    version                Show version
    help                   Show this help

  Options:
    -l, --locale <code>    Locale code (default: en)
    -d, --as-of <value>    Reference date/timestamp
        --short            Short compactness
        --compact          Compact compactness
    -g, --gender <m|f>     Gender for stage labels
        --with-year        Include year (date only)
    -h, --help             Show this help
    -v, --version          Show version\
  """

  def main(argv) do
    {command, positionals, options} = parse_args(argv)

    case command do
      nil ->
        IO.puts(@help)
        System.halt(2)

      "help" ->
        IO.puts(@help)
        System.halt(0)

      "version" ->
        IO.puts("sayable #{@version}")
        System.halt(0)

      "locales" ->
        cmd_locales()
        System.halt(0)

      "age" ->
        cmd_age(positionals, options)

      "stage" ->
        cmd_stage(positionals, options)

      "date" ->
        cmd_date(positionals, options)

      "relative" ->
        cmd_relative(positionals, options)

      "time" ->
        cmd_time(positionals, options)

      "duration" ->
        cmd_duration(positionals, options)

      "since" ->
        cmd_since(positionals, options)

      "until" ->
        cmd_until(positionals, options)

      other ->
        error("unknown command '#{other}'")
    end
  end

  # Argument parsing

  defp parse_args([]), do: {nil, [], %{}}

  defp parse_args([first | _]) when first in ["-h", "--help", "help"],
    do: {"help", [], %{}}

  defp parse_args([first | _]) when first in ["-v", "--version", "version"],
    do: {"version", [], %{}}

  defp parse_args([command | rest]) do
    options = %{
      locale: "en",
      as_of: nil,
      compactness: :normal,
      gender: nil,
      with_year: false
    }

    {positionals, options} = parse_options(rest, [], options, false)
    {command, positionals, options}
  end

  defp parse_options([], positionals, options, _stop_opts),
    do: {Enum.reverse(positionals), options}

  defp parse_options(["--" | rest], positionals, options, false),
    do: parse_options(rest, positionals, options, true)

  defp parse_options([arg | rest], positionals, options, false) when binary_part(arg, 0, 1) == "-" do
    case arg do
      a when a in ["-l", "--locale"] ->
        case rest do
          [] -> error("'#{arg}' requires a value")
          [val | rest2] -> parse_options(rest2, positionals, %{options | locale: val}, false)
        end

      a when a in ["-d", "--as-of"] ->
        case rest do
          [] -> error("'#{arg}' requires a value")
          [val | rest2] -> parse_options(rest2, positionals, %{options | as_of: val}, false)
        end

      a when a in ["-g", "--gender"] ->
        case rest do
          [] -> error("'#{arg}' requires a value")
          [val | rest2] -> parse_options(rest2, positionals, %{options | gender: val}, false)
        end

      "--short" ->
        parse_options(rest, positionals, %{options | compactness: :short}, false)

      "--compact" ->
        parse_options(rest, positionals, %{options | compactness: :compact}, false)

      "--with-year" ->
        parse_options(rest, positionals, %{options | with_year: true}, false)

      a when a in ["-h", "--help"] ->
        IO.puts(@help)
        System.halt(0)

      a when a in ["-v", "--version"] ->
        IO.puts("sayable #{@version}")
        System.halt(0)

      _ ->
        error("unknown option '#{arg}'")
    end
  end

  defp parse_options([arg | rest], positionals, options, stop_opts),
    do: parse_options(rest, [arg | positionals], options, stop_opts)

  # Null sentinel handling

  defp nullify("null"), do: nil
  defp nullify(value), do: value

  # Error helper

  defp error(msg) do
    IO.puts(:stderr, "error: #{msg}")
    IO.puts(:stderr, "Run 'sayable help' for usage.")
    System.halt(2)
  end

  # Today's date

  defp get_today do
    {year, month, day} = :erlang.date()

    y = year |> Integer.to_string() |> String.pad_leading(4, "0")
    m = month |> Integer.to_string() |> String.pad_leading(2, "0")
    d = day |> Integer.to_string() |> String.pad_leading(2, "0")

    "#{y}-#{m}-#{d}"
  end

  # Gender conversion

  defp parse_gender("f"), do: :female
  defp parse_gender("m"), do: :male
  defp parse_gender(nil), do: nil
  defp parse_gender(_), do: nil

  # Command implementations

  defp cmd_age([], _options), do: error("age requires a date-of-birth argument")

  defp cmd_age([raw_dob | _], options) do
    dob = nullify(raw_dob)
    locale_code = options.locale

    case SayableAge.get_locale(locale_code) do
      {:ok, locale} ->
        as_of =
          case options.as_of do
            nil -> get_today()
            val -> nullify(val)
          end

        result = SayableAge.format_age(locale, options.compactness, dob, as_of)

        case result do
          {:ok, text} -> IO.puts(text)
          :error -> System.halt(1)
        end

      :error ->
        error("unknown locale '#{locale_code}'")
    end
  end

  defp cmd_stage([], _options), do: error("stage requires a date-of-birth argument")

  defp cmd_stage([raw_dob | _], options) do
    dob = nullify(raw_dob)
    locale_code = options.locale

    case SayableAge.get_locale(locale_code) do
      {:ok, locale} ->
        as_of =
          case options.as_of do
            nil -> get_today()
            val -> nullify(val)
          end

        gender = parse_gender(options.gender)
        result = SayableAge.format_stage(locale, dob, as_of, gender)

        case result do
          {:ok, text} -> IO.puts(text)
          :error -> System.halt(1)
        end

      :error ->
        error("unknown locale '#{locale_code}'")
    end
  end

  defp cmd_date([], _options), do: error("date requires a date argument")

  defp cmd_date([raw_date | _], options) do
    date_val = nullify(raw_date)
    locale_code = options.locale

    case SayableDate.get_locale(locale_code) do
      {:ok, locale} ->
        result =
          if options.with_year do
            SayableDate.format_date_with_year(locale, options.compactness, date_val)
          else
            SayableDate.format_date(locale, options.compactness, date_val)
          end

        case result do
          {:ok, text} -> IO.puts(text)
          nil -> System.halt(1)
        end

      :error ->
        error("unknown locale '#{locale_code}'")
    end
  end

  defp cmd_relative([], _options), do: error("relative requires a date argument")

  defp cmd_relative([raw_date | _], options) do
    date_val = nullify(raw_date)

    case options.as_of do
      nil ->
        error("relative requires --as-of / -d option")

      raw_as_of ->
        as_of = nullify(raw_as_of)
        locale_code = options.locale

        case SayableDate.get_locale(locale_code) do
          {:ok, locale} ->
            result = SayableDate.format_relative(locale, options.compactness, date_val, as_of)

            case result do
              {:ok, text} -> IO.puts(text)
              nil -> System.halt(1)
            end

          :error ->
            error("unknown locale '#{locale_code}'")
        end
    end
  end

  defp cmd_time([], _options), do: error("time requires a time argument")

  defp cmd_time([raw_time | _], options) do
    time_val = nullify(raw_time)
    locale_code = options.locale

    case SayableTime.get_locale(locale_code) do
      {:ok, locale} ->
        result = SayableTime.format_time(locale, options.compactness, time_val)

        case result do
          {:ok, text} -> IO.puts(text)
          nil -> System.halt(1)
        end

      :error ->
        error("unknown locale '#{locale_code}'")
    end
  end

  defp cmd_duration([], _options), do: error("duration requires a value argument")

  defp cmd_duration(positionals, options) do
    [raw_value | rest] = positionals
    value = nullify(raw_value)
    locale_code = options.locale

    case SayableDuration.get_locale(locale_code) do
      {:ok, locale} ->
        result =
          cond do
            value == nil ->
              SayableDuration.format_duration(locale, options.compactness, nil)

            is_integer_string(value) ->
              SayableDuration.format_duration(locale, options.compactness, String.to_integer(value))

            true ->
              case rest do
                [] ->
                  error("duration with timestamps requires start and end arguments")

                [raw_end | _] ->
                  end_val = nullify(raw_end)
                  SayableDuration.format_duration(locale, options.compactness, value, end_val)
              end
          end

        case result do
          {:ok, text} -> IO.puts(text)
          nil -> System.halt(1)
        end

      :error ->
        error("unknown locale '#{locale_code}'")
    end
  end

  defp cmd_since([], _options), do: error("since requires a start timestamp argument")

  defp cmd_since([raw_start | _], options) do
    start = nullify(raw_start)

    case options.as_of do
      nil ->
        error("since requires --as-of / -d option")

      raw_as_of ->
        as_of = nullify(raw_as_of)
        locale_code = options.locale

        case SayableDuration.get_locale(locale_code) do
          {:ok, locale} ->
            result = SayableDuration.format_since(locale, options.compactness, start, as_of)

            case result do
              {:ok, text} -> IO.puts(text)
              nil -> System.halt(1)
            end

          :error ->
            error("unknown locale '#{locale_code}'")
        end
    end
  end

  defp cmd_until([], _options), do: error("until requires a target timestamp argument")

  defp cmd_until([raw_target | _], options) do
    target = nullify(raw_target)

    case options.as_of do
      nil ->
        error("until requires --as-of / -d option")

      raw_as_of ->
        as_of = nullify(raw_as_of)
        locale_code = options.locale

        case SayableDuration.get_locale(locale_code) do
          {:ok, locale} ->
            result = SayableDuration.format_until(locale, options.compactness, target, as_of)

            case result do
              {:ok, text} -> IO.puts(text)
              nil -> System.halt(1)
            end

          :error ->
            error("unknown locale '#{locale_code}'")
        end
    end
  end

  defp cmd_locales do
    codes =
      ~w(af ak am ar az bci be bem bg bm bn br bs ca ceb cs cy da de din dje dyu
         ee el en es et eu fa fan ff fi fil fon fr ga gd gl gn gu gv ha he hi
         hr ht hu hy id ig is it ja jv ka kbp kk km kn ko kpe ktu ku kw ky lg
         ln lo lt lv men mfe mg mi mk ml mn mnk mos mr ms mt my nb nd ne ng nl
         nso nus ny om or pa pl pov ps pt qu ro ru rw sar sd sg shi si sk sl sn
         snk so sq sr ss st su suk sv sw ta te tem tg th ti tig tk tn tr ts tzm
         uk umb ur uz vi vmw wo xh yo yue zdj zh zu)
      |> Enum.filter(fn code ->
        case SayableAge.get_locale(code) do
          {:ok, _} -> true
          :error -> false
        end
      end)
      |> Enum.sort()

    Enum.each(codes, &IO.puts/1)
  end

  # Integer detection for duration argument

  defp is_integer_string(""), do: false

  defp is_integer_string(<<"-", rest::binary>>) when byte_size(rest) > 0,
    do: all_digits?(rest)

  defp is_integer_string(s), do: all_digits?(s)

  defp all_digits?(""), do: false

  defp all_digits?(s) do
    s
    |> String.to_charlist()
    |> Enum.all?(fn c -> c >= ?0 and c <= ?9 end)
  end
end
