using System;
using System.Collections.Generic;
using System.Reflection;

using AgeLib = SayableAgeLib;
using DateLib = SayableDateLib;
using TimeLib = SayableTimeLib;
using DurationLib = SayableDurationLib;

namespace SayableCli;

static class Program
{
    const string Version = "0.5.0";

    const string HelpText = @"Usage: sayable <command> [arguments] [options]

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
  -v, --version          Show version";

    // Lazy locale dictionaries built via reflection
    static readonly Lazy<Dictionary<string, AgeLib.AgeLocale>> AgeLocales = new(BuildAgeLocales);
    static readonly Lazy<Dictionary<string, DateLib.DateLocale>> DateLocales = new(BuildDateLocales);
    static readonly Lazy<Dictionary<string, TimeLib.TimeLocale>> TimeLocales = new(BuildTimeLocales);
    static readonly Lazy<Dictionary<string, DurationLib.DurationLocale>> DurationLocales = new(BuildDurationLocales);

    static Dictionary<string, AgeLib.AgeLocale> BuildAgeLocales()
    {
        var dict = new Dictionary<string, AgeLib.AgeLocale>();
        foreach (var field in typeof(AgeLib.Locales).GetFields(BindingFlags.Public | BindingFlags.Static))
        {
            if (field.FieldType == typeof(AgeLib.AgeLocale) && field.GetValue(null) is AgeLib.AgeLocale locale)
                dict[locale.Code] = locale;
        }
        return dict;
    }

    static Dictionary<string, DateLib.DateLocale> BuildDateLocales()
    {
        var dict = new Dictionary<string, DateLib.DateLocale>();
        foreach (var field in typeof(DateLib.Locales).GetFields(BindingFlags.Public | BindingFlags.Static))
        {
            if (field.FieldType == typeof(DateLib.DateLocale) && field.GetValue(null) is DateLib.DateLocale locale)
                dict[locale.Code] = locale;
        }
        return dict;
    }

    static Dictionary<string, TimeLib.TimeLocale> BuildTimeLocales()
    {
        var dict = new Dictionary<string, TimeLib.TimeLocale>();
        foreach (var field in typeof(TimeLib.Locales).GetFields(BindingFlags.Public | BindingFlags.Static))
        {
            if (field.FieldType == typeof(TimeLib.TimeLocale) && field.GetValue(null) is TimeLib.TimeLocale locale)
                dict[locale.Code] = locale;
        }
        return dict;
    }

    static Dictionary<string, DurationLib.DurationLocale> BuildDurationLocales()
    {
        var dict = new Dictionary<string, DurationLib.DurationLocale>();
        foreach (var field in typeof(DurationLib.Locales).GetFields(BindingFlags.Public | BindingFlags.Static))
        {
            if (field.FieldType == typeof(DurationLib.DurationLocale) && field.GetValue(null) is DurationLib.DurationLocale locale)
                dict[locale.Code] = locale;
        }
        return dict;
    }

    static int Main(string[] args)
    {
        if (args is ["--repl"])
            return Repl();

        var outcome = Run(args);
        if (outcome.Output != null)
            Console.WriteLine(outcome.Output);
        return outcome.ExitCode;
    }

    /// <summary>Answers one tab-separated request per stdin line (see cli/SPEC.md, "REPL Mode").</summary>
    static int Repl()
    {
        string? line;
        while ((line = Console.In.ReadLine()) != null)
        {
            var outcome = RunCatchingCrashes(line.Split('\t'));
            string output = outcome.Output?.Replace('\n', '\t') ?? "";
            Console.Out.Write($"{outcome.ExitCode}\t{output}\n");
            Console.Out.Flush();
        }
        return 0;
    }

    /// <summary>A crash must not end the REPL: the request answers 1 (cli/SPEC.md) and the error goes to stderr.</summary>
    static Outcome RunCatchingCrashes(string[] args)
    {
        try
        {
            return Run(args);
        }
        catch (Exception e)
        {
            Console.Error.WriteLine(e);
            return new Outcome(1, null);
        }
    }

