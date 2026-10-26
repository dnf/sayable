"SayableDuration — human-friendly duration and relative time formatter."

Object subclass: #SayableDuration
	instanceVariableNames: 'locale units half delimiter justNow agoTemplate inFutureTemplate'
	classVariableNames: 'Version'
	package: 'SayableDuration'!

SayableDuration class instanceVariableNames: ''!

!SayableDuration class methodsFor: 'class initialization'!
initialize
	Version := '0.5.0'
! !

SayableDuration initialize!

!SayableDuration class methodsFor: 'accessing'!
version
	^ Version
! !

!SayableDuration class methodsFor: 'instance creation'!
withLocale: aLocale
	^ self withLocale: aLocale compactness: #normal
!

withLocale: aLocale compactness: aSymbol
	^ self new initWithLocale: aLocale compactness: aSymbol
! !

!SayableDuration class methodsFor: 'convenience'!
formatDuration: seconds
	| formatter |
	formatter := self withLocale: (SayableDurationLocales get: 'en').
	^ formatter formatDuration: seconds
!

formatSince: start asOf: asOf
	| formatter |
	formatter := self withLocale: (SayableDurationLocales get: 'en').
	^ formatter formatSince: start asOf: asOf
!

formatUntil: target asOf: asOf
	| formatter |
	formatter := self withLocale: (SayableDurationLocales get: 'en').
	^ formatter formatUntil: target asOf: asOf
! !

