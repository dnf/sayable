{$mode objfpc}{$H+}
{$codepage utf8}
unit SayableTime;

interface

uses SayableTimeTypes, SayableTimeLocales;

const
  SayableTimeVersion = '0.5.0';

function FormatTime(const ALocale: TTimeLocale; ACompactness: TCompactness;
  const AInput: string): string;

function GetLocale(const ACode: string): TTimeLocalePtr;

function IsNullResult(const AResult: string): Boolean;

implementation

uses SysUtils;

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

{ YYYY-MM-DD naming a real calendar day. }
function IsRealDate(const S: string): Boolean;
var
  Y, M, D: Integer;
begin
  Result := False;
  if (Length(S) <> 10) or (S[5] <> '-') or (S[8] <> '-') then exit;
  if not (IsDigitsAt(S, 1, 4) and IsDigitsAt(S, 6, 2) and IsDigitsAt(S, 9, 2)) then exit;
  Y := DigitsValue(S, 1, 4);
  M := DigitsValue(S, 6, 2);
  D := DigitsValue(S, 9, 2);
  Result := (M >= 1) and (M <= 12) and (D >= 1) and (D <= DaysInMonth(Y, M));
end;

{ Z or +HH:MM / -HH:MM (validated, never applied). }
function IsZoneSuffix(const S: string): Boolean;
begin
  Result := (S = 'Z') or ((Length(S) = 6) and (S[1] in ['+', '-']) and IsDigitsAt(S, 2, 2)
    and (S[4] = ':') and IsDigitsAt(S, 5, 2));
end;

{ H:MM or HH:MM, then optional :SS with optional .fraction, then an
  optional zone suffix. }
function ParseClock(const S: string; out AHour, AMinute: Integer): Boolean;
var
  P, HourDigits, Second: Integer;
begin
  Result := False;
  AHour := 0; AMinute := 0; Second := 0;
  HourDigits := 0;
  while (HourDigits < 2) and IsDigitsAt(S, HourDigits + 1, 1) do Inc(HourDigits);
  P := HourDigits + 1;
  if (HourDigits = 0) or (P > Length(S)) or (S[P] <> ':') or not IsDigitsAt(S, P + 1, 2) then exit;
  AHour := DigitsValue(S, 1, HourDigits);
  AMinute := DigitsValue(S, P + 1, 2);
  P := P + 3;
  if (P <= Length(S)) and (S[P] = ':') and IsDigitsAt(S, P + 1, 2) then begin
    Second := DigitsValue(S, P + 1, 2);
    P := P + 3;
    if (P <= Length(S)) and (S[P] = '.') and IsDigitsAt(S, P + 1, 1) then begin
      Inc(P);
      while IsDigitsAt(S, P, 1) do Inc(P);
    end;
  end;
  if (P <= Length(S)) and not IsZoneSuffix(Copy(S, P, MaxInt)) then exit;
  Result := (AHour <= 23) and (AMinute <= 59) and (Second <= 59);
end;

{ A clock time alone, or after the T of an ISO datetime whose date part
  is a real calendar day. }
function ParseTime(const AInput: string; out AHour, AMinute: Integer): Boolean;
var
  P: Integer;
begin
  AHour := 0; AMinute := 0;
  P := Pos('T', AInput);
  if P = 0 then
    Result := ParseClock(AInput, AHour, AMinute)
  else
    Result := IsRealDate(Copy(AInput, 1, P - 1)) and ParseClock(Copy(AInput, P + 1, MaxInt), AHour, AMinute);
end;

function RoundTo5(AMinute: Integer): Integer;
begin
  Result := ((AMinute + 2) div 5) * 5;
end;

function FormatNatural(const ALocale: TTimeLocale; AHour, AMinute: Integer): string;
var
  Rounded, H, H12, NextH12: Integer;
  HName, NextHName, Pattern: string;
begin
  Rounded := RoundTo5(AMinute);
  H := AHour;
  if Rounded = 60 then begin
    Rounded := 0;
    H := (H + 1) mod 24;
  end;

  if Rounded = 0 then begin
    if H = 0 then begin
      Result := ALocale.Clock.Midnight;
      exit;
    end;
    if H = 12 then begin
      Result := ALocale.Clock.Noon;
      exit;
    end;
  end;

  H12 := H mod 12;
  NextH12 := (H + 1) mod 12;
  HName := ALocale.Clock.Hours[H12];
  NextHName := ALocale.Clock.Hours[NextH12];

  Pattern := ALocale.Clock.Patterns[Rounded];
  if Pattern = '' then
    Pattern := ALocale.Clock.Patterns[0];

  Result := StringReplace1(Pattern, '{h}', HName);
  Result := StringReplace1(Result, '{next_h}', NextHName);
end;

function FormatDigital(const ALocale: TTimeLocale; const ASC: TShortClockConfig;
  AHour, AMinute: Integer): string;
var
  Fmt, MinStr, AmPmStr: string;
  H12: Integer;
begin
  Fmt := ASC.Format;
  MinStr := IntToStr(AMinute);
  if Length(MinStr) < 2 then
    MinStr := '0' + MinStr;

  if ASC.Use24h then begin
    Result := StringReplace1(Fmt, '{h}', IntToStr(AHour));
    Result := StringReplace1(Result, '{mm}', MinStr);
  end else begin
    H12 := AHour mod 12;
    if H12 = 0 then H12 := 12;
    if ASC.HasAmPm then begin
      if AHour < 12 then
        AmPmStr := ASC.AmStr
      else
        AmPmStr := ASC.PmStr;
    end else begin
      if AHour < 12 then
        AmPmStr := 'AM'
      else
        AmPmStr := 'PM';
    end;
    Result := StringReplace1(Fmt, '{h}', IntToStr(H12));
    Result := StringReplace1(Result, '{mm}', MinStr);
    Result := StringReplace1(Result, '{ampm}', AmPmStr);
  end;
end;

function FormatTime(const ALocale: TTimeLocale; ACompactness: TCompactness;
  const AInput: string): string;
var
  Hour, Minute: Integer;
begin
  if AInput = '' then begin
    Result := NullResult;
    exit;
  end;
  if not ParseTime(AInput, Hour, Minute) then begin
    Result := NullResult;
    exit;
  end;

  if (ACompactness = csShort) and ALocale.HasShort then begin
    Result := FormatDigital(ALocale, ALocale.ShortOverride.Clock, Hour, Minute);
    exit;
  end;
  if (ACompactness = csCompact) and ALocale.HasCompact then begin
    Result := FormatDigital(ALocale, ALocale.CompactOverride.Clock, Hour, Minute);
    exit;
  end;

  Result := FormatNatural(ALocale, Hour, Minute);
end;

function GetLocale(const ACode: string): TTimeLocalePtr;
begin
  Result := GetLocaleByCode(ACode);
end;

end.
