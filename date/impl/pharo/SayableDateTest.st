"SayableDate tests — all canonical test cases from date/config/tests.json.
Uses SUnit framework. Each test annotated with canonical IDs."

TestCase subclass: #SayableDateTest
	instanceVariableNames: ''
	classVariableNames: ''
	package: 'SayableDate-Tests'!

!SayableDateTest methodsFor: 'tests-null'!
"1.1"
testReturnsNilForNilInput
	self assert: (SayableDate formatDate: nil) isNil
!

"1.2"
testReturnsNilForEmptyString
	self assert: (SayableDate formatDate: '') isNil
!

"1.3"
testReturnsNilForInvalidInput
	self assert: (SayableDate formatDate: 'invalid') isNil
!

"1.4"
testReturnsNilForRelativeNilAsOf
	self assert: (SayableDate formatRelative: '2025-03-15' asOf: nil) isNil
!

"1.5"
testReturnsNilForRelativeNilDate
	self assert: (SayableDate formatRelative: nil asOf: '2025-03-15') isNil
! !

!SayableDateTest methodsFor: 'tests-format-date-normal'!
"2.1"
testFormatDateMarch15th
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en').
	self assert: (sd formatDate: '2025-03-15') equals: 'March 15th'
!

"2.2"
testFormatDateJan1st
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en').
	self assert: (sd formatDate: '2025-01-01') equals: 'January 1st'
!

"2.3"
testFormatDateMay22nd
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en').
	self assert: (sd formatDate: '2025-05-22') equals: 'May 22nd'
!

"2.4"
testFormatDateJuly3rd
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en').
	self assert: (sd formatDate: '2025-07-03') equals: 'July 3rd'
!

"2.5"
testFormatDateDec31st
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en').
	self assert: (sd formatDate: '2025-12-31') equals: 'December 31st'
!

"2.6"
testFormatDateJune11th
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en').
	self assert: (sd formatDate: '2025-06-11') equals: 'June 11th'
!

"2.7"
testFormatDateIsoDatetime
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en').
	self assert: (sd formatDate: '2025-03-15T14:30:00') equals: 'March 15th'
! !

!SayableDateTest methodsFor: 'tests-format-date-short'!
"3.1"
testShortMar15
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en') compactness: #short.
	self assert: (sd formatDate: '2025-03-15') equals: 'Mar 15'
!

"3.2"
testShortJan1
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en') compactness: #short.
	self assert: (sd formatDate: '2025-01-01') equals: 'Jan 1'
!

"3.3"
testShortDec25
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en') compactness: #short.
	self assert: (sd formatDate: '2025-12-25') equals: 'Dec 25'
! !

!SayableDateTest methodsFor: 'tests-format-date-compact'!
"4.1"
testCompactMar15
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en') compactness: #compact.
	self assert: (sd formatDate: '2025-03-15') equals: '3/15'
!

"4.2"
testCompactJan1
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en') compactness: #compact.
	self assert: (sd formatDate: '2025-01-01') equals: '1/1'
! !

!SayableDateTest methodsFor: 'tests-format-relative'!
"5.1"
testRelativeToday
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en').
	self assert: (sd formatRelative: '2025-03-15' asOf: '2025-03-15') equals: 'today'
!

"5.2"
testRelativeTomorrow
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en').
	self assert: (sd formatRelative: '2025-03-16' asOf: '2025-03-15') equals: 'tomorrow'
!

"5.3"
testRelativeYesterday
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en').
	self assert: (sd formatRelative: '2025-03-14' asOf: '2025-03-15') equals: 'yesterday'
!

"5.4"
testRelativeDayAfterTomorrow
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en').
	self assert: (sd formatRelative: '2025-03-17' asOf: '2025-03-15') equals: 'the day after tomorrow'
!

"5.5"
testRelativeDayBeforeYesterday
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en').
	self assert: (sd formatRelative: '2025-03-13' asOf: '2025-03-15') equals: 'the day before yesterday'
!

"5.6"
testRelativeThisWednesday
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en').
	self assert: (sd formatRelative: '2025-03-19' asOf: '2025-03-15') equals: 'this Wednesday'
!

"5.7"
testRelativeThisThursday
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en').
	self assert: (sd formatRelative: '2025-03-20' asOf: '2025-03-15') equals: 'this Thursday'
!

