package main

import (
	"fmt"
	"os"
	"sort"
	"time"

	sayableage "github.com/dnf/sayable/age/impl/go"
	agelocales "github.com/dnf/sayable/age/impl/go/locales"
	sayabledate "github.com/dnf/sayable/date/impl/go"
	datelocales "github.com/dnf/sayable/date/impl/go/locales"
	sayableduration "github.com/dnf/sayable/duration/impl/go"
	durationlocales "github.com/dnf/sayable/duration/impl/go/locales"
	sayabletime "github.com/dnf/sayable/time/impl/go"
	timelocales "github.com/dnf/sayable/time/impl/go/locales"
)

const version = "0.5.0"

const helpText = `Usage: sayable <command> [arguments] [options]

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
  -v, --version          Show version`

// options holds parsed CLI options.
type options struct {
	locale      string
	asOf        string
	hasAsOf     bool
	compactness string
	gender      string
	withYear    bool
}

func main() {
	command, positionals, opts := parseArgs(os.Args[1:])

	switch command {
	case "":
		fmt.Println(helpText)
		os.Exit(2)
	case "help":
		fmt.Println(helpText)
		os.Exit(0)
	case "version":
		fmt.Printf("sayable %s\n", version)
		os.Exit(0)
	case "locales":
		cmdLocales()
		os.Exit(0)
	case "age":
		cmdAge(positionals, opts)
	case "stage":
		cmdStage(positionals, opts)
	case "date":
		cmdDate(positionals, opts)
	case "relative":
		cmdRelative(positionals, opts)
	case "time":
		cmdTime(positionals, opts)
	case "duration":
		cmdDuration(positionals, opts)
	case "since":
		cmdSince(positionals, opts)
	case "until":
		cmdUntil(positionals, opts)
	default:
		cliError(fmt.Sprintf("unknown command '%s'", command))
	}
}

// parseArgs parses CLI arguments into (command, positionals, options).
func parseArgs(argv []string) (string, []string, options) {
	if len(argv) == 0 {
		return "", nil, options{}
	}

	// Global flags that can appear as the first argument
	switch argv[0] {
	case "-h", "--help", "help":
		return "help", nil, options{}
	case "-v", "--version", "version":
		return "version", nil, options{}
	}

	command := argv[0]
	positionals := []string{}
	opts := options{
		locale:      "en",
		compactness: "normal",
	}

	i := 1
	stopOpts := false
	for i < len(argv) {
		arg := argv[i]

		if arg == "--" && !stopOpts {
			stopOpts = true
			i++
			continue
		}

		if !stopOpts && len(arg) > 0 && arg[0] == '-' {
			switch arg {
			case "-l", "--locale":
				if i+1 >= len(argv) {
					cliError(fmt.Sprintf("'%s' requires a value", arg))
				}
				i++
				opts.locale = argv[i]
			case "-d", "--as-of":
				if i+1 >= len(argv) {
					cliError(fmt.Sprintf("'%s' requires a value", arg))
				}
				i++
				opts.asOf = argv[i]
				opts.hasAsOf = true
			case "-g", "--gender":
				if i+1 >= len(argv) {
					cliError(fmt.Sprintf("'%s' requires a value", arg))
				}
				i++
				opts.gender = argv[i]
			case "--short":
				opts.compactness = "short"
			case "--compact":
				opts.compactness = "compact"
			case "--with-year":
				opts.withYear = true
			case "-h", "--help":
				return "help", nil, options{}
			case "-v", "--version":
				return "version", nil, options{}
			default:
				cliError(fmt.Sprintf("unknown option '%s'", arg))
			}
		} else {
			positionals = append(positionals, arg)
		}

		i++
	}

	return command, positionals, opts
}

// nullify converts the CLI "null" sentinel to empty string (signaling nil).
// Returns the value and whether it was null.
func nullify(value string) (string, bool) {
	if value == "null" {
		return "", true
	}
	return value, false
}

// cliError prints an error to stderr and exits with code 2.
func cliError(msg string) {
	fmt.Fprintf(os.Stderr, "error: %s\n", msg)
	fmt.Fprintln(os.Stderr, "Run 'sayable help' for usage.")
	os.Exit(2)
}

// getToday returns today's date as YYYY-MM-DD.
func getToday() string {
	now := time.Now()
	return fmt.Sprintf("%04d-%02d-%02d", now.Year(), int(now.Month()), now.Day())
}

// ageCompactness converts the string compactness to the age library type.
func ageCompactness(s string) sayableage.Compactness {
	switch s {
	case "short":
		return sayableage.Short
	case "compact":
		return sayableage.Compact
	default:
		return sayableage.Normal
	}
}

// dateCompactness converts the string compactness to the date library type.
func dateCompactness(s string) sayabledate.Compactness {
	switch s {
	case "short":
		return sayabledate.Short
	case "compact":
		return sayabledate.Compact
	default:
		return sayabledate.Normal
	}
}

