"SayableCli — the Sayable command-line interface (see cli/SPEC.md).
Loaded by sayable.st after the four Sayable libraries."

Error subclass: #SayableUsageError
	instanceVariableNames: ''
	classVariableNames: ''
	package: 'SayableCLI'!

Object subclass: #SayableCli
	instanceVariableNames: ''
	classVariableNames: ''
	package: 'SayableCLI'!

!SayableCli class methodsFor: 'running'!
main: commandLineArguments
	"Run the CLI with the VM's command-line arguments and exit."
	| argv outcome cli |
	argv := self userArgumentsFrom: commandLineArguments.
	cli := self new.
	argv = #('--repl') ifTrue: [ cli repl. ^ Smalltalk exit: 0 ].
	outcome := cli run: argv.
	outcome second ifNotNil: [ :text | cli writeLine: text ].
	Smalltalk exit: outcome first
!

userArgumentsFrom: rawArgs
	"When invoked as 'pharo Pharo.image st sayable.st -- arg1 arg2', the
	arguments are #('st' '/path/to/sayable.st' '--' 'arg1' 'arg2'): skip past
	the .st file and the '--' that follows it."
	| argv foundScript |
	argv := OrderedCollection new.
	foundScript := false.
	rawArgs do: [ :a |
		foundScript
			ifTrue: [ (a = '--' and: [ argv isEmpty ]) ifFalse: [ argv add: a ] ]
			ifFalse: [ (a endsWith: '.st') ifTrue: [ foundScript := true ] ] ].
	foundScript ifFalse: [ ^ rawArgs asArray ].
	^ argv asArray
! !

!SayableCli methodsFor: 'running'!
run: args
	"Run one command as the one-shot CLI would, without printing or exiting.
	Answers { exitCode. stdoutText or nil }."
	^ [ self dispatch: args ]
		on: SayableUsageError
		do: [ :e | e return: { 2. nil } ]
!

dispatch: args
	| parsed command result |
	parsed := self parseArgs: args.
	command := parsed first.
	command ifNil: [ ^ { 2. self helpText } ].
	command = 'help' ifTrue: [ ^ { 0. self helpText } ].
	command = 'version' ifTrue: [ ^ { 0. 'sayable ', SayableAge version } ].
	command = 'locales' ifTrue: [ ^ { 0. self localesText } ].
	(self commandSelectors includesKey: command)
		ifFalse: [ self usageError: 'unknown command ''', command, '''' ].
	result := self
		perform: (self commandSelectors at: command)
		with: parsed second
		with: parsed third.
	^ result
		ifNil: [ { 1. nil } ]
		ifNotNil: [ { 0. result } ]
!

commandSelectors
	^ Dictionary newFromPairs: {
		'age'. #age:options:.
		'stage'. #stage:options:.
		'date'. #date:options:.
		'relative'. #relative:options:.
		'time'. #time:options:.
		'duration'. #duration:options:.
		'since'. #since:options:.
		'until'. #until:options: }
! !

!SayableCli methodsFor: 'repl'!
repl
	"Answer one tab-separated request per stdin line until end of input."
	| line response |
	[ (line := self readRequest) notNil ] whileTrue: [
		response := [ self formatResponse: (self run: (self splitFields: line)) ]
			on: Error
			do: [ :e |
				"A crash exits 1 in one-shot mode; keep serving."
				Stdio stderr nextPutAll: e description; nextPut: Character lf; flush.
				e return: '1', (String with: Character tab) ].
		self writeLine: response ]
!

readRequest
	"Read one line a byte at a time, decoded as UTF-8, so a request is
	answered as soon as its newline arrives. Answers nil at end of input."
	| bytes byte line |
	bytes := WriteStream on: ByteArray new.
	[ byte := Stdio stdin next.
	  byte notNil and: [ byte asInteger ~= 10 ] ]
		whileTrue: [ bytes nextPut: byte asInteger ].
	(byte isNil and: [ bytes contents isEmpty ]) ifTrue: [ ^ nil ].
	line := bytes contents utf8Decoded.
	(line notEmpty and: [ line last = Character cr ]) ifTrue: [ ^ line allButLast ].
	^ line
!

splitFields: line
	"Split on tabs, keeping empty fields ('age<TAB>' is 'age' and '')."
	| fields start |
	fields := OrderedCollection new.
	start := 1.
	line doWithIndex: [ :char :index |
		char = Character tab ifTrue: [
			fields add: (line copyFrom: start to: index - 1).
			start := index + 1 ] ].
	fields add: (line copyFrom: start to: line size).
	^ fields asArray
!

formatResponse: outcome
	| text |
	text := outcome second ifNil: [ '' ].
	[ text notEmpty and: [ text last = Character lf ] ]
		whileTrue: [ text := text allButLast ].
	^ outcome first printString, (String with: Character tab),
		(text copyReplaceAll: (String with: Character lf) with: (String with: Character tab))
!

writeLine: text
	"Write a line to stdout as UTF-8 and flush it (REPL responses must not
	wait in a buffer)."
	Stdio stdout nextPutAll: (text, (String with: Character lf)) utf8Encoded; flush
! !

!SayableCli methodsFor: 'arguments'!
parseArgs: args
	"Answer { command. positionals. options }."
	| command positionals options i stopOptions arg |
	args isEmpty ifTrue: [ ^ { nil. #(). Dictionary new } ].
	(#('-h' '--help' 'help') includes: args first) ifTrue: [ ^ { 'help'. #(). Dictionary new } ].
	(#('-v' '--version' 'version') includes: args first) ifTrue: [ ^ { 'version'. #(). Dictionary new } ].
	command := args first.
	positionals := OrderedCollection new.
	options := self defaultOptions.
	i := 2.
	stopOptions := false.
	[ i <= args size ] whileTrue: [
		arg := args at: i.
		(arg = '--' and: [ stopOptions not ])
			ifTrue: [ stopOptions := true ]
			ifFalse: [
				(stopOptions not and: [ arg notEmpty and: [ arg first = $- ] ])
					ifTrue: [
						(#('-h' '--help') includes: arg) ifTrue: [ ^ { 'help'. #(). Dictionary new } ].
						(#('-v' '--version') includes: arg) ifTrue: [ ^ { 'version'. #(). Dictionary new } ].
						(self valueOptionKeyFor: arg)
							ifNotNil: [ :key |
								i + 1 > args size ifTrue: [ self usageError: '''', arg, ''' requires a value' ].
								i := i + 1.
								options at: key put: (args at: i) ]
							ifNil: [ self applyFlag: arg to: options ] ]
					ifFalse: [ positionals add: arg ] ].
		i := i + 1 ].
	^ { command. positionals asArray. options }
