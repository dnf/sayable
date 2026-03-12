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

function ParseTime(const AInput: string; out AHour, AMinute: Integer): Boolean;
var
  T: string;
  P, ColonPos: Integer;
  DotPos: Integer;
begin
  Result := False;
  if AInput = '' then exit;

  T := AInput;
  P := Pos('T', T);
  if P > 0 then
    T := Copy(T, P + 1, MaxInt);
  P := Pos('+', T);
  if P > 0 then
    T := Copy(T, 1, P - 1);
  P := Pos('Z', T);
  if P > 0 then
    T := Copy(T, 1, P - 1);

  ColonPos := Pos(':', T);
  if ColonPos = 0 then exit;

  try
    AHour := StrToInt(Copy(T, 1, ColonPos - 1));
    { Handle seconds part after minute }
    T := Copy(T, ColonPos + 1, MaxInt);
    P := Pos(':', T);
    if P > 0 then
      T := Copy(T, 1, P - 1);
    DotPos := Pos('.', T);
    if DotPos > 0 then
      T := Copy(T, 1, DotPos - 1);
    AMinute := StrToInt(T);
  except
    exit;
  end;

  if (AHour < 0) or (AHour > 23) or (AMinute < 0) or (AMinute > 59) then exit;
  Result := True;
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
