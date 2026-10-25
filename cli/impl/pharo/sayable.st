"Sayable CLI — loads the four Sayable libraries and SayableCli.st, then runs
the CLI. See cli/SPEC.md for the full specification."

| scriptDir projectRoot fileIn |

"Resolve cli/impl/pharo from the .st script on the command line, falling back
 to the working directory."
scriptDir := (Smalltalk commandLine arguments
	detect: [ :a | a endsWith: '.st' ]
	ifNone: [ nil ])
		ifNil: [ FileSystem workingDirectory ]
		ifNotNil: [ :script | script asFileReference asAbsolute parent ].
projectRoot := scriptDir parent parent parent.

fileIn := [ :file |
	file readStreamDo: [ :stream | CodeImporter evaluateString: stream contents ] ].

"Each component: locale type, locales holder, locale files, registry, formatter."
#('age' 'date' 'time' 'duration') do: [ :component |
	| implDir prefix |
	implDir := projectRoot / component / 'impl' / 'pharo'.
	prefix := 'Sayable', component capitalized.
	fileIn value: implDir / (prefix, 'Locale.st').
	fileIn value: implDir / (prefix, 'Locales.st').
	(implDir / 'locales') children
		select: [ :each | each extension = 'st' and: [ each basename ~= 'registry.st' ] ]
		thenDo: fileIn.
	fileIn value: implDir / 'locales' / 'registry.st'.
	fileIn value: implDir / (prefix, '.st') ].

fileIn value: scriptDir / 'SayableCli.st'.

(Smalltalk at: #SayableCli) main: Smalltalk commandLine arguments.
