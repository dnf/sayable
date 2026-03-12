"SayableDuration tests — all canonical test cases from duration/config/tests.json.
Uses SUnit framework. Each test annotated with canonical IDs."

TestCase subclass: #SayableDurationTest
	instanceVariableNames: ''
	classVariableNames: ''
	package: 'SayableDuration-Tests'.

!SayableDurationTest methodsFor: 'tests-null'!
"1.1"
testNullSeconds
	self assert: (SayableDuration formatDuration: nil) isNil
!

"1.2"
testNegativeSeconds
	self assert: (SayableDuration formatDuration: -1) isNil
!

"1.3"
testNullSinceStart
	| sd |
	sd := SayableDuration withLocale: (SayableDurationLocales get: 'en').
	self assert: (sd formatSince: nil asOf: '2025-01-15T10:00:00') isNil
!

"1.4"
testNullUntilTarget
	| sd |
	sd := SayableDuration withLocale: (SayableDurationLocales get: 'en').
	self assert: (sd formatUntil: nil asOf: '2025-01-15T10:00:00') isNil
!

"1.5"
testSinceAsOfBeforeStart
	| sd |
	sd := SayableDuration withLocale: (SayableDurationLocales get: 'en').
	self assert: (sd formatSince: '2025-01-15T10:00:00' asOf: '2025-01-15T09:00:00') isNil
!

"1.6"
testUntilTargetInPast
	| sd |
	sd := SayableDuration withLocale: (SayableDurationLocales get: 'en').
	self assert: (sd formatUntil: '2025-01-15T09:00:00' asOf: '2025-01-15T10:00:00') isNil
! !

!SayableDurationTest methodsFor: 'tests-seconds'!
"2.1"
testZeroSeconds
	self assert: (SayableDuration formatDuration: 0) equals: 'just now'
!

"2.2"
testOneSecond
	self assert: (SayableDuration formatDuration: 1) equals: '1 second'
!

"2.3"
test45Seconds
	self assert: (SayableDuration formatDuration: 45) equals: '45 seconds'
!

"2.4"
test59Seconds
	self assert: (SayableDuration formatDuration: 59) equals: '59 seconds'
! !

!SayableDurationTest methodsFor: 'tests-minutes-seconds'!
"3.1"
test1Minute
	self assert: (SayableDuration formatDuration: 60) equals: '1 minute'
!

"3.2"
test1Min30Sec
	self assert: (SayableDuration formatDuration: 90) equals: '1 minute, 30 seconds'
!

"3.3"
test4Minutes
	self assert: (SayableDuration formatDuration: 240) equals: '4 minutes'
!

"3.4"
test4Min30Sec
	self assert: (SayableDuration formatDuration: 270) equals: '4 minutes, 30 seconds'
! !

!SayableDurationTest methodsFor: 'tests-minutes'!
"4.1"
test5Minutes
	self assert: (SayableDuration formatDuration: 300) equals: '5 minutes'
!

"4.2"
test25Minutes
	self assert: (SayableDuration formatDuration: 1500) equals: '25 minutes'
!

"4.3"
test59Minutes
	self assert: (SayableDuration formatDuration: 3540) equals: '59 minutes'
! !

!SayableDurationTest methodsFor: 'tests-hours-minutes'!
"5.1"
test1Hour
	self assert: (SayableDuration formatDuration: 3600) equals: '1 hour'
!

"5.2"
test1HalfHours
	self assert: (SayableDuration formatDuration: 5400) equals: '1½ hours'
!

"5.3"
test2Hours15Min
	self assert: (SayableDuration formatDuration: 8100) equals: '2 hours, 15 minutes'
!

"5.4"
test5Hours
	self assert: (SayableDuration formatDuration: 18000) equals: '5 hours'
! !

!SayableDurationTest methodsFor: 'tests-hours'!
"6.1"
test8Hours
	self assert: (SayableDuration formatDuration: 28800) equals: '8 hours'
!

"6.2"
test23Hours
	self assert: (SayableDuration formatDuration: 82800) equals: '23 hours'
! !

!SayableDurationTest methodsFor: 'tests-days'!
"7.1"
test1Day
	self assert: (SayableDuration formatDuration: 86400) equals: '1 day'
!

"7.2"
test1Day3Hours
	self assert: (SayableDuration formatDuration: 97200) equals: '1 day, 3 hours'
!

"7.3"
test1HalfDays
	self assert: (SayableDuration formatDuration: 129600) equals: '1½ days'
!

"7.4"
test5Days
	self assert: (SayableDuration formatDuration: 432000) equals: '5 days'
!

"7.5"
test2Days
	self assert: (SayableDuration formatDuration: 172800) equals: '2 days'
! !

!SayableDurationTest methodsFor: 'tests-weeks'!
"8.1"
test1Week
	self assert: (SayableDuration formatDuration: 604800) equals: '1 week'
!

"8.2"
test2Weeks1Day
	self assert: (SayableDuration formatDuration: 1296000) equals: '2 weeks, 1 day'
!

"8.3"
test4Weeks
	self assert: (SayableDuration formatDuration: 2419200) equals: '4 weeks'
! !

!SayableDurationTest methodsFor: 'tests-months-years'!
"9.1"
test1Month
	self assert: (SayableDuration formatDuration: 2678400) equals: '1 month'
!

"9.2"
test3Months
	self assert: (SayableDuration formatDuration: 7884000) equals: '3 months'
!

