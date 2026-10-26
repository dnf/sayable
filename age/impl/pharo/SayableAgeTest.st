"SayableAge tests — all canonical test cases from age/config/tests.json.
Uses SUnit framework. Each test annotated with canonical IDs."

TestCase subclass: #SayableAgeFormatAgeTest
	instanceVariableNames: ''
	classVariableNames: ''
	package: 'SayableAge-Tests'!

!SayableAgeFormatAgeTest methodsFor: 'tests-null'!
"1.1"
testReturnsNilForNilInput
	self assert: (SayableAge formatAge: nil asOf: '2025-06-15') isNil
!

"1.3"
testReturnsNilForEmptyString
	self assert: (SayableAge formatAge: '' asOf: '2025-06-15') isNil
!

"1.4"
testReturnsNilForFutureDob
	self assert: (SayableAge formatAge: '2025-07-01' asOf: '2025-06-15') isNil
!

"1.5"
testExactly500YearsIsAllowed
	self assert: (SayableAge formatAge: '1525-06-15' asOf: '2025-06-15') equals: '500 years'
!

"1.6"
test501YearsExceedsMaxAge
	self assert: (SayableAge formatAge: '1524-06-15' asOf: '2025-06-15') isNil
!

"1.7"
test1000YearsExceedsMaxAge
	self assert: (SayableAge formatAge: '1025-06-15' asOf: '2025-06-15') isNil
! !

!SayableAgeFormatAgeTest methodsFor: 'tests-days'!
"2.1"
testBornTodayNewborn
	self assert: (SayableAge formatAge: '2025-06-15' asOf: '2025-06-15') equals: 'Newborn'
!

"2.2"
test1DaySingular
	self assert: (SayableAge formatAge: '2025-06-14' asOf: '2025-06-15') equals: '1 day'
!

"2.3"
test3Days
	self assert: (SayableAge formatAge: '2025-06-12' asOf: '2025-06-15') equals: '3 days'
!

"2.4"
test6Days
	self assert: (SayableAge formatAge: '2025-06-09' asOf: '2025-06-15') equals: '6 days'
!

"2.5"
test7DaysBecomes1Week
	self assert: (SayableAge formatAge: '2025-06-08' asOf: '2025-06-15') equals: '1 week'
! !

!SayableAgeFormatAgeTest methodsFor: 'tests-weeks'!
"3.1"
test7Days
	self assert: (SayableAge formatAge: '2025-06-08' asOf: '2025-06-15') equals: '1 week'
!

"3.2"
test8Days
	self assert: (SayableAge formatAge: '2025-06-07' asOf: '2025-06-15') equals: '1 week, 1 day'
!

"3.3"
test9Days
	self assert: (SayableAge formatAge: '2025-06-06' asOf: '2025-06-15') equals: '1 week, 2 days'
!

"3.4"
test13Days
	self assert: (SayableAge formatAge: '2025-06-02' asOf: '2025-06-15') equals: '1 week, 6 days'
!

"3.5"
test14Days
	self assert: (SayableAge formatAge: '2025-06-01' asOf: '2025-06-15') equals: '2 weeks'
!

"3.6"
test15Days
	self assert: (SayableAge formatAge: '2025-05-31' asOf: '2025-06-15') equals: '2 weeks, 1 day'
!

"3.7"
test20Days
	self assert: (SayableAge formatAge: '2025-05-26' asOf: '2025-06-15') equals: '2 weeks, 6 days'
!

"3.8"
test21Days
	self assert: (SayableAge formatAge: '2025-05-25' asOf: '2025-06-15') equals: '3 weeks'
!

"3.9"
testAt1CalMonthStillWeeksDays
	self assert: (SayableAge formatAge: '2025-05-15' asOf: '2025-06-15') equals: '4 weeks, 3 days'
!

"3.10"
testAt2CalMonthsStillWeeksDays
	self assert: (SayableAge formatAge: '2025-04-15' asOf: '2025-06-15') equals: '8 weeks, 5 days'
!

"3.11"
testOneDayBefore3moStillWeeks
	self assert: ((SayableAge formatAge: '2025-03-15' asOf: '2025-06-14') includesSubstring: 'week')
!

"3.12"
testOn3moBirthdaySwitches
	self assert: (SayableAge formatAge: '2025-03-15' asOf: '2025-06-15') equals: '3 months'
! !

!SayableAgeFormatAgeTest methodsFor: 'tests-month-boundaries-standard'!
"4.1"
testJan1Apr13mo
	self assert: (SayableAge formatAge: '2025-01-01' asOf: '2025-04-01') equals: '3 months'
!

"4.2"
testJan1Mar31StillWeeks
	self assert: ((SayableAge formatAge: '2025-01-01' asOf: '2025-03-31') includesSubstring: 'week')
!

"4.3"
testJun15Sep153mo
	self assert: (SayableAge formatAge: '2025-06-15' asOf: '2025-09-15') equals: '3 months'
!

"4.4"
testJun15Sep14StillWeeks
	self assert: ((SayableAge formatAge: '2025-06-15' asOf: '2025-09-14') includesSubstring: 'week')
!

"4.5"
testJun15Dec156mo
	self assert: (SayableAge formatAge: '2025-06-15' asOf: '2025-12-15') equals: '6 months'
! !

!SayableAgeFormatAgeTest methodsFor: 'tests-month-boundaries-feb-nonleap'!
"5.1"
testJan31Feb28NonLeap
	self assert: (SayableAge formatAge: '2025-01-31' asOf: '2025-02-28') equals: '4 weeks'
!

"5.2"
testJan31Apr303moClamp
	self assert: (SayableAge formatAge: '2025-01-31' asOf: '2025-04-30') equals: '3 months'
!

"5.3"
testJan31Apr29StillWeeks
	self assert: ((SayableAge formatAge: '2025-01-31' asOf: '2025-04-29') includesSubstring: 'week')
!

