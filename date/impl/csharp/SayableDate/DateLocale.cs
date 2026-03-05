using System.Collections.Generic;

namespace SayableDateLib;

public enum Compactness
{
    Normal, Short, Compact
}

public sealed class CompactnessOverride
{
    public string[]? Months { get; }
    public string[]? MonthsInDate { get; }
    public string[]? Weekdays { get; }
    public string? DayFormat { get; }
    public IReadOnlyDictionary<string, string>? DayFormatExceptions { get; }
    public string? DatePattern { get; }
    public string? DatePatternWithYear { get; }
    public string? Today { get; }
    public string? Tomorrow { get; }
    public string? Yesterday { get; }

    public CompactnessOverride(string[]? months = null, string[]? monthsInDate = null,
                               string[]? weekdays = null, string? dayFormat = null,
                               Dictionary<string, string>? dayFormatExceptions = null,
                               string? datePattern = null, string? datePatternWithYear = null,
                               string? today = null, string? tomorrow = null,
                               string? yesterday = null)
    {
        Months = months;
        MonthsInDate = monthsInDate;
        Weekdays = weekdays;
        DayFormat = dayFormat;
        DayFormatExceptions = dayFormatExceptions;
        DatePattern = datePattern;
        DatePatternWithYear = datePatternWithYear;
        Today = today;
        Tomorrow = tomorrow;
        Yesterday = yesterday;
    }
}

public sealed class DateLocale
{
    public string Code { get; }
    public string[] Months { get; }
    public string[] Weekdays { get; }
    public string DayFormat { get; }
    public IReadOnlyDictionary<string, string> DayFormatExceptions { get; }
    public string DatePattern { get; }
    public string DatePatternWithYear { get; }
    public string Today { get; }
    public string Tomorrow { get; }
    public string Yesterday { get; }
    public string? DayAfterTomorrow { get; }
    public string? DayBeforeYesterday { get; }
    public string? ThisWeekday { get; }
    public string? NextWeekday { get; }
    public string? LastWeekday { get; }
    public string[]? MonthsInDate { get; }
    public CompactnessOverride? ShortOverride { get; }
    public CompactnessOverride? CompactOverride { get; }

    public DateLocale(string code, string[] months, string[] weekdays,
                      string dayFormat,
                      Dictionary<string, string>? dayFormatExceptions = null,
                      string datePattern = "{day} {month}",
                      string datePatternWithYear = "{day} {month} {year}",
                      string today = "today", string tomorrow = "tomorrow",
                      string yesterday = "yesterday",
                      string? dayAfterTomorrow = null,
                      string? dayBeforeYesterday = null,
                      string? thisWeekday = null,
                      string? nextWeekday = null,
                      string? lastWeekday = null,
                      string[]? monthsInDate = null,
                      CompactnessOverride? shortOverride = null,
                      CompactnessOverride? compactOverride = null)
    {
        Code = code;
        Months = months;
        Weekdays = weekdays;
        DayFormat = dayFormat;
        DayFormatExceptions = dayFormatExceptions ?? new Dictionary<string, string>();
        DatePattern = datePattern;
        DatePatternWithYear = datePatternWithYear;
        Today = today;
        Tomorrow = tomorrow;
        Yesterday = yesterday;
        DayAfterTomorrow = dayAfterTomorrow;
        DayBeforeYesterday = dayBeforeYesterday;
        ThisWeekday = thisWeekday;
        NextWeekday = nextWeekday;
        LastWeekday = lastWeekday;
        MonthsInDate = monthsInDate;
        ShortOverride = shortOverride;
        CompactOverride = compactOverride;
    }
}
