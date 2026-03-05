using System;
using System.Collections.Generic;

namespace SayableDurationLib;

public class SayableDuration
{
    public const string Version = "0.1.0";

    private readonly DurationLocale _locale;
    private readonly UnitForms _second;
    private readonly UnitForms _minute;
    private readonly UnitForms _hour;
    private readonly UnitForms _day;
    private readonly UnitForms _week;
    private readonly UnitForms _month;
    private readonly UnitForms _year;
    private readonly string _half;
    private readonly string _delimiter;
    private readonly string _justNow;
    private readonly string _ago;
    private readonly string _inFuture;

    private static readonly SayableDuration Default =
        new(Locales.EN);

    public SayableDuration(DurationLocale locale, Compactness compactness = Compactness.Normal)
    {
        _locale = locale;

        var ovr = compactness switch
        {
            Compactness.Short => locale.ShortOverride,
            Compactness.Compact => locale.CompactOverride,
            _ => null,
        };

        _second = ovr?.Second ?? locale.Units.Second;
        _minute = ovr?.Minute ?? locale.Units.Minute;
        _hour = ovr?.Hour ?? locale.Units.Hour;
        _day = ovr?.Day ?? locale.Units.Day;
        _week = ovr?.Week ?? locale.Units.Week;
        _month = ovr?.Month ?? locale.Units.Month;
        _year = ovr?.Year ?? locale.Units.Year;
        _half = ovr?.Half ?? locale.Half;
        _delimiter = ovr?.Delimiter ?? locale.Delimiter;
        _justNow = locale.JustNow;
        _ago = ovr?.Ago ?? locale.Ago;
        _inFuture = ovr?.InFuture ?? locale.InFuture;
    }

    public static string? FormatDurationSeconds(int seconds) =>
        Default.FormatDuration(seconds);

    public static string? FormatDurationIso(string start, string end) =>
        Default.FormatIso(start, end);

    public static string? FormatSince(string? start, string? asOf) =>
        Default.Since(start, asOf);

    public static string? FormatUntil(string? target, string? asOf) =>
        Default.Until(target, asOf);

    public string? FormatDuration(int seconds)
    {
        if (seconds < 0) return null;
        return FormatDurationInternal(seconds);
    }

    public string? FormatIso(string start, string end)
    {
        if (string.IsNullOrEmpty(start) || string.IsNullOrEmpty(end)) return null;
        var s = ParseIsoToSeconds(start);
        var e = ParseIsoToSeconds(end);
        if (s == null || e == null) return null;
        var total = Math.Abs(e.Value - s.Value);
        return FormatDurationInternal(total);
    }

    public string? Since(string? start, string? asOf)
    {
        if (string.IsNullOrEmpty(start) || string.IsNullOrEmpty(asOf)) return null;
        var s = ParseIsoToSeconds(start!);
        var a = ParseIsoToSeconds(asOf!);
        if (s == null || a == null) return null;
        var diff = a.Value - s.Value;
        if (diff < 0) return null;
        if (diff == 0) return _justNow;
        var dur = FormatDurationInternal(diff);
        return _ago.Replace("{0}", dur);
    }

    public string? Until(string? target, string? asOf)
    {
        if (string.IsNullOrEmpty(target) || string.IsNullOrEmpty(asOf)) return null;
        var t = ParseIsoToSeconds(target!);
        var a = ParseIsoToSeconds(asOf!);
        if (t == null || a == null) return null;
        var diff = t.Value - a.Value;
        if (diff < 0) return null;
        if (diff == 0) return _justNow;
        var dur = FormatDurationInternal(diff);
        return _inFuture.Replace("{0}", dur);
    }

    private string FormatDurationInternal(int total)
    {
        if (total == 0) return _justNow;

        // 1-59 seconds
        if (total < 60) return ResolveUnit(total, _second);

        int totalMinutes = total / 60;
        int remainderSeconds = total % 60;

        // 1-4 minutes: minutes + seconds
        if (totalMinutes < 5)
        {
            var result = ResolveUnit(totalMinutes, _minute);
            if (remainderSeconds > 0)
                result += _delimiter + ResolveUnit(remainderSeconds, _second);
            return result;
        }

        // 5-59 minutes
        if (totalMinutes < 60) return ResolveUnit(totalMinutes, _minute);

        int totalHours = total / 3600;
        int remainderMinutes = (total % 3600) / 60;

        // 1-5 hours: hours + minutes (with half marker)
        if (totalHours <= 5)
        {
            if (remainderMinutes == 30)
                return ResolveUnit(totalHours, _hour, _half);
            var result = ResolveUnit(totalHours, _hour);
            if (remainderMinutes > 0)
                result += _delimiter + ResolveUnit(remainderMinutes, _minute);
            return result;
        }

        // 6-23 hours
        if (totalHours < 24) return ResolveUnit(totalHours, _hour);

        int totalDays = total / 86400;
        int remainderHours = (total % 86400) / 3600;

        // 1-2 days: days + hours (with half marker)
        if (totalDays <= 2)
        {
            if (remainderHours == 12)
                return ResolveUnit(totalDays, _day, _half);
            var result = ResolveUnit(totalDays, _day);
            if (remainderHours > 0)
                result += _delimiter + ResolveUnit(remainderHours, _hour);
            return result;
        }

        // 3-6 days
        if (totalDays < 7) return ResolveUnit(totalDays, _day);

        int totalWeeks = totalDays / 7;
        int remainderDays = totalDays % 7;

        // 1-4 weeks (up to 29 days; 30+ transitions to months)
        if (totalDays < 30)
        {
            var result = ResolveUnit(totalWeeks, _week);
            if (remainderDays > 0)
                result += _delimiter + ResolveUnit(remainderDays, _day);
            return result;
        }

        // Approximate months (30.44 days average)
        int totalMonths = (int)Math.Round(totalDays / 30.44);

        // 1-11 months
        if (totalMonths < 12)
        {
            if (totalMonths == 0) totalMonths = 1;
            return ResolveUnit(totalMonths, _month);
        }

        // 12+ months: years + months
        int totalYears = totalMonths / 12;
        int remainderMonths = totalMonths % 12;
        var yearResult = ResolveUnit(totalYears, _year);
        if (remainderMonths > 0)
            yearResult += _delimiter + ResolveUnit(remainderMonths, _month);
        return yearResult;
    }