"5.4"
testFeb1May13mo
	self assert: (SayableAge formatAge: '2025-02-01' asOf: '2025-05-01') equals: '3 months'
!

"5.5"
testFeb1Apr30StillWeeks
	self assert: ((SayableAge formatAge: '2025-02-01' asOf: '2025-04-30') includesSubstring: 'week')
! !

!SayableAgeFormatAgeTest methodsFor: 'tests-month-boundaries-feb-leap'!
"6.1"
testJan31Feb29Leap
	self assert: (SayableAge formatAge: '2024-01-31' asOf: '2024-02-29') equals: '4 weeks, 1 day'
!

"6.2"
testJan31Feb28Leap
	self assert: (SayableAge formatAge: '2024-01-31' asOf: '2024-02-28') equals: '4 weeks'
!

"6.3"
testJan31Apr30Leap3mo
	self assert: (SayableAge formatAge: '2024-01-31' asOf: '2024-04-30') equals: '3 months'
!

"6.4"
testJan30Feb29LeapStillWeeks
	self assert: ((SayableAge formatAge: '2024-01-30' asOf: '2024-02-29') includesSubstring: 'week')
!

"6.5"
testJan30Feb28LeapStillWeeks
	self assert: ((SayableAge formatAge: '2024-01-30' asOf: '2024-02-28') includesSubstring: 'week')
! !

!SayableAgeFormatAgeTest methodsFor: 'tests-month-boundaries-30day'!
"7.1"
testMar31Jun303mo
	self assert: (SayableAge formatAge: '2025-03-31' asOf: '2025-06-30') equals: '3 months'
!

"7.2"
testMar31Jun29StillWeeks
	self assert: ((SayableAge formatAge: '2025-03-31' asOf: '2025-06-29') includesSubstring: 'week')
!

"7.3"
testAug31Nov303mo
	self assert: (SayableAge formatAge: '2025-08-31' asOf: '2025-11-30') equals: '3 months'
!

"7.4"
testAug31Nov29StillWeeks
	self assert: ((SayableAge formatAge: '2025-08-31' asOf: '2025-11-29') includesSubstring: 'week')
! !

!SayableAgeFormatAgeTest methodsFor: 'tests-month-boundaries-leapbaby'!
"8.1"
testFeb29May293mo
	self assert: (SayableAge formatAge: '2024-02-29' asOf: '2024-05-29') equals: '3 months'
!

"8.2"
testFeb29May28StillWeeks
	self assert: ((SayableAge formatAge: '2024-02-29' asOf: '2024-05-28') includesSubstring: 'week')
!

"8.3"
testFeb292024Feb282025Is12mo
	self assert: (SayableAge formatAge: '2024-02-29' asOf: '2025-02-28') equals: '12 months'
!

"8.4"
testFeb292024Mar12025Is12mo
	self assert: (SayableAge formatAge: '2024-02-29' asOf: '2025-03-01') equals: '12 months'
! !

!SayableAgeFormatAgeTest methodsFor: 'tests-months'!
"9.1"
test3MonthsAtTransition
	self assert: (SayableAge formatAge: '2025-01-15' asOf: '2025-04-15') equals: '3 months'
!

"9.2"
test6Months
	self assert: (SayableAge formatAge: '2025-01-15' asOf: '2025-07-15') equals: '6 months'
!

"9.3"
test12MonthsNot1Year
	self assert: (SayableAge formatAge: '2024-06-15' asOf: '2025-06-15') equals: '12 months'
!

"9.4"
test23MonthsUpperBoundary
	self assert: (SayableAge formatAge: '2024-01-15' asOf: '2025-12-15') equals: '23 months'
!

"9.5"
testOneDayBeforeMonthBoundary
	self assert: (SayableAge formatAge: '2025-01-15' asOf: '2025-07-14') equals: '5 months'
!

"9.6"
testCrossingYearBoundary
	self assert: (SayableAge formatAge: '2024-11-10' asOf: '2025-04-10') equals: '5 months'
! !

!SayableAgeFormatAgeTest methodsFor: 'tests-years-months'!
"10.1"
test2YearsAt24mo
	self assert: (SayableAge formatAge: '2023-06-15' asOf: '2025-06-15') equals: '2 years'
!

"10.2"
test2Years1Month
	self assert: (SayableAge formatAge: '2023-06-15' asOf: '2025-07-15') equals: '2 years, 1 month'
!

"10.3"
test2Years6Months
	self assert: (SayableAge formatAge: '2023-06-15' asOf: '2025-12-15') equals: '2 years, 6 months'
!

"10.4"
test2Years11Months
	self assert: (SayableAge formatAge: '2023-06-15' asOf: '2026-05-15') equals: '2 years, 11 months'
!

"10.5"
testOneDayBefore24moStaysMonths
	self assert: (SayableAge formatAge: '2023-06-15' asOf: '2025-06-14') equals: '23 months'
! !

!SayableAgeFormatAgeTest methodsFor: 'tests-half-years'!
"11.1"
test3YearsExactly
	self assert: (SayableAge formatAge: '2022-06-15' asOf: '2025-06-15') equals: '3 years'
!

"11.2"
test3Years5Months
	self assert: (SayableAge formatAge: '2022-06-15' asOf: '2025-11-15') equals: '3 years'
!

"11.3"
test3HalfYearsAt3y6m
	self assert: (SayableAge formatAge: '2022-06-15' asOf: '2025-12-15') equals: '3½ years'
!

"11.4"
test3HalfYearsAt3y11m
	self assert: (SayableAge formatAge: '2022-06-15' asOf: '2026-05-15') equals: '3½ years'
!

"11.5"
test4YearsExactly
	self assert: (SayableAge formatAge: '2021-06-15' asOf: '2025-06-15') equals: '4 years'
!

"11.6"
test4HalfYears
	self assert: (SayableAge formatAge: '2021-06-15' asOf: '2025-12-15') equals: '4½ years'
!

