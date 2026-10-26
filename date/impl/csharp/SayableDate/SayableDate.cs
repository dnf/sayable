using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text.RegularExpressions;

namespace SayableDateLib;

public class SayableDate
{
    public const string Version = "0.5.0";

    private readonly DateLocale _locale;
    private readonly Compactness _compactness;
    private readonly string[] _months;
    private readonly string[]? _monthsInDate;
    private readonly string[] _weekdays;
    private readonly string _dayFormat;
    private readonly IReadOnlyDictionary<string, string> _dayFormatExceptions;
    private readonly string _datePattern;
    private readonly string _datePatternWithYear;
    private readonly string _todayStr;
    private readonly string _tomorrowStr;
    private readonly string _yesterdayStr;

    private static readonly SayableDate Default =
        new(Locales.EN);

    public SayableDate(DateLocale locale, Compactness compactness = Compactness.Normal)
    {
        _locale = locale;
        _compactness = compactness;

        var ovr = compactness switch
        {
            Compactness.Short => locale.ShortOverride,
            Compactness.Compact => locale.CompactOverride,
            _ => null,
        };

        _months = ovr?.Months ?? locale.Months;
        _monthsInDate = ovr?.MonthsInDate ?? locale.MonthsInDate;
        _weekdays = ovr?.Weekdays ?? locale.Weekdays;

        // When override provides dayFormat but not dayFormatExceptions, clear exceptions
        if (ovr?.DayFormat != null && ovr.DayFormatExceptions == null)
        {
            _dayFormat = ovr.DayFormat;
            _dayFormatExceptions = new Dictionary<string, string>();
        }
        else
        {
            _dayFormat = ovr?.DayFormat ?? locale.DayFormat;
            _dayFormatExceptions = ovr?.DayFormatExceptions ?? locale.DayFormatExceptions;
        }

        _datePattern = ovr?.DatePattern ?? locale.DatePattern;
        _datePatternWithYear = ovr?.DatePatternWithYear ?? locale.DatePatternWithYear;
        _todayStr = ovr?.Today ?? locale.Today;
        _tomorrowStr = ovr?.Tomorrow ?? locale.Tomorrow;
        _yesterdayStr = ovr?.Yesterday ?? locale.Yesterday;
    }

    public static string? FormatDate(string? date) => Default.Format(date);

    public static string? FormatRelative(string? date, string? asOf) =>
        Default.Relative(date, asOf);

    public string? Format(string? date)
    {
        if (string.IsNullOrEmpty(date)) return null;
        var parsed = ParseDate(date!);
        if (parsed == null) return null;
        return FormatAbsolute(parsed[0], parsed[1], parsed[2], false);
    }

    public string? FormatWithYear(string? date)
    {
        if (string.IsNullOrEmpty(date)) return null;
        var parsed = ParseDate(date!);
        if (parsed == null) return null;
        return FormatAbsolute(parsed[0], parsed[1], parsed[2], true);
    }