// timeCompactness converts the string compactness to the time library type.
func timeCompactness(s string) sayabletime.Compactness {
	switch s {
	case "short":
		return sayabletime.Short
	case "compact":
		return sayabletime.Compact
	default:
		return sayabletime.Normal
	}
}

// durationCompactness converts the string compactness to the duration library type.
func durationCompactness(s string) sayableduration.Compactness {
	switch s {
	case "short":
		return sayableduration.Short
	case "compact":
		return sayableduration.Compact
	default:
		return sayableduration.Normal
	}
}

func cmdAge(positionals []string, opts options) {
	if len(positionals) == 0 {
		cliError("age requires a date-of-birth argument")
	}
	dob, isNull := nullify(positionals[0])

	locale := agelocales.GetLocale(opts.locale)
	if locale == nil {
		cliError(fmt.Sprintf("unknown locale '%s'", opts.locale))
	}

	asOf := opts.asOf
	if opts.hasAsOf {
		asOfVal, asOfNull := nullify(opts.asOf)
		if asOfNull {
			asOf = ""
		} else {
			asOf = asOfVal
		}
	} else {
		asOf = getToday()
	}

	formatter := sayableage.NewSayableAge(*locale, ageCompactness(opts.compactness))

	var result *string
	if isNull {
		result = formatter.FormatAge("")
	} else {
		result = formatter.FormatAge(dob, asOf)
	}

	if result == nil {
		os.Exit(1)
	}
	fmt.Println(*result)
}

func cmdStage(positionals []string, opts options) {
	if len(positionals) == 0 {
		cliError("stage requires a date-of-birth argument")
	}
	dob, isNull := nullify(positionals[0])

	locale := agelocales.GetLocale(opts.locale)
	if locale == nil {
		cliError(fmt.Sprintf("unknown locale '%s'", opts.locale))
	}

	asOf := opts.asOf
	if opts.hasAsOf {
		asOfVal, asOfNull := nullify(opts.asOf)
		if asOfNull {
			asOf = ""
		} else {
			asOf = asOfVal
		}
	} else {
		asOf = getToday()
	}

	formatter := sayableage.NewSayableAge(*locale, ageCompactness(opts.compactness))

	var result *string
	if isNull {
		result = formatter.FormatStage("")
	} else {
		result = formatter.FormatStage(dob, asOf, opts.gender)
	}

	if result == nil {
		os.Exit(1)
	}
	fmt.Println(*result)
}

func cmdDate(positionals []string, opts options) {
	if len(positionals) == 0 {
		cliError("date requires a date argument")
	}
	dateVal, isNull := nullify(positionals[0])

	locale := datelocales.GetLocale(opts.locale)
	if locale == nil {
		cliError(fmt.Sprintf("unknown locale '%s'", opts.locale))
	}

	formatter := sayabledate.NewSayableDate(*locale, dateCompactness(opts.compactness))

	var result *string
	if isNull {
		if opts.withYear {
			result = formatter.FormatDateWithYear("")
		} else {
			result = formatter.FormatDate("")
		}
	} else {
		if opts.withYear {
			result = formatter.FormatDateWithYear(dateVal)
		} else {
			result = formatter.FormatDate(dateVal)
		}
	}

	if result == nil {
		os.Exit(1)
	}
	fmt.Println(*result)
}

func cmdRelative(positionals []string, opts options) {
	if len(positionals) == 0 {
		cliError("relative requires a date argument")
	}
	dateVal, isNull := nullify(positionals[0])

	if !opts.hasAsOf {
		cliError("relative requires --as-of / -d option")
	}
	asOf, asOfNull := nullify(opts.asOf)

	locale := datelocales.GetLocale(opts.locale)
	if locale == nil {
		cliError(fmt.Sprintf("unknown locale '%s'", opts.locale))
	}

	formatter := sayabledate.NewSayableDate(*locale, dateCompactness(opts.compactness))

	var result *string
	if isNull || asOfNull {
		result = formatter.FormatRelative("", "")
	} else {
		result = formatter.FormatRelative(dateVal, asOf)
	}

	if result == nil {
		os.Exit(1)
	}
	fmt.Println(*result)
}

func cmdTime(positionals []string, opts options) {
	if len(positionals) == 0 {
		cliError("time requires a time argument")
	}
	timeVal, isNull := nullify(positionals[0])

	locale := timelocales.GetLocale(opts.locale)
	if locale == nil {
		cliError(fmt.Sprintf("unknown locale '%s'", opts.locale))
	}

	formatter := sayabletime.NewSayableTime(*locale, timeCompactness(opts.compactness))

	var result *string
	if isNull {
		result = formatter.FormatTime("")
	} else {
		result = formatter.FormatTime(timeVal)
	}

	if result == nil {
		os.Exit(1)
	}
	fmt.Println(*result)
}

