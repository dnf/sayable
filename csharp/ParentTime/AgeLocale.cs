using System;
using System.Collections.Generic;

namespace ParentTimeLib;

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

public sealed class StageLabel
{
    private readonly string? _label;
    private readonly string? _m;
    private readonly string? _f;

    private StageLabel(string? label, string? m, string? f)
    {
        _label = label;
        _m = m;
        _f = f;
    }

    public static StageLabel Neutral(string label) => new(label, null, null);

    public static StageLabel Gendered(string m, string f) => new(null, m, f);

    public string Resolve(string? gender) =>
        _label ?? (gender == "f" ? _f! : _m!);
}

public sealed class Units
{
    public UnitForms Day { get; }
    public UnitForms Week { get; }
    public UnitForms Month { get; }
    public UnitForms Year { get; }

    public Units(UnitForms day, UnitForms week, UnitForms month, UnitForms year)
    {
        Day = day;
        Week = week;
        Month = month;
        Year = year;
    }
}

public sealed class Stages
{
    public StageLabel Newborn { get; }
    public StageLabel Infant { get; }
    public StageLabel Toddler { get; }
    public StageLabel Child { get; }
    public StageLabel Teenager { get; }
    public StageLabel Adult { get; }

    public Stages(StageLabel newborn, StageLabel infant, StageLabel toddler,
                  StageLabel child, StageLabel teenager, StageLabel adult)
    {
        Newborn = newborn;
        Infant = infant;
        Toddler = toddler;
        Child = child;
        Teenager = teenager;
        Adult = adult;
    }
}

public sealed class CompactnessOverride
{
    public UnitForms? Day { get; }
    public UnitForms? Week { get; }
    public UnitForms? Month { get; }
    public UnitForms? Year { get; }
    public string? Half { get; }
    public string? Delimiter { get; }
    public string? JustBorn { get; }

    public CompactnessOverride(UnitForms? day, UnitForms? week, UnitForms? month,
                               UnitForms? year, string? half, string? delimiter,
                               string? justBorn)
    {
        Day = day;
        Week = week;
        Month = month;
        Year = year;
        Half = half;
        Delimiter = delimiter;
        JustBorn = justBorn;
    }
}

public delegate PluralCategory PluralRule(int n);

public sealed class AgeLocale
{
    public string Code { get; }
    public PluralRule Plural { get; }
    public Units Units { get; }
    public string Half { get; }
    public string Delimiter { get; }
    public string JustBorn { get; }
    public Stages Stages { get; }
    public CompactnessOverride? ShortOverride { get; }
    public CompactnessOverride? CompactOverride { get; }
    public Func<int, string>? FormatNumber { get; }
    public Func<int, string, string>? FormatUnit { get; }

    public AgeLocale(string code, PluralRule plural, Units units,
                     string half, string delimiter, string justBorn,
                     Stages stages,
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
        JustBorn = justBorn;
        Stages = stages;
        ShortOverride = shortOverride;
        CompactOverride = compactOverride;
        FormatNumber = formatNumber;
        FormatUnit = formatUnit;
    }
}
