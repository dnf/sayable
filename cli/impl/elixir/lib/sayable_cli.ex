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

  defmodule UsageError do
    @moduledoc false
    defexception [:message]
  end

  @type result :: {0..2, [String.t()]}

  def main(["--repl"]) do
    repl()
    System.halt(0)
  end

  def main(argv) do
    {code, lines} = run(argv)
    Enum.each(lines, &IO.puts/1)
    System.halt(code)
  end

  @spec run([String.t()]) :: result()
  def run(argv) do
    {command, positionals, options} = parse_args(argv)
    dispatch(command, positionals, options)
  rescue
    e in UsageError ->
      IO.puts(:stderr, "error: #{e.message}")
      IO.puts(:stderr, "Run 'sayable help' for usage.")
      {2, []}
  end

  defp dispatch(nil, _positionals, _options), do: {2, [@help]}
  defp dispatch("help", _positionals, _options), do: {0, [@help]}
  defp dispatch("version", _positionals, _options), do: {0, ["sayable #{@version}"]}
  defp dispatch("locales", _positionals, _options), do: {0, locale_codes()}
  defp dispatch("age", positionals, options), do: cmd_age(positionals, options)
  defp dispatch("stage", positionals, options), do: cmd_stage(positionals, options)
  defp dispatch("date", positionals, options), do: cmd_date(positionals, options)
  defp dispatch("relative", positionals, options), do: cmd_relative(positionals, options)
  defp dispatch("time", positionals, options), do: cmd_time(positionals, options)
  defp dispatch("duration", positionals, options), do: cmd_duration(positionals, options)
  defp dispatch("since", positionals, options), do: cmd_since(positionals, options)
  defp dispatch("until", positionals, options), do: cmd_until(positionals, options)
  defp dispatch(other, _positionals, _options), do: error("unknown command '#{other}'")

  # REPL mode (see cli/SPEC.md)

  defp repl do
    case IO.read(:stdio, :line) do
      :eof ->
        :ok

      {:error, reason} ->
        IO.puts(:stderr, "error: cannot read request: #{inspect(reason)}")
        System.halt(1)

      line ->
        {code, lines} = line |> request_args() |> run_isolated()

        IO.write([
          Integer.to_string(code),
          "\t",
          Enum.join(lines, "\t") |> String.replace("\n", "\t"),
          "\n"
        ])

        repl()
    end
  end

  defp request_args(line) do
    line
    |> String.replace_suffix("\n", "")
    |> String.replace_suffix("\r", "")
    |> String.split("\t")
  end

  # A crashed one-shot run exits 1, so a crashed request answers 1 and the REPL keeps serving.
  defp run_isolated(args) do
    run(args)
  catch
    kind, reason ->
      IO.puts(:stderr, "error: " <> Exception.format(kind, reason, __STACKTRACE__))
      {1, []}
  end

  # Argument parsing

  defp parse_args([]), do: {nil, [], %{}}

  defp parse_args([first | _]) when first in ["-h", "--help", "help"],
    do: {"help", [], %{}}

  defp parse_args([first | _]) when first in ["-v", "--version", "version"],
    do: {"version", [], %{}}

  # An option such as `--help` replaces the whole command, wherever it appears.
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
  catch
    {:replace_command, replacement} -> {replacement, [], %{}}
  end

  defp parse_options([], positionals, options, _stop_opts),
    do: {Enum.reverse(positionals), options}

  defp parse_options(["--" | rest], positionals, options, false),
    do: parse_options(rest, positionals, options, true)

  defp parse_options([arg | rest], positionals, options, false)
       when binary_part(arg, 0, 1) == "-" do
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
        throw({:replace_command, "help"})

      a when a in ["-v", "--version"] ->
        throw({:replace_command, "version"})

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

  # Unwinds to run/1, which reports the message and answers exit code 2.
  defp error(msg), do: raise(UsageError, msg)

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

  # Command results

  defp formatted({:ok, text}), do: {0, [text]}
  defp formatted(_null), do: {1, []}

  defp locale(component, locale_code) do
    case component.get_locale(locale_code) do
      {:ok, locale} -> locale
      :error -> error("unknown locale '#{locale_code}'")
    end
  end

  defp as_of_or_today(%{as_of: nil}), do: get_today()
  defp as_of_or_today(%{as_of: raw_as_of}), do: nullify(raw_as_of)

  defp required_as_of(command, %{as_of: nil}),
    do: error("#{command} requires --as-of / -d option")

  defp required_as_of(_command, %{as_of: raw_as_of}), do: nullify(raw_as_of)

  # Command implementations

  defp cmd_age([], _options), do: error("age requires a date-of-birth argument")

  defp cmd_age([raw_dob | _], options) do
    locale = locale(SayableAge, options.locale)

    formatted(
      SayableAge.format_age(
        locale,
        options.compactness,
        nullify(raw_dob),
        as_of_or_today(options)
      )
    )
  end

  defp cmd_stage([], _options), do: error("stage requires a date-of-birth argument")

  defp cmd_stage([raw_dob | _], options) do
    locale = locale(SayableAge, options.locale)
    gender = parse_gender(options.gender)
    formatted(SayableAge.format_stage(locale, nullify(raw_dob), as_of_or_today(options), gender))
  end

  defp cmd_date([], _options), do: error("date requires a date argument")

  defp cmd_date([raw_date | _], options) do
    date_val = nullify(raw_date)
    locale = locale(SayableDate, options.locale)

    if options.with_year do
      formatted(SayableDate.format_date_with_year(locale, options.compactness, date_val))
    else
      formatted(SayableDate.format_date(locale, options.compactness, date_val))
    end
  end

  defp cmd_relative([], _options), do: error("relative requires a date argument")

  defp cmd_relative([raw_date | _], options) do
    as_of = required_as_of("relative", options)
    locale = locale(SayableDate, options.locale)
    formatted(SayableDate.format_relative(locale, options.compactness, nullify(raw_date), as_of))
  end

  defp cmd_time([], _options), do: error("time requires a time argument")

  defp cmd_time([raw_time | _], options) do
    locale = locale(SayableTime, options.locale)
    formatted(SayableTime.format_time(locale, options.compactness, nullify(raw_time)))
  end

  defp cmd_duration([], _options), do: error("duration requires a value argument")

  defp cmd_duration([raw_value | rest], options) do
    value = nullify(raw_value)
    locale = locale(SayableDuration, options.locale)

    cond do
      value == nil ->
        formatted(SayableDuration.format_duration(locale, options.compactness, nil))

      is_integer_string(value) ->
        formatted(
          SayableDuration.format_duration(locale, options.compactness, String.to_integer(value))
        )

      true ->
        case rest do
          [] ->
            error("duration with timestamps requires start and end arguments")

          [raw_end | _] ->
            formatted(
              SayableDuration.format_duration(
                locale,
                options.compactness,
                value,
                nullify(raw_end)
              )
            )
        end
    end
  end

  defp cmd_since([], _options), do: error("since requires a start timestamp argument")

  defp cmd_since([raw_start | _], options) do
    as_of = required_as_of("since", options)
    locale = locale(SayableDuration, options.locale)

    formatted(
      SayableDuration.format_since(locale, options.compactness, nullify(raw_start), as_of)
    )
  end

  defp cmd_until([], _options), do: error("until requires a target timestamp argument")

  defp cmd_until([raw_target | _], options) do
    as_of = required_as_of("until", options)
    locale = locale(SayableDuration, options.locale)

    formatted(
      SayableDuration.format_until(locale, options.compactness, nullify(raw_target), as_of)
    )
  end

  # Every generated SayableAge.Locales.<CODE> module, so the list can't drift
  # from the locale JSON files.
  defp locale_codes do
    Application.load(:sayable_age)
    {:ok, modules} = :application.get_key(:sayable_age, :modules)

    modules
    |> Enum.filter(&age_locale_module?/1)
    |> Enum.map(& &1.locale().code)
    |> Enum.sort()
  end

  defp age_locale_module?(module), do: match?(["SayableAge", "Locales", _], Module.split(module))

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
