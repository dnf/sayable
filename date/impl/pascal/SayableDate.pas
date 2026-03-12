{$mode objfpc}{$H+}
{$codepage utf8}
unit SayableDate;

interface

uses SayableDateTypes, SayableDateLocales;

const
  SayableDateVersion = '0.5.0';

function FormatDate(const ALocale: TDateLocale; ACompactness: TCompactness;
  const ADate: string): string;

function FormatDateWithYear(const ALocale: TDateLocale; ACompactness: TCompactness;
  const ADate: string): string;

function FormatRelative(const ALocale: TDateLocale; ACompactness: TCompactness;
  const ADate: string; const AAsOf: string): string;

function GetLocale(const ACode: string): TDateLocalePtr;

function IsNullResult(const AResult: string): Boolean;

implementation

uses SysUtils;

const
  NullResult = #1;

function IsNullResult(const AResult: string): Boolean;
begin
  Result := AResult = NullResult;
end;

function ParseDateParts(const ADate: string; out AYear, AMonth, ADay: Integer): Boolean;
var
  DatePart: string;
  P: Integer;
begin
  Result := False;
  if Length(ADate) = 0 then exit;

  DatePart := ADate;
  P := Pos('T', DatePart);
  if P > 0 then
    DatePart := Copy(DatePart, 1, P - 1);

  if Length(DatePart) < 10 then exit;
  if (DatePart[5] <> '-') or (DatePart[8] <> '-') then exit;
  try
    AYear := StrToInt(Copy(DatePart, 1, 4));
    AMonth := StrToInt(Copy(DatePart, 6, 2));
    ADay := StrToInt(Copy(DatePart, 9, 2));
    if (AMonth < 1) or (AMonth > 12) or (ADay < 1) or (ADay > 31) then exit;
    Result := True;
  except
    Result := False;
  end;
end;

function JulianDay(AYear, AMonth, ADay: Integer): Int64;
var
  A, Y, M: Integer;
begin
  A := (14 - AMonth) div 12;
  Y := AYear + 4800 - A;
  M := AMonth + 12 * A - 3;
  Result := ADay + (153 * M + 2) div 5 + 365 * Int64(Y) + Int64(Y) div 4
            - Int64(Y) div 100 + Int64(Y) div 400 - 32045;
end;

function Weekday(AYear, AMonth, ADay: Integer): Integer;
begin
  Result := (JulianDay(AYear, AMonth, ADay) + 1) mod 7;
end;

function StringReplace1(const ASource, ASearch, AReplace: string): string;
var
  P: Integer;
begin
  P := Pos(ASearch, ASource);
  if P = 0 then
    Result := ASource
  else
    Result := Copy(ASource, 1, P - 1) + AReplace + Copy(ASource, P + Length(ASearch), MaxInt);
end;

function PickStr(AHasOverride: Boolean; const AOverride, ADefault: string): string;
begin
  if AHasOverride then
    Result := AOverride
  else
    Result := ADefault;
end;

function FormatAbsolute(const ALocale: TDateLocale; ACompactness: TCompactness;
  AYear, AMonth, ADay: Integer; AIncludeYear: Boolean): string;
var
  DayStr, Fmt, FormattedDay, MonthName, Pattern: string;
  Ovr: TDateCompactnessOverride;
  UseOverride: Boolean;
  DayFormat: string;
  DatePat, DatePatYear: string;
  I: Integer;
  HasDFExc: Boolean;
