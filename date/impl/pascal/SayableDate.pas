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

function DaysInMonth(AYear, AMonth: Integer): Integer;
begin
  case AMonth of
    2: begin
      if ((AYear mod 4 = 0) and (AYear mod 100 <> 0)) or (AYear mod 400 = 0) then
        Result := 29
      else
        Result := 28;
    end;
    4, 6, 9, 11: Result := 30;
  else
    Result := 31;
  end;
end;

function IsDigitsAt(const S: string; AFirst, ACount: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := AFirst to AFirst + ACount - 1 do
    if not (S[I] in ['0'..'9']) then exit;
  Result := True;
end;

function DigitsValue(const S: string; AFirst, ACount: Integer): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := AFirst to AFirst + ACount - 1 do
    Result := Result * 10 + Ord(S[I]) - Ord('0');
end;

{ YYYY-MM-DD naming a real calendar day, optionally followed by T and a
  time (only the date part is read). }
function ParseDateParts(const ADate: string; out AYear, AMonth, ADay: Integer): Boolean;
begin
  Result := False;
  AYear := 0; AMonth := 0; ADay := 0;
  if (Length(ADate) < 10) or ((Length(ADate) > 10) and (ADate[11] <> 'T')) then exit;
  if (ADate[5] <> '-') or (ADate[8] <> '-') then exit;
  if not (IsDigitsAt(ADate, 1, 4) and IsDigitsAt(ADate, 6, 2) and IsDigitsAt(ADate, 9, 2)) then exit;
  AYear := DigitsValue(ADate, 1, 4);
  AMonth := DigitsValue(ADate, 6, 2);
  ADay := DigitsValue(ADate, 9, 2);
  Result := (AMonth >= 1) and (AMonth <= 12) and (ADay >= 1) and (ADay <= DaysInMonth(AYear, AMonth));
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