!

defaultOptions
	^ Dictionary newFromPairs: {
		'locale'. 'en'.
		'as_of'. nil.
		'compactness'. 'normal'.
		'gender'. nil.
		'with_year'. false }
!

valueOptionKeyFor: arg
	"The options key an option that takes a value sets, or nil for a flag."
	(#('-l' '--locale') includes: arg) ifTrue: [ ^ 'locale' ].
	(#('-d' '--as-of') includes: arg) ifTrue: [ ^ 'as_of' ].
	(#('-g' '--gender') includes: arg) ifTrue: [ ^ 'gender' ].
	^ nil
!

applyFlag: arg to: options
	arg = '--short' ifTrue: [ ^ options at: 'compactness' put: 'short' ].
	arg = '--compact' ifTrue: [ ^ options at: 'compactness' put: 'compact' ].
	arg = '--with-year' ifTrue: [ ^ options at: 'with_year' put: true ].
	self usageError: 'unknown option ''', arg, ''''
! !

!SayableCli methodsFor: 'commands'!
age: positionals options: options
	| formatter |
	positionals isEmpty ifTrue: [ self usageError: 'age requires a date-of-birth argument' ].
	formatter := SayableAge
		withLocale: (self locale: options from: SayableAgeLocales)
		compactness: (self compactness: options).
	^ formatter formatAge: (self nullify: positionals first) asOf: (self ageAsOf: options)
!

stage: positionals options: options
	| formatter |
	positionals isEmpty ifTrue: [ self usageError: 'stage requires a date-of-birth argument' ].
	formatter := SayableAge
		withLocale: (self locale: options from: SayableAgeLocales)
		compactness: (self compactness: options).
	^ formatter
		formatStage: (self nullify: positionals first)
		asOf: (self ageAsOf: options)
		gender: (options at: 'gender')
!

date: positionals options: options
	| formatter dateValue |
	positionals isEmpty ifTrue: [ self usageError: 'date requires a date argument' ].
	dateValue := self nullify: positionals first.
	formatter := SayableDate
		withLocale: (self locale: options from: SayableDateLocales)
		compactness: (self compactness: options).
	(options at: 'with_year') ifTrue: [ ^ formatter formatDateWithYear: dateValue ].
	^ formatter formatDate: dateValue
!

relative: positionals options: options
	| formatter dateValue asOf |
	positionals isEmpty ifTrue: [ self usageError: 'relative requires a date argument' ].
	dateValue := self nullify: positionals first.
	asOf := self requiredAsOf: options for: 'relative'.
	formatter := SayableDate
		withLocale: (self locale: options from: SayableDateLocales)
		compactness: (self compactness: options).
	^ formatter formatRelative: dateValue asOf: asOf
!

time: positionals options: options
	| formatter |
	positionals isEmpty ifTrue: [ self usageError: 'time requires a time argument' ].
	formatter := SayableTime
		withLocale: (self locale: options from: SayableTimeLocales)
		compactness: (self compactness: options).
	^ formatter formatTime: (self nullify: positionals first)
!

duration: positionals options: options
	| formatter value |
	positionals isEmpty ifTrue: [ self usageError: 'duration requires a value argument' ].
	value := self nullify: positionals first.
	formatter := SayableDuration
		withLocale: (self locale: options from: SayableDurationLocales)
		compactness: (self compactness: options).
	value ifNil: [ ^ formatter formatDuration: nil ].
	(self isIntegerString: value) ifTrue: [ ^ formatter formatDuration: value asInteger ].
	positionals size < 2 ifTrue: [
		self usageError: 'duration with timestamps requires start and end arguments' ].
	^ formatter formatDuration: value end: (self nullify: (positionals at: 2))
!

since: positionals options: options
	| formatter start asOf |
	positionals isEmpty ifTrue: [ self usageError: 'since requires a start timestamp argument' ].
	start := self nullify: positionals first.
	asOf := self requiredAsOf: options for: 'since'.
	formatter := SayableDuration
		withLocale: (self locale: options from: SayableDurationLocales)
		compactness: (self compactness: options).
	^ formatter formatSince: start asOf: asOf
!

until: positionals options: options
	| formatter target asOf |
	positionals isEmpty ifTrue: [ self usageError: 'until requires a target timestamp argument' ].
	target := self nullify: positionals first.
	asOf := self requiredAsOf: options for: 'until'.
	formatter := SayableDuration
		withLocale: (self locale: options from: SayableDurationLocales)
		compactness: (self compactness: options).
	^ formatter formatUntil: target asOf: asOf
!

localesText
	"All locale codes, one per line; every component shares the age set."
	^ String streamContents: [ :out |
		SayableAgeLocales registry keys asSortedCollection
			do: [ :code | out nextPutAll: code ]
			separatedBy: [ out nextPut: Character lf ] ]
! !

!SayableCli methodsFor: 'helpers'!
usageError: message
	"Report a usage error on stderr and fail the request with exit 2.
	Signalling instead of exiting lets the REPL keep serving."
	Stdio stderr
		nextPutAll: 'error: '; nextPutAll: message; nextPut: Character lf;
		nextPutAll: 'Run ''sayable help'' for usage.'; nextPut: Character lf;
		flush.
	SayableUsageError new signal: message
!

nullify: value
	"The literal 'null' stands for a null input."
	value = 'null' ifTrue: [ ^ nil ].
	^ value
!

locale: options from: localesClass
	| code |
	code := options at: 'locale'.
	^ (localesClass get: code) ifNil: [ self usageError: 'unknown locale ''', code, '''' ]
!

compactness: options
	| name |
	name := options at: 'compactness'.
	name = 'short' ifTrue: [ ^ #short ].
	name = 'compact' ifTrue: [ ^ #compact ].
	^ #normal
!

ageAsOf: options
	"Age and stage default to today when -d is not given."
	(options at: 'as_of') ifNil: [ ^ self today ].
	^ self nullify: (options at: 'as_of')
!

requiredAsOf: options for: command
	(options at: 'as_of') ifNil: [ self usageError: command, ' requires --as-of / -d option' ].
	^ self nullify: (options at: 'as_of')
!

today
	"Today as YYYY-MM-DD."
	| today |
	today := Date today.
	^ String streamContents: [ :out |
		out
			nextPutAll: (today year printString padLeftTo: 4 with: $0);
			nextPut: $-;
			nextPutAll: (today monthIndex printString padLeftTo: 2 with: $0);
			nextPut: $-;
			nextPutAll: (today dayOfMonth printString padLeftTo: 2 with: $0) ]
!

isIntegerString: aString
	"True for ASCII digits, optionally after a minus sign."
	| digits |
	digits := (aString notEmpty and: [ aString first = $- ])
		ifTrue: [ aString allButFirst ]
		ifFalse: [ aString ].
	^ digits notEmpty and: [ digits allSatisfy: [ :c | c between: $0 and: $9 ] ]
!

helpText
	^ 'Usage: sayable <command> [arguments] [options]

Commands:
  age <dob>              Format an age
  stage <dob>            Get developmental stage
  date <date>            Format a calendar date
  relative <date>        Format a relative date
  time <time>            Format a clock time
  duration <value> [end] Format a duration
  since <start>          Format elapsed time
  until <target>         Format remaining time
  locales                List available locale codes
  version                Show version
  help                   Show this help

Options:
  -l, --locale <code>    Locale code (default: en)
  -d, --as-of <value>    Reference date/timestamp
      --short            Short compactness
      --compact          Compact compactness
  -g, --gender <m|f>     Gender for stage labels
      --with-year        Include year (date only)
  -h, --help             Show this help
  -v, --version          Show version'
! !
