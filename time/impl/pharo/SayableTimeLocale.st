"SayableTimeLocale — data object holding locale configuration for time formatting."

Object subclass: #SayableTimeLocale
	instanceVariableNames: 'code clock short compact'
	classVariableNames: ''
	package: 'SayableTime'.

!SayableTimeLocale methodsFor: 'accessing'!
code
	^ code
!

code: aString
	code := aString
!

clock
	^ clock
!

clock: aDictionary
	clock := aDictionary
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
