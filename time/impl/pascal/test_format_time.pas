{$mode objfpc}{$H+}
{$codepage utf8}
program test_format_time;

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
  if IsTimeNullResult(AActual) then
    Inc(PassCount)
  else begin
    WriteLn('FAIL ', ATestID, ': expected null got "', AActual, '"');
    Inc(FailCount);
  end;
end;

var
  EN, DE, FR, JA, FI: TTimeLocale;

begin
  GetTimeLocale_en(EN);
  GetTimeLocale_de(DE);
  GetTimeLocale_fr(FR);
  GetTimeLocale_ja(JA);
  GetTimeLocale_fi(FI);

  { Section 1: Null / edge cases }
  { 1.1 }
  AssertNull('1.1', FormatTime(EN, tcNormal, ''));
  { 1.2 }
  AssertNull('1.2', FormatTime(EN, tcNormal, ''));
  { 1.3 }
  AssertNull('1.3', FormatTime(EN, tcNormal, 'invalid'));
  { 1.4 }
  AssertNull('1.4', FormatTime(EN, tcNormal, '25:00'));

  { Section 2: Clock time (normal compactness) }
  { 2.1 }
  AssertEqual('2.1', 'midnight', FormatTime(EN, tcNormal, '00:00'));
  { 2.2 }
  AssertEqual('2.2', 'noon', FormatTime(EN, tcNormal, '12:00'));
  { 2.3 }
  AssertEqual('2.3', 'three o''clock', FormatTime(EN, tcNormal, '15:00'));
  { 2.4 }
  AssertEqual('2.4', 'a quarter past two', FormatTime(EN, tcNormal, '14:15'));
  { 2.5 }
  AssertEqual('2.5', 'half past nine', FormatTime(EN, tcNormal, '09:30'));
  { 2.6 }
  AssertEqual('2.6', 'a quarter to eleven', FormatTime(EN, tcNormal, '10:45'));
  { 2.7 }
  AssertEqual('2.7', 'five past eight', FormatTime(EN, tcNormal, '08:05'));
  { 2.8 }
  AssertEqual('2.8', 'five to five', FormatTime(EN, tcNormal, '16:55'));
  { 2.9 }
  AssertEqual('2.9', 'midnight', FormatTime(EN, tcNormal, '23:58'));
  { 2.10 }
  AssertEqual('2.10', 'twenty past seven', FormatTime(EN, tcNormal, '07:22'));
  { 2.11 - ISO datetime input }
  AssertEqual('2.11', 'a quarter past two', FormatTime(EN, tcNormal, '2025-01-15T14:15:00'));

  { Section 3: Clock time (short compactness) }
  { 3.1 }
  AssertEqual('3.1', '2:15 PM', FormatTime(EN, tcShort, '14:15'));
  { 3.2 }
  AssertEqual('3.2', '9:30 AM', FormatTime(EN, tcShort, '09:30'));
  { 3.3 }
  AssertEqual('3.3', '12:00 AM', FormatTime(EN, tcShort, '00:00'));
  { 3.4 }
  AssertEqual('3.4', '12:00 PM', FormatTime(EN, tcShort, '12:00'));

  { Section 4: Clock time (compact) }
  { 4.1 }
  AssertEqual('4.1', '2:15p', FormatTime(EN, tcCompact, '14:15'));
  { 4.2 }
  AssertEqual('4.2', '9:30a', FormatTime(EN, tcCompact, '09:30'));

  { Section 5: Locale — German }
  { 5.1 }
  AssertEqual('5.1', 'halb vier', FormatTime(DE, tcNormal, '15:30'));

  { Section 6: Locale — French }
  { 6.1 }
  AssertEqual('6.1', 'trois heures et quart', FormatTime(FR, tcNormal, '15:15'));
  { 6.2 }
  AssertEqual('6.2', 'une heure', FormatTime(FR, tcNormal, '13:00'));
  { 6.3 }
  AssertEqual('6.3', 'une heure et demie', FormatTime(FR, tcNormal, '13:30'));
  { 6.4 }
  AssertEqual('6.4', 'trois heures moins le quart', FormatTime(FR, tcNormal, '14:45'));
  { 6.5 }
  AssertEqual('6.5', 'trois heures moins dix', FormatTime(FR, tcNormal, '14:50'));

  { Section 7: Locale — Japanese }
  { 7.1 }
  AssertEqual('7.1', '三時半', FormatTime(JA, tcNormal, '15:30'));

  { Section 8: Locale — Finnish (dot separator, short) }
  { 8.1 }
  AssertEqual('8.1', '14.15', FormatTime(FI, tcShort, '14:15'));
  { 8.2 }
  AssertEqual('8.2', '0.00', FormatTime(FI, tcShort, '00:00'));

  { Print results }
  WriteLn('');
  WriteLn(PassCount, ' passed, ', FailCount, ' failed');
  if FailCount > 0 then
    Halt(1);
end.
