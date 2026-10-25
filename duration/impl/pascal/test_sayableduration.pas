{$mode objfpc}{$H+}
{$codepage utf8}
program test_sayableduration;

uses SysUtils, SayableDurationTypes, SayableDuration, SayableDurationLocales;

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

procedure AssertLocaleNotNil(const ATestID: string; const APtr: TDurationLocalePtr);
begin
  if APtr <> nil then
    Inc(PassCount)
  else begin
    WriteLn('FAIL ', ATestID, ': expected non-nil locale');
    Inc(FailCount);
  end;
end;

procedure AssertLocaleNil(const ATestID: string; const APtr: TDurationLocalePtr);
begin
  if APtr = nil then
    Inc(PassCount)
  else begin
    WriteLn('FAIL ', ATestID, ': expected nil locale');
    Inc(FailCount);
  end;
end;

var
  EN, DE, FR, JA: TDurationLocale;
  LPtr: TDurationLocalePtr;

begin
  GetLocale_en(EN);
  GetLocale_de(DE);
  GetLocale_fr(FR);
  GetLocale_ja(JA);

  { Section 1: Null / edge cases }
  { 1.1 - null seconds => null (we use -1 for null) }
  AssertNull('1.1', FormatDuration(EN, csNormal, -1));
  { 1.2 }
  AssertNull('1.2', FormatDuration(EN, csNormal, -1));
  { 1.3 }
  AssertNull('1.3', FormatSince(EN, csNormal, '', '2025-01-15T10:00:00'));
  { 1.4 }
  AssertNull('1.4', FormatUntil(EN, csNormal, '', '2025-01-15T10:00:00'));
  { 1.5 }
  AssertNull('1.5', FormatSince(EN, csNormal, '2025-01-15T10:00:00', '2025-01-15T09:00:00'));
  { 1.6 }
  AssertNull('1.6', FormatUntil(EN, csNormal, '2025-01-15T09:00:00', '2025-01-15T10:00:00'));

  { Section 2: Duration — seconds tier (0-59s) }
  { 2.1 }
  AssertEqual('2.1', 'just now', FormatDuration(EN, csNormal, 0));
  { 2.2 }
  AssertEqual('2.2', '1 second', FormatDuration(EN, csNormal, 1));
  { 2.3 }
  AssertEqual('2.3', '45 seconds', FormatDuration(EN, csNormal, 45));
  { 2.4 }
  AssertEqual('2.4', '59 seconds', FormatDuration(EN, csNormal, 59));

  { Section 3: Duration — minutes + seconds tier (1-4 min) }
  { 3.1 }
  AssertEqual('3.1', '1 minute', FormatDuration(EN, csNormal, 60));
  { 3.2 }
  AssertEqual('3.2', '1 minute, 30 seconds', FormatDuration(EN, csNormal, 90));
  { 3.3 }
  AssertEqual('3.3', '4 minutes', FormatDuration(EN, csNormal, 240));
  { 3.4 }
  AssertEqual('3.4', '4 minutes, 30 seconds', FormatDuration(EN, csNormal, 270));

  { Section 4: Duration — minutes tier (5-59 min) }
  { 4.1 }
  AssertEqual('4.1', '5 minutes', FormatDuration(EN, csNormal, 300));
  { 4.2 }
  AssertEqual('4.2', '25 minutes', FormatDuration(EN, csNormal, 1500));
  { 4.3 }
  AssertEqual('4.3', '59 minutes', FormatDuration(EN, csNormal, 3540));

  { Section 5: Duration — hours + minutes tier (1-5 hr) }
  { 5.1 }
  AssertEqual('5.1', '1 hour', FormatDuration(EN, csNormal, 3600));
  { 5.2 }
  AssertEqual('5.2', '1½ hours', FormatDuration(EN, csNormal, 5400));
  { 5.3 }
  AssertEqual('5.3', '2 hours, 15 minutes', FormatDuration(EN, csNormal, 8100));
  { 5.4 }
  AssertEqual('5.4', '5 hours', FormatDuration(EN, csNormal, 18000));

  { Section 6: Duration — hours tier (6-23 hr) }
  { 6.1 }
  AssertEqual('6.1', '8 hours', FormatDuration(EN, csNormal, 28800));
  { 6.2 }
  AssertEqual('6.2', '23 hours', FormatDuration(EN, csNormal, 82800));

  { Section 7: Duration — days tier }
  { 7.1 }
  AssertEqual('7.1', '1 day', FormatDuration(EN, csNormal, 86400));
  { 7.2 }
  AssertEqual('7.2', '1 day, 3 hours', FormatDuration(EN, csNormal, 97200));
  { 7.3 }
  AssertEqual('7.3', '1½ days', FormatDuration(EN, csNormal, 129600));
  { 7.4 }
  AssertEqual('7.4', '5 days', FormatDuration(EN, csNormal, 432000));
  { 7.5 }
  AssertEqual('7.5', '2 days', FormatDuration(EN, csNormal, 172800));

  { Section 8: Duration — weeks tier }
  { 8.1 }
  AssertEqual('8.1', '1 week', FormatDuration(EN, csNormal, 604800));
  { 8.2 }
  AssertEqual('8.2', '2 weeks, 1 day', FormatDuration(EN, csNormal, 1296000));
  { 8.3 }
  AssertEqual('8.3', '4 weeks', FormatDuration(EN, csNormal, 2419200));

  { Section 9: Duration — months and years tier }
  { 9.1 }
  AssertEqual('9.1', '1 month', FormatDuration(EN, csNormal, 2678400));
  { 9.2 }
  AssertEqual('9.2', '3 months', FormatDuration(EN, csNormal, 7884000));
  { 9.3 }
  AssertEqual('9.3', '1 year', FormatDuration(EN, csNormal, 31536000));
  { 9.4 }
  AssertEqual('9.4', '1 year, 3 months', FormatDuration(EN, csNormal, 39420000));

  { Section 10: Duration from ISO timestamps }
  { 10.1 }
  AssertEqual('10.1', '1½ hours', FormatDurationISO(EN, csNormal, '2025-01-15T10:00:00', '2025-01-15T11:30:00'));
  { 10.2 }
  AssertEqual('10.2', '45 minutes', FormatDurationISO(EN, csNormal, '2025-01-15T10:00:00', '2025-01-15T10:45:00'));

  { Section 11: Relative time — since }
  { 11.1 }
  AssertEqual('11.1', 'just now', FormatSince(EN, csNormal, '2025-01-15T10:00:00', '2025-01-15T10:00:00'));
  { 11.2 }
  AssertEqual('11.2', '30 seconds ago', FormatSince(EN, csNormal, '2025-01-15T10:00:00', '2025-01-15T10:00:30'));
  { 11.3 }
  AssertEqual('11.3', '45 minutes ago', FormatSince(EN, csNormal, '2025-01-15T10:00:00', '2025-01-15T10:45:00'));
  { 11.4 }
  AssertEqual('11.4', '3 hours ago', FormatSince(EN, csNormal, '2025-01-15T10:00:00', '2025-01-15T13:00:00'));

  { Section 12: Relative time — until }
  { 12.1 }
  AssertEqual('12.1', 'just now', FormatUntil(EN, csNormal, '2025-01-15T10:00:00', '2025-01-15T10:00:00'));
  { 12.2 }
  AssertEqual('12.2', 'in 20 minutes', FormatUntil(EN, csNormal, '2025-01-15T10:20:00', '2025-01-15T10:00:00'));
  { 12.3 }
  AssertEqual('12.3', 'in 3 hours', FormatUntil(EN, csNormal, '2025-01-15T13:00:00', '2025-01-15T10:00:00'));

  { Section 13: Locale — German }
  { 13.1 }
  AssertEqual('13.1', '1 Stunde', FormatDuration(DE, csNormal, 3600));
  { 13.2 }
  AssertEqual('13.2', 'vor 5 Minuten', FormatSince(DE, csNormal, '2025-01-15T10:00:00', '2025-01-15T10:05:00'));

  { Section 14: Locale — French }
  { 14.1 }
  AssertEqual('14.1', '2 heures', FormatDuration(FR, csNormal, 7200));

  { Section 15: Locale — Japanese }
  { 15.1 }
  AssertEqual('15.1', '2分', FormatDuration(JA, csNormal, 120));
  { 15.2 }
  AssertEqual('15.2', '1時間前', FormatSince(JA, csNormal, '2025-01-15T10:00:00', '2025-01-15T11:00:00'));

  { Section 16: Short compactness — duration }
  { 16.1 }
  AssertEqual('16.1', '1h', FormatDuration(EN, csShort, 3600));
  { 16.2 }
  AssertEqual('16.2', '1m, 30s', FormatDuration(EN, csShort, 90));

  { Section 17: Compact compactness — duration }
  { 17.1 }
  AssertEqual('17.1', '1h', FormatDuration(EN, csCompact, 3600));
  { 17.2 }
  AssertEqual('17.2', '1m30s', FormatDuration(EN, csCompact, 90));

  { Locale lookup }
  LPtr := GetLocale('en');
  AssertLocaleNotNil('lookup.1', LPtr);
  LPtr := GetLocale('xx');
  AssertLocaleNil('lookup.2', LPtr);

  { Section 18: Short compactness — relative time }
  { 18.1 }
  AssertEqual('18.1', 'lɔhɔnga 2, awa 14 taa gbɔyɔ', FormatSince(GetLocale('men')^, csNormal, '2025-01-20T01:32:11', '2025-01-22T15:39:16'));

  { Section 19: Range (500-year ceiling) }
  { 19.1 }
  AssertEqual('19.1', '500 years', FormatDuration(GetLocale('en')^, csNormal, 15778800000));
  { 19.2 }
  AssertNull('19.2', FormatDuration(GetLocale('en')^, csNormal, 15800000000));
  { 19.3 }
  AssertNull('19.3', FormatDuration(GetLocale('en')^, csNormal, 99999999999));
  { 19.4 }
  AssertNull('19.4', FormatSince(GetLocale('en')^, csNormal, '1500-01-01T00:00:00', '2025-01-01T00:00:00'));
  { 19.5 }
  AssertNull('19.5', FormatUntil(GetLocale('en')^, csNormal, '2600-01-01T00:00:00', '2025-01-01T00:00:00'));

  { Section 20: Timestamp validation }
  { 20.1 }
  AssertEqual('20.1', '1½ hours', FormatDurationISO(GetLocale('en')^, csNormal, '2025-01-15T10:00', '2025-01-15T11:30:00'));
  { 20.2 }
  AssertNull('20.2', FormatDurationISO(GetLocale('en')^, csNormal, '2025-01-15T10', '2025-01-15T11:30:00'));
  { 20.3 }
  AssertNull('20.3', FormatDurationISO(GetLocale('en')^, csNormal, '2025-1-5T10:00:00', '2025-01-15T11:30:00'));
  { 20.4 }
  AssertNull('20.4', FormatDurationISO(GetLocale('en')^, csNormal, '2025-02-30T10:00:00', '2025-03-15T11:30:00'));
  { 20.5 }
  AssertNull('20.5', FormatSince(GetLocale('en')^, csNormal, '2025-01-15T10:00:00', '2025-01-15T25:00:00'));

  { Print results }
  WriteLn('');
  WriteLn(PassCount, ' passed, ', FailCount, ' failed');
  if FailCount > 0 then
    Halt(1);
end.
