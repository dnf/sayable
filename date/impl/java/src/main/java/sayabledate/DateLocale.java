package sayabledate;

import java.util.Collections;
import java.util.List;
import java.util.Map;

public final class DateLocale {

    private final String code;
    private final List<String> months;
    private final List<String> weekdays;
    private final String dayFormat;
    private final Map<String, String> dayFormatExceptions;
    private final String datePattern;
    private final String datePatternWithYear;
    private final String today;
    private final String tomorrow;
    private final String yesterday;
    private final String dayAfterTomorrow;
    private final String dayBeforeYesterday;
    private final String thisWeekday;
    private final String nextWeekday;
    private final String lastWeekday;
    private final List<String> monthsInDate;
    private final CompactnessOverride shortOverride;
    private final CompactnessOverride compactOverride;

    @SuppressWarnings("ParameterNumber")
    public DateLocale(
        String code,
        List<String> months,
        List<String> weekdays,
        String dayFormat,
        Map<String, String> dayFormatExceptions,
        String datePattern,
        String datePatternWithYear,
        String today,
        String tomorrow,
        String yesterday,
        String dayAfterTomorrow,
        String dayBeforeYesterday,
        String thisWeekday,
        String nextWeekday,
        String lastWeekday,
        List<String> monthsInDate,
        CompactnessOverride shortOverride,
        CompactnessOverride compactOverride
    ) {
        this.code = code;
        this.months = months;
        this.weekdays = weekdays;
        this.dayFormat = dayFormat;
        this.dayFormatExceptions = dayFormatExceptions != null ? dayFormatExceptions : Collections.emptyMap();
        this.datePattern = datePattern != null ? datePattern : "{day} {month}";
        this.datePatternWithYear = datePatternWithYear != null ? datePatternWithYear : "{day} {month} {year}";
        this.today = today != null ? today : "today";
        this.tomorrow = tomorrow != null ? tomorrow : "tomorrow";
        this.yesterday = yesterday != null ? yesterday : "yesterday";
        this.dayAfterTomorrow = dayAfterTomorrow;
        this.dayBeforeYesterday = dayBeforeYesterday;
        this.thisWeekday = thisWeekday;
        this.nextWeekday = nextWeekday;
        this.lastWeekday = lastWeekday;
        this.monthsInDate = monthsInDate;
        this.shortOverride = shortOverride;
        this.compactOverride = compactOverride;
    }

    public String code() { return code; }
    public List<String> months() { return months; }
    public List<String> weekdays() { return weekdays; }
    public String dayFormat() { return dayFormat; }
    public Map<String, String> dayFormatExceptions() { return dayFormatExceptions; }
    public String datePattern() { return datePattern; }
    public String datePatternWithYear() { return datePatternWithYear; }
    public String today() { return today; }
    public String tomorrow() { return tomorrow; }
    public String yesterday() { return yesterday; }
    public String dayAfterTomorrow() { return dayAfterTomorrow; }
    public String dayBeforeYesterday() { return dayBeforeYesterday; }
    public String thisWeekday() { return thisWeekday; }
    public String nextWeekday() { return nextWeekday; }
    public String lastWeekday() { return lastWeekday; }
    public List<String> monthsInDate() { return monthsInDate; }
    public CompactnessOverride shortOverride() { return shortOverride; }
    public CompactnessOverride compactOverride() { return compactOverride; }
}
