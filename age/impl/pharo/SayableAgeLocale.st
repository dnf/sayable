"SayableAgeLocale — data object holding locale configuration for age formatting."

Object subclass: #SayableAgeLocale
	instanceVariableNames: 'code plural units half delimiter justBorn stages short compact'
	classVariableNames: ''
	package: 'SayableAge'!

!SayableAgeLocale methodsFor: 'accessing'!
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

justBorn
	^ justBorn
!

justBorn: aString
	justBorn := aString
!

stages
	^ stages
!

stages: aDictionary
	stages := aDictionary
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