func cmdDuration(positionals []string, opts options) {
	if len(positionals) == 0 {
		cliError("duration requires a value argument")
	}
	value, isNull := nullify(positionals[0])

	locale := durationlocales.GetLocale(opts.locale)
	if locale == nil {
		cliError(fmt.Sprintf("unknown locale '%s'", opts.locale))
	}

	formatter := sayableduration.NewSayableDuration(*locale, durationCompactness(opts.compactness))

	var result *string
	if isNull {
		// null input: pass -1 to get nil result
		result = formatter.FormatDurationSeconds(-1)
	} else if isInteger(value) {
		seconds := parseInt(value)
		result = formatter.FormatDurationSeconds(seconds)
	} else {
		// Timestamp mode: need an end argument
		if len(positionals) < 2 {
			cliError("duration with timestamps requires start and end arguments")
		}
		end, _ := nullify(positionals[1])
		result = formatter.FormatDurationISO(value, end)
	}

	if result == nil {
		os.Exit(1)
	}
	fmt.Println(*result)
}

func cmdSince(positionals []string, opts options) {
	if len(positionals) == 0 {
		cliError("since requires a start timestamp argument")
	}
	start, isNull := nullify(positionals[0])

	if !opts.hasAsOf {
		cliError("since requires --as-of / -d option")
	}
	asOf, asOfNull := nullify(opts.asOf)

	locale := durationlocales.GetLocale(opts.locale)
	if locale == nil {
		cliError(fmt.Sprintf("unknown locale '%s'", opts.locale))
	}

	formatter := sayableduration.NewSayableDuration(*locale, durationCompactness(opts.compactness))

	var result *string
	if isNull || asOfNull {
		result = formatter.FormatSince("", "")
	} else {
		result = formatter.FormatSince(start, asOf)
	}

	if result == nil {
		os.Exit(1)
	}
	fmt.Println(*result)
}

func cmdUntil(positionals []string, opts options) {
	if len(positionals) == 0 {
		cliError("until requires a target timestamp argument")
	}
	target, isNull := nullify(positionals[0])

	if !opts.hasAsOf {
		cliError("until requires --as-of / -d option")
	}
	asOf, asOfNull := nullify(opts.asOf)

	locale := durationlocales.GetLocale(opts.locale)
	if locale == nil {
		cliError(fmt.Sprintf("unknown locale '%s'", opts.locale))
	}

	formatter := sayableduration.NewSayableDuration(*locale, durationCompactness(opts.compactness))

	var result *string
	if isNull || asOfNull {
		result = formatter.FormatUntil("", "")
	} else {
		result = formatter.FormatUntil(target, asOf)
	}

	if result == nil {
		os.Exit(1)
	}
	fmt.Println(*result)
}

// allLocaleCodes returns all supported locale codes, sorted alphabetically.
var allLocaleCodes = []string{
	"af", "ak", "am", "ar", "az",
	"bci", "be", "bem", "bg", "bm", "bn", "br", "bs",
	"ca", "ceb", "cs", "cy",
	"da", "de", "din", "dje", "dyu",
	"ee", "el", "en", "es", "et", "eu",
	"fa", "fan", "ff", "fi", "fil", "fon", "fr",
	"ga", "gd", "gl", "gn", "gu", "gv",
	"ha", "he", "hi", "hr", "ht", "hu", "hy",
	"id", "ig", "is", "it",
	"ja", "jv",
	"ka", "kbp", "kk", "km", "kn", "ko", "kpe", "ktu", "ku", "kw", "ky",
	"lg", "ln", "lo", "lt", "lv",
	"men", "mfe", "mg", "mi", "mk", "ml", "mn", "mnk", "mos", "mr", "ms", "mt", "my",
	"nb", "nd", "ne", "ng", "nl", "nso", "nus", "ny",
	"om", "or",
	"pa", "pl", "pov", "ps", "pt",
	"qu",
	"ro", "ru", "rw",
	"sar", "sd", "sg", "shi", "si", "sk", "sl", "sn", "snk", "so", "sq", "sr", "ss", "st", "su", "suk", "sv", "sw",
	"ta", "te", "tem", "tg", "th", "ti", "tig", "tk", "tn", "tr", "ts", "tzm",
	"uk", "umb", "ur", "uz",
	"vi", "vmw",
	"wo",
	"xh",
	"yo", "yue",
	"zdj", "zh", "zu",
}

func cmdLocales() {
	sorted := make([]string, len(allLocaleCodes))
	copy(sorted, allLocaleCodes)
	sort.Strings(sorted)
	for _, code := range sorted {
		fmt.Println(code)
	}
}

// isInteger returns true if the string represents an integer (possibly negative).
func isInteger(s string) bool {
	if len(s) == 0 {
		return false
	}
	start := 0
	if s[0] == '-' {
		start = 1
		if len(s) == 1 {
			return false
		}
	}
	for i := start; i < len(s); i++ {
		if s[i] < '0' || s[i] > '9' {
			return false
		}
	}
	return true
}

// parseInt parses a string as an integer (possibly negative).
func parseInt(s string) int {
	negative := false
	start := 0
	if s[0] == '-' {
		negative = true
		start = 1
	}
	n := 0
	for i := start; i < len(s); i++ {
		n = n*10 + int(s[i]-'0')
	}
	if negative {
		return -n
	}
	return n
}