"5.8"
testRelativeLastTuesday
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en').
	self assert: (sd formatRelative: '2025-03-11' asOf: '2025-03-15') equals: 'last Tuesday'
!

"5.9"
testRelativeNextSaturday
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en').
	self assert: (sd formatRelative: '2025-03-22' asOf: '2025-03-15') equals: 'next Saturday'
!

"5.10"
testRelativeNextThursday
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en').
	self assert: (sd formatRelative: '2025-03-27' asOf: '2025-03-15') equals: 'next Thursday'
!

"5.11"
testRelativeCalendarFallbackSameYear
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en').
	self assert: (sd formatRelative: '2025-03-01' asOf: '2025-03-15') equals: 'March 1st'
!

"5.12"
testRelativeCalendarFallbackFutureSameYear
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en').
	self assert: (sd formatRelative: '2025-04-10' asOf: '2025-03-15') equals: 'April 10th'
!

"5.13"
testRelativeDifferentYearFuture
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en').
	self assert: (sd formatRelative: '2026-01-05' asOf: '2025-03-15') equals: 'January 5th, 2026'
!

"5.14"
testRelativeDifferentYearPast
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en').
	self assert: (sd formatRelative: '2024-12-25' asOf: '2025-03-15') equals: 'December 25th, 2024'
! !

!SayableDateTest methodsFor: 'tests-compact-skips-weekday'!
"6.1"
testCompactRelativeToday
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en') compactness: #compact.
	self assert: (sd formatRelative: '2025-03-15' asOf: '2025-03-15') equals: 'today'
!

"6.2"
testCompactRelativeTomorrow
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en') compactness: #compact.
	self assert: (sd formatRelative: '2025-03-16' asOf: '2025-03-15') equals: 'tomorrow'
!

"6.3"
testCompactSkipsWeekday
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en') compactness: #compact.
	self assert: (sd formatRelative: '2025-03-19' asOf: '2025-03-15') equals: '3/19'
!

"6.4"
testCompactDifferentYear
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en') compactness: #compact.
	self assert: (sd formatRelative: '2026-01-05' asOf: '2025-03-15') equals: '1/5/26'
! !

!SayableDateTest methodsFor: 'tests-locale-german'!
"7.1"
testGermanFormatDate
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'de').
	self assert: (sd formatDate: '2025-03-15') equals: '15. März'
!

"7.2"
testGermanTomorrow
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'de').
	self assert: (sd formatRelative: '2025-03-16' asOf: '2025-03-15') equals: 'morgen'
!

"7.3"
testGermanDayAfterTomorrow
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'de').
	self assert: (sd formatRelative: '2025-03-17' asOf: '2025-03-15') equals: 'übermorgen'
!

"7.4"
testGermanThisWeekday
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'de').
	self assert: (sd formatRelative: '2025-03-19' asOf: '2025-03-15') equals: 'diesen Mittwoch'
! !

!SayableDateTest methodsFor: 'tests-locale-french'!
"8.1"
testFrenchFormatDate1er
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'fr').
	self assert: (sd formatDate: '2025-03-01') equals: '1er mars'
!

"8.2"
testFrenchFormatDate15
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'fr').
	self assert: (sd formatDate: '2025-03-15') equals: '15 mars'
!

"8.3"
testFrenchTomorrow
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'fr').
	self assert: (sd formatRelative: '2025-03-16' asOf: '2025-03-15') equals: 'demain'
! !

!SayableDateTest methodsFor: 'tests-locale-japanese'!
"9.1"
testJapaneseFormatDate
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'ja').
	self assert: (sd formatDate: '2025-03-15') equals: '3月15日'
!

"9.2"
testJapaneseTomorrow
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'ja').
	self assert: (sd formatRelative: '2025-03-16' asOf: '2025-03-15') equals: '明日'
!

"9.3"
testJapaneseThisWeekday
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'ja').
	self assert: (sd formatRelative: '2025-03-19' asOf: '2025-03-15') equals: '今度の水曜日'
! !

!SayableDateTest methodsFor: 'tests-locale-russian'!
"10.1"
testRussianGenitiveMonth
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'ru').
	self assert: (sd formatDate: '2025-03-15') equals: '15 марта'
!

"10.2"
testRussianTomorrow
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'ru').
	self assert: (sd formatRelative: '2025-03-16' asOf: '2025-03-15') equals: 'завтра'
! !

