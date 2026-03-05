using System;
using System.Collections.Generic;

namespace SayableDurationLib;

public enum PluralCategory
{
    Zero, One, Two, Few, Many, Other
}

public enum Compactness
{
    Normal, Short, Compact
}

public sealed class UnitForms
{
    public string? SimpleTemplate { get; }
    public IReadOnlyDictionary<PluralCategory, string>? Forms { get; }

    private UnitForms(string? simple, IReadOnlyDictionary<PluralCategory, string>? forms)
    {
        SimpleTemplate = simple;
        Forms = forms;
    }

    public static UnitForms Simple(string template) => new(template, null);

    public static UnitForms Plural(Dictionary<PluralCategory, string> forms) => new(null, forms);
}

public sealed class Units
{
    public UnitForms Second { get; }
    public UnitForms Minute { get; }
    public UnitForms Hour { get; }
    public UnitForms Day { get; }
    public UnitForms Week { get; }
    public UnitForms Month { get; }
    public UnitForms Year { get; }

    public Units(UnitForms second, UnitForms minute, UnitForms hour,
                 UnitForms day, UnitForms week, UnitForms month, UnitForms year)
    {
        Second = second;
        Minute = minute;
        Hour = hour;
        Day = day;
        Week = week;
        Month = month;
        Year = year;
    }
}

public sealed class CompactnessOverride
{
    public UnitForms? Second { get; }
    public UnitForms? Minute { get; }
    public UnitForms? Hour { get; }
    public UnitForms? Day { get; }
    public UnitForms? Week { get; }
    public UnitForms? Month { get; }
    public UnitForms? Year { get; }
    public string? Half { get; }
    public string? Delimiter { get; }
    public string? Ago { get; }
    public string? InFuture { get; }

    public CompactnessOverride(UnitForms? second = null, UnitForms? minute = null,
                               UnitForms? hour = null, UnitForms? day = null,
                               UnitForms? week = null, UnitForms? month = null,
                               UnitForms? year = null, string? half = null,
                               string? delimiter = null, string? ago = null,
                               string? inFuture = null)
    {
        Second = second;
        Minute = minute;
        Hour = hour;
        Day = day;
        Week = week;
        Month = month;
        Year = year;
        Half = half;
        Delimiter = delimiter;
        Ago = ago;
        InFuture = inFuture;
    }
}

public delegate PluralCategory PluralRule(int n);

public sealed class DurationLocale
{
    public string Code { get; }
    public PluralRule Plural { get; }
    public Units Units { get; }
    public string Half { get; }
    public string Delimiter { get; }
    public string JustNow { get; }
    public string Ago { get; }
    public string InFuture { get; }
    public CompactnessOverride? ShortOverride { get; }
    public CompactnessOverride? CompactOverride { get; }
    public Func<int, string>? FormatNumber { get; }
    public Func<int, string, string>? FormatUnit { get; }

    public DurationLocale(string code, PluralRule plural, Units units,
                          string half, string delimiter, string justNow,
                          string ago, string inFuture,
                          CompactnessOverride? shortOverride = null,
                          CompactnessOverride? compactOverride = null,
                          Func<int, string>? formatNumber = null,
                          Func<int, string, string>? formatUnit = null)
    {
        Code = code;
        Plural = plural;
        Units = units;
        Half = half;
        Delimiter = delimiter;
        JustNow = justNow;
        Ago = ago;
        InFuture = inFuture;
        ShortOverride = shortOverride;
        CompactOverride = compactOverride;
        FormatNumber = formatNumber;
        FormatUnit = formatUnit;
    }
}
