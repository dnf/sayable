{$mode objfpc}{$H+}
{$codepage utf8}
unit SayableDuration;

interface

uses SayableDurationTypes, SayableDurationLocales;

const
  SayableDurationVersion = '0.5.0';
  { 500 years, the same ceiling as sayable-age }
  MaxDurationMonths = 6000;

function FormatDuration(const ALocale: TDurationLocale; ACompactness: TCompactness;
  ATotalSeconds: Int64): string;

function FormatDurationISO(const ALocale: TDurationLocale; ACompactness: TCompactness;
  const AStart, AEnd: string): string;

function FormatSince(const ALocale: TDurationLocale; ACompactness: TCompactness;
  const AStart, AAsOf: string): string;

function FormatUntil(const ALocale: TDurationLocale; ACompactness: TCompactness;
  const ATarget, AAsOf: string): string;

function GetLocale(const ACode: string): TDurationLocalePtr;

function IsNullResult(const AResult: string): Boolean;

implementation

uses SysUtils, Math;

const
  NullResult = #1;

function IsNullResult(const AResult: string): Boolean;
begin
  Result := AResult = NullResult;
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

function IsLeapYear(AYear: Integer): Boolean;
begin
  Result := ((AYear mod 4 = 0) and (AYear mod 100 <> 0)) or (AYear mod 400 = 0);
end;

function DaysInMonth(AYear, AMonth: Integer): Integer;
begin
  case AMonth of
    1, 3, 5, 7, 8, 10, 12: Result := 31;
    4, 6, 9, 11: Result := 30;
    2: if IsLeapYear(AYear) then Result := 29 else Result := 28;
  else
    Result := 31;
  end;
end;

function DaysSinceEpoch(AYear, AMonth, ADay: Integer): Int64;
var
  Days: Int64;
  Y, M: Integer;
begin
  Days := 0;
  if AYear >= 2000 then begin
    for Y := 2000 to AYear - 1 do
      if IsLeapYear(Y) then Days := Days + 366 else Days := Days + 365;
  end else begin
    for Y := AYear to 1999 do
      if IsLeapYear(Y) then Days := Days - 366 else Days := Days - 365;
  end;
  for M := 1 to AMonth - 1 do
    Days := Days + DaysInMonth(AYear, M);
  Days := Days + ADay - 1;
  Result := Days;
end;