    static Outcome Run(string[] args)
    {
        string? command;
        List<string> positionals;
        Options options;
        try
        {
            (command, positionals, options) = ParseArgs(args);
        }
        catch (UsageException e)
        {
            return Error(e.Message);
        }

        return command switch
        {
            null => new Outcome(2, HelpText),
            "help" => Outcome.Printing(HelpText),
            "version" => Outcome.Printing($"sayable {Version}"),
            "locales" => CmdLocales(),
            "age" => CmdAge(positionals, options),
            "stage" => CmdStage(positionals, options),
            "date" => CmdDate(positionals, options),
            "relative" => CmdRelative(positionals, options),
            "time" => CmdTime(positionals, options),
            "duration" => CmdDuration(positionals, options),
            "since" => CmdSince(positionals, options),
            "until" => CmdUntil(positionals, options),
            _ => Error($"unknown command '{command}'"),
        };
    }

    static (string? Command, List<string> Positionals, Options Opts) ParseArgs(string[] argv)
    {
        if (argv.Length == 0)
            return (null, new List<string>(), new Options());

        // Global flags that can appear as the first argument
        if (argv[0] is "-h" or "--help" or "help")
            return ("help", new List<string>(), new Options());
        if (argv[0] is "-v" or "--version" or "version")
            return ("version", new List<string>(), new Options());

        string command = argv[0];
        var positionals = new List<string>();
        var options = new Options();

        int i = 1;
        bool stopOpts = false;
        while (i < argv.Length)
        {
            string arg = argv[i];

            if (arg == "--" && !stopOpts)
            {
                stopOpts = true;
                i++;
                continue;
            }

            if (!stopOpts && arg.StartsWith("-"))
            {
                if (arg is "-l" or "--locale")
                {
                    if (i + 1 >= argv.Length)
                        throw new UsageException($"'{arg}' requires a value");
                    i++;
                    options.Locale = argv[i];
                }
                else if (arg is "-d" or "--as-of")
                {
                    if (i + 1 >= argv.Length)
                        throw new UsageException($"'{arg}' requires a value");
                    i++;
                    options.AsOf = argv[i];
                }
                else if (arg is "-g" or "--gender")
                {
                    if (i + 1 >= argv.Length)
                        throw new UsageException($"'{arg}' requires a value");
                    i++;
                    options.Gender = argv[i];
                }
                else if (arg == "--short")
                {
                    options.Compactness = "short";
                }
                else if (arg == "--compact")
                {
                    options.Compactness = "compact";
                }
                else if (arg == "--with-year")
                {
                    options.WithYear = true;
                }
                else if (arg is "-h" or "--help")
                {
                    return ("help", new List<string>(), new Options());
                }
                else if (arg is "-v" or "--version")
                {
                    return ("version", new List<string>(), new Options());
                }
                else
                {
                    throw new UsageException($"unknown option '{arg}'");
                }
            }
            else
            {
                positionals.Add(arg);
            }

            i++;
        }

        return (command, positionals, options);
    }

    static string? Nullify(string value) => value == "null" ? null : value;

    static string GetToday() => DateTime.Today.ToString("yyyy-MM-dd");

    static AgeLib.Compactness ToAgeCompactness(string compactness) => compactness switch
    {
        "short" => AgeLib.Compactness.Short,
        "compact" => AgeLib.Compactness.Compact,
        _ => AgeLib.Compactness.Normal,
    };

    static DateLib.Compactness ToDateCompactness(string compactness) => compactness switch
    {
        "short" => DateLib.Compactness.Short,
        "compact" => DateLib.Compactness.Compact,
        _ => DateLib.Compactness.Normal,
    };

