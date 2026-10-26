"SayableDurationLocale — data object holding locale configuration for duration formatting."

Object subclass: #SayableDurationLocale
	instanceVariableNames: 'code plural units half delimiter justNow ago inFuture short compact'
	classVariableNames: ''
	package: 'SayableDuration'!

!SayableDurationLocale methodsFor: 'accessing'!
code
	^ code
!

code: aString
	code := aString
!

plural
	^ plural
!

plural: aBlock
	plural := aBlock
!

units
	^ units
!

units: aDictionary
	units := aDictionary
!

half
	^ half
!

half: aString
	half := aString
!

delimiter
	^ delimiter
!

delimiter: aString
	delimiter := aString
!

justNow
	^ justNow
!

justNow: aString
	justNow := aString
!

ago
	^ ago
!

ago: aString
	ago := aString
!

inFuture
	^ inFuture
!

inFuture: aString
	inFuture := aString
!

short
	^ short
!

short: aDictionary
	short := aDictionary
!

compact
	^ compact
!

compact: aDictionary
	compact := aDictionary
! !
