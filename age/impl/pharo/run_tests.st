"Load all source files and run tests headlessly."

| dir loader suite result |
dir := FileSystem workingDirectory.

"Load classes in order"
loader := [ :filename |
	(dir / filename) readStreamDo: [ :stream |
		stream contents fileIn ] ].

loader value: 'SayableAgeLocale.st'.
loader value: 'SayableAgeLocales.st'.

"Load all locale files"
(dir / 'locales') children
	select: [ :each | each extension = 'st' and: [ each basename ~= 'registry.st' ] ]
	thenDo: [ :each |
		each readStreamDo: [ :stream |
			stream contents fileIn ] ].

"Load registry"
(dir / 'locales' / 'registry.st') readStreamDo: [ :stream |
	stream contents fileIn ].

"Load formatter"
loader value: 'SayableAge.st'.

"Load tests"
loader value: 'SayableAgeTest.st'.

"Run tests"
suite := TestSuite new.
suite addTests: SayableAgeFormatAgeTest buildSuite tests.
suite addTests: SayableAgeFormatStageTest buildSuite tests.
suite addTests: SayableAgeFormatterTest buildSuite tests.

result := suite run.

Transcript show: 'Tests run: ', result runCount printString; cr.
Transcript show: 'Passed: ', result passedCount printString; cr.
Transcript show: 'Failures: ', result failureCount printString; cr.
Transcript show: 'Errors: ', result errorCount printString; cr.

result failures do: [ :each |
	Transcript show: 'FAIL: ', each printString; cr ].
result errors do: [ :each |
	Transcript show: 'ERROR: ', each printString; cr ].

result hasFailures ifTrue: [ Smalltalk exit: 1 ].
result hasErrors ifTrue: [ Smalltalk exit: 1 ].
Smalltalk exit: 0.
