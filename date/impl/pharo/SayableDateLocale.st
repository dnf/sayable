"SayableDateLocale — data object holding locale configuration for date formatting."

Object subclass: #SayableDateLocale
	instanceVariableNames: 'code months weekdays dayFormat dayFormatExceptions datePattern datePatternWithYear today tomorrow yesterday dayAfterTomorrow dayBeforeYesterday thisWeekday nextWeekday lastWeekday monthsInDate short compact'
	classVariableNames: ''
	package: 'SayableDate'.

!SayableDateLocale methodsFor: 'accessing'!
code
	^ code
!

code: aString
	code := aString
!

months
	^ months
!

months: aCollection
	months := aCollection
!

weekdays
	^ weekdays
!

weekdays: aCollection
	weekdays := aCollection
!

dayFormat
	^ dayFormat
!

dayFormat: aString
	dayFormat := aString
!

dayFormatExceptions
	^ dayFormatExceptions
!

dayFormatExceptions: aDictionary
	dayFormatExceptions := aDictionary
!

datePattern
	^ datePattern
!

datePattern: aString
	datePattern := aString
!

datePatternWithYear
	^ datePatternWithYear
!

datePatternWithYear: aString
	datePatternWithYear := aString
!

today
	^ today
!

today: aString
	today := aString
!

tomorrow
	^ tomorrow
!

tomorrow: aString
	tomorrow := aString
!

yesterday
	^ yesterday
!

yesterday: aString
	yesterday := aString
!

dayAfterTomorrow
	^ dayAfterTomorrow
!

dayAfterTomorrow: aStringOrNil
	dayAfterTomorrow := aStringOrNil
!

dayBeforeYesterday
	^ dayBeforeYesterday
!

dayBeforeYesterday: aStringOrNil
	dayBeforeYesterday := aStringOrNil
!

thisWeekday
	^ thisWeekday
!

thisWeekday: aStringOrNil
	thisWeekday := aStringOrNil
!

nextWeekday
	^ nextWeekday
!

nextWeekday: aStringOrNil
	nextWeekday := aStringOrNil
!

lastWeekday
	^ lastWeekday
!

lastWeekday: aStringOrNil
	lastWeekday := aStringOrNil
!

monthsInDate
	^ monthsInDate
!

monthsInDate: aCollectionOrNil
	monthsInDate := aCollectionOrNil
!

short
	^ short
!

short: aDictionaryOrNil
	short := aDictionaryOrNil
!

compact
	^ compact
!

compact: aDictionaryOrNil
	compact := aDictionaryOrNil
! !
