using System;

namespace SayableAgeLib;

public sealed class SayableAgeFormatter
{
    public const string Version = "0.5.0";

    private const int MaxAgeMonths = 6000;

    private readonly AgeLocale _locale;
    private readonly UnitForms _day;
    private readonly UnitForms _week;
    private readonly UnitForms _month;
    private readonly UnitForms _year;
    private readonly string _half;
    private readonly string _delimiter;
    private readonly string _justBorn;

    internal static Func<DateTime> TimeNow = () => DateTime.Today;

    public SayableAgeFormatter(AgeLocale locale, Compactness compactness = Compactness.Normal)
    {
        _locale = locale;

        var d = locale.Units.Day;
        var w = locale.Units.Week;
        var m = locale.Units.Month;
        var y = locale.Units.Year;
        var h = locale.Half;
        var del = locale.Delimiter;
        var jb = locale.JustBorn;

        CompactnessOverride? ovr = compactness switch
        {
            Compactness.Short => locale.ShortOverride,
            Compactness.Compact => locale.CompactOverride,
            _ => null,
        };

        if (ovr != null)
        {
            if (ovr.Day != null) d = ovr.Day;
            if (ovr.Week != null) w = ovr.Week;
            if (ovr.Month != null) m = ovr.Month;
            if (ovr.Year != null) y = ovr.Year;
            if (ovr.Half != null) h = ovr.Half;
            if (ovr.Delimiter != null) del = ovr.Delimiter;
            if (ovr.JustBorn != null) jb = ovr.JustBorn;
        }

        _day = d;
        _week = w;
        _month = m;
        _year = y;
        _half = h;
        _delimiter = del;
        _justBorn = jb;
    }

    private record AgeComponents(int Months, int DiffDays);

    private static AgeComponents? ParseAge(string? dateOfBirth, string? asOf)
    {
        if (string.IsNullOrEmpty(dateOfBirth)) return null;

        var dobParts = ParseDateParts(dateOfBirth);
        if (dobParts == null) return null;
        int dobY = dobParts[0], dobM = dobParts[1], dobD = dobParts[2];

        int refY, refM, refD;
        if (!string.IsNullOrEmpty(asOf))
        {
            var refParts = ParseDateParts(asOf);
            if (refParts == null) return null;
            refY = refParts[0];
            refM = refParts[1];
            refD = refParts[2];
        }
        else
        {
            var now = TimeNow();
            refY = now.Year;
            refM = now.Month;
            refD = now.Day;
        }

        int diffDays = JulianDay(refY, refM, refD) - JulianDay(dobY, dobM, dobD);
        if (diffDays < 0) return null;

        int lastDay = DaysInMonth(refY, refM);
        int clampedBirthday = Math.Min(dobD, lastDay);
        int months = (refY - dobY) * 12 + (refM - dobM);
        if (refD < clampedBirthday) months--;
        if (months > MaxAgeMonths) return null;

        return new AgeComponents(months, diffDays);
    }

    /// <summary>Parses exactly YYYY-MM-DD naming a real calendar day; null otherwise.</summary>
    private static int[]? ParseDateParts(string s)
    {
        if (s.Length != 10 || s[4] != '-' || s[7] != '-') return null;
        int y = SafeAtoi(s, 0, 4);
        int m = SafeAtoi(s, 5, 7);
        int d = SafeAtoi(s, 8, 10);
        if (y < 0 || m < 1 || m > 12 || d < 1 || d > DaysInMonth(y, m)) return null;
        return [y, m, d];
    }

    // DateTime can't represent year 0000, which the spec accepts (proleptic Gregorian).
    private static int DaysInMonth(int year, int month) => month switch
    {
        2 => (year % 4 == 0 && year % 100 != 0) || year % 400 == 0 ? 29 : 28,
        4 or 6 or 9 or 11 => 30,
        _ => 31,
    };

    private static int JulianDay(int year, int month, int day)
    {
        int a = (14 - month) / 12;
        int y = year + 4800 - a;
        int m = month + 12 * a - 3;
        return day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045;
    }

