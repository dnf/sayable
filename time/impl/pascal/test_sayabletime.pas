{$mode objfpc}{$H+}
{$codepage utf8}
program test_sayabletime;

uses SysUtils, SayableTimeTypes, SayableTime, SayableTimeLocales;

var
  PassCount: Integer = 0;
  FailCount: Integer = 0;

procedure AssertEqual(const ATestID, AExpected, AActual: string);
begin
  if AExpected = AActual then
    Inc(PassCount)
  else begin
    WriteLn('FAIL ', ATestID, ': expected "', AExpected, '" got "', AActual, '"');
    Inc(FailCount);
  end;
end;

procedure AssertNull(const ATestID, AActual: string);
begin
  if IsNullResult(AActual) then
    Inc(PassCount)
  else begin
    WriteLn('FAIL ', ATestID, ': expected null got "', AActual, '"');
    Inc(FailCount);
  end;
end;

procedure AssertLocaleNotNil(const ATestID: string; const APtr: TTimeLocalePtr);
begin
  if APtr <> nil then
    Inc(PassCount)
  else begin
    WriteLn('FAIL ', ATestID, ': expected non-nil locale');
    Inc(FailCount);
  end;
end;

procedure AssertLocaleNil(const ATestID: string; const APtr: TTimeLocalePtr);
begin
  if APtr = nil then
    Inc(PassCount)
  else begin
    WriteLn('FAIL ', ATestID, ': expected nil locale');
    Inc(FailCount);
  end;
end;

var
  EN, DE, FR, JA, FI: TTimeLocale;
  LPtr: TTimeLocalePtr;

begin
  GetLocale_en(EN);
  GetLocale_de(DE);
  GetLocale_fr(FR);
  GetLocale_ja(JA);
  GetLocale_fi(FI);

  { Section 1: Null / edge cases }
  { 1.1 }
  AssertNull('1.1', FormatTime(EN, csNormal, ''));
  { 1.2 }
  AssertNull('1.2', FormatTime(EN, csNormal, ''));
  { 1.3 }
  AssertNull('1.3', FormatTime(EN, csNormal, 'invalid'));
  { 1.4 }
  AssertNull('1.4', FormatTime(EN, csNormal, '25:00'));

  { Section 2: Clock time (normal compactness) }
  { 2.1 }
  AssertEqual('2.1', 'midnight', FormatTime(EN, csNormal, '00:00'));
  { 2.2 }
  AssertEqual('2.2', 'noon', FormatTime(EN, csNormal, '12:00'));
  { 2.3 }
  AssertEqual('2.3', 'three o''clock', FormatTime(EN, csNormal, '15:00'));
  { 2.4 }
  AssertEqual('2.4', 'a quarter past two', FormatTime(EN, csNormal, '14:15'));
  { 2.5 }
  AssertEqual('2.5', 'half past nine', FormatTime(EN, csNormal, '09:30'));
  { 2.6 }
  AssertEqual('2.6', 'a quarter to eleven', FormatTime(EN, csNormal, '10:45'));
  { 2.7 }
  AssertEqual('2.7', 'five past eight', FormatTime(EN, csNormal, '08:05'));
  { 2.8 }
  AssertEqual('2.8', 'five to five', FormatTime(EN, csNormal, '16:55'));
  { 2.9 }
  AssertEqual('2.9', 'midnight', FormatTime(EN, csNormal, '23:58'));
  { 2.10 }
  AssertEqual('2.10', 'twenty past seven', FormatTime(EN, csNormal, '07:22'));
  { 2.11 }
  AssertEqual('2.11', 'a quarter past two', FormatTime(EN, csNormal, '2025-01-15T14:15:00'));

  { Section 3: Clock time (short compactness) }
  { 3.1 }
  AssertEqual('3.1', '2:15 PM', FormatTime(EN, csShort, '14:15'));
  { 3.2 }
  AssertEqual('3.2', '9:30 AM', FormatTime(EN, csShort, '09:30'));
  { 3.3 }
  AssertEqual('3.3', '12:00 AM', FormatTime(EN, csShort, '00:00'));
  { 3.4 }
  AssertEqual('3.4', '12:00 PM', FormatTime(EN, csShort, '12:00'));

  { Section 4: Clock time (compact) }
  { 4.1 }
  AssertEqual('4.1', '2:15p', FormatTime(EN, csCompact, '14:15'));
  { 4.2 }
  AssertEqual('4.2', '9:30a', FormatTime(EN, csCompact, '09:30'));

  { Section 5: Locale — German }
  { 5.1 }
  AssertEqual('5.1', 'halb vier', FormatTime(DE, csNormal, '15:30'));

  { Section 6: Locale — French }
  { 6.1 }
  AssertEqual('6.1', 'trois heures et quart', FormatTime(FR, csNormal, '15:15'));

  { Section 7: Locale — Japanese }
  { 7.1 }
  AssertEqual('7.1', '三時半', FormatTime(JA, csNormal, '15:30'));

  { Section 8: Locale — Finnish (dot separator, short) }
  { 8.1 }
  AssertEqual('8.1', '14.15', FormatTime(FI, csShort, '14:15'));
  { 8.2 }
  AssertEqual('8.2', '0.00', FormatTime(FI, csShort, '00:00'));

  { Locale lookup }
  LPtr := GetLocale('en');
  AssertLocaleNotNil('lookup.1', LPtr);
  LPtr := GetLocale('xx');
  AssertLocaleNil('lookup.2', LPtr);

  { Section 9: Minutes in short and compact modes }
  { 9.1 }
  AssertEqual('9.1', '6:01 PM', FormatTime(GetLocale('en')^, csShort, '18:01'));
  { 9.2 }
  AssertEqual('9.2', '7:05p', FormatTime(GetLocale('en')^, csCompact, '19:05'));

  { Section 10: Input validation }
  { 10.1 }
  AssertEqual('10.1', 'half past nine', FormatTime(GetLocale('en')^, csNormal, '9:30'));
  { 10.2 }
  AssertEqual('10.2', 'half past nine', FormatTime(GetLocale('en')^, csNormal, '09:30'));
  { 10.3 }
  AssertNull('10.3', FormatTime(GetLocale('en')^, csNormal, ' 9:30'));
  { 10.4 }
  AssertNull('10.4', FormatTime(GetLocale('en')^, csNormal, '9:30 '));
  { 10.5 }
  AssertNull('10.5', FormatTime(GetLocale('en')^, csNormal, '9:5'));
  { 10.6 }
  AssertNull('10.6', FormatTime(GetLocale('en')^, csNormal, '24:00'));
  { 10.7 }
  AssertEqual('10.7', 'a quarter past two', FormatTime(GetLocale('en')^, csNormal, '14:15:30'));
  { 10.8 }
  AssertEqual('10.8', 'a quarter past two', FormatTime(GetLocale('en')^, csNormal, '2025-01-15T14:15:00Z'));
  { 10.9 }
  AssertNull('10.9', FormatTime(GetLocale('en')^, csNormal, '2025-02-30T14:15:00'));

  { Print results }
  WriteLn('');
  WriteLn(PassCount, ' passed, ', FailCount, ' failed');
  if FailCount > 0 then
    Halt(1);
end.