!SayableDateTest methodsFor: 'tests-locale-arabic'!
"11.1"
testArabicFormatDate
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'ar').
	self assert: (sd formatDate: '2025-03-15') equals: '15 مارس'
!

"11.2"
testArabicTomorrow
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'ar').
	self assert: (sd formatRelative: '2025-03-16' asOf: '2025-03-15') equals: 'غداً'
! !

!SayableDateTest methodsFor: 'tests-locale-spanish'!
"12.1"
testSpanishFormatDate
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'es').
	self assert: (sd formatDate: '2025-03-15') equals: '15 de marzo'
!

"12.2"
testSpanishDayAfterTomorrow
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'es').
	self assert: (sd formatRelative: '2025-03-17' asOf: '2025-03-15') equals: 'pasado mañana'
! !

!SayableDateTest methodsFor: 'tests-input-formats-and-regressions'!
"13.1"
test13_1FormatDateWithYear
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en').
	self assert: (sd formatDateWithYear: '2018-02-04') equals: 'February 4th, 2018'
!

"13.2"
test13_2FormatDateWithYear
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en') compactness: #short.
	self assert: (sd formatDateWithYear: '2025-03-15') equals: 'Mar 15, 2025'
!

"13.3"
test13_3FormatDateWithYear
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en') compactness: #compact.
	self assert: (sd formatDateWithYear: '1997-01-21') equals: '1/21/97'
!

"13.4"
test13_4TwoDigitYearKeepsItsLeadingZero
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'tg') compactness: #compact.
	self assert: (sd formatDateWithYear: '2007-05-20') equals: '20/5/07'
!

"13.5"
test13_5FormatDateWithYear
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'fi') compactness: #short.
	self assert: (sd formatDateWithYear: '1996-06-21') equals: '21. kesäkuuta 1996'
!

"14.1"
test14_1ShortMonthNamesLocalesThatKeepTheFullGenitive
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'sk') compactness: #short.
	self assert: (sd formatDate: '2031-02-15') equals: '15. februára'
!

"14.2"
test14_2ShortMonthNamesLocalesThatKeepTheFullGenitive
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'cs') compactness: #short.
	self assert: (sd formatDate: '2025-12-10') equals: '10. prosince'
!

"14.3"
test14_3ShortMonthNamesLocalesThatKeepTheFullGenitive
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'uk') compactness: #short.
	self assert: (sd formatDate: '2025-11-05') equals: '5 листопада'
!

"14.4"
test14_4ShortMonthNamesLocalesThatKeepTheFullGenitive
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'fi') compactness: #short.
	self assert: (sd formatRelative: '1998-08-08' asOf: '1998-08-15') equals: '8. elokuuta'
!

"15.1"
test15_1DayAfterTomorrow
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'kw') compactness: #short.
	self assert: (sd formatRelative: '2035-12-04' asOf: '2035-12-02') equals: 'an Mth ma'
!

"15.2"
test15_2DayBeforeYesterday
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'mam') compactness: #short.
	self assert: (sd formatRelative: '2000-01-23' asOf: '2000-01-25') equals: 'Dom nchi''j'
!

"15.3"
test15_3DayAfterTomorrow
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'kek') compactness: #short.
	self assert: (sd formatRelative: '2014-10-24' asOf: '2014-10-22') equals: 'a''in Vie'
!

"16.1"
test16_1February30DoesnTExist
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en').
	self assert: (sd formatDate: '2025-02-30') isNil
!

"16.2"
test16_2Month13
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en').
	self assert: (sd formatDate: '2025-13-01') isNil
!

"16.3"
test16_3UnpaddedMonthAndDay
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en').
	self assert: (sd formatDate: '2025-6-1') isNil
!

"16.4"
test16_4SurroundingWhitespace
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en').
	self assert: (sd formatDate: ' 2025-06-01') isNil
!

"16.5"
test16_5AnISODatetimeOnlyTheDatePartIsUsed
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en').
	self assert: (sd formatDate: '2025-06-01T10:00:00') equals: 'June 1st'
!

"16.6"
test16_6February29InANonLeapYear
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en').
	self assert: (sd formatDateWithYear: '2023-02-29') isNil
!

"16.7"
test16_7InvalidAsOf
	| sd |
	sd := SayableDate withLocale: (SayableDateLocales get: 'en').
	self assert: (sd formatRelative: '2025-03-16' asOf: '2025-04-31') isNil
! !
