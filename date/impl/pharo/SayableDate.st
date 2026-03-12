"SayableDate — human-friendly date formatter."

Object subclass: #SayableDate
	instanceVariableNames: 'locale compactness months monthsInDate weekdays dayFormat dayFormatExceptions datePattern datePatternWithYear todayStr tomorrowStr yesterdayStr'
	classVariableNames: 'Version'
	package: 'SayableDate'.

SayableDate class instanceVariableNames: ''.

Version := '0.5.0'.

!SayableDate class methodsFor: 'accessing'!
version
	^ Version
! !

!SayableDate class methodsFor: 'instance creation'!
withLocale: aLocale
	^ self withLocale: aLocale compactness: #normal
!

withLocale: aLocale compactness: aSymbol
	^ self new initWithLocale: aLocale compactness: aSymbol
! !

!SayableDate class methodsFor: 'convenience'!
formatDate: date
	| formatter |
	formatter := self withLocale: (SayableDateLocales get: 'en').
	^ formatter formatDate: date
!

formatRelative: date asOf: asOfDate
	| formatter |
	formatter := self withLocale: (SayableDateLocales get: 'en').
	^ formatter formatRelative: date asOf: asOfDate
! !

!SayableDate methodsFor: 'initialization'!
initWithLocale: aLocale compactness: aSymbol
	| ovr |
	locale := aLocale.
	compactness := aSymbol.
	ovr := nil.
	aSymbol = #short ifTrue: [ ovr := aLocale short ].
	aSymbol = #compact ifTrue: [ ovr := aLocale compact ].

	months := self resolveOverrideList: ovr key: #months default: aLocale months.
	monthsInDate := self resolveOverrideList: ovr key: #monthsInDate default: aLocale monthsInDate.
	weekdays := self resolveOverrideList: ovr key: #weekdays default: aLocale weekdays.

	"When short/compact overrides dayFormat but not dayFormatExceptions, clear exceptions"
	(ovr notNil and: [ ovr includesKey: #dayFormat ])
		ifTrue: [
			dayFormat := ovr at: #dayFormat.
			(ovr includesKey: #dayFormatExceptions)
				ifTrue: [ dayFormatExceptions := ovr at: #dayFormatExceptions ]
				ifFalse: [ dayFormatExceptions := Dictionary new ] ]
		ifFalse: [
			dayFormat := aLocale dayFormat.
			dayFormatExceptions := aLocale dayFormatExceptions ].

	datePattern := self resolveOverrideField: ovr key: #datePattern default: aLocale datePattern.
	datePatternWithYear := self resolveOverrideField: ovr key: #datePatternWithYear default: aLocale datePatternWithYear.
	todayStr := self resolveOverrideField: ovr key: #today default: aLocale today.
	tomorrowStr := self resolveOverrideField: ovr key: #tomorrow default: aLocale tomorrow.
	yesterdayStr := self resolveOverrideField: ovr key: #yesterday default: aLocale yesterday.
! !

!SayableDate methodsFor: 'private-init'!
resolveOverrideField: ovr key: fieldKey default: defaultValue
	(ovr notNil and: [ ovr includesKey: fieldKey ])
		ifTrue: [ ^ ovr at: fieldKey ].
	^ defaultValue
!

resolveOverrideList: ovr key: fieldKey default: defaultValue
	(ovr notNil and: [ ovr includesKey: fieldKey ])
		ifTrue: [ ^ ovr at: fieldKey ].
	^ defaultValue
! !

!SayableDate methodsFor: 'formatting'!
formatDate: date
	"Format a calendar date in locale-appropriate form. Always absolute."
	| parsed |
	(date isNil or: [ date isEmpty ]) ifTrue: [ ^ nil ].
	parsed := self parseDate: date.
	parsed ifNil: [ ^ nil ].
	^ self formatAbsolute: parsed includeYear: false
!

formatDateWithYear: date
	"Format a calendar date with year in locale-appropriate form."
	| parsed |
	(date isNil or: [ date isEmpty ]) ifTrue: [ ^ nil ].
	parsed := self parseDate: date.
	parsed ifNil: [ ^ nil ].
	^ self formatAbsolute: parsed includeYear: true
!

formatRelative: date asOf: asOfDate
	"Format a date relative to asOf, picking the most natural reference."
	| parsedDate parsedAsOf dy dm dd ay am ad dateJdn asofJdn diff dow weekdayName includeYear |
	(date isNil or: [ date isEmpty ]) ifTrue: [ ^ nil ].
	(asOfDate isNil or: [ asOfDate isEmpty ]) ifTrue: [ ^ nil ].
	parsedDate := self parseDate: date.
	parsedAsOf := self parseDate: asOfDate.
	(parsedDate isNil or: [ parsedAsOf isNil ]) ifTrue: [ ^ nil ].

	dy := parsedDate first. dm := parsedDate second. dd := parsedDate third.
	ay := parsedAsOf first. am := parsedAsOf second. ad := parsedAsOf third.

	dateJdn := self toJdn: dy month: dm day: dd.
	asofJdn := self toJdn: ay month: am day: ad.
	diff := dateJdn - asofJdn.

	"Today"
	diff = 0 ifTrue: [ ^ todayStr ].

	"Tomorrow"
	diff = 1 ifTrue: [ ^ tomorrowStr ].

	"Yesterday"
	diff = -1 ifTrue: [ ^ yesterdayStr ].

	"Day after tomorrow (optional)"
	(diff = 2 and: [ locale dayAfterTomorrow notNil and: [ compactness ~= #compact ] ])
		ifTrue: [ ^ locale dayAfterTomorrow ].

	"Day before yesterday (optional)"
	(diff = -2 and: [ locale dayBeforeYesterday notNil and: [ compactness ~= #compact ] ])
		ifTrue: [ ^ locale dayBeforeYesterday ].

	"Compact mode: skip weekday references, go straight to calendar date"
	compactness = #compact ifTrue: [
		includeYear := dy ~= ay.
		^ self formatAbsolute: parsedDate includeYear: includeYear ].

	"This weekday (+2 to +6)"
	(diff >= 2 and: [ diff <= 6 and: [ locale thisWeekday notNil ] ])
		ifTrue: [
			dow := self weekdayOf: dy month: dm day: dd.
			weekdayName := weekdays at: dow + 1.
			^ locale thisWeekday copyReplaceAll: '{weekday}' with: weekdayName ].

	"Last weekday (-2 to -6)"
	(diff >= -6 and: [ diff <= -2 and: [ locale lastWeekday notNil ] ])
		ifTrue: [
			dow := self weekdayOf: dy month: dm day: dd.
			weekdayName := weekdays at: dow + 1.
			^ locale lastWeekday copyReplaceAll: '{weekday}' with: weekdayName ].

	"Next weekday (+7 to +13)"
	(diff >= 7 and: [ diff <= 13 and: [ locale nextWeekday notNil ] ])
		ifTrue: [
			dow := self weekdayOf: dy month: dm day: dd.
			weekdayName := weekdays at: dow + 1.
			^ locale nextWeekday copyReplaceAll: '{weekday}' with: weekdayName ].

	"Calendar fallback"
	includeYear := dy ~= ay.
	^ self formatAbsolute: parsedDate includeYear: includeYear
! !

!SayableDate methodsFor: 'private-formatting'!
formatAbsolute: parsed includeYear: includeYear
	| year month day dayStr fmt formattedDay monthNames monthName pattern result |
	year := parsed first. month := parsed second. day := parsed third.
	dayStr := day printString.
	fmt := dayFormatExceptions at: dayStr ifAbsent: [ dayFormat ].
	formattedDay := fmt copyReplaceAll: '{n}' with: dayStr.

	monthNames := monthsInDate ifNil: [ months ].
	monthName := monthNames at: month.

	pattern := includeYear ifTrue: [ datePatternWithYear ] ifFalse: [ datePattern ].
	result := pattern copyReplaceAll: '{month}' with: monthName.
	result := result copyReplaceAll: '{day}' with: formattedDay.
	result := result copyReplaceAll: '{d}' with: day printString.
	result := result copyReplaceAll: '{m}' with: month printString.
	includeYear ifTrue: [
		result := result copyReplaceAll: '{year}' with: year printString.
		result := result copyReplaceAll: '{yy}' with: (year \\ 100 printString padLeftTo: 2 with: $0) ].
	^ result
! !

!SayableDate methodsFor: 'private-parsing'!
parseDate: input
	"Parse YYYY-MM-DD or ISO datetime to {year. month. day}. Returns nil on failure."
	| datePart parts year month day |
	(input includesSubstring: 'T')
		ifTrue: [ datePart := (input substrings: $T) first ]
		ifFalse: [ datePart := input ].
	parts := datePart substrings: $-.
	parts size = 3 ifFalse: [ ^ nil ].
	[ year := parts first asInteger.
	  month := (parts at: 2) asInteger.
	  day := parts third asInteger ]
		on: Error do: [ :e | ^ nil ].
	(month < 1 or: [ month > 12 or: [ day < 1 or: [ day > 31 ] ] ]) ifTrue: [ ^ nil ].
	^ { year. month. day }
! !

!SayableDate methodsFor: 'private-helpers'!
toJdn: year month: month day: day
	"Convert a date to Julian Day Number."
	| a y m |
	a := (14 - month) // 12.
	y := year + 4800 - a.
	m := month + (12 * a) - 3.
	^ day + ((153 * m + 2) // 5) + (365 * y) + (y // 4) - (y // 100) + (y // 400) - 32045
!

weekdayOf: year month: month day: day
	"Return day of week: 0=Sunday, 1=Monday, ..., 6=Saturday."
	^ ((self toJdn: year month: month day: day) + 1) \\ 7
! !
