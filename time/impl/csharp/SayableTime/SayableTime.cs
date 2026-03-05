using System;

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

    internal static (int Hour, int Minute)? ParseTime(string input)
    {
        if (string.IsNullOrEmpty(input)) return null;
        var t = input;
        int tIdx = t.IndexOf('T');
        if (tIdx >= 0) t = t.Substring(tIdx + 1);
        int plusIdx = t.IndexOf('+');
        if (plusIdx >= 0) t = t.Substring(0, plusIdx);
        int zIdx = t.IndexOf('Z');
        if (zIdx >= 0) t = t.Substring(0, zIdx);
        var parts = t.Split(':');
        if (parts.Length < 2) return null;
        if (!int.TryParse(parts[0], out int hour)) return null;
        if (!int.TryParse(parts[1], out int minute)) return null;
        if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
        return (hour, minute);
    }

    internal static int RoundTo5(int minute) => (minute + 2) / 5 * 5;
}
