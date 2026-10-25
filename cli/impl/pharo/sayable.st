"Sayable CLI — unified command-line interface to all four Sayable components.
See cli/SPEC.md for the full specification."

| projectRoot scriptRef scriptDir loader loadComponent
  SayableAgeClass SayableAgeLocalesClass
  SayableDateClass SayableDateLocalesClass
  SayableTimeClass SayableTimeLocalesClass
  SayableDurationClass SayableDurationLocalesClass
  version helpText
  usageErrorClass errorExit nullify getToday compactnessSymbol isIntegerString
  parseArgs
  cmdAge cmdStage cmdDate cmdRelative cmdTime cmdDuration cmdSince cmdUntil cmdLocales
  commands fixedCommands dispatch runCommand
  stdin readRequest splitFields formatResponse writeOut repl
  rawArgs argv foundSep outcome |

"Resolve project root from script location (cli/impl/pharo -> project root).
 Find the .st script path in the command line arguments."
projectRoot := nil.
Smalltalk commandLine arguments do: [ :a |
	(projectRoot isNil and: [ a endsWith: '.st' ]) ifTrue: [
		scriptRef := a asFileReference asAbsolute.
		scriptDir := scriptRef parent.
		"Navigate from cli/impl/pharo up to project root"
		projectRoot := scriptDir parent parent parent ] ].
"Fall back: assume CWD is cli/impl/pharo"
projectRoot ifNil: [
	projectRoot := FileSystem workingDirectory parent parent parent ].

"File loader helper"
loader := [ :dir :filename |
	(dir / filename) readStreamDo: [ :stream |
		stream contents fileIn ] ].

"Load a component: locale type, locales registry, locale files, registry, formatter"
loadComponent := [ :component :localeClass :localesClass :formatterFile |
	| implDir |
	implDir := projectRoot / component / 'impl' / 'pharo'.
	loader value: implDir value: localeClass.
	loader value: implDir value: localesClass.
	(implDir / 'locales') children
		select: [ :each | each extension = 'st' and: [ each basename ~= 'registry.st' ] ]
		thenDo: [ :each |
			each readStreamDo: [ :stream |
				stream contents fileIn ] ].
	(implDir / 'locales' / 'registry.st') readStreamDo: [ :stream |
		stream contents fileIn ].
	loader value: implDir value: formatterFile ].

"Load all four components"
loadComponent value: 'age' value: 'SayableAgeLocale.st' value: 'SayableAgeLocales.st' value: 'SayableAge.st'.
loadComponent value: 'date' value: 'SayableDateLocale.st' value: 'SayableDateLocales.st' value: 'SayableDate.st'.
loadComponent value: 'time' value: 'SayableTimeLocale.st' value: 'SayableTimeLocales.st' value: 'SayableTime.st'.
loadComponent value: 'duration' value: 'SayableDurationLocale.st' value: 'SayableDurationLocales.st' value: 'SayableDuration.st'.

"Dynamic class references (pharo st compiles script before fileIn runs)"
SayableAgeClass := Smalltalk at: #SayableAge.
SayableAgeLocalesClass := Smalltalk at: #SayableAgeLocales.
SayableDateClass := Smalltalk at: #SayableDate.
SayableDateLocalesClass := Smalltalk at: #SayableDateLocales.
SayableTimeClass := Smalltalk at: #SayableTime.
SayableTimeLocalesClass := Smalltalk at: #SayableTimeLocales.
SayableDurationClass := Smalltalk at: #SayableDuration.
SayableDurationLocalesClass := Smalltalk at: #SayableDurationLocales.

version := '0.5.0'.

helpText := 'Usage: sayable <command> [arguments] [options]

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
  -v, --version          Show version'.

"A usage error: its message is already on stderr; the run exits 2.
 Signalling it instead of exiting lets the REPL keep serving."
usageErrorClass := Error
	subclass: #SayableUsageError
	instanceVariableNames: ''
	classVariableNames: ''
	package: 'SayableCLI'.

