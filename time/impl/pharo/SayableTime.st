"SayableTime — human-friendly clock time formatter."

Object subclass: #SayableTime
	instanceVariableNames: 'locale compactness shortClock'
	classVariableNames: 'Version'
	package: 'SayableTime'!

SayableTime class instanceVariableNames: ''!

!SayableTime class methodsFor: 'class initialization'!
initialize
	Version := '0.5.0'
! !

SayableTime initialize!

!SayableTime class methodsFor: 'accessing'!
version
	^ Version
! !

!SayableTime class methodsFor: 'instance creation'!
withLocale: aLocale
	^ self withLocale: aLocale compactness: #normal
!

withLocale: aLocale compactness: aSymbol
	^ self new initWithLocale: aLocale compactness: aSymbol
! !

!SayableTime class methodsFor: 'convenience'!
formatTime: input
	| formatter |
	formatter := self withLocale: (SayableTimeLocales get: 'en').
	^ formatter formatTime: input
! !

!SayableTime methodsFor: 'initialization'!
initWithLocale: aLocale compactness: aSymbol
	| ovr |
	locale := aLocale.
	compactness := aSymbol.
	ovr := nil.
	aSymbol = #short ifTrue: [ ovr := aLocale short ].
	aSymbol = #compact ifTrue: [ ovr := aLocale compact ].

	shortClock := (ovr notNil and: [ ovr includesKey: #clock ])
		ifTrue: [ ovr at: #clock ]
		ifFalse: [ nil ].
! !

!SayableTime methodsFor: 'formatting'!
formatTime: input
	"Format a time string as natural language clock reading."
	| parsed hour minute |
	(input isNil or: [ input isEmpty ]) ifTrue: [ ^ nil ].
	parsed := self parseTime: input.
	parsed ifNil: [ ^ nil ].
	hour := parsed first.
	minute := parsed second.

	(compactness ~= #normal and: [ shortClock notNil ])
		ifTrue: [ ^ self formatDigital: hour minute: minute ].
	^ self formatNatural: hour minute: minute
! !

!SayableTime methodsFor: 'private-formatting'!
formatNatural: hour minute: minute
	| clock rounded h h12 nextH12 hName nextHName pattern |
	clock := locale clock.
	rounded := self roundTo5: minute.
	h := hour.
	rounded = 60 ifTrue: [
		rounded := 0.
		h := (h + 1) \\ 24 ].

	(rounded = 0 and: [ h = 0 ]) ifTrue: [ ^ clock at: #midnight ].
	(rounded = 0 and: [ h = 12 ]) ifTrue: [ ^ clock at: #noon ].

	h12 := h \\ 12.
	nextH12 := (h + 1) \\ 12.
	hName := (clock at: #hours) at: h12 + 1.
	nextHName := (clock at: #hours) at: nextH12 + 1.
	pattern := (clock at: #patterns) at: rounded ifAbsent: [ (clock at: #patterns) at: 0 ifAbsent: [ '{h}' ] ].
	^ (pattern copyReplaceAll: '{h}' with: hName) copyReplaceAll: '{next_h}' with: nextHName
!

formatDigital: hour minute: minute
	| sc fmt h12 amPm ampmStr |
	sc := shortClock.
	fmt := sc at: #format.
	(sc at: #use24h) ifTrue: [
		^ (fmt copyReplaceAll: '{h}' with: hour printString) copyReplaceAll: '{mm}' with: (minute printString padLeftTo: 2 with: $0) ].

	h12 := hour \\ 12.
	h12 = 0 ifTrue: [ h12 := 12 ].
	amPm := (sc includesKey: #amPm)
		ifTrue: [ sc at: #amPm ]
		ifFalse: [ OrderedCollection withAll: { 'AM'. 'PM' } ].
	ampmStr := hour < 12 ifTrue: [ amPm first ] ifFalse: [ amPm second ].
	^ ((fmt copyReplaceAll: '{h}' with: h12 printString) copyReplaceAll: '{mm}' with: (minute printString padLeftTo: 2 with: $0)) copyReplaceAll: '{ampm}' with: ampmStr
! !

!SayableTime methodsFor: 'private-parsing'!
parseTime: input
	"Parse a clock time (H:MM or HH:MM, optional :SS and fraction, optional
	zone suffix, which is ignored), alone or after the T of an ISO datetime,
	to {hour. minute}. Returns nil on failure."
	| tIndex clock colon hour minute second |
	tIndex := input indexOf: $T.
	clock := input.
	tIndex > 0 ifTrue: [
		(self isRealDate: (input copyFrom: 1 to: tIndex - 1)) ifFalse: [ ^ nil ].
		clock := input copyFrom: tIndex + 1 to: input size ].
	(clock matchesRegex: self class clockPattern) ifFalse: [ ^ nil ].
	colon := clock indexOf: $:.
	hour := (clock copyFrom: 1 to: colon - 1) asInteger.
	minute := (clock copyFrom: colon + 1 to: colon + 2) asInteger.
	second := (clock size >= (colon + 5) and: [ (clock at: colon + 3) = $: ])
		ifTrue: [ (clock copyFrom: colon + 4 to: colon + 5) asInteger ]
		ifFalse: [ 0 ].
	(hour > 23 or: [ minute > 59 or: [ second > 59 ] ]) ifTrue: [ ^ nil ].
	^ { hour. minute }
!

isRealDate: aString
	"True when aString is exactly YYYY-MM-DD naming a real calendar day."
	| year month day |
	(aString matchesRegex: '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]') ifFalse: [ ^ false ].
	year := (aString copyFrom: 1 to: 4) asInteger.
	month := (aString copyFrom: 6 to: 7) asInteger.
	day := (aString copyFrom: 9 to: 10) asInteger.
	^ (month between: 1 and: 12) and: [ day between: 1 and: (self daysInMonth: month year: year) ]
!

daysInMonth: month year: year
	| isLeap |
	isLeap := (year \\ 4 = 0 and: [ year \\ 100 ~= 0 ]) or: [ year \\ 400 = 0 ].
	month = 2 ifTrue: [ ^ isLeap ifTrue: [ 29 ] ifFalse: [ 28 ] ].
	^ (#(4 6 9 11) includes: month) ifTrue: [ 30 ] ifFalse: [ 31 ]
! !

!SayableTime class methodsFor: 'parsing'!
clockPattern
	"H:MM or HH:MM, optional :SS with an optional fraction, optional zone suffix."
	^ '[0-9][0-9]?\:[0-9][0-9](\:[0-9][0-9](\.[0-9]+)?)?(Z|\+[0-9][0-9]\:[0-9][0-9]|-[0-9][0-9]\:[0-9][0-9])?'
! !

!SayableTime methodsFor: 'private-helpers'!
roundTo5: minute
	"Round minute to nearest 5."
	^ ((minute + 2) // 5) * 5
! !