"11.7"
test5Years
	self assert: (SayableAge formatAge: '2020-06-15' asOf: '2025-06-15') equals: '5 years'
!

"11.8"
test5HalfYearsAt5y8m
	self assert: (SayableAge formatAge: '2020-06-15' asOf: '2026-02-15') equals: '5½ years'
!

"11.9"
test6Years
	self assert: (SayableAge formatAge: '2019-06-15' asOf: '2025-06-15') equals: '6 years'
!

"11.10"
test6HalfYears
	self assert: (SayableAge formatAge: '2019-06-15' asOf: '2025-12-15') equals: '6½ years'
!

"11.11"
test6HalfYearsAt6y11m
	self assert: (SayableAge formatAge: '2019-06-15' asOf: '2026-05-15') equals: '6½ years'
!

"11.12"
testOneDayBefore3rdBday
	self assert: (SayableAge formatAge: '2022-06-15' asOf: '2025-06-14') equals: '2 years, 11 months'
! !

!SayableAgeFormatAgeTest methodsFor: 'tests-integer-years'!
"12.1"
test7YearsExactly
	self assert: (SayableAge formatAge: '2018-06-15' asOf: '2025-06-15') equals: '7 years'
!

"12.2"
test7Years6MonthsNoHalf
	self assert: (SayableAge formatAge: '2018-03-20' asOf: '2025-06-15') equals: '7 years'
!

"12.3"
test45Years
	self assert: (SayableAge formatAge: '1980-01-01' asOf: '2025-06-15') equals: '45 years'
! !

!SayableAgeFormatAgeTest methodsFor: 'tests-cross-year'!
"13.1"
testDec31Mar313mo
	self assert: (SayableAge formatAge: '2024-12-31' asOf: '2025-03-31') equals: '3 months'
!

"13.2"
testDec31Mar30StillWeeks
	self assert: ((SayableAge formatAge: '2024-12-31' asOf: '2025-03-30') includesSubstring: 'week')
!

"13.3"
testNov30Feb283mo
	self assert: (SayableAge formatAge: '2024-11-30' asOf: '2025-02-28') equals: '3 months'
!

"13.4"
testNov30Feb27StillWeeks
	self assert: ((SayableAge formatAge: '2024-11-30' asOf: '2025-02-27') includesSubstring: 'week')
! !

!SayableAgeFormatAgeTest methodsFor: 'tests-born-on-31st'!
"14.1"
testJan31Apr303mo
	self assert: (SayableAge formatAge: '2025-01-31' asOf: '2025-04-30') equals: '3 months'
!

"14.2"
testJan31May314mo
	self assert: (SayableAge formatAge: '2025-01-31' asOf: '2025-05-31') equals: '4 months'
!

"14.3"
testJan31Jun305moClamped
	self assert: (SayableAge formatAge: '2025-01-31' asOf: '2025-06-30') equals: '5 months'
!

"14.4"
testJan31Jul15mo
	self assert: (SayableAge formatAge: '2025-01-31' asOf: '2025-07-01') equals: '5 months'
!

"14.5"
testJan31Jul316mo
	self assert: (SayableAge formatAge: '2025-01-31' asOf: '2025-07-31') equals: '6 months'
! !

"================================================================"
"formatStage tests"
"================================================================"

TestCase subclass: #SayableAgeFormatStageTest
	instanceVariableNames: ''
	classVariableNames: ''
	package: 'SayableAge-Tests'!

!SayableAgeFormatStageTest methodsFor: 'tests-null'!
"16.1"
testReturnsNilForNil
	self assert: (SayableAge formatStage: nil asOf: '2025-06-15') isNil
!

"16.3"
testReturnsNilForEmpty
	self assert: (SayableAge formatStage: '' asOf: '2025-06-15') isNil
!

"16.4"
testReturnsNilForFuture
	self assert: (SayableAge formatStage: '2025-07-01' asOf: '2025-06-15') isNil
!

"16.5"
testExactly500YearsReturnsAdult
	self assert: (SayableAge formatStage: '1525-06-15' asOf: '2025-06-15') equals: 'Adult'
!

"16.6"
test501YearsExceedsMaxAge
	self assert: (SayableAge formatStage: '1524-06-15' asOf: '2025-06-15') isNil
! !

!SayableAgeFormatStageTest methodsFor: 'tests-newborn'!
"17.1"
testNewbornBornToday
	self assert: (SayableAge formatStage: '2025-06-15' asOf: '2025-06-15') equals: 'Newborn'
!

"17.2"
testNewborn1Day
	self assert: (SayableAge formatStage: '2025-06-14' asOf: '2025-06-15') equals: 'Newborn'
!

"17.3"
testNewborn3Weeks
	self assert: (SayableAge formatStage: '2025-05-25' asOf: '2025-06-15') equals: 'Newborn'
!

"17.4"
testNewborn1Month
	self assert: (SayableAge formatStage: '2025-05-15' asOf: '2025-06-15') equals: 'Newborn'
!

"17.5"
testNewborn1Month29Days
	self assert: (SayableAge formatStage: '2025-04-16' asOf: '2025-06-15') equals: 'Newborn'
!

"17.6"
testExactly2MonthsInfant
	self assert: (SayableAge formatStage: '2025-04-15' asOf: '2025-06-15') equals: 'Infant'
! !

!SayableAgeFormatStageTest methodsFor: 'tests-infant'!
"18.1"
testInfant2Months
	self assert: (SayableAge formatStage: '2025-04-15' asOf: '2025-06-15') equals: 'Infant'
!

"18.2"
testInfant6Months
	self assert: (SayableAge formatStage: '2024-12-15' asOf: '2025-06-15') equals: 'Infant'
!

"18.3"
testInfant11Months
	self assert: (SayableAge formatStage: '2024-07-15' asOf: '2025-06-15') equals: 'Infant'
!

