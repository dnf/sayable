{$mode objfpc}{$H+}
{$codepage utf8}
program test_format_age;

uses SysUtils, SayableAgeTypes, SayableAge, SayableAgeLocales;

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

procedure AssertContains(const ATestID, ASubstr, AActual: string);
begin
  if Pos(ASubstr, AActual) > 0 then
    Inc(PassCount)
  else begin
    WriteLn('FAIL ', ATestID, ': expected "', AActual, '" to contain "', ASubstr, '"');
    Inc(FailCount);
  end;
end;

procedure AssertNotNull(const ATestID, AActual: string);
begin
  if not IsNullResult(AActual) then
    Inc(PassCount)
  else begin
    WriteLn('FAIL ', ATestID, ': expected non-null got null');
    Inc(FailCount);
  end;
end;

procedure AssertLocaleNotNil(const ATestID: string; const APtr: TAgeLocalePtr);
begin
  if APtr <> nil then
    Inc(PassCount)
  else begin
    WriteLn('FAIL ', ATestID, ': expected non-nil locale');
    Inc(FailCount);
  end;
end;

procedure AssertLocaleNil(const ATestID: string; const APtr: TAgeLocalePtr);
begin
  if APtr = nil then
    Inc(PassCount)
  else begin
    WriteLn('FAIL ', ATestID, ': expected nil locale');
    Inc(FailCount);
  end;
end;

procedure AssertLocaleCode(const ATestID, AExpected: string; const APtr: TAgeLocalePtr);
begin
  if (APtr <> nil) and (APtr^.Code = AExpected) then
    Inc(PassCount)
  else begin
    WriteLn('FAIL ', ATestID, ': expected locale code "', AExpected, '"');
    Inc(FailCount);
  end;
end;

var
  EN, ES, HE, MK, SW, ID_LOC, AM: TAgeLocale;
  LPtr: TAgeLocalePtr;

