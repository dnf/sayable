using System;
using System.Globalization;
using System.Text.RegularExpressions;

namespace SayableTimeLib;

public class SayableTime
{
    public const string Version = "0.5.0";

    private readonly TimeLocale _locale;
    private readonly ShortClockConfig? _shortClock;

    private static readonly SayableTime Default =
        new(Locales.EN);

    public SayableTime(TimeLocale locale, Compactness compactness = Compactness.Normal)
    {
        _locale = locale;
        var ovr = compactness switch
        {
            Compactness.Short => locale.ShortOverride,
            Compactness.Compact => locale.CompactOverride,
            _ => null,
        };
        _shortClock = ovr?.Clock;
    }

    public static string? FormatTime(string? input) => Default.Format(input);

    public string? Format(string? input)
    {
        if (string.IsNullOrEmpty(input)) return null;
        var parsed = ParseTime(input!);
        if (parsed == null) return null;

        if (_shortClock != null)
            return FormatDigital(parsed.Value.Hour, parsed.Value.Minute);
        return FormatNatural(parsed.Value.Hour, parsed.Value.Minute);
    }

    private string FormatNatural(int hour, int minute)
    {
        var clock = _locale.Clock;
        int rounded = RoundTo5(minute);
        int h = hour;
        if (rounded == 60)
        {
            rounded = 0;
            h = (h + 1) % 24;
        }
        if (rounded == 0)
        {
            if (h == 0) return clock.Midnight;
            if (h == 12) return clock.Noon;
        }
        int h12 = h % 12;
        int nextH12 = (h + 1) % 12;
        string hName = clock.Hours[h12];
        string nextHName = clock.Hours[nextH12];
        string pattern = clock.Patterns.TryGetValue(rounded, out var p) ? p
            : clock.Patterns.TryGetValue(0, out var p0) ? p0
            : "{h}";
        return pattern.Replace("{h}", hName).Replace("{next_h}", nextHName);
    }

    private string FormatDigital(int hour, int minute)
    {
        var sc = _shortClock!;
        var fmt = sc.Format;
        if (sc.Use24h)
        {
            return fmt
                .Replace("{h}", hour.ToString())
                .Replace("{mm}", minute.ToString().PadLeft(2, '0'));
        }
        int h12 = hour % 12;
        if (h12 == 0) h12 = 12;
        var amPm = sc.AmPm ?? ("AM", "PM");
        string ampmStr = hour < 12 ? amPm.Am : amPm.Pm;
        return fmt
            .Replace("{h}", h12.ToString())
            .Replace("{mm}", minute.ToString().PadLeft(2, '0'))
            .Replace("{ampm}", ampmStr);
    }

    /// <summary>H:MM or HH:MM, optional :SS and fraction, optional zone suffix (ignored).</summary>
    private static readonly Regex Clock = new(
        @"\A([0-9]{1,2}):([0-9]{2})(?::([0-9]{2})(?:\.[0-9]+)?)?(?:Z|[+-][0-9]{2}:[0-9]{2})?\z",
        RegexOptions.CultureInvariant);

    private static readonly Regex DateOnly =
        new(@"\A([0-9]{4})-([0-9]{2})-([0-9]{2})\z", RegexOptions.CultureInvariant);

    internal static (int Hour, int Minute)? ParseTime(string input)
    {
        if (string.IsNullOrEmpty(input)) return null;
        var clock = input;
        int tIdx = input.IndexOf('T');
        if (tIdx >= 0)
        {
            if (!IsRealDate(input.Substring(0, tIdx))) return null;
            clock = input.Substring(tIdx + 1);
        }
        var match = Clock.Match(clock);
        if (!match.Success) return null;
        int hour = ParseDigits(match.Groups[1].Value);
        int minute = ParseDigits(match.Groups[2].Value);
        int second = match.Groups[3].Success ? ParseDigits(match.Groups[3].Value) : 0;
        if (hour > 23 || minute > 59 || second > 59) return null;
        return (hour, minute);
    }

    private static bool IsRealDate(string s)
    {
        var match = DateOnly.Match(s);
        if (!match.Success) return false;
        int year = ParseDigits(match.Groups[1].Value);
        int month = ParseDigits(match.Groups[2].Value);
        int day = ParseDigits(match.Groups[3].Value);
        return month >= 1 && month <= 12 && day >= 1 && day <= DaysInMonth(year, month);
    }

    // DateTime can't represent year 0000, which the spec accepts (proleptic Gregorian).
    private static int DaysInMonth(int year, int month) => month switch
    {
        2 => (year % 4 == 0 && year % 100 != 0) || year % 400 == 0 ? 29 : 28,
        4 or 6 or 9 or 11 => 30,
        _ => 31,
    };

    private static int ParseDigits(string digits) => int.Parse(digits, CultureInfo.InvariantCulture);

    internal static int RoundTo5(int minute) => (minute + 2) / 5 * 5;
}