"18.4"
testExactly12MonthsToddler
	self assert: (SayableAge formatStage: '2024-06-15' asOf: '2025-06-15') equals: 'Toddler'
! !

!SayableAgeFormatStageTest methodsFor: 'tests-toddler'!
"19.1"
testToddler12Months
	self assert: (SayableAge formatStage: '2024-06-15' asOf: '2025-06-15') equals: 'Toddler'
!

"19.2"
testToddler18Months
	self assert: (SayableAge formatStage: '2024-01-15' asOf: '2025-07-15') equals: 'Toddler'
!

"19.3"
testToddler24Months
	self assert: (SayableAge formatStage: '2023-06-15' asOf: '2025-06-15') equals: 'Toddler'
!

"19.4"
testToddler35Months
	self assert: (SayableAge formatStage: '2023-06-15' asOf: '2026-05-15') equals: 'Toddler'
!

"19.5"
testExactly36MonthsChild
	self assert: (SayableAge formatStage: '2022-06-15' asOf: '2025-06-15') equals: 'Child'
! !

!SayableAgeFormatStageTest methodsFor: 'tests-child'!
"20.1"
testChild3Years
	self assert: (SayableAge formatStage: '2022-06-15' asOf: '2025-06-15') equals: 'Child'
!

"20.2"
testChild4Years
	self assert: (SayableAge formatStage: '2021-06-15' asOf: '2025-06-15') equals: 'Child'
!

"20.3"
testChild6Years
	self assert: (SayableAge formatStage: '2019-06-15' asOf: '2025-06-15') equals: 'Child'
!

"20.4"
testChild9Years
	self assert: (SayableAge formatStage: '2016-06-15' asOf: '2025-06-15') equals: 'Child'
!

"20.5"
testChild12y11m
	self assert: (SayableAge formatStage: '2013-06-15' asOf: '2026-05-15') equals: 'Child'
!

"20.6"
testExactly13YearsTeenager
	self assert: (SayableAge formatStage: '2012-06-15' asOf: '2025-06-15') equals: 'Teenager'
! !

!SayableAgeFormatStageTest methodsFor: 'tests-teenager'!
"21.1"
testTeenager13Years
	self assert: (SayableAge formatStage: '2012-06-15' asOf: '2025-06-15') equals: 'Teenager'
!

"21.2"
testTeenager15Years
	self assert: (SayableAge formatStage: '2010-06-15' asOf: '2025-06-15') equals: 'Teenager'
!

"21.3"
testTeenager17y11m
	self assert: (SayableAge formatStage: '2008-06-15' asOf: '2026-05-15') equals: 'Teenager'
!

"21.4"
testExactly18YearsAdult
	self assert: (SayableAge formatStage: '2007-06-15' asOf: '2025-06-15') equals: 'Adult'
! !

!SayableAgeFormatStageTest methodsFor: 'tests-adult'!
"22.1"
testAdult18Years
	self assert: (SayableAge formatStage: '2007-06-15' asOf: '2025-06-15') equals: 'Adult'
!

"22.2"
testAdult25Years
	self assert: (SayableAge formatStage: '2000-06-15' asOf: '2025-06-15') equals: 'Adult'
!

"22.3"
testAdult45Years
	self assert: (SayableAge formatStage: '1980-01-01' asOf: '2025-06-15') equals: 'Adult'
! !

"================================================================"
"Formatter class tests"
"================================================================"

TestCase subclass: #SayableAgeFormatterTest
	instanceVariableNames: ''
	classVariableNames: ''
	package: 'SayableAge-Tests'!

!SayableAgeFormatterTest methodsFor: 'tests-english'!
"24.1, 24.2, 24.3, 24.4, 24.5, 24.6, 24.7"
testEnglishFormatAge
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'en').
	self assert: (pt formatAge: '2025-06-15' asOf: '2025-06-15') equals: 'Newborn'.
	self assert: (pt formatAge: '2025-06-12' asOf: '2025-06-15') equals: '3 days'.
	self assert: (pt formatAge: '2025-06-07' asOf: '2025-06-15') equals: '1 week, 1 day'.
	self assert: (pt formatAge: '2025-01-15' asOf: '2025-07-15') equals: '6 months'.
	self assert: (pt formatAge: '2023-06-15' asOf: '2025-07-15') equals: '2 years, 1 month'.
	self assert: (pt formatAge: '2022-06-15' asOf: '2025-12-15') equals: '3½ years'.
	self assert: (pt formatAge: '2018-06-15' asOf: '2025-06-15') equals: '7 years'.
!

"24.8, 24.9, 24.10, 24.11, 24.12, 24.13"
testEnglishFormatStage
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'en').
	self assert: (pt formatStage: '2025-06-15' asOf: '2025-06-15') equals: 'Newborn'.
	self assert: (pt formatStage: '2025-01-15' asOf: '2025-06-15') equals: 'Infant'.
	self assert: (pt formatStage: '2024-06-15' asOf: '2025-06-15') equals: 'Toddler'.
	self assert: (pt formatStage: '2022-06-15' asOf: '2025-06-15') equals: 'Child'.
	self assert: (pt formatStage: '2012-06-15' asOf: '2025-06-15') equals: 'Teenager'.
	self assert: (pt formatStage: '2007-06-15' asOf: '2025-06-15') equals: 'Adult'.
!

"24.14, 24.15"
testNullHandling
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'en').
	self assert: (pt formatAge: nil asOf: '2025-06-15') isNil.
	self assert: (pt formatStage: nil asOf: '2025-06-15') isNil.
	self assert: (pt formatAge: '' asOf: '2025-06-15') isNil.
! !

