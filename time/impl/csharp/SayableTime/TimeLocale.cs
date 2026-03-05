using System.Collections.Generic;

namespace SayableTimeLib;

public enum Compactness
{
    Normal, Short, Compact
}

public sealed class ClockConfig
{
    public string[] Hours { get; }
    public string Midnight { get; }
    public string Noon { get; }
    public IReadOnlyDictionary<int, string> Patterns { get; }

    public ClockConfig(string[] hours, string midnight, string noon,
                       Dictionary<int, string> patterns)
    {
        Hours = hours;
        Midnight = midnight;
        Noon = noon;
        Patterns = patterns;
    }
}

public sealed class ShortClockConfig
{
    public bool Use24h { get; }
    public (string Am, string Pm)? AmPm { get; }
    public string Format { get; }

    public ShortClockConfig(bool use24h, (string, string)? amPm, string format)
    {
        Use24h = use24h;
        AmPm = amPm;
        Format = format;
    }
}

public sealed class CompactnessOverride
{
    public ShortClockConfig? Clock { get; }

    public CompactnessOverride(ShortClockConfig? clock = null)
    {
        Clock = clock;
    }
}

public sealed class TimeLocale
{
    public string Code { get; }
    public ClockConfig Clock { get; }
    public CompactnessOverride? ShortOverride { get; }
    public CompactnessOverride? CompactOverride { get; }

    public TimeLocale(string code, ClockConfig clock,
                      CompactnessOverride? shortOverride = null,
                      CompactnessOverride? compactOverride = null)
    {
        Code = code;
        Clock = clock;
        ShortOverride = shortOverride;
        CompactOverride = compactOverride;
    }
}