!SayableDuration methodsFor: 'initialization'!
initWithLocale: aLocale compactness: aSymbol
	| ovr ovrUnits |
	locale := aLocale.
	ovr := nil.
	aSymbol = #short ifTrue: [ ovr := aLocale short ].
	aSymbol = #compact ifTrue: [ ovr := aLocale compact ].

	ovrUnits := (ovr notNil and: [ ovr includesKey: #units ])
		ifTrue: [ ovr at: #units ]
		ifFalse: [ nil ].

	units := Dictionary new.
	#('second' 'minute' 'hour' 'day' 'week' 'month' 'year') do: [ :unitName |
		| val |
		val := (ovrUnits notNil and: [ ovrUnits includesKey: unitName ])
			ifTrue: [ ovrUnits at: unitName ]
			ifFalse: [ aLocale units at: unitName ].
		units at: unitName put: val ].

	half := self resolveOverrideField: ovr key: #half default: aLocale half.
	delimiter := self resolveOverrideField: ovr key: #delimiter default: aLocale delimiter.
	justNow := aLocale justNow.
	agoTemplate := self resolveOverrideField: ovr key: #ago default: aLocale ago.
	inFutureTemplate := self resolveOverrideField: ovr key: #inFuture default: aLocale inFuture.
! !

!SayableDuration methodsFor: 'private-init'!
resolveOverrideField: ovr key: fieldKey default: defaultValue
	(ovr notNil and: [ ovr includesKey: fieldKey ])
		ifTrue: [ ^ ovr at: fieldKey ].
	^ defaultValue
! !

!SayableDuration methodsFor: 'formatting'!
formatDuration: startOrSeconds
	^ self formatDuration: startOrSeconds end: nil
!

formatDuration: startOrSeconds end: end
	"Format a duration. startOrSeconds is either an integer (seconds) or an ISO datetime string."
	| totalSeconds s e |
	startOrSeconds isNil ifTrue: [ ^ nil ].

	startOrSeconds isInteger ifTrue: [
		startOrSeconds < 0 ifTrue: [ ^ nil ].
		^ self formatDurationSeconds: startOrSeconds ].

	startOrSeconds isString ifTrue: [
		end isNil ifTrue: [ ^ nil ].
		s := self parseIsoToSeconds: startOrSeconds.
		e := self parseIsoToSeconds: end.
		(s isNil or: [ e isNil ]) ifTrue: [ ^ nil ].
		totalSeconds := (e - s) abs.
		^ self formatDurationSeconds: totalSeconds ].

	^ nil
!

formatSince: start asOf: asOf
	"Format elapsed time as 'X ago'."
	| s a diff dur |
	(start isNil or: [ start isEmpty ]) ifTrue: [ ^ nil ].
	(asOf isNil or: [ asOf isEmpty ]) ifTrue: [ ^ nil ].
	s := self parseIsoToSeconds: start.
	a := self parseIsoToSeconds: asOf.
	(s isNil or: [ a isNil ]) ifTrue: [ ^ nil ].
	diff := a - s.
	diff < 0 ifTrue: [ ^ nil ].
	diff = 0 ifTrue: [ ^ justNow ].
	dur := self formatDurationSeconds: diff.
	dur ifNil: [ ^ nil ].
	^ agoTemplate copyReplaceAll: '{0}' with: dur
!

formatUntil: target asOf: asOf
	"Format time until a future event as 'in X'."
	| t a diff dur |
	(target isNil or: [ target isEmpty ]) ifTrue: [ ^ nil ].
	(asOf isNil or: [ asOf isEmpty ]) ifTrue: [ ^ nil ].
	t := self parseIsoToSeconds: target.
	a := self parseIsoToSeconds: asOf.
	(t isNil or: [ a isNil ]) ifTrue: [ ^ nil ].
	diff := t - a.
	diff < 0 ifTrue: [ ^ nil ].
	diff = 0 ifTrue: [ ^ justNow ].
	dur := self formatDurationSeconds: diff.
	dur ifNil: [ ^ nil ].
	^ inFutureTemplate copyReplaceAll: '{0}' with: dur
! !

!SayableDuration methodsFor: 'private-formatting'!
formatDurationSeconds: total
	| totalMinutes remainderSeconds result totalHours remainderMinutes totalDays remainderHours totalWeeks remainderDays totalMonths totalYears remainderMonths |
	"0 seconds"
	total = 0 ifTrue: [ ^ justNow ].

	"1-59 seconds"
	total < 60 ifTrue: [
		^ self resolveUnit: total forms: (units at: 'second') half: '' ].

	totalMinutes := total // 60.
	remainderSeconds := total \\ 60.

	"1-4 minutes: minutes + seconds"
	totalMinutes < 5 ifTrue: [
		result := self resolveUnit: totalMinutes forms: (units at: 'minute') half: ''.
		remainderSeconds > 0 ifTrue: [
			result := result , delimiter , (self resolveUnit: remainderSeconds forms: (units at: 'second') half: '') ].
		^ result ].

	"5-59 minutes"
	totalMinutes < 60 ifTrue: [
		^ self resolveUnit: totalMinutes forms: (units at: 'minute') half: '' ].

	totalHours := total // 3600.
	remainderMinutes := (total \\ 3600) // 60.

	"1-5 hours: hours + minutes (with half marker)"
	totalHours <= 5 ifTrue: [
		remainderMinutes = 30 ifTrue: [
			^ self resolveUnit: totalHours forms: (units at: 'hour') half: half ].
		result := self resolveUnit: totalHours forms: (units at: 'hour') half: ''.
		remainderMinutes > 0 ifTrue: [
			result := result , delimiter , (self resolveUnit: remainderMinutes forms: (units at: 'minute') half: '') ].
		^ result ].

	"6-23 hours"
	totalHours < 24 ifTrue: [
		^ self resolveUnit: totalHours forms: (units at: 'hour') half: '' ].

	totalDays := total // 86400.
	remainderHours := (total \\ 86400) // 3600.

	"1-2 days: days + hours (with half marker)"
	totalDays <= 2 ifTrue: [
		remainderHours = 12 ifTrue: [
			^ self resolveUnit: totalDays forms: (units at: 'day') half: half ].
		result := self resolveUnit: totalDays forms: (units at: 'day') half: ''.
		remainderHours > 0 ifTrue: [
			result := result , delimiter , (self resolveUnit: remainderHours forms: (units at: 'hour') half: '') ].
		^ result ].

	"3-6 days"
	totalDays < 7 ifTrue: [
		^ self resolveUnit: totalDays forms: (units at: 'day') half: '' ].

	totalWeeks := totalDays // 7.
	remainderDays := totalDays \\ 7.

	"1-4 weeks (up to 29 days; 30+ transitions to months)"
	totalDays < 30 ifTrue: [
		result := self resolveUnit: totalWeeks forms: (units at: 'week') half: ''.
		remainderDays > 0 ifTrue: [
			result := result , delimiter , (self resolveUnit: remainderDays forms: (units at: 'day') half: '') ].
		^ result ].

	"Approximate months (30.44 days average)"
	totalMonths := (totalDays / 30.44) rounded.
	totalMonths > self class maxDurationMonths ifTrue: [ ^ nil ].

	"1-11 months"
	totalMonths < 12 ifTrue: [
		totalMonths = 0 ifTrue: [ totalMonths := 1 ].
		^ self resolveUnit: totalMonths forms: (units at: 'month') half: '' ].

	"12+ months: years + months"
	totalYears := totalMonths // 12.
	remainderMonths := totalMonths \\ 12.
	result := self resolveUnit: totalYears forms: (units at: 'year') half: ''.
	remainderMonths > 0 ifTrue: [
		result := result , delimiter , (self resolveUnit: remainderMonths forms: (units at: 'month') half: '') ].
	^ result
! !

!SayableDuration methodsFor: 'private-helpers'!
resolveUnit: count forms: unitForms half: halfTemplate
	| baseN n template cat result |
	baseN := count printString.

	n := (halfTemplate notEmpty and: [ halfTemplate includesSubstring: '{n}' ])
		ifTrue: [ halfTemplate copyReplaceAll: '{n}' with: baseN ]
		ifFalse: [ baseN ].

	template := unitForms isString
		ifTrue: [ unitForms ]
		ifFalse: [
			cat := halfTemplate notEmpty
				ifTrue: [ #other ]
				ifFalse: [ locale plural value: count ].
			unitForms at: cat ifAbsent: [ unitForms at: #other ] ].

	result := template copyReplaceAll: '{n}' with: n.

	(halfTemplate notEmpty and: [ halfTemplate includesSubstring: '{0}' ])
		ifTrue: [ result := halfTemplate copyReplaceAll: '{0}' with: result ].

	^ result
! !

!SayableDuration methodsFor: 'private-parsing'!
parseIsoToSeconds: isoStr
	"Parse YYYY-MM-DDTHH:MM (optional :SS, fraction and zone suffix, which is
	ignored) to epoch-ish seconds for diffing. Returns nil if malformed."
	| year month day colon hour minute second |
	isoStr isNil ifTrue: [ ^ nil ].
	(isoStr matchesRegex: self class timestampPattern) ifFalse: [ ^ nil ].
	year := (isoStr copyFrom: 1 to: 4) asInteger.
	month := (isoStr copyFrom: 6 to: 7) asInteger.
	day := (isoStr copyFrom: 9 to: 10) asInteger.
	colon := isoStr indexOf: $: startingAt: 12.
	hour := (isoStr copyFrom: 12 to: colon - 1) asInteger.
	minute := (isoStr copyFrom: colon + 1 to: colon + 2) asInteger.
	second := (isoStr size >= (colon + 5) and: [ (isoStr at: colon + 3) = $: ])
		ifTrue: [ (isoStr copyFrom: colon + 4 to: colon + 5) asInteger ]
		ifFalse: [ 0 ].
	(month between: 1 and: 12) ifFalse: [ ^ nil ].
	(day between: 1 and: (self daysInMonth: year month: month)) ifFalse: [ ^ nil ].
	(hour > 23 or: [ minute > 59 or: [ second > 59 ] ]) ifTrue: [ ^ nil ].
	^ ((self daysSinceEpoch: year month: month day: day) * 86400) + (hour * 3600) + (minute * 60) + second
!

daysSinceEpoch: year month: month day: day
	"Calculate days since 2000-01-01."
	| days y m |
	days := 0.
	year >= 2000
		ifTrue: [
			y := 2000.
			[ y < year ] whileTrue: [
				days := days + ((self isLeapYear: y) ifTrue: [ 366 ] ifFalse: [ 365 ]).
				y := y + 1 ] ]
		ifFalse: [
			y := year.
			[ y < 2000 ] whileTrue: [
				days := days - ((self isLeapYear: y) ifTrue: [ 366 ] ifFalse: [ 365 ]).
				y := y + 1 ] ].
	m := 1.
	[ m < month ] whileTrue: [
		days := days + (self daysInMonth: year month: m).
		m := m + 1 ].
	days := days + day - 1.
	^ days
!

isLeapYear: year
	^ (year \\ 4 = 0 and: [ year \\ 100 ~= 0 ]) or: [ year \\ 400 = 0 ]
!

daysInMonth: year month: month
	(#(1 3 5 7 8 10 12) includes: month) ifTrue: [ ^ 31 ].
	(#(4 6 9 11) includes: month) ifTrue: [ ^ 30 ].
	^ (self isLeapYear: year) ifTrue: [ 29 ] ifFalse: [ 28 ]
! !

!SayableDuration class methodsFor: 'constants'!
maxDurationMonths
	"500 years, the same ceiling as sayable-age."
	^ 6000
!

timestampPattern
	"YYYY-MM-DDTHH:MM, optional :SS with an optional fraction, optional zone suffix."
	^ '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]?\:[0-9][0-9](\:[0-9][0-9](\.[0-9]+)?)?(Z|\+[0-9][0-9]\:[0-9][0-9]|-[0-9][0-9]\:[0-9][0-9])?'
! !