!SayableAgeFormatterTest methodsFor: 'tests-spanish'!
"25.1 through 25.20"
testSpanishLocale
	| es pt |
	es := SayableAgeLocale new.
	es code: 'es-test'.
	es plural: [ :n | n = 1 ifTrue: [ #one ] ifFalse: [ #other ] ].
	es units: (Dictionary newFromPairs: {
		'day'. (Dictionary newFromPairs: { #one. '{n} día'. #other. '{n} días' }).
		'week'. (Dictionary newFromPairs: { #one. '{n} semana'. #other. '{n} semanas' }).
		'month'. (Dictionary newFromPairs: { #one. '{n} mes'. #other. '{n} meses' }).
		'year'. (Dictionary newFromPairs: { #one. '{n} año'. #other. '{n} años' }).
	}).
	es half: '{0} y medio'.
	es delimiter: ', '.
	es justBorn: 'Recién nacido'.
	es stages: (Dictionary newFromPairs: {
		#newborn. 'Recién nacido'. #infant. 'Bebé'.
		#toddler. 'Niño pequeño'. #child. 'Niño'.
		#teenager. 'Adolescente'. #adult. 'Adulto'.
	}).

	pt := SayableAge withLocale: es.
	self assert: (pt formatAge: '2025-06-15' asOf: '2025-06-15') equals: 'Recién nacido'.
	self assert: (pt formatAge: '2025-06-14' asOf: '2025-06-15') equals: '1 día'.
	self assert: (pt formatAge: '2025-06-12' asOf: '2025-06-15') equals: '3 días'.
	self assert: (pt formatAge: '2025-06-08' asOf: '2025-06-15') equals: '1 semana'.
	self assert: (pt formatAge: '2025-06-07' asOf: '2025-06-15') equals: '1 semana, 1 día'.
	self assert: (pt formatAge: '2025-05-26' asOf: '2025-06-15') equals: '2 semanas, 6 días'.
	self assert: (pt formatAge: '2025-01-15' asOf: '2025-07-15') equals: '6 meses'.
	self assert: (pt formatAge: '2023-06-15' asOf: '2025-07-15') equals: '2 años, 1 mes'.
	self assert: (pt formatAge: '2023-06-15' asOf: '2025-12-15') equals: '2 años, 6 meses'.
	self assert: (pt formatAge: '2022-06-15' asOf: '2025-12-15') equals: '3 años y medio'.
	self assert: (pt formatAge: '2022-06-15' asOf: '2025-06-15') equals: '3 años'.
	self assert: (pt formatAge: '2018-06-15' asOf: '2025-06-15') equals: '7 años'.
	self assert: (pt formatStage: '2025-06-15' asOf: '2025-06-15') equals: 'Recién nacido'.
	self assert: (pt formatStage: '2025-01-15' asOf: '2025-06-15') equals: 'Bebé'.
	self assert: (pt formatStage: '2024-06-15' asOf: '2025-06-15') equals: 'Niño pequeño'.
	self assert: (pt formatStage: '2022-06-15' asOf: '2025-06-15') equals: 'Niño'.
	self assert: (pt formatStage: '2012-06-15' asOf: '2025-06-15') equals: 'Adolescente'.
	self assert: (pt formatStage: '2007-06-15' asOf: '2025-06-15') equals: 'Adulto'.
	self assert: (pt formatAge: nil asOf: '2025-06-15') isNil.
	self assert: (pt formatStage: nil asOf: '2025-06-15') isNil.
! !

!SayableAgeFormatterTest methodsFor: 'tests-compactness'!
"26.1 through 26.9"
testCompactnessShort
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'en') compactness: #short.
	self assert: (pt formatAge: '2025-06-12' asOf: '2025-06-15') equals: '3 d'.
	self assert: (pt formatAge: '2025-06-08' asOf: '2025-06-15') equals: '1 wk'.
	self assert: (pt formatAge: '2025-06-07' asOf: '2025-06-15') equals: '1 wk, 1 d'.
	self assert: (pt formatAge: '2025-01-15' asOf: '2025-07-15') equals: '6 mo'.
	self assert: (pt formatAge: '2023-06-15' asOf: '2025-07-15') equals: '2 yr, 1 mo'.
	self assert: (pt formatAge: '2022-06-15' asOf: '2025-12-15') equals: '3½ yr'.
	self assert: (pt formatAge: '2018-06-15' asOf: '2025-06-15') equals: '7 yr'.
	self assert: (pt formatAge: '2025-06-15' asOf: '2025-06-15') equals: 'Newborn'.
	self assert: (pt formatStage: '2025-01-15' asOf: '2025-06-15') equals: 'Infant'.
!

"27.1 through 27.8"
testCompactnessCompact
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'en') compactness: #compact.
	self assert: (pt formatAge: '2025-06-12' asOf: '2025-06-15') equals: '3d'.
	self assert: (pt formatAge: '2025-06-08' asOf: '2025-06-15') equals: '1w'.
	self assert: (pt formatAge: '2025-06-07' asOf: '2025-06-15') equals: '1w1d'.
	self assert: (pt formatAge: '2025-01-15' asOf: '2025-07-15') equals: '6m'.
	self assert: (pt formatAge: '2023-06-15' asOf: '2025-07-15') equals: '2y1m'.
	self assert: (pt formatAge: '2022-06-15' asOf: '2025-12-15') equals: '3½y'.
	self assert: (pt formatAge: '2018-06-15' asOf: '2025-06-15') equals: '7y'.
	self assert: (pt formatAge: '2025-06-15' asOf: '2025-06-15') equals: 'Newborn'.
! !

!SayableAgeFormatterTest methodsFor: 'tests-gender'!
testEnglishStageIgnoresGender
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'en').
	self assert: (pt formatStage: '2025-06-15' asOf: '2025-06-15' gender: 'm') equals: 'Newborn'.
	self assert: (pt formatStage: '2025-06-15' asOf: '2025-06-15' gender: 'f') equals: 'Newborn'.
	self assert: (pt formatStage: '2025-06-15' asOf: '2025-06-15' gender: nil) equals: 'Newborn'.
	self assert: (pt formatStage: '2007-06-15' asOf: '2025-06-15' gender: 'f') equals: 'Adult'.
!

testSpanishGenderedStages
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'es').
	self assert: (pt formatStage: '2025-06-15' asOf: '2025-06-15') equals: 'Recién nacido'.
	self assert: (pt formatStage: '2025-06-15' asOf: '2025-06-15' gender: 'm') equals: 'Recién nacido'.
	self assert: (pt formatStage: '2025-06-15' asOf: '2025-06-15' gender: 'f') equals: 'Recién nacida'.
	self assert: (pt formatStage: '2025-01-15' asOf: '2025-06-15' gender: 'f') equals: 'Bebé'.
	self assert: (pt formatStage: '2025-01-15' asOf: '2025-06-15' gender: 'm') equals: 'Bebé'.
	self assert: (pt formatStage: '2024-06-15' asOf: '2025-06-15' gender: 'm') equals: 'Niño pequeño'.
	self assert: (pt formatStage: '2024-06-15' asOf: '2025-06-15' gender: 'f') equals: 'Niña pequeña'.
	self assert: (pt formatStage: '2022-06-15' asOf: '2025-06-15' gender: 'm') equals: 'Niño'.
	self assert: (pt formatStage: '2022-06-15' asOf: '2025-06-15' gender: 'f') equals: 'Niña'.
	self assert: (pt formatStage: '2012-06-15' asOf: '2025-06-15' gender: 'f') equals: 'Adolescente'.
	self assert: (pt formatStage: '2007-06-15' asOf: '2025-06-15' gender: 'm') equals: 'Adulto'.
	self assert: (pt formatStage: '2007-06-15' asOf: '2025-06-15' gender: 'f') equals: 'Adulta'.
!

testArabicAllGenderedStages
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'ar').
	self assert: (pt formatStage: '2025-06-15' asOf: '2025-06-15' gender: 'm') equals: 'حديث الولادة'.
	self assert: (pt formatStage: '2025-06-15' asOf: '2025-06-15' gender: 'f') equals: 'حديثة الولادة'.
	self assert: (pt formatStage: '2025-01-15' asOf: '2025-06-15' gender: 'm') equals: 'رضيع'.
	self assert: (pt formatStage: '2025-01-15' asOf: '2025-06-15' gender: 'f') equals: 'رضيعة'.
	self assert: (pt formatStage: '2024-06-15' asOf: '2025-06-15' gender: 'm') equals: 'طفل صغير'.
	self assert: (pt formatStage: '2024-06-15' asOf: '2025-06-15' gender: 'f') equals: 'طفلة صغيرة'.
	self assert: (pt formatStage: '2022-06-15' asOf: '2025-06-15' gender: 'm') equals: 'طفل'.
	self assert: (pt formatStage: '2022-06-15' asOf: '2025-06-15' gender: 'f') equals: 'طفلة'.
	self assert: (pt formatStage: '2012-06-15' asOf: '2025-06-15' gender: 'm') equals: 'مراهق'.
	self assert: (pt formatStage: '2012-06-15' asOf: '2025-06-15' gender: 'f') equals: 'مراهقة'.
	self assert: (pt formatStage: '2007-06-15' asOf: '2025-06-15' gender: 'm') equals: 'بالغ'.
	self assert: (pt formatStage: '2007-06-15' asOf: '2025-06-15' gender: 'f') equals: 'بالغة'.
!

testGermanAdultGendered
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'de').
	self assert: (pt formatStage: '2007-06-15' asOf: '2025-06-15' gender: 'm') equals: 'Erwachsener'.
	self assert: (pt formatStage: '2007-06-15' asOf: '2025-06-15' gender: 'f') equals: 'Erwachsene'.
	self assert: (pt formatStage: '2007-06-15' asOf: '2025-06-15') equals: 'Erwachsener'.
!

testFrenchGenderedStages
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'fr').
	self assert: (pt formatStage: '2025-06-15' asOf: '2025-06-15' gender: 'm') equals: 'Nouveau-né'.
	self assert: (pt formatStage: '2025-06-15' asOf: '2025-06-15' gender: 'f') equals: 'Nouveau-née'.
	self assert: (pt formatStage: '2024-06-15' asOf: '2025-06-15') equals: 'Tout-petit'.
	self assert: (pt formatStage: '2012-06-15' asOf: '2025-06-15' gender: 'm') equals: 'Adolescent'.
	self assert: (pt formatStage: '2012-06-15' asOf: '2025-06-15' gender: 'f') equals: 'Adolescente'.
	self assert: (pt formatStage: '2007-06-15' asOf: '2025-06-15' gender: 'f') equals: 'Adulte'.
!

testModuleLevelFormatStageWithGender
	self assert: (SayableAge formatStage: '2007-06-15' asOf: '2025-06-15' gender: 'f') equals: 'Adult'.
	self assert: (SayableAge formatStage: '2007-06-15' asOf: '2025-06-15' gender: 'm') equals: 'Adult'.
!

testNilHandlingWithGender
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'es').
	self assert: (pt formatStage: nil asOf: '2025-06-15' gender: 'f') isNil.
	self assert: (pt formatStage: '' asOf: '2025-06-15' gender: 'm') isNil.
! !

!SayableAgeFormatterTest methodsFor: 'tests-locale-specific'!
"29.1"
test29_1HeJustBorn
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'he').
	self assert: (pt formatAge: '2025-06-15' asOf: '2025-06-15') equals: 'רק נולד'
!

"29.2"
test29_2HeOneDay
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'he').
	self assert: (pt formatAge: '2025-06-14' asOf: '2025-06-15') equals: 'יום'
