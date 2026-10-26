"SayableAge — human-friendly age formatter."

Object subclass: #SayableAge
	instanceVariableNames: 'locale dayUnit weekUnit monthUnit yearUnit half delimiter justBorn'
	classVariableNames: 'Version'
	package: 'SayableAge'!

SayableAge class instanceVariableNames: ''!

!SayableAge class methodsFor: 'class initialization'!
initialize
	Version := '0.5.0'
! !

SayableAge initialize!

!SayableAge class methodsFor: 'accessing'!
version
	^ Version
! !

!SayableAge class methodsFor: 'instance creation'!
withLocale: aLocale
	^ self withLocale: aLocale compactness: #normal
!

withLocale: aLocale compactness: aSymbol
	^ self new initWithLocale: aLocale compactness: aSymbol
! !

!SayableAge class methodsFor: 'convenience'!
formatAge: dateOfBirth
	^ self formatAge: dateOfBirth asOf: nil
!

formatAge: dateOfBirth asOf: asOfDate
	| formatter |
	formatter := self withLocale: (SayableAgeLocales get: 'en').
	^ formatter formatAge: dateOfBirth asOf: asOfDate
!

formatStage: dateOfBirth
	^ self formatStage: dateOfBirth asOf: nil gender: nil
!

formatStage: dateOfBirth asOf: asOfDate
	^ self formatStage: dateOfBirth asOf: asOfDate gender: nil
!

formatStage: dateOfBirth asOf: asOfDate gender: gender
	| formatter |
	formatter := self withLocale: (SayableAgeLocales get: 'en').
	^ formatter formatStage: dateOfBirth asOf: asOfDate gender: gender
! !

!SayableAge methodsFor: 'initialization'!
initWithLocale: aLocale compactness: aSymbol
	| ovr |
	locale := aLocale.
	ovr := nil.
	aSymbol = #short ifTrue: [ ovr := aLocale short ].
	aSymbol = #compact ifTrue: [ ovr := aLocale compact ].

	dayUnit := self resolveOverrideUnit: ovr key: 'day' from: aLocale.
	weekUnit := self resolveOverrideUnit: ovr key: 'week' from: aLocale.
	monthUnit := self resolveOverrideUnit: ovr key: 'month' from: aLocale.
	yearUnit := self resolveOverrideUnit: ovr key: 'year' from: aLocale.

	half := self resolveOverrideField: ovr key: #half default: aLocale half.
	delimiter := self resolveOverrideField: ovr key: #delimiter default: aLocale delimiter.
	justBorn := self resolveOverrideField: ovr key: #justBorn default: aLocale justBorn.
! !

