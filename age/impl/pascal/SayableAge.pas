{$mode objfpc}{$H+}
{$codepage utf8}
unit SayableAge;

interface

uses SayableAgeTypes, SayableAgeLocales;

const
  SayableAgeVersion = '0.5.0';
  MaxAgeMonths = 6000;

function FormatAge(const ALocale: TAgeLocale; ACompactness: TCompactness;
  const ADateOfBirth: string; const AAsOf: string): string;

function FormatStage(const ALocale: TAgeLocale; const ADateOfBirth: string;
  const AAsOf: string; const AGender: string): string;

function GetLocale(const ACode: string): TAgeLocalePtr;

procedure GetLocaleByName(const ACode: string; out ALoc: TAgeLocale; out AFound: Boolean);

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
begin
  Result := False;
  if Length(ADate) < 10 then exit;
  if (ADate[5] <> '-') or (ADate[8] <> '-') then exit;
  try
    AYear := StrToInt(Copy(ADate, 1, 4));
    AMonth := StrToInt(Copy(ADate, 6, 2));
    ADay := StrToInt(Copy(ADate, 9, 2));
    Result := True;
  except
    Result := False;
  end;
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

function ResolveStage(const ALabel: TStageLabel; const AGender: string): string;
begin
  if ALabel.M = '' then
    Result := ALabel.LabelText
  else if AGender = 'f' then
    Result := ALabel.F
  else
    Result := ALabel.M;
end;

function ResolveUnit(ACount: Integer; const AUnitForms: TUnitForms;
  const ALocale: TAgeLocale; const AHalf: string): string;
var
  BaseN, N, Template, UnitResult: string;
  Cat: TPluralCategory;
begin
  BaseN := IntToStr(ACount);

  // Apply half marker with placeholder {n} to the number
  if (AHalf <> '') and (Pos('{n}', AHalf) > 0) then
    N := StringReplace1(AHalf, '{n}', BaseN)
  else
    N := BaseN;

  { Select template }
  if AUnitForms.HasSimple then
    Template := AUnitForms.Simple
  else begin
    Cat := ALocale.Plural(ACount);
    Template := AUnitForms.Forms[Ord(Cat)];
    if Template = '' then
      Template := AUnitForms.Forms[Ord(pcOther)];
  end;

  UnitResult := StringReplace1(Template, '{n}', N);

  // Apply half marker with placeholder {0} (wraps the whole expression)
  if (AHalf <> '') and (Pos('{0}', AHalf) > 0) then
    Result := StringReplace1(AHalf, '{0}', UnitResult)
  else
    Result := UnitResult;
end;

function StageKey(AMonths: Integer): string;
begin
  if AMonths < 2 then
    Result := 'newborn'
  else if AMonths < 12 then
    Result := 'infant'
  else if AMonths < 36 then
    Result := 'toddler'
  else if AMonths < 156 then
    Result := 'child'
  else if AMonths < 216 then
    Result := 'teenager'
  else
    Result := 'adult';
end;

function FormatAge(const ALocale: TAgeLocale; ACompactness: TCompactness;
  const ADateOfBirth: string; const AAsOf: string): string;
var
  DobY, DobM, DobD: Integer;
  RefY, RefM, RefD: Integer;
  DiffDays: Int64;
  Months, LastDay, ClampedBirthday: Integer;
  Weeks, Days, Years, Rem: Integer;
  DayUF, WeekUF, MonthUF, YearUF: TUnitForms;
  Half, Delim, JB: string;
  Ovr: TCompactnessOverride;