!

"29.3"
test29_3HeThreeDays
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'he').
	self assert: (pt formatAge: '2025-06-12' asOf: '2025-06-15') equals: '3 ימים'
!

"29.4"
test29_4HeTwoWeeksDual
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'he').
	self assert: (pt formatAge: '2025-06-01' asOf: '2025-06-15') equals: 'שבועיים'
!

"29.5"
test29_5HeThreeWeeks
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'he').
	self assert: (pt formatAge: '2025-05-25' asOf: '2025-06-15') equals: '3 שבועות'
!

"29.6"
test29_6HeSixMonths
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'he').
	self assert: (pt formatAge: '2025-01-15' asOf: '2025-07-15') equals: '6 חודשים'
!

"29.7"
test29_7HeThreeMonths
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'he').
	self assert: (pt formatAge: '2025-03-15' asOf: '2025-06-15') equals: '3 חודשים'
!

"29.8"
test29_8HeTwoYearsDualOneMonth
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'he').
	self assert: (pt formatAge: '2023-06-15' asOf: '2025-07-15') equals: 'שנתיים, חודש'
!

"29.9"
test29_9HeHalfYears
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'he').
	self assert: (pt formatAge: '2022-06-15' asOf: '2025-12-15') equals: '3 שנים וחצי'
!