    private string ResolveUnit(int count, UnitForms uf, string half = "")
    {
        string baseN = _locale.FormatNumber != null
            ? _locale.FormatNumber(count)
            : count.ToString();

        // Apply {n}-style half marker to the number
        string n = (half.Length > 0 && half.Contains("{n}"))
            ? half.Replace("{n}", baseN)
            : baseN;

        // Select template
        string template;
        if (uf.SimpleTemplate != null)
        {
            template = uf.SimpleTemplate;
        }
        else
        {
            var cat = half.Length > 0 ? PluralCategory.Other : _locale.Plural(count);
            template = uf.Forms != null && uf.Forms.TryGetValue(cat, out var t)
                ? t
                : uf.Forms != null && uf.Forms.TryGetValue(PluralCategory.Other, out var t2)
                    ? t2
                    : "{n}";
        }

        var result = template.Replace("{n}", n);

        if (_locale.FormatUnit != null)
            result = _locale.FormatUnit(count, result);

        // Apply {0}-style half marker (wraps the whole expression)
        if (half.Length > 0 && half.Contains("{0}"))
            result = half.Replace("{0}", result);

        return result;
    }

    internal static int? ParseIsoToSeconds(string iso)
    {
        if (string.IsNullOrEmpty(iso)) return null;

        int tIdx = iso.IndexOf('T');
        if (tIdx < 0) return null;

        var datePart = iso.Substring(0, tIdx);
        var timePart = iso.Substring(tIdx + 1);

        var dp = datePart.Split('-');
        if (dp.Length < 3) return null;
        var year = SafeAtoi(dp[0]);
        var month = SafeAtoi(dp[1]);
        var day = SafeAtoi(dp[2]);
        if (year == null || month == null || day == null) return null;

        int plusIdx = timePart.IndexOf('+');
        if (plusIdx >= 0) timePart = timePart.Substring(0, plusIdx);
        int zIdx = timePart.IndexOf('Z');
        if (zIdx >= 0) timePart = timePart.Substring(0, zIdx);

        var tp = timePart.Split(':');
        var hour = SafeAtoi(tp[0]);
        if (hour == null) return null;
        var minute = tp.Length > 1 ? SafeAtoi(tp[1]) : 0;
        if (minute == null) return null;
        int second;
        if (tp.Length > 2)
        {
            var secStr = tp[2].Split('.')[0];
            var s = SafeAtoi(secStr);
            if (s == null) return null;
            second = s.Value;
        }
        else
        {
            second = 0;
        }

        int days = DaysSinceEpoch(year.Value, month.Value, day.Value);
        return days * 86400 + hour.Value * 3600 + minute.Value * 60 + second;
    }

    private static int? SafeAtoi(string s)
    {
        if (string.IsNullOrEmpty(s)) return null;
        int n = 0;
        foreach (char c in s)
        {
            if (c < '0' || c > '9') return null;
            n = n * 10 + (c - '0');
        }
        return n;
    }

    private static bool IsLeapYear(int year) =>
        (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);

    private static int DaysInMonth(int year, int month) => month switch
    {
        1 or 3 or 5 or 7 or 8 or 10 or 12 => 31,
        4 or 6 or 9 or 11 => 30,
        2 => IsLeapYear(year) ? 29 : 28,
        _ => 30,
    };

    private static int DaysSinceEpoch(int year, int month, int day)
    {
        int days = 0;
        if (year >= 2000)
        {
            for (int y = 2000; y < year; y++)
                days += IsLeapYear(y) ? 366 : 365;
        }
        else
        {
            for (int y = year; y < 2000; y++)
                days -= IsLeapYear(y) ? 366 : 365;
        }
        for (int m = 1; m < month; m++)
            days += DaysInMonth(year, m);
        days += day - 1;
        return days;
    }
}