    public string? Relative(string? date, string? asOf)
    {
        if (string.IsNullOrEmpty(date) || string.IsNullOrEmpty(asOf)) return null;
        var parsedDate = ParseDate(date!);
        var parsedAsOf = ParseDate(asOf!);
        if (parsedDate == null || parsedAsOf == null) return null;

        int dy = parsedDate[0], dm = parsedDate[1], dd = parsedDate[2];
        int ay = parsedAsOf[0];

        int dateJdn = ToJdn(dy, dm, dd);
        int asofJdn = ToJdn(parsedAsOf[0], parsedAsOf[1], parsedAsOf[2]);
        int diff = dateJdn - asofJdn;

        if (diff == 0) return _todayStr;
        if (diff == 1) return _tomorrowStr;
        if (diff == -1) return _yesterdayStr;

        bool isCompact = _compactness == Compactness.Compact;

        // Day after tomorrow (optional, skipped in compact mode)
        if (diff == 2 && _locale.DayAfterTomorrow != null && !isCompact)
            return _locale.DayAfterTomorrow;

        // Day before yesterday (optional, skipped in compact mode)
        if (diff == -2 && _locale.DayBeforeYesterday != null && !isCompact)
            return _locale.DayBeforeYesterday;

        // Compact mode: skip weekday references
        if (isCompact)
            return FormatAbsolute(dy, dm, dd, dy != ay);

        // This weekday (+2 to +6)
        if (diff >= 2 && diff <= 6 && _locale.ThisWeekday != null)
        {
            int dow = Weekday(dy, dm, dd);
            string wdName = _weekdays[dow];
            return _locale.ThisWeekday.Replace("{weekday}", wdName);
        }

        // Last weekday (-6 to -2)
        if (diff >= -6 && diff <= -2 && _locale.LastWeekday != null)
        {
            int dow = Weekday(dy, dm, dd);
            string wdName = _weekdays[dow];
            return _locale.LastWeekday.Replace("{weekday}", wdName);
        }

        // Next weekday (+7 to +13)
        if (diff >= 7 && diff <= 13 && _locale.NextWeekday != null)
        {
            int dow = Weekday(dy, dm, dd);
            string wdName = _weekdays[dow];
            return _locale.NextWeekday.Replace("{weekday}", wdName);
        }

        // Calendar fallback
        return FormatAbsolute(dy, dm, dd, dy != ay);
    }

    private string FormatAbsolute(int year, int month, int day, bool includeYear)
    {
        string dayStr = day.ToString();
        string fmt = _dayFormatExceptions.TryGetValue(dayStr, out var ex) ? ex : _dayFormat;
        string formattedDay = fmt.Replace("{n}", dayStr);

        string monthName = (_monthsInDate ?? _months)[month - 1];

        string pattern = includeYear ? _datePatternWithYear : _datePattern;
        string result = pattern.Replace("{month}", monthName);
        result = result.Replace("{day}", formattedDay);
        result = result.Replace("{d}", day.ToString());
        result = result.Replace("{m}", month.ToString());
        if (includeYear)
        {
            result = result.Replace("{year}", year.ToString());
            int yy = year % 100;
            result = result.Replace("{yy}", yy.ToString().PadLeft(2, '0'));
        }

        return result;
    }

    /// <summary>YYYY-MM-DD, alone or followed by T and anything (an ISO datetime).</summary>
    private static readonly Regex DatePrefix =
        new(@"\A([0-9]{4})-([0-9]{2})-([0-9]{2})(?:T.*)?\z", RegexOptions.Singleline | RegexOptions.CultureInvariant);

    internal static int[]? ParseDate(string? s)
    {
        if (s == null) return null;
        var match = DatePrefix.Match(s);
        if (!match.Success) return null;
        int year = int.Parse(match.Groups[1].Value, CultureInfo.InvariantCulture);
        int month = int.Parse(match.Groups[2].Value, CultureInfo.InvariantCulture);
        int day = int.Parse(match.Groups[3].Value, CultureInfo.InvariantCulture);
        if (month < 1 || month > 12 || day < 1 || day > DaysInMonth(year, month)) return null;
        return new[] { year, month, day };
    }

    // DateTime can't represent year 0000, which the spec accepts (proleptic Gregorian).
    private static int DaysInMonth(int year, int month) => month switch
    {
        2 => (year % 4 == 0 && year % 100 != 0) || year % 400 == 0 ? 29 : 28,
        4 or 6 or 9 or 11 => 30,
        _ => 31,
    };

    internal static int ToJdn(int year, int month, int day)
    {
        int a = (14 - month) / 12;
        int y = year + 4800 - a;
        int m = month + 12 * a - 3;
        return day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045;
    }

    internal static int Weekday(int year, int month, int day) =>
        (ToJdn(year, month, day) + 1) % 7;
}