"29.10"
test29_10HeSevenYears
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'he').
	self assert: (pt formatAge: '2018-06-15' asOf: '2025-06-15') equals: '7 שנים'
!

"29.11"
test29_11HeStageNewbornMasculine
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'he').
	self assert: (pt formatStage: '2025-06-15' asOf: '2025-06-15' gender: 'm') equals: 'רק נולד'
!

"29.12"
test29_12HeStageNewbornFeminine
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'he').
	self assert: (pt formatStage: '2025-06-15' asOf: '2025-06-15' gender: 'f') equals: 'רק נולדה'
!

"29.13"
test29_13HeStageAdultMasculine
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'he').
	self assert: (pt formatStage: '2007-06-15' asOf: '2025-06-15' gender: 'm') equals: 'מבוגר'
!

"29.14"
test29_14HeStageAdultFeminine
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'he').
	self assert: (pt formatStage: '2007-06-15' asOf: '2025-06-15' gender: 'f') equals: 'מבוגרת'
!

"29.15"
test29_15MkJustBorn
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'mk').
	self assert: (pt formatAge: '2025-06-15' asOf: '2025-06-15') equals: 'Новороденче'
!

"29.16"
test29_16MkOneDay
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'mk').
	self assert: (pt formatAge: '2025-06-14' asOf: '2025-06-15') equals: '1 ден'
!

"29.17"
test29_17MkThreeDays
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'mk').
	self assert: (pt formatAge: '2025-06-12' asOf: '2025-06-15') equals: '3 дена'
!

"29.18"
test29_18MkSixMonths
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'mk').
	self assert: (pt formatAge: '2025-01-15' asOf: '2025-07-15') equals: '6 месеци'
!

"29.19"
test29_19MkTwoYearsOneMonth
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'mk').
	self assert: (pt formatAge: '2023-06-15' asOf: '2025-07-15') equals: '2 години, 1 месец'
!

"29.20"
test29_20MkHalfYears
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'mk').
	self assert: (pt formatAge: '2022-06-15' asOf: '2025-12-15') equals: '3 години и пол'
!

"29.21"
test29_21MkSevenYears
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'mk').
	self assert: (pt formatAge: '2018-06-15' asOf: '2025-06-15') equals: '7 години'
!

"29.22"
test29_22SwJustBorn
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'sw').
	self assert: (pt formatAge: '2025-06-15' asOf: '2025-06-15') equals: 'Mzaliwa mpya'
!

"29.23"
test29_23SwOneDay
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'sw').
	self assert: (pt formatAge: '2025-06-14' asOf: '2025-06-15') equals: 'siku 1'
!

"29.24"
test29_24SwThreeDays
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'sw').
	self assert: (pt formatAge: '2025-06-12' asOf: '2025-06-15') equals: 'siku 3'
!

"29.25"
test29_25SwSixMonths
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'sw').
	self assert: (pt formatAge: '2025-01-15' asOf: '2025-07-15') equals: 'miezi 6'
!

"29.26"
test29_26SwTwoYearsOneMonth
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'sw').
	self assert: (pt formatAge: '2023-06-15' asOf: '2025-07-15') equals: 'miaka 2, mwezi 1'
!

"29.27"
test29_27SwHalfYears
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'sw').
	self assert: (pt formatAge: '2022-06-15' asOf: '2025-12-15') equals: 'miaka 3 na nusu'
!

"29.28"
test29_28IdJustBorn
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'id').
	self assert: (pt formatAge: '2025-06-15' asOf: '2025-06-15') equals: 'Baru lahir'
!

"29.29"
test29_29IdOneDay
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'id').
	self assert: (pt formatAge: '2025-06-14' asOf: '2025-06-15') equals: '1 hari'
!

"29.30"
test29_30IdThreeDays
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'id').
	self assert: (pt formatAge: '2025-06-12' asOf: '2025-06-15') equals: '3 hari'
!

"29.31"
test29_31IdSixMonths
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'id').
	self assert: (pt formatAge: '2025-01-15' asOf: '2025-07-15') equals: '6 bulan'
!

"29.32"
test29_32IdHalfYears
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'id').
	self assert: (pt formatAge: '2022-06-15' asOf: '2025-12-15') equals: '3 setengah tahun'
!

"29.33"
test29_33IdSevenYears
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'id').
	self assert: (pt formatAge: '2018-06-15' asOf: '2025-06-15') equals: '7 tahun'
!

"29.34"
test29_34AmJustBorn
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'am').
	self assert: (pt formatAge: '2025-06-15' asOf: '2025-06-15') equals: 'አዲስ የተወለደ'
!

"29.35"
test29_35AmOneDay
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'am').
	self assert: (pt formatAge: '2025-06-14' asOf: '2025-06-15') equals: '1 ቀን'
!

"29.36"
test29_36AmThreeDays
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'am').
	self assert: (pt formatAge: '2025-06-12' asOf: '2025-06-15') equals: '3 ቀናት'
!

"29.37"
test29_37AmOneWeekOneDayEthiopic
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'am').
	self assert: (pt formatAge: '2025-06-07' asOf: '2025-06-15') equals: '1 ሳምንት፣ 1 ቀን'
