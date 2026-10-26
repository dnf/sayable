"SayableTime tests — all canonical test cases from time/config/tests.json.
Uses SUnit framework. Each test annotated with canonical IDs."

TestCase subclass: #SayableTimeTest
	instanceVariableNames: ''
	classVariableNames: ''
	package: 'SayableTime-Tests'!

!SayableTimeTest methodsFor: 'tests-null'!
"1.1"
testNilInput
	self assert: (SayableTime formatTime: nil) isNil
!

"1.2"
testEmptyInput
	self assert: (SayableTime formatTime: '') isNil
!

"1.3"
testInvalidInput
	self assert: (SayableTime formatTime: 'invalid') isNil
!

"1.4"
testInvalidHour
	self assert: (SayableTime formatTime: '25:00') isNil
! !

!SayableTimeTest methodsFor: 'tests-clock-normal'!
"2.1"
testMidnight
	| st |
	st := SayableTime withLocale: (SayableTimeLocales get: 'en').
	self assert: (st formatTime: '00:00') equals: 'midnight'
!

"2.2"
testNoon
	| st |
	st := SayableTime withLocale: (SayableTimeLocales get: 'en').
	self assert: (st formatTime: '12:00') equals: 'noon'
!

"2.3"
testThreeOClock
	| st |
	st := SayableTime withLocale: (SayableTimeLocales get: 'en').
	self assert: (st formatTime: '15:00') equals: 'three o''clock'
!

"2.4"
testQuarterPastTwo
	| st |
	st := SayableTime withLocale: (SayableTimeLocales get: 'en').
	self assert: (st formatTime: '14:15') equals: 'a quarter past two'
!

"2.5"
testHalfPastNine
	| st |
	st := SayableTime withLocale: (SayableTimeLocales get: 'en').
	self assert: (st formatTime: '09:30') equals: 'half past nine'
!

"2.6"
testQuarterToEleven
	| st |
	st := SayableTime withLocale: (SayableTimeLocales get: 'en').
	self assert: (st formatTime: '10:45') equals: 'a quarter to eleven'
!

"2.7"
testFivePastEight
	| st |
	st := SayableTime withLocale: (SayableTimeLocales get: 'en').
	self assert: (st formatTime: '08:05') equals: 'five past eight'
!

"2.8"
testFiveToFive
	| st |
	st := SayableTime withLocale: (SayableTimeLocales get: 'en').
	self assert: (st formatTime: '16:55') equals: 'five to five'
!

"2.9"
test2358RoundsToMidnight
	| st |
	st := SayableTime withLocale: (SayableTimeLocales get: 'en').
	self assert: (st formatTime: '23:58') equals: 'midnight'
!

"2.10"
test722RoundsTo720
	| st |
	st := SayableTime withLocale: (SayableTimeLocales get: 'en').
	self assert: (st formatTime: '07:22') equals: 'twenty past seven'
!

"2.11"
testIsoDatetimeInput
	| st |
	st := SayableTime withLocale: (SayableTimeLocales get: 'en').
	self assert: (st formatTime: '2025-01-15T14:15:00') equals: 'a quarter past two'
! !

!SayableTimeTest methodsFor: 'tests-clock-short'!
"3.1"
testShort2_15PM
	| st |
	st := SayableTime withLocale: (SayableTimeLocales get: 'en') compactness: #short.
	self assert: (st formatTime: '14:15') equals: '2:15 PM'
!

"3.2"
testShort9_30AM
	| st |
	st := SayableTime withLocale: (SayableTimeLocales get: 'en') compactness: #short.
	self assert: (st formatTime: '09:30') equals: '9:30 AM'
!

"3.3"
testShort12_00AM
	| st |
	st := SayableTime withLocale: (SayableTimeLocales get: 'en') compactness: #short.
	self assert: (st formatTime: '00:00') equals: '12:00 AM'
!

"3.4"
testShort12_00PM
	| st |
	st := SayableTime withLocale: (SayableTimeLocales get: 'en') compactness: #short.
	self assert: (st formatTime: '12:00') equals: '12:00 PM'
! !

!SayableTimeTest methodsFor: 'tests-clock-compact'!
"4.1"
testCompact2_15p
	| st |
	st := SayableTime withLocale: (SayableTimeLocales get: 'en') compactness: #compact.
	self assert: (st formatTime: '14:15') equals: '2:15p'