begin
  UseOverride := False;
  if (ACompactness = csShort) and ALocale.HasShort then begin
    Ovr := ALocale.ShortOverride;
    UseOverride := True;
  end else if (ACompactness = csCompact) and ALocale.HasCompact then begin
    Ovr := ALocale.CompactOverride;
    UseOverride := True;
  end;

  DayStr := IntToStr(ADay);

  { Resolve day format }
  if UseOverride and Ovr.HasDayFormat then
    DayFormat := Ovr.DayFormat
  else
    DayFormat := ALocale.DayFormat;

  { Resolve day format exceptions }
  HasDFExc := False;
  if UseOverride and Ovr.HasDayFormatExceptions then begin
    if Ovr.DayFormatExceptions[ADay] <> '' then begin
      Fmt := Ovr.DayFormatExceptions[ADay];
      HasDFExc := True;
    end;
  end;
  if not HasDFExc then begin
    if ALocale.DayFormatExceptions[ADay] <> '' then begin
      if not (UseOverride and Ovr.HasDayFormat and not Ovr.HasDayFormatExceptions) then begin
        Fmt := ALocale.DayFormatExceptions[ADay];
        HasDFExc := True;
      end;
    end;
  end;
  if not HasDFExc then
    Fmt := DayFormat;

  FormattedDay := StringReplace1(Fmt, '{n}', DayStr);

  { Resolve month name }
  if UseOverride and Ovr.HasMonthsInDate then
    MonthName := Ovr.MonthsInDate[AMonth - 1]
  else if ALocale.HasMonthsInDate then
    MonthName := ALocale.MonthsInDate[AMonth - 1]
  else if UseOverride and Ovr.HasMonths then
    MonthName := Ovr.Months[AMonth - 1]
  else
    MonthName := ALocale.Months[AMonth - 1];

  { Resolve pattern }
  if UseOverride and Ovr.HasDatePatternWithYear and AIncludeYear then
    DatePatYear := Ovr.DatePatternWithYear
  else
    DatePatYear := ALocale.DatePatternWithYear;

  if UseOverride and Ovr.HasDatePattern and not AIncludeYear then
    DatePat := Ovr.DatePattern
  else
    DatePat := ALocale.DatePattern;

  if AIncludeYear then
    Pattern := DatePatYear
  else
    Pattern := DatePat;

  Result := StringReplace1(Pattern, '{month}', MonthName);
  Result := StringReplace1(Result, '{day}', FormattedDay);
  Result := StringReplace1(Result, '{d}', IntToStr(ADay));
  Result := StringReplace1(Result, '{m}', IntToStr(AMonth));
  if AIncludeYear then begin
    Result := StringReplace1(Result, '{year}', IntToStr(AYear));
    I := AYear mod 100;
    if I < 10 then
      Result := StringReplace1(Result, '{yy}', '0' + IntToStr(I))
    else
      Result := StringReplace1(Result, '{yy}', IntToStr(I));
  end;
end;

function FormatDate(const ALocale: TDateLocale; ACompactness: TCompactness;
  const ADate: string): string;
var
  Y, M, D: Integer;
begin
  if ADate = '' then begin
    Result := NullResult;
    exit;
  end;
  if not ParseDateParts(ADate, Y, M, D) then begin
    Result := NullResult;
    exit;
  end;
  Result := FormatAbsolute(ALocale, ACompactness, Y, M, D, False);
end;

function FormatDateWithYear(const ALocale: TDateLocale; ACompactness: TCompactness;
  const ADate: string): string;
var
  Y, M, D: Integer;
begin
  if ADate = '' then begin
    Result := NullResult;
    exit;
  end;
  if not ParseDateParts(ADate, Y, M, D) then begin
    Result := NullResult;
    exit;
  end;
  Result := FormatAbsolute(ALocale, ACompactness, Y, M, D, True);
end;

function FormatRelative(const ALocale: TDateLocale; ACompactness: TCompactness;
  const ADate: string; const AAsOf: string): string;
var
  DY, DM, DD: Integer;
  AY, AM, AD: Integer;
  DateJdn, AsOfJdn, Diff: Int64;
  DOW: Integer;
  WeekdayName: string;
  IncludeYear: Boolean;
  TodayStr, TomorrowStr, YesterdayStr: string;
  Ovr: TDateCompactnessOverride;
  UseOverride, IsCompact: Boolean;