begin
  if ADateOfBirth = '' then begin
    Result := NullResult;
    exit;
  end;

  if not ParseDateParts(ADateOfBirth, DobY, DobM, DobD) then begin
    Result := NullResult;
    exit;
  end;

  if AAsOf = '' then begin
    Result := NullResult;
    exit;
  end;

  if not ParseDateParts(AAsOf, RefY, RefM, RefD) then begin
    Result := NullResult;
    exit;
  end;

  DiffDays := JulianDay(RefY, RefM, RefD) - JulianDay(DobY, DobM, DobD);
  if DiffDays < 0 then begin
    Result := NullResult;
    exit;
  end;

  LastDay := DaysInMonth(RefY, RefM);
  if DobD < LastDay then
    ClampedBirthday := DobD
  else
    ClampedBirthday := LastDay;

  Months := (RefY - DobY) * 12 + (RefM - DobM);
  if RefD < ClampedBirthday then
    Dec(Months);

  if Months > MaxAgeMonths then begin
    Result := NullResult;
    exit;
  end;

  { Resolve compactness overrides }
  DayUF := ALocale.Units.Day;
  WeekUF := ALocale.Units.Week;
  MonthUF := ALocale.Units.Month;
  YearUF := ALocale.Units.Year;
  Half := ALocale.Half;
  Delim := ALocale.Delimiter;
  JB := ALocale.JustBorn;

  if (ACompactness = csShort) and ALocale.HasShort then begin
    Ovr := ALocale.ShortOverride;
    if Ovr.HasDay then DayUF := Ovr.Day;
    if Ovr.HasWeek then WeekUF := Ovr.Week;
    if Ovr.HasMonth then MonthUF := Ovr.Month;
    if Ovr.HasYear then YearUF := Ovr.Year;
    if Ovr.HasHalf then Half := Ovr.Half;
    if Ovr.HasDelimiter then Delim := Ovr.Delimiter;
    if Ovr.HasJustBorn then JB := Ovr.JustBorn;
  end
  else if (ACompactness = csCompact) and ALocale.HasCompact then begin
    Ovr := ALocale.CompactOverride;
    if Ovr.HasDay then DayUF := Ovr.Day;
    if Ovr.HasWeek then WeekUF := Ovr.Week;
    if Ovr.HasMonth then MonthUF := Ovr.Month;
    if Ovr.HasYear then YearUF := Ovr.Year;
    if Ovr.HasHalf then Half := Ovr.Half;
    if Ovr.HasDelimiter then Delim := Ovr.Delimiter;
    if Ovr.HasJustBorn then JB := Ovr.JustBorn;
  end;

  { Tier 1: 0 days }
  if DiffDays = 0 then begin
    Result := JB;
    exit;
  end;

  { Tier 1b: 1-6 days }
  if DiffDays < 7 then begin
    Result := ResolveUnit(Integer(DiffDays), DayUF, ALocale, '');
    exit;
  end;

  { Tier 2: weeks + days until 3 calendar months }
  if Months < 3 then begin
    Weeks := Integer(DiffDays) div 7;
    Days := Integer(DiffDays) mod 7;
    Result := ResolveUnit(Weeks, WeekUF, ALocale, '');
    if Days > 0 then
      Result := Result + Delim + ResolveUnit(Days, DayUF, ALocale, '');
    exit;
  end;

  { Tier 3: 3-23 months }
  if Months < 24 then begin
    Result := ResolveUnit(Months, MonthUF, ALocale, '');
    exit;
  end;

  { Tier 4: 24-35 months -> years + months }
  if Months < 36 then begin
    Years := Months div 12;
    Rem := Months mod 12;
    if Rem = 0 then
      Result := ResolveUnit(Years, YearUF, ALocale, '')
    else
      Result := ResolveUnit(Years, YearUF, ALocale, '') + Delim
                + ResolveUnit(Rem, MonthUF, ALocale, '');
    exit;
  end;

  { Tier 5: 3-6 years -> years with half marker }
  if Months < 84 then begin
    Years := Months div 12;
    Rem := Months mod 12;
    if Rem >= 6 then
      Result := ResolveUnit(Years, YearUF, ALocale, Half)
    else
      Result := ResolveUnit(Years, YearUF, ALocale, '');
    exit;
  end;

  { Tier 6: 7+ years }
  Years := Months div 12;
  Result := ResolveUnit(Years, YearUF, ALocale, '');
end;

function FormatStage(const ALocale: TAgeLocale; const ADateOfBirth: string;
  const AAsOf: string; const AGender: string): string;
var
  DobY, DobM, DobD: Integer;
  RefY, RefM, RefD: Integer;
  DiffDays: Int64;
  Months, LastDay, ClampedBirthday: Integer;
  Key: string;
  SL: TStageLabel;
begin
  if ADateOfBirth = '' then begin
    Result := NullResult;
    exit;
  end;

  if not ParseDateParts(ADateOfBirth, DobY, DobM, DobD) then begin
    Result := NullResult;
    exit;
  end;

  if AAsOf = '' then begin
    Result := NullResult;
    exit;
  end;

  if not ParseDateParts(AAsOf, RefY, RefM, RefD) then begin
    Result := NullResult;
    exit;
  end;

  DiffDays := JulianDay(RefY, RefM, RefD) - JulianDay(DobY, DobM, DobD);
  if DiffDays < 0 then begin
    Result := NullResult;
    exit;
  end;

  LastDay := DaysInMonth(RefY, RefM);
  if DobD < LastDay then
    ClampedBirthday := DobD
  else
    ClampedBirthday := LastDay;

  Months := (RefY - DobY) * 12 + (RefM - DobM);
  if RefD < ClampedBirthday then
    Dec(Months);

  if Months > MaxAgeMonths then begin
    Result := NullResult;
    exit;
  end;

  Key := StageKey(Months);

  if Key = 'newborn' then SL := ALocale.Stages.Newborn
  else if Key = 'infant' then SL := ALocale.Stages.Infant
  else if Key = 'toddler' then SL := ALocale.Stages.Toddler
  else if Key = 'child' then SL := ALocale.Stages.Child
  else if Key = 'teenager' then SL := ALocale.Stages.Teenager
  else SL := ALocale.Stages.Adult;

  Result := ResolveStage(SL, AGender);
end;

function GetLocale(const ACode: string): TAgeLocalePtr;
begin
  Result := GetLocaleByCode(ACode);
end;

procedure GetLocaleByName(const ACode: string; out ALoc: TAgeLocale; out AFound: Boolean);
var
  P: TAgeLocalePtr;
begin
  P := GetLocaleByCode(ACode);
  if P <> nil then begin
    ALoc := P^;
    AFound := True;
  end else
    AFound := False;
end;

end.