    static TimeLib.Compactness ToTimeCompactness(string compactness) => compactness switch
    {
        "short" => TimeLib.Compactness.Short,
        "compact" => TimeLib.Compactness.Compact,
        _ => TimeLib.Compactness.Normal,
    };

    static DurationLib.Compactness ToDurationCompactness(string compactness) => compactness switch
    {
        "short" => DurationLib.Compactness.Short,
        "compact" => DurationLib.Compactness.Compact,
        _ => DurationLib.Compactness.Normal,
    };

    static Outcome CmdAge(List<string> positionals, Options options)
    {
        if (positionals.Count == 0)
            return Error("age requires a date-of-birth argument");

        string? dob = Nullify(positionals[0]);
        string localeCode = options.Locale;

        if (!AgeLocales.Value.TryGetValue(localeCode, out var locale))
            return Error($"unknown locale '{localeCode}'");

        string? asOf = options.AsOf != null ? Nullify(options.AsOf) : GetToday();

        var formatter = new AgeLib.SayableAgeFormatter(locale, ToAgeCompactness(options.Compactness));
        string? result = formatter.FormatAge(dob, asOf);

        return Outcome.OfResult(result);
    }

    static Outcome CmdStage(List<string> positionals, Options options)
    {
        if (positionals.Count == 0)
            return Error("stage requires a date-of-birth argument");

        string? dob = Nullify(positionals[0]);
        string localeCode = options.Locale;

        if (!AgeLocales.Value.TryGetValue(localeCode, out var locale))
            return Error($"unknown locale '{localeCode}'");

        string? asOf = options.AsOf != null ? Nullify(options.AsOf) : GetToday();
        string? gender = options.Gender;

        var formatter = new AgeLib.SayableAgeFormatter(locale, ToAgeCompactness(options.Compactness));
        string? result = formatter.FormatStage(dob, asOf, gender);

        return Outcome.OfResult(result);
    }

    static Outcome CmdDate(List<string> positionals, Options options)
    {
        if (positionals.Count == 0)
            return Error("date requires a date argument");

        string? dateVal = Nullify(positionals[0]);
        string localeCode = options.Locale;

        if (!DateLocales.Value.TryGetValue(localeCode, out var locale))
            return Error($"unknown locale '{localeCode}'");

        var formatter = new DateLib.SayableDate(locale, ToDateCompactness(options.Compactness));

        string? result;
        if (options.WithYear)
            result = formatter.FormatWithYear(dateVal);
        else
            result = formatter.Format(dateVal);

        return Outcome.OfResult(result);
    }

    static Outcome CmdRelative(List<string> positionals, Options options)
    {
        if (positionals.Count == 0)
            return Error("relative requires a date argument");

        string? dateVal = Nullify(positionals[0]);

        if (options.AsOf == null)
            return Error("relative requires --as-of / -d option");

        string? asOf = Nullify(options.AsOf);
        string localeCode = options.Locale;

        if (!DateLocales.Value.TryGetValue(localeCode, out var locale))
            return Error($"unknown locale '{localeCode}'");

        var formatter = new DateLib.SayableDate(locale, ToDateCompactness(options.Compactness));
        string? result = formatter.Relative(dateVal, asOf);

        return Outcome.OfResult(result);
    }

    static Outcome CmdTime(List<string> positionals, Options options)
    {
        if (positionals.Count == 0)
            return Error("time requires a time argument");

        string? timeVal = Nullify(positionals[0]);
        string localeCode = options.Locale;

        if (!TimeLocales.Value.TryGetValue(localeCode, out var locale))
            return Error($"unknown locale '{localeCode}'");

        var formatter = new TimeLib.SayableTime(locale, ToTimeCompactness(options.Compactness));
        string? result = formatter.Format(timeVal);

        return Outcome.OfResult(result);
    }