begin
  GetLocale_en(EN);
  GetLocale_es(ES);
  GetLocale_he(HE);
  GetLocale_mk(MK);
  GetLocale_sw(SW);
  GetLocale_id(ID_LOC);
  GetLocale_am(AM);

  { Section 1: Null / edge cases }
  { 1.1 }
  AssertNull('1.1', FormatAge(EN, csNormal, '', '2025-06-15'));
  { 1.3 }
  AssertNull('1.3', FormatAge(EN, csNormal, '', '2025-06-15'));
  { 1.4 }
  AssertNull('1.4', FormatAge(EN, csNormal, '2025-07-01', '2025-06-15'));
  { 1.5 }
  AssertEqual('1.5', '500 years', FormatAge(EN, csNormal, '1525-06-15', '2025-06-15'));
  { 1.6 }
  AssertNull('1.6', FormatAge(EN, csNormal, '1524-06-15', '2025-06-15'));
  { 1.7 }
  AssertNull('1.7', FormatAge(EN, csNormal, '1025-06-15', '2025-06-15'));

  { Section 2: Days tier (0-6 days) }
  { 2.1 }
  AssertEqual('2.1', 'Newborn', FormatAge(EN, csNormal, '2025-06-15', '2025-06-15'));
  { 2.2 }
  AssertEqual('2.2', '1 day', FormatAge(EN, csNormal, '2025-06-14', '2025-06-15'));
  { 2.3 }
  AssertEqual('2.3', '3 days', FormatAge(EN, csNormal, '2025-06-12', '2025-06-15'));
  { 2.4 }
  AssertEqual('2.4', '6 days', FormatAge(EN, csNormal, '2025-06-09', '2025-06-15'));
  { 2.5 }
  AssertEqual('2.5', '1 week', FormatAge(EN, csNormal, '2025-06-08', '2025-06-15'));

  { Section 3: Weeks+days tier }
  { 3.1 }
  AssertEqual('3.1', '1 week', FormatAge(EN, csNormal, '2025-06-08', '2025-06-15'));
  { 3.2 }
  AssertEqual('3.2', '1 week, 1 day', FormatAge(EN, csNormal, '2025-06-07', '2025-06-15'));
  { 3.3 }
  AssertEqual('3.3', '1 week, 2 days', FormatAge(EN, csNormal, '2025-06-06', '2025-06-15'));
  { 3.4 }
  AssertEqual('3.4', '1 week, 6 days', FormatAge(EN, csNormal, '2025-06-02', '2025-06-15'));
  { 3.5 }
  AssertEqual('3.5', '2 weeks', FormatAge(EN, csNormal, '2025-06-01', '2025-06-15'));
  { 3.6 }
  AssertEqual('3.6', '2 weeks, 1 day', FormatAge(EN, csNormal, '2025-05-31', '2025-06-15'));
  { 3.7 }
  AssertEqual('3.7', '2 weeks, 6 days', FormatAge(EN, csNormal, '2025-05-26', '2025-06-15'));
  { 3.8 }
  AssertEqual('3.8', '3 weeks', FormatAge(EN, csNormal, '2025-05-25', '2025-06-15'));
  { 3.9 }
  AssertEqual('3.9', '4 weeks, 3 days', FormatAge(EN, csNormal, '2025-05-15', '2025-06-15'));
  { 3.10 }
  AssertEqual('3.10', '8 weeks, 5 days', FormatAge(EN, csNormal, '2025-04-15', '2025-06-15'));
  { 3.11 }
  AssertEqual('3.11', '13 weeks', FormatAge(EN, csNormal, '2025-03-15', '2025-06-14'));
  { 3.12 }
  AssertEqual('3.12', '3 months', FormatAge(EN, csNormal, '2025-03-15', '2025-06-15'));

  { Section 4: Month boundaries - standard months }
  { 4.1 }
  AssertEqual('4.1', '3 months', FormatAge(EN, csNormal, '2025-01-01', '2025-04-01'));
  { 4.2 - weeks_pattern }
  AssertContains('4.2', 'week', FormatAge(EN, csNormal, '2025-01-01', '2025-03-31'));
  { 4.3 }
  AssertEqual('4.3', '3 months', FormatAge(EN, csNormal, '2025-06-15', '2025-09-15'));
  { 4.4 }
  AssertContains('4.4', 'week', FormatAge(EN, csNormal, '2025-06-15', '2025-09-14'));
  { 4.5 }
  AssertEqual('4.5', '6 months', FormatAge(EN, csNormal, '2025-06-15', '2025-12-15'));

  { Section 5: Month boundaries - February non-leap }
  { 5.1 }
  AssertEqual('5.1', '4 weeks', FormatAge(EN, csNormal, '2025-01-31', '2025-02-28'));
  { 5.2 }
  AssertEqual('5.2', '3 months', FormatAge(EN, csNormal, '2025-01-31', '2025-04-30'));
  { 5.3 }
  AssertContains('5.3', 'week', FormatAge(EN, csNormal, '2025-01-31', '2025-04-29'));
  { 5.4 }
  AssertEqual('5.4', '3 months', FormatAge(EN, csNormal, '2025-02-01', '2025-05-01'));
  { 5.5 }
  AssertContains('5.5', 'week', FormatAge(EN, csNormal, '2025-02-01', '2025-04-30'));

  { Section 6: Month boundaries - February leap year }
  { 6.1 }
  AssertEqual('6.1', '4 weeks, 1 day', FormatAge(EN, csNormal, '2024-01-31', '2024-02-29'));
  { 6.2 }
  AssertEqual('6.2', '4 weeks', FormatAge(EN, csNormal, '2024-01-31', '2024-02-28'));
  { 6.3 }
  AssertEqual('6.3', '3 months', FormatAge(EN, csNormal, '2024-01-31', '2024-04-30'));
  { 6.4 }
  AssertContains('6.4', 'week', FormatAge(EN, csNormal, '2024-01-30', '2024-02-29'));
  { 6.5 }
  AssertContains('6.5', 'week', FormatAge(EN, csNormal, '2024-01-30', '2024-02-28'));

  { Section 7: Month boundaries - 30-day months }
  { 7.1 }
  AssertEqual('7.1', '3 months', FormatAge(EN, csNormal, '2025-03-31', '2025-06-30'));
  { 7.2 }
  AssertContains('7.2', 'week', FormatAge(EN, csNormal, '2025-03-31', '2025-06-29'));
  { 7.3 }
  AssertEqual('7.3', '3 months', FormatAge(EN, csNormal, '2025-08-31', '2025-11-30'));
  { 7.4 }
  AssertContains('7.4', 'week', FormatAge(EN, csNormal, '2025-08-31', '2025-11-29'));

  { Section 8: Month boundaries - leap year baby }
  { 8.1 }
  AssertEqual('8.1', '3 months', FormatAge(EN, csNormal, '2024-02-29', '2024-05-29'));
  { 8.2 }
  AssertContains('8.2', 'week', FormatAge(EN, csNormal, '2024-02-29', '2024-05-28'));
  { 8.3 }
  AssertEqual('8.3', '12 months', FormatAge(EN, csNormal, '2024-02-29', '2025-02-28'));
  { 8.4 }
  AssertEqual('8.4', '12 months', FormatAge(EN, csNormal, '2024-02-29', '2025-03-01'));

  { Section 9: Months tier (3-23 months) }
  { 9.1 }
  AssertEqual('9.1', '3 months', FormatAge(EN, csNormal, '2025-01-15', '2025-04-15'));
  { 9.2 }
  AssertEqual('9.2', '6 months', FormatAge(EN, csNormal, '2025-01-15', '2025-07-15'));
  { 9.3 }
  AssertEqual('9.3', '12 months', FormatAge(EN, csNormal, '2024-06-15', '2025-06-15'));
  { 9.4 }
  AssertEqual('9.4', '23 months', FormatAge(EN, csNormal, '2024-01-15', '2025-12-15'));
  { 9.5 }
  AssertEqual('9.5', '5 months', FormatAge(EN, csNormal, '2025-01-15', '2025-07-14'));
  { 9.6 }
  AssertEqual('9.6', '5 months', FormatAge(EN, csNormal, '2024-11-10', '2025-04-10'));

  { Section 10: Years+months tier (24-35 months) }
  { 10.1 }
  AssertEqual('10.1', '2 years', FormatAge(EN, csNormal, '2023-06-15', '2025-06-15'));
  { 10.2 }
  AssertEqual('10.2', '2 years, 1 month', FormatAge(EN, csNormal, '2023-06-15', '2025-07-15'));
  { 10.3 }
  AssertEqual('10.3', '2 years, 6 months', FormatAge(EN, csNormal, '2023-06-15', '2025-12-15'));
  { 10.4 }
  AssertEqual('10.4', '2 years, 11 months', FormatAge(EN, csNormal, '2023-06-15', '2026-05-15'));
  { 10.5 }
  AssertEqual('10.5', '23 months', FormatAge(EN, csNormal, '2023-06-15', '2025-06-14'));

  { Section 11: Half-year tier (3-6 years) }
  { 11.1 }
  AssertEqual('11.1', '3 years', FormatAge(EN, csNormal, '2022-06-15', '2025-06-15'));
  { 11.2 }
  AssertEqual('11.2', '3 years', FormatAge(EN, csNormal, '2022-06-15', '2025-11-15'));
  { 11.3 - half char is UTF-8: 0xC2 0xBD = #194#189 = '½' }
  AssertEqual('11.3', '3½ years', FormatAge(EN, csNormal, '2022-06-15', '2025-12-15'));
  { 11.4 }
  AssertEqual('11.4', '3½ years', FormatAge(EN, csNormal, '2022-06-15', '2026-05-15'));
  { 11.5 }
  AssertEqual('11.5', '4 years', FormatAge(EN, csNormal, '2021-06-15', '2025-06-15'));
  { 11.6 }
  AssertEqual('11.6', '4½ years', FormatAge(EN, csNormal, '2021-06-15', '2025-12-15'));
  { 11.7 }
  AssertEqual('11.7', '5 years', FormatAge(EN, csNormal, '2020-06-15', '2025-06-15'));
  { 11.8 }
  AssertEqual('11.8', '5½ years', FormatAge(EN, csNormal, '2020-06-15', '2026-02-15'));
  { 11.9 }
  AssertEqual('11.9', '6 years', FormatAge(EN, csNormal, '2019-06-15', '2025-06-15'));
  { 11.10 }
  AssertEqual('11.10', '6½ years', FormatAge(EN, csNormal, '2019-06-15', '2025-12-15'));
  { 11.11 }
  AssertEqual('11.11', '6½ years', FormatAge(EN, csNormal, '2019-06-15', '2026-05-15'));
  { 11.12 }
  AssertEqual('11.12', '2 years, 11 months', FormatAge(EN, csNormal, '2022-06-15', '2025-06-14'));

  { Section 12: Integer tier (7+ years) }
  { 12.1 }
  AssertEqual('12.1', '7 years', FormatAge(EN, csNormal, '2018-06-15', '2025-06-15'));
  { 12.2 }
  AssertEqual('12.2', '7 years', FormatAge(EN, csNormal, '2018-03-20', '2025-06-15'));
  { 12.3 }
  AssertEqual('12.3', '45 years', FormatAge(EN, csNormal, '1980-01-01', '2025-06-15'));

  { Section 13: Cross-year transitions with February }
  { 13.1 }
  AssertEqual('13.1', '3 months', FormatAge(EN, csNormal, '2024-12-31', '2025-03-31'));
  { 13.2 }
  AssertContains('13.2', 'week', FormatAge(EN, csNormal, '2024-12-31', '2025-03-30'));
  { 13.3 }
  AssertEqual('13.3', '3 months', FormatAge(EN, csNormal, '2024-11-30', '2025-02-28'));
  { 13.4 }
  AssertContains('13.4', 'week', FormatAge(EN, csNormal, '2024-11-30', '2025-02-27'));

  { Section 14: Born-on-31st progression }
  { 14.1 }
  AssertEqual('14.1', '3 months', FormatAge(EN, csNormal, '2025-01-31', '2025-04-30'));
  { 14.2 }
  AssertEqual('14.2', '4 months', FormatAge(EN, csNormal, '2025-01-31', '2025-05-31'));
  { 14.3 }
  AssertEqual('14.3', '5 months', FormatAge(EN, csNormal, '2025-01-31', '2025-06-30'));
  { 14.4 }
  AssertEqual('14.4', '5 months', FormatAge(EN, csNormal, '2025-01-31', '2025-07-01'));
  { 14.5 }
  AssertEqual('14.5', '6 months', FormatAge(EN, csNormal, '2025-01-31', '2025-07-31'));

  { Section 15: Default asOf - skipped (no system date mocking in Pascal) }

  { Section 16: formatStage null/edge cases }
  { 16.1 }
  AssertNull('16.1', FormatStage(EN, '', '2025-06-15', ''));
  { 16.3 }
  AssertNull('16.3', FormatStage(EN, '', '2025-06-15', ''));
  { 16.4 }
  AssertNull('16.4', FormatStage(EN, '2025-07-01', '2025-06-15', ''));
  { 16.5 }
  AssertEqual('16.5', 'Adult', FormatStage(EN, '1525-06-15', '2025-06-15', ''));
  { 16.6 }
  AssertNull('16.6', FormatStage(EN, '1524-06-15', '2025-06-15', ''));

  { Section 17: formatStage - Newborn }
  { 17.1 }
  AssertEqual('17.1', 'Newborn', FormatStage(EN, '2025-06-15', '2025-06-15', ''));
  { 17.2 }
  AssertEqual('17.2', 'Newborn', FormatStage(EN, '2025-06-14', '2025-06-15', ''));
  { 17.3 }
  AssertEqual('17.3', 'Newborn', FormatStage(EN, '2025-05-25', '2025-06-15', ''));
  { 17.4 }
  AssertEqual('17.4', 'Newborn', FormatStage(EN, '2025-05-15', '2025-06-15', ''));
  { 17.5 }
  AssertEqual('17.5', 'Newborn', FormatStage(EN, '2025-04-16', '2025-06-15', ''));
  { 17.6 }
  AssertEqual('17.6', 'Infant', FormatStage(EN, '2025-04-15', '2025-06-15', ''));

  { Section 18: formatStage - Infant }
  { 18.1 }
  AssertEqual('18.1', 'Infant', FormatStage(EN, '2025-04-15', '2025-06-15', ''));
  { 18.2 }
  AssertEqual('18.2', 'Infant', FormatStage(EN, '2024-12-15', '2025-06-15', ''));
  { 18.3 }
  AssertEqual('18.3', 'Infant', FormatStage(EN, '2024-07-15', '2025-06-15', ''));
  { 18.4 }
  AssertEqual('18.4', 'Toddler', FormatStage(EN, '2024-06-15', '2025-06-15', ''));

  { Section 19: formatStage - Toddler }
  { 19.1 }
  AssertEqual('19.1', 'Toddler', FormatStage(EN, '2024-06-15', '2025-06-15', ''));
  { 19.2 }
  AssertEqual('19.2', 'Toddler', FormatStage(EN, '2024-01-15', '2025-07-15', ''));
  { 19.3 }
  AssertEqual('19.3', 'Toddler', FormatStage(EN, '2023-06-15', '2025-06-15', ''));
  { 19.4 }
  AssertEqual('19.4', 'Toddler', FormatStage(EN, '2023-06-15', '2026-05-15', ''));
  { 19.5 }
  AssertEqual('19.5', 'Child', FormatStage(EN, '2022-06-15', '2025-06-15', ''));

  { Section 20: formatStage - Child }
  { 20.1 }
  AssertEqual('20.1', 'Child', FormatStage(EN, '2022-06-15', '2025-06-15', ''));
  { 20.2 }
  AssertEqual('20.2', 'Child', FormatStage(EN, '2021-06-15', '2025-06-15', ''));
  { 20.3 }
  AssertEqual('20.3', 'Child', FormatStage(EN, '2019-06-15', '2025-06-15', ''));
  { 20.4 }
  AssertEqual('20.4', 'Child', FormatStage(EN, '2016-06-15', '2025-06-15', ''));
  { 20.5 }
  AssertEqual('20.5', 'Child', FormatStage(EN, '2013-06-15', '2026-05-15', ''));
  { 20.6 }
  AssertEqual('20.6', 'Teenager', FormatStage(EN, '2012-06-15', '2025-06-15', ''));

  { Section 21: formatStage - Teenager }
  { 21.1 }
  AssertEqual('21.1', 'Teenager', FormatStage(EN, '2012-06-15', '2025-06-15', ''));
  { 21.2 }
  AssertEqual('21.2', 'Teenager', FormatStage(EN, '2010-06-15', '2025-06-15', ''));
  { 21.3 }
  AssertEqual('21.3', 'Teenager', FormatStage(EN, '2008-06-15', '2026-05-15', ''));
  { 21.4 }
  AssertEqual('21.4', 'Adult', FormatStage(EN, '2007-06-15', '2025-06-15', ''));

  { Section 22: formatStage - Adult }
  { 22.1 }
  AssertEqual('22.1', 'Adult', FormatStage(EN, '2007-06-15', '2025-06-15', ''));
  { 22.2 }
  AssertEqual('22.2', 'Adult', FormatStage(EN, '2000-06-15', '2025-06-15', ''));
  { 22.3 }
  AssertEqual('22.3', 'Adult', FormatStage(EN, '1980-01-01', '2025-06-15', ''));

  { Section 23: formatStage default asOf - skipped (no system date mocking) }

  { Section 24: SayableAge class - English locale delegation }
  { 24.1 }
  AssertEqual('24.1', 'Newborn', FormatAge(EN, csNormal, '2025-06-15', '2025-06-15'));
  { 24.2 }
  AssertEqual('24.2', '3 days', FormatAge(EN, csNormal, '2025-06-12', '2025-06-15'));
  { 24.3 }
  AssertEqual('24.3', '1 week, 1 day', FormatAge(EN, csNormal, '2025-06-07', '2025-06-15'));
  { 24.4 }
  AssertEqual('24.4', '6 months', FormatAge(EN, csNormal, '2025-01-15', '2025-07-15'));
  { 24.5 }
  AssertEqual('24.5', '2 years, 1 month', FormatAge(EN, csNormal, '2023-06-15', '2025-07-15'));
  { 24.6 }
  AssertEqual('24.6', '3½ years', FormatAge(EN, csNormal, '2022-06-15', '2025-12-15'));
  { 24.7 }
  AssertEqual('24.7', '7 years', FormatAge(EN, csNormal, '2018-06-15', '2025-06-15'));
  { 24.8 }
  AssertEqual('24.8', 'Newborn', FormatStage(EN, '2025-06-15', '2025-06-15', ''));
  { 24.9 }
  AssertEqual('24.9', 'Infant', FormatStage(EN, '2025-01-15', '2025-06-15', ''));
  { 24.10 }
  AssertEqual('24.10', 'Toddler', FormatStage(EN, '2024-06-15', '2025-06-15', ''));
  { 24.11 }
  AssertEqual('24.11', 'Child', FormatStage(EN, '2022-06-15', '2025-06-15', ''));
  { 24.12 }
  AssertEqual('24.12', 'Teenager', FormatStage(EN, '2012-06-15', '2025-06-15', ''));
  { 24.13 }
  AssertEqual('24.13', 'Adult', FormatStage(EN, '2007-06-15', '2025-06-15', ''));
  { 24.14 }
  AssertNull('24.14', FormatAge(EN, csNormal, '', '2025-06-15'));
  { 24.15 }
  AssertNull('24.15', FormatStage(EN, '', '2025-06-15', ''));

  { Section 25: i18n - Spanish locale }
  { 25.1 }
  AssertEqual('25.1', 'Recién nacido', FormatAge(ES, csNormal, '2025-06-15', '2025-06-15'));
  { 25.2 }
  AssertEqual('25.2', '1 día', FormatAge(ES, csNormal, '2025-06-14', '2025-06-15'));
  { 25.3 }
  AssertEqual('25.3', '3 días', FormatAge(ES, csNormal, '2025-06-12', '2025-06-15'));
  { 25.4 }
  AssertEqual('25.4', '1 semana', FormatAge(ES, csNormal, '2025-06-08', '2025-06-15'));
  { 25.5 }
  AssertEqual('25.5', '1 semana, 1 día', FormatAge(ES, csNormal, '2025-06-07', '2025-06-15'));
  { 25.6 }
  AssertEqual('25.6', '2 semanas, 6 días', FormatAge(ES, csNormal, '2025-05-26', '2025-06-15'));
  { 25.7 }
  AssertEqual('25.7', '6 meses', FormatAge(ES, csNormal, '2025-01-15', '2025-07-15'));
  { 25.8 }
  AssertEqual('25.8', '2 años, 1 mes', FormatAge(ES, csNormal, '2023-06-15', '2025-07-15'));
  { 25.9 }
  AssertEqual('25.9', '2 años, 6 meses', FormatAge(ES, csNormal, '2023-06-15', '2025-12-15'));
  { 25.10 }
  AssertEqual('25.10', '3 años y medio', FormatAge(ES, csNormal, '2022-06-15', '2025-12-15'));
  { 25.11 }
  AssertEqual('25.11', '3 años', FormatAge(ES, csNormal, '2022-06-15', '2025-06-15'));
  { 25.12 }
  AssertEqual('25.12', '7 años', FormatAge(ES, csNormal, '2018-06-15', '2025-06-15'));
  { 25.13 }
  AssertEqual('25.13', 'Recién nacido', FormatStage(ES, '2025-06-15', '2025-06-15', ''));
  { 25.14 }
  AssertEqual('25.14', 'Bebé', FormatStage(ES, '2025-01-15', '2025-06-15', ''));
  { 25.15 }
  AssertEqual('25.15', 'Niño pequeño', FormatStage(ES, '2024-06-15', '2025-06-15', ''));
  { 25.16 }
  AssertEqual('25.16', 'Niño', FormatStage(ES, '2022-06-15', '2025-06-15', ''));
  { 25.17 }
  AssertEqual('25.17', 'Adolescente', FormatStage(ES, '2012-06-15', '2025-06-15', ''));
  { 25.18 }
  AssertEqual('25.18', 'Adulto', FormatStage(ES, '2007-06-15', '2025-06-15', ''));
  { 25.19 }
  AssertNull('25.19', FormatAge(ES, csNormal, '', '2025-06-15'));
  { 25.20 }
  AssertNull('25.20', FormatStage(ES, '', '2025-06-15', ''));

  { Section 26: Compactness - short }
  { 26.1 }
  AssertEqual('26.1', '3 d', FormatAge(EN, csShort, '2025-06-12', '2025-06-15'));
  { 26.2 }
  AssertEqual('26.2', '1 wk', FormatAge(EN, csShort, '2025-06-08', '2025-06-15'));
  { 26.3 }
  AssertEqual('26.3', '1 wk, 1 d', FormatAge(EN, csShort, '2025-06-07', '2025-06-15'));
  { 26.4 }
  AssertEqual('26.4', '6 mo', FormatAge(EN, csShort, '2025-01-15', '2025-07-15'));
  { 26.5 }
  AssertEqual('26.5', '2 yr, 1 mo', FormatAge(EN, csShort, '2023-06-15', '2025-07-15'));
  { 26.6 }
  AssertEqual('26.6', '3½ yr', FormatAge(EN, csShort, '2022-06-15', '2025-12-15'));
  { 26.7 }
  AssertEqual('26.7', '7 yr', FormatAge(EN, csShort, '2018-06-15', '2025-06-15'));
  { 26.8 }
  AssertEqual('26.8', 'Newborn', FormatAge(EN, csShort, '2025-06-15', '2025-06-15'));
  { 26.9 }
  AssertEqual('26.9', 'Infant', FormatStage(EN, '2025-01-15', '2025-06-15', ''));

  { Section 27: Compactness - compact }
  { 27.1 }
  AssertEqual('27.1', '3d', FormatAge(EN, csCompact, '2025-06-12', '2025-06-15'));
  { 27.2 }
  AssertEqual('27.2', '1w', FormatAge(EN, csCompact, '2025-06-08', '2025-06-15'));
  { 27.3 }
  AssertEqual('27.3', '1w1d', FormatAge(EN, csCompact, '2025-06-07', '2025-06-15'));
  { 27.4 }
  AssertEqual('27.4', '6m', FormatAge(EN, csCompact, '2025-01-15', '2025-07-15'));
  { 27.5 }
  AssertEqual('27.5', '2y1m', FormatAge(EN, csCompact, '2023-06-15', '2025-07-15'));
  { 27.6 }
  AssertEqual('27.6', '3½y', FormatAge(EN, csCompact, '2022-06-15', '2025-12-15'));
  { 27.7 }
  AssertEqual('27.7', '7y', FormatAge(EN, csCompact, '2018-06-15', '2025-06-15'));
  { 27.8 }
  AssertEqual('27.8', 'Newborn', FormatAge(EN, csCompact, '2025-06-15', '2025-06-15'));

  { Section 29: Locale-specific edge cases - plural rules }
  { Hebrew - 29.1 to 29.14 }
  AssertNotNull('29.1', FormatAge(HE, csNormal, '2025-06-15', '2025-06-15'));
  AssertNotNull('29.2', FormatAge(HE, csNormal, '2025-06-14', '2025-06-15'));
  AssertNotNull('29.3', FormatAge(HE, csNormal, '2025-06-12', '2025-06-15'));
  AssertNotNull('29.4', FormatAge(HE, csNormal, '2025-06-01', '2025-06-15'));
  AssertNotNull('29.5', FormatAge(HE, csNormal, '2025-05-25', '2025-06-15'));
  AssertNotNull('29.6', FormatAge(HE, csNormal, '2025-01-15', '2025-07-15'));
  AssertNotNull('29.7', FormatAge(HE, csNormal, '2025-03-15', '2025-06-15'));
  AssertNotNull('29.8', FormatAge(HE, csNormal, '2023-06-15', '2025-07-15'));
  AssertNotNull('29.9', FormatAge(HE, csNormal, '2022-06-15', '2025-12-15'));
  AssertNotNull('29.10', FormatAge(HE, csNormal, '2018-06-15', '2025-06-15'));
  AssertNotNull('29.11', FormatStage(HE, '2025-06-15', '2025-06-15', 'm'));
  AssertNotNull('29.12', FormatStage(HE, '2025-06-15', '2025-06-15', 'f'));
  AssertNotNull('29.13', FormatStage(HE, '2007-06-15', '2025-06-15', 'm'));
  AssertNotNull('29.14', FormatStage(HE, '2007-06-15', '2025-06-15', 'f'));

  { Macedonian - 29.15 to 29.21 }
  AssertNotNull('29.15', FormatAge(MK, csNormal, '2025-06-15', '2025-06-15'));
  AssertNotNull('29.16', FormatAge(MK, csNormal, '2025-06-14', '2025-06-15'));
  AssertNotNull('29.17', FormatAge(MK, csNormal, '2025-06-12', '2025-06-15'));
  AssertNotNull('29.18', FormatAge(MK, csNormal, '2025-01-15', '2025-07-15'));
  AssertNotNull('29.19', FormatAge(MK, csNormal, '2023-06-15', '2025-07-15'));
  AssertNotNull('29.20', FormatAge(MK, csNormal, '2022-06-15', '2025-12-15'));
  AssertNotNull('29.21', FormatAge(MK, csNormal, '2018-06-15', '2025-06-15'));

  { Swahili - 29.22 to 29.27 }
  AssertNotNull('29.22', FormatAge(SW, csNormal, '2025-06-15', '2025-06-15'));
  AssertNotNull('29.23', FormatAge(SW, csNormal, '2025-06-14', '2025-06-15'));
  AssertNotNull('29.24', FormatAge(SW, csNormal, '2025-06-12', '2025-06-15'));
  AssertNotNull('29.25', FormatAge(SW, csNormal, '2025-01-15', '2025-07-15'));
  AssertNotNull('29.26', FormatAge(SW, csNormal, '2023-06-15', '2025-07-15'));
  AssertNotNull('29.27', FormatAge(SW, csNormal, '2022-06-15', '2025-12-15'));

  { Indonesian - 29.28 to 29.33 }
  AssertNotNull('29.28', FormatAge(ID_LOC, csNormal, '2025-06-15', '2025-06-15'));
  AssertNotNull('29.29', FormatAge(ID_LOC, csNormal, '2025-06-14', '2025-06-15'));
  AssertNotNull('29.30', FormatAge(ID_LOC, csNormal, '2025-06-12', '2025-06-15'));
  AssertNotNull('29.31', FormatAge(ID_LOC, csNormal, '2025-01-15', '2025-07-15'));
  AssertNotNull('29.32', FormatAge(ID_LOC, csNormal, '2022-06-15', '2025-12-15'));
  AssertNotNull('29.33', FormatAge(ID_LOC, csNormal, '2018-06-15', '2025-06-15'));

  { Amharic - 29.34 to 29.39 }
  AssertNotNull('29.34', FormatAge(AM, csNormal, '2025-06-15', '2025-06-15'));
  AssertNotNull('29.35', FormatAge(AM, csNormal, '2025-06-14', '2025-06-15'));
  AssertNotNull('29.36', FormatAge(AM, csNormal, '2025-06-12', '2025-06-15'));
  AssertNotNull('29.37', FormatAge(AM, csNormal, '2025-06-07', '2025-06-15'));
  AssertNotNull('29.38', FormatAge(AM, csNormal, '2025-01-15', '2025-07-15'));
  AssertNotNull('29.39', FormatAge(AM, csNormal, '2022-06-15', '2025-12-15'));

  { Section 30: Locale lookup by code string }
  { 30.1 }
  LPtr := GetLocale('en');
  AssertLocaleNotNil('30.1', LPtr);
  AssertLocaleCode('30.1b', 'en', LPtr);
  { 30.2 }
  LPtr := GetLocale('fr');
  AssertLocaleNotNil('30.2', LPtr);
  AssertLocaleCode('30.2b', 'fr', LPtr);
  { 30.3 }
  AssertLocaleNil('30.3', GetLocale('xx'));
  { 30.4 }
  AssertLocaleNil('30.4', GetLocale(''));
  { 30.5 }
  AssertLocaleNil('30.5', GetLocale('EN'));

  { Section 31: Weeks and days across month ends }
  { 31.1 }
  AssertEqual('31.1', '12 weeks, 4 days', FormatAge(GetLocale('en')^, csNormal, '2016-12-31', '2017-03-29'));
  { 31.2 }
  AssertEqual('31.2', '12 weeks, 6 days', FormatAge(GetLocale('en')^, csNormal, '1991-11-27', '1992-02-25'));
  { 31.3 }
  AssertEqual('31.3', '4 weeks, 5 days', FormatAge(GetLocale('en')^, csNormal, '2020-11-30', '2021-01-02'));
  { 31.4 }
  AssertEqual('31.4', '12w4d', FormatAge(GetLocale('en')^, csCompact, '2016-12-31', '2017-03-29'));

  { Section 32: Half years take their plural form from whole years }
  { 32.1 }
  AssertEqual('32.1', '3 i pół lata', FormatAge(GetLocale('pl')^, csNormal, '2021-06-15', '2025-01-15'));
  { 32.2 }
  AssertEqual('32.2', '5 i pół lat', FormatAge(GetLocale('pl')^, csShort, '2020-06-15', '2025-12-15'));
  { 32.3 }
  AssertEqual('32.3', '6 iseggasen d uzgen', FormatAge(GetLocale('shi')^, csNormal, '2005-06-08', '2012-06-07'));

  { Section 33: Input validation }
  { 33.1 }
  AssertNull('33.1', FormatAge(GetLocale('en')^, csNormal, '2025-02-30', '2032-06-25'));
  { 33.2 }
  AssertNull('33.2', FormatAge(GetLocale('en')^, csNormal, '2025-13-01', '2027-01-31'));
  { 33.3 }
  AssertNull('33.3', FormatAge(GetLocale('en')^, csNormal, '2023-02-29', '2025-03-01'));
  { 33.4 }
  AssertNull('33.4', FormatAge(GetLocale('en')^, csNormal, '2025-06-00', '2027-02-25'));
  { 33.5 }
  AssertNull('33.5', FormatAge(GetLocale('en')^, csNormal, '2025-6-1', '2027-02-25'));
  { 33.6 }
  AssertNull('33.6', FormatAge(GetLocale('en')^, csNormal, ' 2025-06-01', '2027-02-25'));
  { 33.7 }
  AssertNull('33.7', FormatAge(GetLocale('en')^, csNormal, '2025-06-15T10:00:00', '2027-02-25'));
  { 33.8 }
  AssertNull('33.8', FormatAge(GetLocale('en')^, csNormal, '2020-01-01', '2025-04-31'));
  { 33.9 }
  AssertNull('33.9', FormatStage(GetLocale('en')^, '2025-02-30', '2027-09-05', ''));
  { 33.10 }
  AssertEqual('33.10', '2 years', FormatAge(GetLocale('en')^, csNormal, '2024-02-29', '2026-03-01'));

  { Print results }
  WriteLn('');
  WriteLn(PassCount, ' passed, ', FailCount, ' failed');
  if FailCount > 0 then
    Halt(1);
end.