    private static int SafeAtoi(string s, int from, int to)
    {
        int n = 0;
        for (int i = from; i < to; i++)
        {
            char c = s[i];
            if (c < '0' || c > '9') return -1;
            n = n * 10 + (c - '0');
        }
        return n;
    }

    private static string StageKey(int months) => months switch
    {
        < 2 => "newborn",
        < 12 => "infant",
        < 36 => "toddler",
        < 156 => "child",
        < 216 => "teenager",
        _ => "adult",
    };

    private string ResolveUnit(int count, UnitForms uf, string half)
    {
        string baseN;
        if (_locale.FormatNumber != null)
            baseN = _locale.FormatNumber(count);
        else
            baseN = count.ToString();

        string n;
        if (half.Length > 0 && half.Contains("{n}"))
            n = half.Replace("{n}", baseN);
        else
            n = baseN;

        string template;
        if (uf.SimpleTemplate != null)
        {
            template = uf.SimpleTemplate;
        }
        else
        {
            var cat = _locale.Plural(count);
            if (!uf.Forms!.TryGetValue(cat, out var form))
                uf.Forms!.TryGetValue(PluralCategory.Other, out form);
            template = form ?? "{n}";
        }

        string result = template.Replace("{n}", n);

        if (_locale.FormatUnit != null)
            result = _locale.FormatUnit(count, result);

        if (half.Length > 0 && half.Contains("{0}"))
            result = half.Replace("{0}", result);

        return result;
    }

    public string? FormatAge(string? dateOfBirth, string? asOf = null)
    {
        var age = ParseAge(dateOfBirth, asOf);
        if (age == null) return null;

        int months = age.Months;
        int diffDays = age.DiffDays;

        // Tier 1: 0 days
        if (diffDays == 0) return _justBorn;

        // Tier 1b: 1-6 days
        if (diffDays < 7) return ResolveUnit(diffDays, _day, "");

        // Tier 2: weeks + days until 3 calendar months
        if (months < 3)
        {
            int weeks = diffDays / 7;
            int days = diffDays % 7;
            string result = ResolveUnit(weeks, _week, "");
            if (days > 0)
                result += _delimiter + ResolveUnit(days, _day, "");
            return result;
        }

        // Tier 3: 3-23 months
        if (months < 24) return ResolveUnit(months, _month, "");

        // Tier 4: 24-35 months -> years + months
        if (months < 36)
        {
            int years = months / 12;
            int rem = months % 12;
            if (rem == 0) return ResolveUnit(years, _year, "");
            return ResolveUnit(years, _year, "") + _delimiter + ResolveUnit(rem, _month, "");
        }

        // Tier 5: 3-6 years -> years with half marker
        if (months < 84)
        {
            int years = months / 12;
            int rem = months % 12;
            if (rem >= 6)
                return ResolveUnit(years, _year, _half);
            else
                return ResolveUnit(years, _year, "");
        }

        // Tier 6: 7+ years
        {
            int years = months / 12;
            return ResolveUnit(years, _year, "");
        }
    }

    public string? FormatStage(string? dateOfBirth, string? asOf = null, string? gender = null)
    {
        var age = ParseAge(dateOfBirth, asOf);
        if (age == null) return null;

        StageLabel label = StageKey(age.Months) switch
        {
            "newborn" => _locale.Stages.Newborn,
            "infant" => _locale.Stages.Infant,
            "toddler" => _locale.Stages.Toddler,
            "child" => _locale.Stages.Child,
            "teenager" => _locale.Stages.Teenager,
            "adult" => _locale.Stages.Adult,
            _ => _locale.Stages.Adult,
        };

        return label.Resolve(gender);
    }

    // Static convenience methods using default English locale
    private static readonly SayableAgeFormatter Default = new(Locales.EN);

    public static string? FormatAgeDefault(string? dateOfBirth, string? asOf = null) =>
        Default.FormatAge(dateOfBirth, asOf);

    public static string? FormatStageDefault(string? dateOfBirth, string? asOf = null, string? gender = null) =>
        Default.FormatStage(dateOfBirth, asOf, gender);
}