    static Outcome CmdDuration(List<string> positionals, Options options)
    {
        if (positionals.Count == 0)
            return Error("duration requires a value argument");

        string? value = Nullify(positionals[0]);
        string localeCode = options.Locale;

        if (!DurationLocales.Value.TryGetValue(localeCode, out var locale))
            return Error($"unknown locale '{localeCode}'");

        var formatter = new DurationLib.SayableDuration(locale, ToDurationCompactness(options.Compactness));

        string? result;
        if (value == null)
        {
            // null input — format_duration(null) is not a valid call, return null
            return Outcome.OfResult(null);
        }
        else if (IsInteger(value))
        {
            int seconds = int.Parse(value);
            result = formatter.FormatDuration(seconds);
        }
        else
        {
            // Timestamp mode: need an end argument
            if (positionals.Count < 2)
                return Error("duration with timestamps requires start and end arguments");
            string end = positionals[1];
            result = formatter.FormatIso(value, end);
        }

        return Outcome.OfResult(result);
    }

    static Outcome CmdSince(List<string> positionals, Options options)
    {
        if (positionals.Count == 0)
            return Error("since requires a start timestamp argument");

        string? start = Nullify(positionals[0]);

        if (options.AsOf == null)
            return Error("since requires --as-of / -d option");

        string? asOf = Nullify(options.AsOf);
        string localeCode = options.Locale;

        if (!DurationLocales.Value.TryGetValue(localeCode, out var locale))
            return Error($"unknown locale '{localeCode}'");

        var formatter = new DurationLib.SayableDuration(locale, ToDurationCompactness(options.Compactness));
        string? result = formatter.Since(start, asOf);

        return Outcome.OfResult(result);
    }

    static Outcome CmdUntil(List<string> positionals, Options options)
    {
        if (positionals.Count == 0)
            return Error("until requires a target timestamp argument");

        string? target = Nullify(positionals[0]);

        if (options.AsOf == null)
            return Error("until requires --as-of / -d option");

        string? asOf = Nullify(options.AsOf);
        string localeCode = options.Locale;

        if (!DurationLocales.Value.TryGetValue(localeCode, out var locale))
            return Error($"unknown locale '{localeCode}'");

        var formatter = new DurationLib.SayableDuration(locale, ToDurationCompactness(options.Compactness));
        string? result = formatter.Until(target, asOf);

        return Outcome.OfResult(result);
    }

    static Outcome CmdLocales()
    {
        // Use age locales as the canonical list
        var codes = new SortedSet<string>(AgeLocales.Value.Keys);
        return Outcome.Printing(string.Join("\n", codes));
    }

    /// <summary>
    /// Check if a string is an integer (including negative integers).
    /// Matches: "0", "123", "-1", "-42"
    /// </summary>
    static bool IsInteger(string s)
    {
        if (string.IsNullOrEmpty(s)) return false;
        int start = 0;
        if (s[0] == '-')
        {
            if (s.Length == 1) return false;
            start = 1;
        }
        for (int i = start; i < s.Length; i++)
        {
            if (s[i] < '0' || s[i] > '9') return false;
        }
        return true;
    }

    static Outcome Error(string msg)
    {
        Console.Error.WriteLine($"error: {msg}");
        Console.Error.WriteLine("Run 'sayable help' for usage.");
        return new Outcome(2, null);
    }
}

/// <summary>What one invocation prints to stdout (null: nothing) and the code it exits with.</summary>
record Outcome(int ExitCode, string? Output)
{
    public static Outcome Printing(string output) => new(0, output);

    public static Outcome OfResult(string? result) => result == null ? new(1, null) : Printing(result);
}

/// <summary>A usage error found while parsing arguments: reported on stderr, exit code 2.</summary>
class UsageException(string message) : Exception(message);

class Options
{
    public string Locale { get; set; } = "en";
    public string? AsOf { get; set; }
    public string Compactness { get; set; } = "normal";
    public string? Gender { get; set; }
    public bool WithYear { get; set; }
}