function IsDigitsAt(const S: string; AFirst, ACount: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  if (AFirst < 1) or (AFirst + ACount - 1 > Length(S)) then exit;
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

{ Z or +HH:MM / -HH:MM (validated, never applied). }
function IsZoneSuffix(const S: string): Boolean;
begin
  Result := (S = 'Z') or ((Length(S) = 6) and (S[1] in ['+', '-']) and IsDigitsAt(S, 2, 2)
    and (S[4] = ':') and IsDigitsAt(S, 5, 2));
end;

{ YYYY-MM-DDTHH:MM (one- or two-digit hour), then optional :SS with
  optional .fraction, then an optional zone suffix that is ignored. }
function ParseISOToSeconds(const AISO: string; out ASeconds: Int64): Boolean;
var
  AYear, AMonth, ADay, AHour, AMinute, ASecond: Integer;
  P, HourDigits: Integer;
begin
  Result := False;
  ASeconds := 0;
  if (Length(AISO) < 15) or (AISO[5] <> '-') or (AISO[8] <> '-') or (AISO[11] <> 'T') then exit;
  if not (IsDigitsAt(AISO, 1, 4) and IsDigitsAt(AISO, 6, 2) and IsDigitsAt(AISO, 9, 2)) then exit;
  HourDigits := 0;
  while (HourDigits < 2) and IsDigitsAt(AISO, 12 + HourDigits, 1) do Inc(HourDigits);
  P := 12 + HourDigits;
  if (HourDigits = 0) or (P > Length(AISO)) or (AISO[P] <> ':') or not IsDigitsAt(AISO, P + 1, 2) then exit;
  AYear := DigitsValue(AISO, 1, 4);
  AMonth := DigitsValue(AISO, 6, 2);
  ADay := DigitsValue(AISO, 9, 2);
  AHour := DigitsValue(AISO, 12, HourDigits);
  AMinute := DigitsValue(AISO, P + 1, 2);
  ASecond := 0;
  P := P + 3;
  if (P <= Length(AISO)) and (AISO[P] = ':') and IsDigitsAt(AISO, P + 1, 2) then begin
    ASecond := DigitsValue(AISO, P + 1, 2);
    P := P + 3;
    if (P <= Length(AISO)) and (AISO[P] = '.') and IsDigitsAt(AISO, P + 1, 1) then begin
      Inc(P);
      while IsDigitsAt(AISO, P, 1) do Inc(P);
    end;
  end;
  if (P <= Length(AISO)) and not IsZoneSuffix(Copy(AISO, P, MaxInt)) then exit;
  if (AMonth < 1) or (AMonth > 12) or (ADay < 1) or (ADay > DaysInMonth(AYear, AMonth)) then exit;
  if (AHour > 23) or (AMinute > 59) or (ASecond > 59) then exit;
  ASeconds := DaysSinceEpoch(AYear, AMonth, ADay) * 86400
    + Int64(AHour) * 3600 + Int64(AMinute) * 60 + Int64(ASecond);
  Result := True;
end;

function ResolveUnit(ACount: Integer; const AUnitForms: TUnitForms;
  const ALocale: TDurationLocale; const AHalf: string): string;
var
  BaseN, N, Template: string;
  Cat: TPluralCategory;
begin
  BaseN := IntToStr(ACount);

  if (AHalf <> '') and (Pos('{n}', AHalf) > 0) then
    N := StringReplace1(AHalf, '{n}', BaseN)
  else
    N := BaseN;

  if AUnitForms.HasSimple then
    Template := AUnitForms.Simple
  else begin
    if AHalf <> '' then
      Cat := pcOther
    else
      Cat := ALocale.Plural(ACount);
    Template := AUnitForms.Forms[Ord(Cat)];
    if Template = '' then
      Template := AUnitForms.Forms[Ord(pcOther)];
  end;

  Result := StringReplace1(Template, '{n}', N);

  if (AHalf <> '') and (Pos('{0}', AHalf) > 0) then
    Result := StringReplace1(AHalf, '{0}', Result);
end;

function FormatDurationSeconds(ATotalSeconds: Int64;
  const ALocale: TDurationLocale; ACompactness: TCompactness): string;
var
  SecUF, MinUF, HourUF, DayUF, WeekUF, MonthUF, YearUF: TUnitForms;
  Half, Delim: string;
  Ovr: TDurationCompactnessOverride;
  TotalMinutes, RemainderSeconds: Integer;
  TotalHours, RemainderMinutes: Integer;
  TotalDays, RemainderHours: Integer;
  TotalWeeks, RemainderDays: Integer;
  TotalMonths, TotalYears, RemainderMonths: Integer;
begin
  { Resolve compactness overrides }
  SecUF := ALocale.Units.Second;
  MinUF := ALocale.Units.Minute;
  HourUF := ALocale.Units.Hour;
  DayUF := ALocale.Units.Day;
  WeekUF := ALocale.Units.Week;
  MonthUF := ALocale.Units.Month;
  YearUF := ALocale.Units.Year;
  Half := ALocale.Half;
  Delim := ALocale.Delimiter;

  if (ACompactness = csShort) and ALocale.HasShort then begin
    Ovr := ALocale.ShortOverride;
    if Ovr.HasSecond then SecUF := Ovr.Second;
    if Ovr.HasMinute then MinUF := Ovr.Minute;
    if Ovr.HasHour then HourUF := Ovr.Hour;
    if Ovr.HasDay then DayUF := Ovr.Day;
    if Ovr.HasWeek then WeekUF := Ovr.Week;
    if Ovr.HasMonth then MonthUF := Ovr.Month;
    if Ovr.HasYear then YearUF := Ovr.Year;
    if Ovr.HasHalf then Half := Ovr.Half;
    if Ovr.HasDelimiter then Delim := Ovr.Delimiter;
  end else if (ACompactness = csCompact) and ALocale.HasCompact then begin
    Ovr := ALocale.CompactOverride;
    if Ovr.HasSecond then SecUF := Ovr.Second;
    if Ovr.HasMinute then MinUF := Ovr.Minute;
    if Ovr.HasHour then HourUF := Ovr.Hour;
    if Ovr.HasDay then DayUF := Ovr.Day;
    if Ovr.HasWeek then WeekUF := Ovr.Week;
    if Ovr.HasMonth then MonthUF := Ovr.Month;
    if Ovr.HasYear then YearUF := Ovr.Year;
    if Ovr.HasHalf then Half := Ovr.Half;
    if Ovr.HasDelimiter then Delim := Ovr.Delimiter;
  end;

  if Round((ATotalSeconds div 86400) / 30.44) > MaxDurationMonths then begin
    Result := NullResult;
    exit;
  end;

  { 0 seconds }
  if ATotalSeconds = 0 then begin
    Result := ALocale.JustNow;
    exit;
  end;

  { 1-59 seconds }
  if ATotalSeconds < 60 then begin
    Result := ResolveUnit(Integer(ATotalSeconds), SecUF, ALocale, '');
    exit;
  end;

  TotalMinutes := Integer(ATotalSeconds div 60);
  RemainderSeconds := Integer(ATotalSeconds mod 60);

  { 1-4 minutes: minutes + seconds }
  if TotalMinutes < 5 then begin
    Result := ResolveUnit(TotalMinutes, MinUF, ALocale, '');
    if RemainderSeconds > 0 then
      Result := Result + Delim + ResolveUnit(RemainderSeconds, SecUF, ALocale, '');
    exit;
  end;

  { 5-59 minutes }
  if TotalMinutes < 60 then begin
    Result := ResolveUnit(TotalMinutes, MinUF, ALocale, '');
    exit;
  end;

  TotalHours := Integer(ATotalSeconds div 3600);
  RemainderMinutes := Integer((ATotalSeconds mod 3600) div 60);

  { 1-5 hours: hours + minutes (with half marker) }
  if TotalHours <= 5 then begin
    if RemainderMinutes = 30 then begin
      Result := ResolveUnit(TotalHours, HourUF, ALocale, Half);
      exit;
    end;
    Result := ResolveUnit(TotalHours, HourUF, ALocale, '');
    if RemainderMinutes > 0 then
      Result := Result + Delim + ResolveUnit(RemainderMinutes, MinUF, ALocale, '');
    exit;
  end;

  { 6-23 hours }
  if TotalHours < 24 then begin
    Result := ResolveUnit(TotalHours, HourUF, ALocale, '');
    exit;
  end;

  TotalDays := Integer(ATotalSeconds div 86400);
  RemainderHours := Integer((ATotalSeconds mod 86400) div 3600);

  { 1-2 days: days + hours (with half marker) }
  if TotalDays <= 2 then begin
    if RemainderHours = 12 then begin
      Result := ResolveUnit(TotalDays, DayUF, ALocale, Half);
      exit;
    end;
    Result := ResolveUnit(TotalDays, DayUF, ALocale, '');
    if RemainderHours > 0 then
      Result := Result + Delim + ResolveUnit(RemainderHours, HourUF, ALocale, '');
    exit;
  end;

  { 3-6 days }
  if TotalDays < 7 then begin
    Result := ResolveUnit(TotalDays, DayUF, ALocale, '');
    exit;
  end;

  TotalWeeks := TotalDays div 7;
  RemainderDays := TotalDays mod 7;

  { 1-4 weeks: weeks + days }
  if TotalDays < 30 then begin
    Result := ResolveUnit(TotalWeeks, WeekUF, ALocale, '');
    if RemainderDays > 0 then
      Result := Result + Delim + ResolveUnit(RemainderDays, DayUF, ALocale, '');
    exit;
  end;

  { Approximate months }
  TotalMonths := Round(TotalDays / 30.44);

  { 1-11 months }
  if TotalMonths < 12 then begin
    if TotalMonths = 0 then
      TotalMonths := 1;
    Result := ResolveUnit(TotalMonths, MonthUF, ALocale, '');
    exit;
  end;

  { 12+ months: years + months }
  TotalYears := TotalMonths div 12;
  RemainderMonths := TotalMonths mod 12;
  Result := ResolveUnit(TotalYears, YearUF, ALocale, '');
  if RemainderMonths > 0 then
    Result := Result + Delim + ResolveUnit(RemainderMonths, MonthUF, ALocale, '');
end;

function FormatDuration(const ALocale: TDurationLocale; ACompactness: TCompactness;
  ATotalSeconds: Int64): string;
begin
  if ATotalSeconds < 0 then begin
    Result := NullResult;
    exit;
  end;
  Result := FormatDurationSeconds(ATotalSeconds, ALocale, ACompactness);
end;

function FormatDurationISO(const ALocale: TDurationLocale; ACompactness: TCompactness;
  const AStart, AEnd: string): string;
var
  S, E, Total: Int64;
begin
  if (AStart = '') or (AEnd = '') then begin
    Result := NullResult;
    exit;
  end;
  if not (ParseISOToSeconds(AStart, S) and ParseISOToSeconds(AEnd, E)) then begin
    Result := NullResult;
    exit;
  end;
  Total := Abs(E - S);
  Result := FormatDurationSeconds(Total, ALocale, ACompactness);
end;

function FormatSince(const ALocale: TDurationLocale; ACompactness: TCompactness;
  const AStart, AAsOf: string): string;
var
  S, A, Diff: Int64;
  Dur, Ago: string;
begin
  if (AStart = '') or (AAsOf = '') then begin
    Result := NullResult;
    exit;
  end;
  if not (ParseISOToSeconds(AStart, S) and ParseISOToSeconds(AAsOf, A)) then begin
    Result := NullResult;
    exit;
  end;
  Diff := A - S;
  if Diff < 0 then begin
    Result := NullResult;
    exit;
  end;
  if Diff = 0 then begin
    Result := ALocale.JustNow;
    exit;
  end;
  Dur := FormatDurationSeconds(Diff, ALocale, ACompactness);
  if IsNullResult(Dur) then begin
    Result := NullResult;
    exit;
  end;

  Ago := ALocale.Ago;
  if (ACompactness = csShort) and ALocale.HasShort and ALocale.ShortOverride.HasAgo then
    Ago := ALocale.ShortOverride.Ago
  else if (ACompactness = csCompact) and ALocale.HasCompact and ALocale.CompactOverride.HasAgo then
    Ago := ALocale.CompactOverride.Ago;

  Result := StringReplace1(Ago, '{0}', Dur);
end;

function FormatUntil(const ALocale: TDurationLocale; ACompactness: TCompactness;
  const ATarget, AAsOf: string): string;
var
  T, A, Diff: Int64;
  Dur, InFut: string;
begin
  if (ATarget = '') or (AAsOf = '') then begin
    Result := NullResult;
    exit;
  end;
  if not (ParseISOToSeconds(ATarget, T) and ParseISOToSeconds(AAsOf, A)) then begin
    Result := NullResult;
    exit;
  end;
  Diff := T - A;
  if Diff < 0 then begin
    Result := NullResult;
    exit;
  end;
  if Diff = 0 then begin
    Result := ALocale.JustNow;
    exit;
  end;
  Dur := FormatDurationSeconds(Diff, ALocale, ACompactness);
  if IsNullResult(Dur) then begin
    Result := NullResult;
    exit;
  end;

  InFut := ALocale.InFuture;
  if (ACompactness = csShort) and ALocale.HasShort and ALocale.ShortOverride.HasInFuture then
    InFut := ALocale.ShortOverride.InFuture
  else if (ACompactness = csCompact) and ALocale.HasCompact and ALocale.CompactOverride.HasInFuture then
    InFut := ALocale.CompactOverride.InFuture;

  Result := StringReplace1(InFut, '{0}', Dur);
end;

function GetLocale(const ACode: string): TDurationLocalePtr;
begin
  Result := GetLocaleByCode(ACode);
end;

end.