!

"29.38"
test29_38AmSixMonths
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'am').
	self assert: (pt formatAge: '2025-01-15' asOf: '2025-07-15') equals: '6 ወራት'
!

"29.39"
test29_39AmHalfYears
	| pt |
	pt := SayableAge withLocale: (SayableAgeLocales get: 'am').
	self assert: (pt formatAge: '2022-06-15' asOf: '2025-12-15') equals: '3 ዓመታት ተኩል'
! !

!SayableAgeFormatterTest methodsFor: 'tests-locale-lookup'!
"30.1"
test30_1GetLocaleEn
	| loc |
	loc := SayableAgeLocales get: 'en'.
	self deny: loc isNil.
	self assert: loc code equals: 'en'.
!

"30.2"
test30_2GetLocaleFr
	| loc |
	loc := SayableAgeLocales get: 'fr'.
	self deny: loc isNil.
	self assert: loc code equals: 'fr'.
!

"30.3"
test30_3GetLocaleUnknown
	self assert: (SayableAgeLocales get: 'xx') isNil
!

"30.4"
test30_4GetLocaleEmpty
	self assert: (SayableAgeLocales get: '') isNil
!

"30.5"
test30_5GetLocaleCaseSensitive
	self assert: (SayableAgeLocales get: 'EN') isNil
! !

!SayableAgeFormatAgeTest methodsFor: 'tests-input-formats-and-regressions'!
"31.1"
test31_188DaysAcrossA28DayFebruary
	| sa |
	sa := SayableAge withLocale: (SayableAgeLocales get: 'en').
	self assert: (sa formatAge: '2016-12-31' asOf: '2017-03-29') equals: '12 weeks, 4 days'
!

"31.2"
test31_290DaysAcrossAYearEndIntoALeapYear
	| sa |
	sa := SayableAge withLocale: (SayableAgeLocales get: 'en').
	self assert: (sa formatAge: '1991-11-27' asOf: '1992-02-25') equals: '12 weeks, 6 days'
!

"31.3"
test31_333DaysAcrossAYearEnd
	| sa |
	sa := SayableAge withLocale: (SayableAgeLocales get: 'en').
	self assert: (sa formatAge: '2020-11-30' asOf: '2021-01-02') equals: '4 weeks, 5 days'
!

"31.4"
test31_4CompactFormOf311
	| sa |
	sa := SayableAge withLocale: (SayableAgeLocales get: 'en') compactness: #compact.
	self assert: (sa formatAge: '2016-12-31' asOf: '2017-03-29') equals: '12w4d'
!

"32.1"
test32_1Polish3IsFew
	| sa |
	sa := SayableAge withLocale: (SayableAgeLocales get: 'pl').
	self assert: (sa formatAge: '2021-06-15' asOf: '2025-01-15') equals: '3 i pół lata'
!

"32.2"
test32_2Polish5IsMany
	| sa |
	sa := SayableAge withLocale: (SayableAgeLocales get: 'pl') compactness: #short.
	self assert: (sa formatAge: '2020-06-15' asOf: '2025-12-15') equals: '5 i pół lat'
!

"32.3"
test32_3Tachelhit6IsFew
	| sa |
	sa := SayableAge withLocale: (SayableAgeLocales get: 'shi').
	self assert: (sa formatAge: '2005-06-08' asOf: '2012-06-07') equals: '6 iseggasen d uzgen'
!

"33.1"
test33_1February30DoesnTExist
	| sa |
	sa := SayableAge withLocale: (SayableAgeLocales get: 'en').
	self assert: (sa formatAge: '2025-02-30' asOf: '2032-06-25') isNil
!

"33.2"
test33_2Month13
	| sa |
	sa := SayableAge withLocale: (SayableAgeLocales get: 'en').
	self assert: (sa formatAge: '2025-13-01' asOf: '2027-01-31') isNil
!

"33.3"
test33_3February29InANonLeapYear
	| sa |
	sa := SayableAge withLocale: (SayableAgeLocales get: 'en').
	self assert: (sa formatAge: '2023-02-29' asOf: '2025-03-01') isNil
!

"33.4"
test33_4Day00
	| sa |
	sa := SayableAge withLocale: (SayableAgeLocales get: 'en').
	self assert: (sa formatAge: '2025-06-00' asOf: '2027-02-25') isNil
!

"33.5"
test33_5UnpaddedMonthAndDay
	| sa |
	sa := SayableAge withLocale: (SayableAgeLocales get: 'en').
	self assert: (sa formatAge: '2025-6-1' asOf: '2027-02-25') isNil
!

"33.6"
test33_6SurroundingWhitespace
	| sa |
	sa := SayableAge withLocale: (SayableAgeLocales get: 'en').
	self assert: (sa formatAge: ' 2025-06-01' asOf: '2027-02-25') isNil
!

"33.7"
test33_7ADatetimeIsNotADate
	| sa |
	sa := SayableAge withLocale: (SayableAgeLocales get: 'en').
	self assert: (sa formatAge: '2025-06-15T10:00:00' asOf: '2027-02-25') isNil
!

"33.8"
test33_8InvalidAsOf
	| sa |
	sa := SayableAge withLocale: (SayableAgeLocales get: 'en').
	self assert: (sa formatAge: '2020-01-01' asOf: '2025-04-31') isNil
!

"33.9"
test33_9FormatStageValidatesToo
	| sa |
	sa := SayableAge withLocale: (SayableAgeLocales get: 'en').
	self assert: (sa formatStage: '2025-02-30' asOf: '2027-09-05') isNil
!

"33.10"
test33_10February29InALeapYearIsValid
	| sa |
	sa := SayableAge withLocale: (SayableAgeLocales get: 'en').
	self assert: (sa formatAge: '2024-02-29' asOf: '2026-03-01') equals: '2 years'
! !