!SayableAge methodsFor: 'private-init'!
resolveOverrideUnit: ovr key: unitKey from: aLocale
	(ovr notNil and: [ ovr includesKey: #units ])
		ifTrue: [ ^ (ovr at: #units) at: unitKey ifAbsent: [ aLocale units at: unitKey ] ].
	^ aLocale units at: unitKey
!

resolveOverrideField: ovr key: fieldKey default: defaultValue
	(ovr notNil and: [ ovr includesKey: fieldKey ])
		ifTrue: [ ^ ovr at: fieldKey ].
	^ defaultValue
! !

!SayableAge methodsFor: 'formatting'!
formatAge: dateOfBirth
	^ self formatAge: dateOfBirth asOf: nil
!

formatAge: dateOfBirth asOf: asOfDate
	| parsed months diffDays |
	parsed := self parseAge: dateOfBirth asOf: asOfDate.
	parsed ifNil: [ ^ nil ].

	months := parsed first.
	diffDays := parsed second.

	"Tier 1: 0 days"
	diffDays = 0 ifTrue: [ ^ justBorn ].

	"Tier 1b: 1-6 days"
	diffDays < 7 ifTrue: [
		^ self resolveUnit: diffDays forms: dayUnit half: '' ].

	"Tier 2: weeks + days until 3 calendar months"
	months < 3 ifTrue: [
		^ self formatWeeksDays: diffDays ].

	"Tier 3: 3-23 months"
	months < 24 ifTrue: [
		^ self resolveUnit: months forms: monthUnit half: '' ].

	"Tier 4: 24-35 months -> years + months"
	months < 36 ifTrue: [
		^ self formatYearsMonths: months ].

	"Tier 5: 3-6 years -> years with half marker"
	months < 84 ifTrue: [
		^ self formatHalfYears: months ].

	"Tier 6: 7+ years"
	^ self resolveUnit: months // 12 forms: yearUnit half: ''
!

formatStage: dateOfBirth
	^ self formatStage: dateOfBirth asOf: nil gender: nil
!

formatStage: dateOfBirth asOf: asOfDate
	^ self formatStage: dateOfBirth asOf: asOfDate gender: nil
!

formatStage: dateOfBirth asOf: asOfDate gender: gender
	| parsed months key label |
	parsed := self parseAge: dateOfBirth asOf: asOfDate.
	parsed ifNil: [ ^ nil ].

	months := parsed first.
	key := self stageKeyFor: months.
	label := locale stages at: key.
	^ self resolveStage: label gender: gender
! !

!SayableAge methodsFor: 'private-formatting'!
formatWeeksDays: diffDays
	| weeks days result |
	weeks := diffDays // 7.
	days := diffDays \\ 7.
	result := self resolveUnit: weeks forms: weekUnit half: ''.
	days > 0 ifTrue: [
		result := result , delimiter , (self resolveUnit: days forms: dayUnit half: '') ].
	^ result
!

formatYearsMonths: months
	| years rem |
	years := months // 12.
	rem := months \\ 12.
	rem = 0 ifTrue: [
		^ self resolveUnit: years forms: yearUnit half: '' ].
	^ (self resolveUnit: years forms: yearUnit half: '') , delimiter , (self resolveUnit: rem forms: monthUnit half: '')
!

formatHalfYears: months
	| years rem |
	years := months // 12.
	rem := months \\ 12.
	rem >= 6 ifTrue: [
		^ self resolveUnit: years forms: yearUnit half: half ].
	^ self resolveUnit: years forms: yearUnit half: ''
! !

!SayableAge methodsFor: 'private-parsing'!
parseAge: dateOfBirth asOf: asOfDate
	"Parse two YYYY-MM-DD strings into {calendarMonths. elapsedDays}.
	Answers nil if either date is missing or invalid, or dateOfBirth is after asOfDate."
	| dob ref today diffDays lastDay clampedBirthday months |
	(dateOfBirth isNil or: [ dateOfBirth isEmpty ]) ifTrue: [ ^ nil ].
	dob := self parseDate: dateOfBirth.
	(asOfDate isNil or: [ asOfDate isEmpty ])
		ifTrue: [
			today := Date today.
			ref := { today year. today monthIndex. today dayOfMonth } ]
		ifFalse: [ ref := self parseDate: asOfDate ].
	(dob isNil or: [ ref isNil ]) ifTrue: [ ^ nil ].

	diffDays := (self julianDay: ref) - (self julianDay: dob).
	diffDays < 0 ifTrue: [ ^ nil ].

	"Calendar months: clamp birthday to last day of reference month"
	lastDay := self daysInMonth: ref second year: ref first.
	clampedBirthday := dob third min: lastDay.
	months := ((ref first - dob first) * 12) + (ref second - dob second).
	ref third < clampedBirthday ifTrue: [ months := months - 1 ].
	months > 6000 ifTrue: [ ^ nil ].

	^ { months. diffDays }
!

parseDate: aString
	"Parse exactly YYYY-MM-DD naming a real calendar day to {year. month. day}, else nil."
	| year month day |
	(aString matchesRegex: '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]') ifFalse: [ ^ nil ].
	year := (aString copyFrom: 1 to: 4) asInteger.
	month := (aString copyFrom: 6 to: 7) asInteger.
	day := (aString copyFrom: 9 to: 10) asInteger.
	(month between: 1 and: 12) ifFalse: [ ^ nil ].
	(day between: 1 and: (self daysInMonth: month year: year)) ifFalse: [ ^ nil ].
	^ { year. month. day }
!

daysInMonth: month year: year
	| isLeap |
	isLeap := (year \\ 4 = 0 and: [ year \\ 100 ~= 0 ]) or: [ year \\ 400 = 0 ].
	month = 2 ifTrue: [ ^ isLeap ifTrue: [ 29 ] ifFalse: [ 28 ] ].
	^ (#(4 6 9 11) includes: month) ifTrue: [ 30 ] ifFalse: [ 31 ]
!

julianDay: ymd
	| a y m |
	a := (14 - ymd second) // 12.
	y := ymd first + 4800 - a.
	m := ymd second + (12 * a) - 3.
	^ ymd third + ((153 * m + 2) // 5) + (365 * y) + (y // 4) - (y // 100) + (y // 400) - 32045
! !

!SayableAge methodsFor: 'private-helpers'!
stageKeyFor: months
	months < 2 ifTrue: [ ^ #newborn ].
	months < 12 ifTrue: [ ^ #infant ].
	months < 36 ifTrue: [ ^ #toddler ].
	months < 156 ifTrue: [ ^ #child ].
	months < 216 ifTrue: [ ^ #teenager ].
	^ #adult
!

resolveUnit: count forms: unitForms half: halfTemplate
	| baseN n template cat result |
	baseN := count printString.

	n := (halfTemplate notEmpty and: [ halfTemplate includesSubstring: '{n}' ])
		ifTrue: [ halfTemplate copyReplaceAll: '{n}' with: baseN ]
		ifFalse: [ baseN ].

	template := unitForms isString
		ifTrue: [ unitForms ]
		ifFalse: [
			cat := locale plural value: count.
			unitForms at: cat ifAbsent: [ unitForms at: #other ] ].

	result := template copyReplaceAll: '{n}' with: n.

	(halfTemplate notEmpty and: [ halfTemplate includesSubstring: '{0}' ])
		ifTrue: [ result := halfTemplate copyReplaceAll: '{0}' with: result ].

	^ result
!

resolveStage: label gender: gender
	label isDictionary ifFalse: [ ^ label ].
	gender = 'f' ifTrue: [ ^ label at: #f ].
	^ label at: #m
! !