"Helper: print error to stderr and fail the run with exit 2"
errorExit := [ :msg |
	Stdio stderr
		nextPutAll: 'error: '; nextPutAll: msg; nextPut: Character lf;
		nextPutAll: 'Run ''sayable help'' for usage.'; nextPut: Character lf;
		flush.
	usageErrorClass new signal: msg ].

"Helper: convert CLI 'null' sentinel to nil"
nullify := [ :val |
	val = 'null' ifTrue: [ nil ] ifFalse: [ val ] ].

"Helper: today as YYYY-MM-DD"
getToday := [
	| today y m d |
	today := Date today.
	y := today year printString.
	m := today monthIndex printString.
	m size = 1 ifTrue: [ m := '0', m ].
	d := today dayOfMonth printString.
	d size = 1 ifTrue: [ d := '0', d ].
	y, '-', m, '-', d ].

"Helper: compactness string to symbol"
compactnessSymbol := [ :str |
	str = 'short'
		ifTrue: [ #short ]
		ifFalse: [ str = 'compact' ifTrue: [ #compact ] ifFalse: [ #normal ] ] ].

"Helper: check if string is an integer (possibly negative)"
isIntegerString := [ :str |
	| s |
	s := (str size > 0 and: [ str first = $- ])
		ifTrue: [ str allButFirst ]
		ifFalse: [ str ].
	s notEmpty and: [ s allSatisfy: [ :c | c isDigit ] ] ].

"Argument parser — returns { command. positionals. options }"
parseArgs := [ :argArray |
	| cmd pos opts i stopOpts a matched |
	argArray isEmpty
		ifTrue: [ { nil. #(). Dictionary new } ]
		ifFalse: [
			((argArray first = '-h') or: [ (argArray first = '--help') or: [ argArray first = 'help' ] ])
				ifTrue: [ { 'help'. #(). Dictionary new } ]
				ifFalse: [
			((argArray first = '-v') or: [ (argArray first = '--version') or: [ argArray first = 'version' ] ])
				ifTrue: [ { 'version'. #(). Dictionary new } ]
				ifFalse: [
			cmd := argArray first.
			pos := OrderedCollection new.
			opts := Dictionary new.
			opts at: 'locale' put: 'en'.
			opts at: 'as_of' put: nil.
			opts at: 'compactness' put: 'normal'.
			opts at: 'gender' put: nil.
			opts at: 'with_year' put: false.
			i := 2.
			stopOpts := false.
			[ i <= argArray size ] whileTrue: [
				a := argArray at: i.
				(a = '--' and: [ stopOpts not ])
					ifTrue: [ stopOpts := true ]
					ifFalse: [
				(stopOpts not and: [ a size > 0 and: [ a first = $- ] ])
					ifTrue: [
						matched := false.
						((a = '-l') or: [ a = '--locale' ]) ifTrue: [
							i + 1 > argArray size ifTrue: [ errorExit value: '''', a, ''' requires a value' ].
							i := i + 1. opts at: 'locale' put: (argArray at: i). matched := true ].
						((a = '-d') or: [ a = '--as-of' ]) ifTrue: [
							i + 1 > argArray size ifTrue: [ errorExit value: '''', a, ''' requires a value' ].
							i := i + 1. opts at: 'as_of' put: (argArray at: i). matched := true ].
						((a = '-g') or: [ a = '--gender' ]) ifTrue: [
							i + 1 > argArray size ifTrue: [ errorExit value: '''', a, ''' requires a value' ].
							i := i + 1. opts at: 'gender' put: (argArray at: i). matched := true ].
						a = '--short' ifTrue: [ opts at: 'compactness' put: 'short'. matched := true ].
						a = '--compact' ifTrue: [ opts at: 'compactness' put: 'compact'. matched := true ].
						a = '--with-year' ifTrue: [ opts at: 'with_year' put: true. matched := true ].
						((a = '-h') or: [ a = '--help' ]) ifTrue: [
							cmd := 'help'. matched := true ].
						((a = '-v') or: [ a = '--version' ]) ifTrue: [
							cmd := 'version'. matched := true ].
						matched ifFalse: [ errorExit value: 'unknown option ''', a, '''' ] ]
					ifFalse: [
						pos add: a ] ].
				i := i + 1 ].
			{ cmd. pos asArray. opts } ] ] ] ].

"Command: age"
cmdAge := [ :pos :opts |
	| dob localeCode locale asOf comp formatter result |
	pos isEmpty ifTrue: [ errorExit value: 'age requires a date-of-birth argument' ].
	dob := nullify value: pos first.
	localeCode := opts at: 'locale'.
	locale := SayableAgeLocalesClass get: localeCode.
	locale ifNil: [ errorExit value: 'unknown locale ''', localeCode, '''' ].
	asOf := opts at: 'as_of'.
	asOf notNil
		ifTrue: [ asOf := nullify value: asOf ]
		ifFalse: [ asOf := getToday value ].
	comp := compactnessSymbol value: (opts at: 'compactness').
	formatter := SayableAgeClass withLocale: locale compactness: comp.
	result := formatter formatAge: dob asOf: asOf.
	result ].

"Command: stage"
cmdStage := [ :pos :opts |
	| dob localeCode locale asOf gender comp formatter result |
	pos isEmpty ifTrue: [ errorExit value: 'stage requires a date-of-birth argument' ].
	dob := nullify value: pos first.
	localeCode := opts at: 'locale'.
	locale := SayableAgeLocalesClass get: localeCode.
	locale ifNil: [ errorExit value: 'unknown locale ''', localeCode, '''' ].
	asOf := opts at: 'as_of'.
	asOf notNil
		ifTrue: [ asOf := nullify value: asOf ]
		ifFalse: [ asOf := getToday value ].
	gender := opts at: 'gender'.
	comp := compactnessSymbol value: (opts at: 'compactness').
	formatter := SayableAgeClass withLocale: locale compactness: comp.
	result := formatter formatStage: dob asOf: asOf gender: gender.
	result ].

"Command: date"
cmdDate := [ :pos :opts |
	| dateVal localeCode locale comp formatter result |
	pos isEmpty ifTrue: [ errorExit value: 'date requires a date argument' ].
	dateVal := nullify value: pos first.
	localeCode := opts at: 'locale'.
	locale := SayableDateLocalesClass get: localeCode.
	locale ifNil: [ errorExit value: 'unknown locale ''', localeCode, '''' ].
	comp := compactnessSymbol value: (opts at: 'compactness').
	formatter := SayableDateClass withLocale: locale compactness: comp.
	(opts at: 'with_year')
		ifTrue: [ result := formatter formatDateWithYear: dateVal ]
		ifFalse: [ result := formatter formatDate: dateVal ].
	result ].

"Command: relative"
cmdRelative := [ :pos :opts |
	| dateVal asOf localeCode locale comp formatter result |
	pos isEmpty ifTrue: [ errorExit value: 'relative requires a date argument' ].
	dateVal := nullify value: pos first.
	asOf := opts at: 'as_of'.
	asOf ifNil: [ errorExit value: 'relative requires --as-of / -d option' ].
	asOf := nullify value: asOf.
	localeCode := opts at: 'locale'.
	locale := SayableDateLocalesClass get: localeCode.
	locale ifNil: [ errorExit value: 'unknown locale ''', localeCode, '''' ].
	comp := compactnessSymbol value: (opts at: 'compactness').
	formatter := SayableDateClass withLocale: locale compactness: comp.
	result := formatter formatRelative: dateVal asOf: asOf.
	result ].

"Command: time"
cmdTime := [ :pos :opts |
	| timeVal localeCode locale comp formatter result |
	pos isEmpty ifTrue: [ errorExit value: 'time requires a time argument' ].
	timeVal := nullify value: pos first.
	localeCode := opts at: 'locale'.
	locale := SayableTimeLocalesClass get: localeCode.
	locale ifNil: [ errorExit value: 'unknown locale ''', localeCode, '''' ].
	comp := compactnessSymbol value: (opts at: 'compactness').
	formatter := SayableTimeClass withLocale: locale compactness: comp.
	result := formatter formatTime: timeVal.
	result ].

"Command: duration"
cmdDuration := [ :pos :opts |
	| val localeCode locale comp formatter result endVal |
	pos isEmpty ifTrue: [ errorExit value: 'duration requires a value argument' ].
	val := nullify value: pos first.
	localeCode := opts at: 'locale'.
	locale := SayableDurationLocalesClass get: localeCode.
	locale ifNil: [ errorExit value: 'unknown locale ''', localeCode, '''' ].
	comp := compactnessSymbol value: (opts at: 'compactness').
	formatter := SayableDurationClass withLocale: locale compactness: comp.
	val ifNil: [
		result := formatter formatDuration: nil ]
	ifNotNil: [
		(isIntegerString value: val)
			ifTrue: [ result := formatter formatDuration: val asInteger ]
			ifFalse: [
				pos size < 2 ifTrue: [
					errorExit value: 'duration with timestamps requires start and end arguments' ].
				endVal := nullify value: (pos at: 2).
				result := formatter formatDuration: val end: endVal ] ].
	result ].

"Command: since"
cmdSince := [ :pos :opts |
	| start asOf localeCode locale comp formatter result |
	pos isEmpty ifTrue: [ errorExit value: 'since requires a start timestamp argument' ].
	start := nullify value: pos first.
	asOf := opts at: 'as_of'.
	asOf ifNil: [ errorExit value: 'since requires --as-of / -d option' ].
	asOf := nullify value: asOf.
	localeCode := opts at: 'locale'.
	locale := SayableDurationLocalesClass get: localeCode.
	locale ifNil: [ errorExit value: 'unknown locale ''', localeCode, '''' ].
	comp := compactnessSymbol value: (opts at: 'compactness').
	formatter := SayableDurationClass withLocale: locale compactness: comp.
	result := formatter formatSince: start asOf: asOf.
	result ].

"Command: until"
cmdUntil := [ :pos :opts |
	| target asOf localeCode locale comp formatter result |
	pos isEmpty ifTrue: [ errorExit value: 'until requires a target timestamp argument' ].
	target := nullify value: pos first.
	asOf := opts at: 'as_of'.
	asOf ifNil: [ errorExit value: 'until requires --as-of / -d option' ].
	asOf := nullify value: asOf.
	localeCode := opts at: 'locale'.
	locale := SayableDurationLocalesClass get: localeCode.
	locale ifNil: [ errorExit value: 'unknown locale ''', localeCode, '''' ].
	comp := compactnessSymbol value: (opts at: 'compactness').
	formatter := SayableDurationClass withLocale: locale compactness: comp.
	result := formatter formatUntil: target asOf: asOf.
	result ].

"Command: locales"
cmdLocales := [
	String streamContents: [ :out |
		SayableAgeLocalesClass registry keys asSortedCollection
			do: [ :code | out nextPutAll: code ]
			separatedBy: [ out nextPut: Character lf ] ] ].

commands := Dictionary newFromPairs: {
	'age'. cmdAge.
	'stage'. cmdStage.
	'date'. cmdDate.
	'relative'. cmdRelative.
	'time'. cmdTime.
	'duration'. cmdDuration.
	'since'. cmdSince.
	'until'. cmdUntil }.

"Commands that take no arguments and always succeed"
fixedCommands := Dictionary newFromPairs: {
	'help'. [ helpText ].
	'version'. [ 'sayable ', version ].
	'locales'. cmdLocales }.

"Run one command; answers { exitCode. stdoutText or nil }"
dispatch := [ :args |
	| parsed command fixed handler result |
	parsed := parseArgs value: args.
	command := parsed first.
	command
		ifNil: [ { 2. helpText } ]
		ifNotNil: [
			fixed := fixedCommands at: command ifAbsent: [ nil ].
			fixed
				ifNotNil: [ { 0. fixed value } ]
				ifNil: [
					handler := commands at: command ifAbsent: [
						errorExit value: 'unknown command ''', command, '''' ].
					result := handler value: parsed second value: parsed third.
					result
						ifNil: [ { 1. nil } ]
						ifNotNil: [ { 0. result } ] ] ] ].

"Run one command as the one-shot CLI would, without printing or exiting"
runCommand := [ :args |
	[ dispatch value: args ]
		on: usageErrorClass
		do: [ :e | e return: { 2. nil } ] ].

"Helper: write a line to stdout and flush it (REPL responses must not wait in a buffer)"
writeOut := [ :text |
	Stdio stdout nextPutAll: text; nextPut: Character lf; flush ].

"REPL (see cli/SPEC.md): one tab-separated request per stdin line.
 Lines are read a byte at a time and decoded as UTF-8, so a request is
 answered as soon as its newline arrives. Answers nil at end of input."
stdin := Stdio stdin.
readRequest := [
	| bytes byte line |
	bytes := WriteStream on: ByteArray new.
	[ byte := stdin next.
	  byte notNil and: [ byte asInteger ~= 10 ] ]
		whileTrue: [ bytes nextPut: byte asInteger ].
	(byte isNil and: [ bytes contents isEmpty ])
		ifTrue: [ nil ]
		ifFalse: [
			line := bytes contents utf8Decoded.
			(line notEmpty and: [ line last = Character cr ])
				ifTrue: [ line allButLast ]
				ifFalse: [ line ] ] ].

"Helper: split on tabs, keeping empty fields ('age<TAB>' is 'age' and '')"
splitFields := [ :line |
	| fields start |
	fields := OrderedCollection new.
	start := 1.
	line doWithIndex: [ :char :index |
		char = Character tab ifTrue: [
			fields add: (line copyFrom: start to: index - 1).
			start := index + 1 ] ].
	fields add: (line copyFrom: start to: line size).
	fields asArray ].

formatResponse := [ :result |
	| text |
	text := result second ifNil: [ '' ].
	[ text notEmpty and: [ text last = Character lf ] ]
		whileTrue: [ text := text allButLast ].
	result first printString, (String with: Character tab),
		(text copyReplaceAll: (String with: Character lf) with: (String with: Character tab)) ].

repl := [
	| line response |
	[ (line := readRequest value) notNil ] whileTrue: [
		response := [ formatResponse value: (runCommand value: (splitFields value: line)) ]
			on: Error
			do: [ :e |
				"A crash exits 1 in one-shot mode; keep serving."
				Stdio stderr nextPutAll: e description; nextPut: Character lf; flush.
				e return: '1', (String with: Character tab) ].
		writeOut value: response ].
	Smalltalk exit: 0 ].

"Main: extract user arguments from command line.
 When invoked as 'pharo --headless Pharo.image st sayable.st -- arg1 arg2',
 Smalltalk commandLine arguments returns all tokens after the image name:
 #('st' '/path/to/sayable.st' '--' 'age' '2020-01-01' ...).
 We skip past the .st file and any '--' separator to get user args."
rawArgs := Smalltalk commandLine arguments.

argv := OrderedCollection new.
foundSep := false.
rawArgs do: [ :a |
	foundSep
		ifTrue: [
			"Skip the '--' immediately after the script name"
			(a = '--' and: [ argv isEmpty ])
				ifFalse: [ argv add: a ] ]
		ifFalse: [
			(a endsWith: '.st')
				ifTrue: [ foundSep := true ] ] ].

"If no .st file found in args, fall back to using all args
 (handles alternative invocation patterns)"
foundSep ifFalse: [ argv := rawArgs asOrderedCollection ].

(argv size = 1 and: [ argv first = '--repl' ]) ifTrue: [ repl value ].

outcome := runCommand value: argv asArray.
outcome second ifNotNil: [ :text | writeOut value: text ].
Smalltalk exit: outcome first.