begin
  if (ADate = '') or (AAsOf = '') then begin
    Result := NullResult;
    exit;
  end;
  if not ParseDateParts(ADate, DY, DM, DD) then begin
    Result := NullResult;
    exit;
  end;
  if not ParseDateParts(AAsOf, AY, AM, AD) then begin
    Result := NullResult;
    exit;
  end;

  DateJdn := JulianDay(DY, DM, DD);
  AsOfJdn := JulianDay(AY, AM, AD);
  Diff := DateJdn - AsOfJdn;

  IsCompact := ACompactness = csCompact;

  { Resolve today/tomorrow/yesterday }
  UseOverride := False;
  if (ACompactness = csShort) and ALocale.HasShort then begin
    Ovr := ALocale.ShortOverride;
    UseOverride := True;
  end else if (ACompactness = csCompact) and ALocale.HasCompact then begin
    Ovr := ALocale.CompactOverride;
    UseOverride := True;
  end;

  TodayStr := PickStr(UseOverride and Ovr.HasToday, Ovr.Today, ALocale.Today);
  TomorrowStr := PickStr(UseOverride and Ovr.HasTomorrow, Ovr.Tomorrow, ALocale.Tomorrow);
  YesterdayStr := PickStr(UseOverride and Ovr.HasYesterday, Ovr.Yesterday, ALocale.Yesterday);

  { Today }
  if Diff = 0 then begin
    Result := TodayStr;
    exit;
  end;

  { Tomorrow }
  if Diff = 1 then begin
    Result := TomorrowStr;
    exit;
  end;

  { Yesterday }
  if Diff = -1 then begin
    Result := YesterdayStr;
    exit;
  end;

  { Day after tomorrow }
  if (Diff = 2) and (ALocale.DayAfterTomorrow <> '') and (not IsCompact) then begin
    Result := ALocale.DayAfterTomorrow;
    exit;
  end;

  { Day before yesterday }
  if (Diff = -2) and (ALocale.DayBeforeYesterday <> '') and (not IsCompact) then begin
    Result := ALocale.DayBeforeYesterday;
    exit;
  end;

  { Compact skips weekday references }
  if IsCompact then begin
    IncludeYear := DY <> AY;
    Result := FormatAbsolute(ALocale, ACompactness, DY, DM, DD, IncludeYear);
    exit;
  end;

  { This weekday (+2 to +6) }
  if (Diff >= 2) and (Diff <= 6) and (ALocale.ThisWeekday <> '') then begin
    DOW := Weekday(DY, DM, DD);
    if UseOverride and Ovr.HasWeekdays then
      WeekdayName := Ovr.Weekdays[DOW]
    else
      WeekdayName := ALocale.Weekdays[DOW];
    Result := StringReplace1(ALocale.ThisWeekday, '{weekday}', WeekdayName);
    exit;
  end;

  { Last weekday (-2 to -6) }
  if (Diff >= -6) and (Diff <= -2) and (ALocale.LastWeekday <> '') then begin
    DOW := Weekday(DY, DM, DD);
    if UseOverride and Ovr.HasWeekdays then
      WeekdayName := Ovr.Weekdays[DOW]
    else
      WeekdayName := ALocale.Weekdays[DOW];
    Result := StringReplace1(ALocale.LastWeekday, '{weekday}', WeekdayName);
    exit;
  end;

  { Next weekday (+7 to +13) }
  if (Diff >= 7) and (Diff <= 13) and (ALocale.NextWeekday <> '') then begin
    DOW := Weekday(DY, DM, DD);
    if UseOverride and Ovr.HasWeekdays then
      WeekdayName := Ovr.Weekdays[DOW]
    else
      WeekdayName := ALocale.Weekdays[DOW];
    Result := StringReplace1(ALocale.NextWeekday, '{weekday}', WeekdayName);
    exit;
  end;

  { Calendar fallback }
  IncludeYear := DY <> AY;
  Result := FormatAbsolute(ALocale, ACompactness, DY, DM, DD, IncludeYear);
end;

function GetLocale(const ACode: string): TDateLocalePtr;
begin
  Result := GetLocaleByCode(ACode);
end;

end.
