{$mode objfpc}{$H+}
{$codepage utf8}
program test_sayabledate;

uses SysUtils, SayableDateTypes, SayableDate, SayableDateLocales;

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

procedure AssertLocaleNotNil(const ATestID: string; const APtr: TDateLocalePtr);
begin
  if APtr <> nil then
    Inc(PassCount)
  else begin
    WriteLn('FAIL ', ATestID, ': expected non-nil locale');
    Inc(FailCount);
  end;
end;

procedure AssertLocaleNil(const ATestID: string; const APtr: TDateLocalePtr);
begin
  if APtr = nil then
    Inc(PassCount)
  else begin
    WriteLn('FAIL ', ATestID, ': expected nil locale');
    Inc(FailCount);
  end;
end;

var
  EN, DE, FR, JA, RU, AR, ES: TDateLocale;
  LPtr: TDateLocalePtr;

begin
  GetLocale_en(EN);
  GetLocale_de(DE);
  GetLocale_fr(FR);
  GetLocale_ja(JA);
  GetLocale_ru(RU);
  GetLocale_ar(AR);
  GetLocale_es(ES);

  { Section 1: Null / edge cases }
  { 1.1 }
  AssertNull('1.1', FormatDate(EN, csNormal, ''));
  { 1.2 }
  AssertNull('1.2', FormatDate(EN, csNormal, ''));
  { 1.3 }
  AssertNull('1.3', FormatDate(EN, csNormal, 'invalid'));
  { 1.4 }
  AssertNull('1.4', FormatRelative(EN, csNormal, '2025-03-15', ''));
  { 1.5 }
  AssertNull('1.5', FormatRelative(EN, csNormal, '', '2025-03-15'));

  { Section 2: format_date — normal compactness (English) }
  { 2.1 }
  AssertEqual('2.1', 'March 15th', FormatDate(EN, csNormal, '2025-03-15'));
  { 2.2 }
  AssertEqual('2.2', 'January 1st', FormatDate(EN, csNormal, '2025-01-01'));
  { 2.3 }
  AssertEqual('2.3', 'May 22nd', FormatDate(EN, csNormal, '2025-05-22'));
  { 2.4 }
  AssertEqual('2.4', 'July 3rd', FormatDate(EN, csNormal, '2025-07-03'));
  { 2.5 }
  AssertEqual('2.5', 'December 31st', FormatDate(EN, csNormal, '2025-12-31'));
  { 2.6 }
  AssertEqual('2.6', 'June 11th', FormatDate(EN, csNormal, '2025-06-11'));
  { 2.7 }
  AssertEqual('2.7', 'March 15th', FormatDate(EN, csNormal, '2025-03-15T14:30:00'));

  { Section 3: format_date — short compactness (English) }
  { 3.1 }
  AssertEqual('3.1', 'Mar 15', FormatDate(EN, csShort, '2025-03-15'));
  { 3.2 }
  AssertEqual('3.2', 'Jan 1', FormatDate(EN, csShort, '2025-01-01'));
  { 3.3 }
  AssertEqual('3.3', 'Dec 25', FormatDate(EN, csShort, '2025-12-25'));

  { Section 4: format_date — compact (English) }
  { 4.1 }
  AssertEqual('4.1', '3/15', FormatDate(EN, csCompact, '2025-03-15'));
  { 4.2 }
  AssertEqual('4.2', '1/1', FormatDate(EN, csCompact, '2025-01-01'));

  { Section 5: format_relative — proximity tiers (English) }
  { 5.1 }
  AssertEqual('5.1', 'today', FormatRelative(EN, csNormal, '2025-03-15', '2025-03-15'));
  { 5.2 }
  AssertEqual('5.2', 'tomorrow', FormatRelative(EN, csNormal, '2025-03-16', '2025-03-15'));
  { 5.3 }
  AssertEqual('5.3', 'yesterday', FormatRelative(EN, csNormal, '2025-03-14', '2025-03-15'));
  { 5.4 }
  AssertEqual('5.4', 'the day after tomorrow', FormatRelative(EN, csNormal, '2025-03-17', '2025-03-15'));
  { 5.5 }
  AssertEqual('5.5', 'the day before yesterday', FormatRelative(EN, csNormal, '2025-03-13', '2025-03-15'));
  { 5.6 }
  AssertEqual('5.6', 'this Wednesday', FormatRelative(EN, csNormal, '2025-03-19', '2025-03-15'));
  { 5.7 }
  AssertEqual('5.7', 'this Thursday', FormatRelative(EN, csNormal, '2025-03-20', '2025-03-15'));
  { 5.8 }
  AssertEqual('5.8', 'last Tuesday', FormatRelative(EN, csNormal, '2025-03-11', '2025-03-15'));
  { 5.9 }
  AssertEqual('5.9', 'next Saturday', FormatRelative(EN, csNormal, '2025-03-22', '2025-03-15'));
  { 5.10 }
  AssertEqual('5.10', 'next Thursday', FormatRelative(EN, csNormal, '2025-03-27', '2025-03-15'));
  { 5.11 }
  AssertEqual('5.11', 'March 1st', FormatRelative(EN, csNormal, '2025-03-01', '2025-03-15'));
  { 5.12 }
  AssertEqual('5.12', 'April 10th', FormatRelative(EN, csNormal, '2025-04-10', '2025-03-15'));
  { 5.13 }
  AssertEqual('5.13', 'January 5th, 2026', FormatRelative(EN, csNormal, '2026-01-05', '2025-03-15'));
  { 5.14 }
  AssertEqual('5.14', 'December 25th, 2024', FormatRelative(EN, csNormal, '2024-12-25', '2025-03-15'));

  { Section 6: format_relative — compact skips weekday tiers }
  { 6.1 }
  AssertEqual('6.1', 'today', FormatRelative(EN, csCompact, '2025-03-15', '2025-03-15'));
  { 6.2 }
  AssertEqual('6.2', 'tomorrow', FormatRelative(EN, csCompact, '2025-03-16', '2025-03-15'));
  { 6.3 }
  AssertEqual('6.3', '3/19', FormatRelative(EN, csCompact, '2025-03-19', '2025-03-15'));
  { 6.4 }
  AssertEqual('6.4', '1/5/26', FormatRelative(EN, csCompact, '2026-01-05', '2025-03-15'));

  { Section 7: Locale — German }
  { 7.1 }
  AssertEqual('7.1', '15. März', FormatDate(DE, csNormal, '2025-03-15'));
  { 7.2 }
  AssertEqual('7.2', 'morgen', FormatRelative(DE, csNormal, '2025-03-16', '2025-03-15'));
  { 7.3 }
  AssertEqual('7.3', 'übermorgen', FormatRelative(DE, csNormal, '2025-03-17', '2025-03-15'));
  { 7.4 }
  AssertEqual('7.4', 'diesen Mittwoch', FormatRelative(DE, csNormal, '2025-03-19', '2025-03-15'));

  { Section 8: Locale — French }
  { 8.1 }
  AssertEqual('8.1', '1er mars', FormatDate(FR, csNormal, '2025-03-01'));
  { 8.2 }
  AssertEqual('8.2', '15 mars', FormatDate(FR, csNormal, '2025-03-15'));
  { 8.3 }
  AssertEqual('8.3', 'demain', FormatRelative(FR, csNormal, '2025-03-16', '2025-03-15'));

  { Section 9: Locale — Japanese }
  { 9.1 }
  AssertEqual('9.1', '3月15日', FormatDate(JA, csNormal, '2025-03-15'));
  { 9.2 }
  AssertEqual('9.2', '明日', FormatRelative(JA, csNormal, '2025-03-16', '2025-03-15'));
  { 9.3 }
  AssertEqual('9.3', '今度の水曜日', FormatRelative(JA, csNormal, '2025-03-19', '2025-03-15'));

  { Section 10: Locale — Russian (genitive months) }
  { 10.1 }
  AssertEqual('10.1', '15 марта', FormatDate(RU, csNormal, '2025-03-15'));
  { 10.2 }
  AssertEqual('10.2', 'завтра', FormatRelative(RU, csNormal, '2025-03-16', '2025-03-15'));

  { Section 11: Locale — Arabic }
  { 11.1 }
  AssertEqual('11.1', '15 مارس', FormatDate(AR, csNormal, '2025-03-15'));
  { 11.2 }
  AssertEqual('11.2', 'غداً', FormatRelative(AR, csNormal, '2025-03-16', '2025-03-15'));

  { Section 12: Locale — Spanish }
  { 12.1 }
  AssertEqual('12.1', '15 de marzo', FormatDate(ES, csNormal, '2025-03-15'));
  { 12.2 }
  AssertEqual('12.2', 'pasado mañana', FormatRelative(ES, csNormal, '2025-03-17', '2025-03-15'));

  { Locale lookup }
  LPtr := GetLocale('en');
  AssertLocaleNotNil('lookup.1', LPtr);
  LPtr := GetLocale('xx');
  AssertLocaleNil('lookup.2', LPtr);

  { Section 13: format_date_with_year }
  { 13.1 }
  AssertEqual('13.1', 'February 4th, 2018', FormatDateWithYear(GetLocale('en')^, csNormal, '2018-02-04'));
  { 13.2 }
  AssertEqual('13.2', 'Mar 15, 2025', FormatDateWithYear(GetLocale('en')^, csShort, '2025-03-15'));
  { 13.3 }
  AssertEqual('13.3', '1/21/97', FormatDateWithYear(GetLocale('en')^, csCompact, '1997-01-21'));
  { 13.4 }
  AssertEqual('13.4', '20/5/07', FormatDateWithYear(GetLocale('tg')^, csCompact, '2007-05-20'));
  { 13.5 }
  AssertEqual('13.5', '21. kesäkuuta 1996', FormatDateWithYear(GetLocale('fi')^, csShort, '1996-06-21'));

  { Section 14: Short month names (locales that keep the full genitive) }
  { 14.1 }
  AssertEqual('14.1', '15. februára', FormatDate(GetLocale('sk')^, csShort, '2031-02-15'));
  { 14.2 }
  AssertEqual('14.2', '10. prosince', FormatDate(GetLocale('cs')^, csShort, '2025-12-10'));
  { 14.3 }
  AssertEqual('14.3', '5 листопада', FormatDate(GetLocale('uk')^, csShort, '2025-11-05'));
  { 14.4 }
  AssertEqual('14.4', '8. elokuuta', FormatRelative(GetLocale('fi')^, csShort, '1998-08-08', '1998-08-15'));

  { Section 15: format_relative — short phrases }
  { 15.1 }
  AssertEqual('15.1', 'an Mth ma', FormatRelative(GetLocale('kw')^, csShort, '2035-12-04', '2035-12-02'));
  { 15.2 }
  AssertEqual('15.2', 'Dom nchi''j', FormatRelative(GetLocale('mam')^, csShort, '2000-01-23', '2000-01-25'));
  { 15.3 }
  AssertEqual('15.3', 'a''in Vie', FormatRelative(GetLocale('kek')^, csShort, '2014-10-24', '2014-10-22'));

  { Section 16: Input validation }
  { 16.1 }
  AssertNull('16.1', FormatDate(GetLocale('en')^, csNormal, '2025-02-30'));
  { 16.2 }
  AssertNull('16.2', FormatDate(GetLocale('en')^, csNormal, '2025-13-01'));
  { 16.3 }
  AssertNull('16.3', FormatDate(GetLocale('en')^, csNormal, '2025-6-1'));
  { 16.4 }
  AssertNull('16.4', FormatDate(GetLocale('en')^, csNormal, ' 2025-06-01'));
  { 16.5 }
  AssertEqual('16.5', 'June 1st', FormatDate(GetLocale('en')^, csNormal, '2025-06-01T10:00:00'));
  { 16.6 }
  AssertNull('16.6', FormatDateWithYear(GetLocale('en')^, csNormal, '2023-02-29'));
  { 16.7 }
  AssertNull('16.7', FormatRelative(GetLocale('en')^, csNormal, '2025-03-16', '2025-04-31'));

  { Print results }
  WriteLn('');
  WriteLn(PassCount, ' passed, ', FailCount, ' failed');
  if FailCount > 0 then
    Halt(1);
end.
