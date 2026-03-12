{$mode objfpc}{$H+}
{$codepage utf8}
unit SayableDateTypes;

interface

type
  TCompactness = (csNormal, csShort, csCompact);

  TDateCompactnessOverride = record
    HasMonths: Boolean;
    Months: array[0..11] of string;
    HasWeekdays: Boolean;
    Weekdays: array[0..6] of string;
    HasMonthsInDate: Boolean;
    MonthsInDate: array[0..11] of string;
    HasDayFormat: Boolean;
    DayFormat: string;
    HasDayFormatExceptions: Boolean;
    DayFormatExceptions: array[0..31] of string;
    HasDatePattern: Boolean;
    DatePattern: string;
    HasDatePatternWithYear: Boolean;
    DatePatternWithYear: string;
    HasToday: Boolean;
    Today: string;
    HasTomorrow: Boolean;
    Tomorrow: string;
    HasYesterday: Boolean;
    Yesterday: string;
  end;

  TDateLocale = record
    Code: string;
    Months: array[0..11] of string;
    Weekdays: array[0..6] of string;
    DayFormat: string;
    DayFormatExceptions: array[0..31] of string;
    DatePattern: string;
    DatePatternWithYear: string;
    Today: string;
    Tomorrow: string;
    Yesterday: string;
    DayAfterTomorrow: string;
    DayBeforeYesterday: string;
    ThisWeekday: string;
    NextWeekday: string;
    LastWeekday: string;
    HasMonthsInDate: Boolean;
    MonthsInDate: array[0..11] of string;
    HasShort: Boolean;
    ShortOverride: TDateCompactnessOverride;
    HasCompact: Boolean;
    CompactOverride: TDateCompactnessOverride;
  end;

  TDateLocalePtr = ^TDateLocale;

implementation

end.