!

"4.2"
testCompact9_30a
	| st |
	st := SayableTime withLocale: (SayableTimeLocales get: 'en') compactness: #compact.
	self assert: (st formatTime: '09:30') equals: '9:30a'
! !

!SayableTimeTest methodsFor: 'tests-locale-german'!
"5.1"
testGermanHalbVier
	| st |
	st := SayableTime withLocale: (SayableTimeLocales get: 'de').
	self assert: (st formatTime: '15:30') equals: 'halb vier'
! !

!SayableTimeTest methodsFor: 'tests-locale-french'!
"6.1"
testFrenchQuarterPast3
	| st |
	st := SayableTime withLocale: (SayableTimeLocales get: 'fr').
	self assert: (st formatTime: '15:15') equals: 'trois heures et quart'
! !

!SayableTimeTest methodsFor: 'tests-locale-japanese'!
"7.1"
testJapanese330
	| st |
	st := SayableTime withLocale: (SayableTimeLocales get: 'ja').
	self assert: (st formatTime: '15:30') equals: '三時半'
! !

!SayableTimeTest methodsFor: 'tests-locale-finnish'!
"8.1"
testFinnishDotSeparator
	| st |
	st := SayableTime withLocale: (SayableTimeLocales get: 'fi') compactness: #short.
	self assert: (st formatTime: '14:15') equals: '14.15'
!

"8.2"
testFinnishMidnight24h
	| st |
	st := SayableTime withLocale: (SayableTimeLocales get: 'fi') compactness: #short.
	self assert: (st formatTime: '00:00') equals: '0.00'
! !

!SayableTimeTest methodsFor: 'tests-input-formats-and-regressions'!
"9.1"
test9_1DigitalModesKeepTheExactMinute
	| st |
	st := SayableTime withLocale: (SayableTimeLocales get: 'en') compactness: #short.
	self assert: (st formatTime: '18:01') equals: '6:01 PM'
!

"9.2"
test9_2DigitalModesKeepTheExactMinute
	| st |
	st := SayableTime withLocale: (SayableTimeLocales get: 'en') compactness: #compact.
	self assert: (st formatTime: '19:05') equals: '7:05p'
!

"10.1"
test10_1OneDigitHour
	| st |
	st := SayableTime withLocale: (SayableTimeLocales get: 'en').
	self assert: (st formatTime: '9:30') equals: 'half past nine'
!

"10.2"
test10_2TwoDigitHour
	| st |
	st := SayableTime withLocale: (SayableTimeLocales get: 'en').
	self assert: (st formatTime: '09:30') equals: 'half past nine'
!

"10.3"
test10_3LeadingWhitespace
	| st |
	st := SayableTime withLocale: (SayableTimeLocales get: 'en').
	self assert: (st formatTime: ' 9:30') isNil
!

"10.4"
test10_4TrailingWhitespace
	| st |
	st := SayableTime withLocale: (SayableTimeLocales get: 'en').
	self assert: (st formatTime: '9:30 ') isNil
!

"10.5"
test10_5MinutesNeedTwoDigits
	| st |
	st := SayableTime withLocale: (SayableTimeLocales get: 'en').
	self assert: (st formatTime: '9:5') isNil
!

"10.6"
test10_6HourOutOfRange
	| st |
	st := SayableTime withLocale: (SayableTimeLocales get: 'en').
	self assert: (st formatTime: '24:00') isNil
!

"10.7"
test10_7SecondsAreAllowedAndIgnored
	| st |
	st := SayableTime withLocale: (SayableTimeLocales get: 'en').
	self assert: (st formatTime: '14:15:30') equals: 'a quarter past two'
!

"10.8"
test10_8ISODatetimeWithZoneSuffixIgnored
	| st |
	st := SayableTime withLocale: (SayableTimeLocales get: 'en').
	self assert: (st formatTime: '2025-01-15T14:15:00Z') equals: 'a quarter past two'
!

"10.9"
test10_9ISODatetimeWithAnImpossibleDate
	| st |
	st := SayableTime withLocale: (SayableTimeLocales get: 'en').
	self assert: (st formatTime: '2025-02-30T14:15:00') isNil
! !