"9.3"
test1Year
	self assert: (SayableDuration formatDuration: 31536000) equals: '1 year'
!

"9.4"
test1Year3Months
	self assert: (SayableDuration formatDuration: 39420000) equals: '1 year, 3 months'
! !

!SayableDurationTest methodsFor: 'tests-iso-timestamps'!
"10.1"
testIso1HalfHours
	| sd |
	sd := SayableDuration withLocale: (SayableDurationLocales get: 'en').
	self assert: (sd formatDuration: '2025-01-15T10:00:00' end: '2025-01-15T11:30:00') equals: '1½ hours'
!

"10.2"
testIso45Minutes
	| sd |
	sd := SayableDuration withLocale: (SayableDurationLocales get: 'en').
	self assert: (sd formatDuration: '2025-01-15T10:00:00' end: '2025-01-15T10:45:00') equals: '45 minutes'
! !

!SayableDurationTest methodsFor: 'tests-since'!
"11.1"
testSinceJustNow
	| sd |
	sd := SayableDuration withLocale: (SayableDurationLocales get: 'en').
	self assert: (sd formatSince: '2025-01-15T10:00:00' asOf: '2025-01-15T10:00:00') equals: 'just now'
!

"11.2"
testSince30Seconds
	| sd |
	sd := SayableDuration withLocale: (SayableDurationLocales get: 'en').
	self assert: (sd formatSince: '2025-01-15T10:00:00' asOf: '2025-01-15T10:00:30') equals: '30 seconds ago'
!

"11.3"
testSince45Minutes
	| sd |
	sd := SayableDuration withLocale: (SayableDurationLocales get: 'en').
	self assert: (sd formatSince: '2025-01-15T10:00:00' asOf: '2025-01-15T10:45:00') equals: '45 minutes ago'
!

"11.4"
testSince3Hours
	| sd |
	sd := SayableDuration withLocale: (SayableDurationLocales get: 'en').
	self assert: (sd formatSince: '2025-01-15T10:00:00' asOf: '2025-01-15T13:00:00') equals: '3 hours ago'
! !

!SayableDurationTest methodsFor: 'tests-until'!
"12.1"
testUntilJustNow
	| sd |
	sd := SayableDuration withLocale: (SayableDurationLocales get: 'en').
	self assert: (sd formatUntil: '2025-01-15T10:00:00' asOf: '2025-01-15T10:00:00') equals: 'just now'
!

"12.2"
testUntil20Minutes
	| sd |
	sd := SayableDuration withLocale: (SayableDurationLocales get: 'en').
	self assert: (sd formatUntil: '2025-01-15T10:20:00' asOf: '2025-01-15T10:00:00') equals: 'in 20 minutes'
!

"12.3"
testUntil3Hours
	| sd |
	sd := SayableDuration withLocale: (SayableDurationLocales get: 'en').
	self assert: (sd formatUntil: '2025-01-15T13:00:00' asOf: '2025-01-15T10:00:00') equals: 'in 3 hours'
! !

!SayableDurationTest methodsFor: 'tests-locale-german'!
"13.1"
testGerman1Hour
	| sd |
	sd := SayableDuration withLocale: (SayableDurationLocales get: 'de').
	self assert: (sd formatDuration: 3600) equals: '1 Stunde'
!

"13.2"
testGermanSince5Minutes
	| sd |
	sd := SayableDuration withLocale: (SayableDurationLocales get: 'de').
	self assert: (sd formatSince: '2025-01-15T10:00:00' asOf: '2025-01-15T10:05:00') equals: 'vor 5 Minuten'
! !

!SayableDurationTest methodsFor: 'tests-locale-french'!
"14.1"
testFrench2Hours
	| sd |
	sd := SayableDuration withLocale: (SayableDurationLocales get: 'fr').
	self assert: (sd formatDuration: 7200) equals: '2 heures'
! !

!SayableDurationTest methodsFor: 'tests-locale-japanese'!
"15.1"
testJapanese2Minutes
	| sd |
	sd := SayableDuration withLocale: (SayableDurationLocales get: 'ja').
	self assert: (sd formatDuration: 120) equals: '2分'
!

"15.2"
testJapaneseSince1Hour
	| sd |
	sd := SayableDuration withLocale: (SayableDurationLocales get: 'ja').
	self assert: (sd formatSince: '2025-01-15T10:00:00' asOf: '2025-01-15T11:00:00') equals: '1時間前'
! !

!SayableDurationTest methodsFor: 'tests-short'!
"16.1"
testShort1Hour
	| sd |
	sd := SayableDuration withLocale: (SayableDurationLocales get: 'en') compactness: #short.
	self assert: (sd formatDuration: 3600) equals: '1h'
!

"16.2"
testShort1Min30Sec
	| sd |
	sd := SayableDuration withLocale: (SayableDurationLocales get: 'en') compactness: #short.
	self assert: (sd formatDuration: 90) equals: '1m, 30s'
! !

!SayableDurationTest methodsFor: 'tests-compact'!
"17.1"
testCompact1Hour
	| sd |
	sd := SayableDuration withLocale: (SayableDurationLocales get: 'en') compactness: #compact.
	self assert: (sd formatDuration: 3600) equals: '1h'
!

"17.2"
testCompact1Min30Sec
	| sd |
	sd := SayableDuration withLocale: (SayableDurationLocales get: 'en') compactness: #compact.
	self assert: (sd formatDuration: 90) equals: '1m30s'
! !
