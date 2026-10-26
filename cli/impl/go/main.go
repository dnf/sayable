package main

import (
	"bufio"
	"errors"
	"fmt"
	"io"
	"os"
	"sort"
	"strconv"
	"strings"
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
	if len(os.Args) == 2 && os.Args[1] == "--repl" {
		repl(os.Stdin, os.Stdout)
		return
	}
	os.Exit(run(os.Args[1:], os.Stdout))
}

// run executes one invocation, writing its stdout text to out, and returns
// the exit code. Usage errors are reported on stderr.
func run(argv []string, out io.Writer) int {
	code, err := dispatch(argv, out)
	var usage usageError
	if errors.As(err, &usage) {
		fmt.Fprintf(os.Stderr, "error: %s\n", usage.msg)
		fmt.Fprintln(os.Stderr, "Run 'sayable help' for usage.")
		return 2
	}
	return code
}

// command formats its arguments; a nil result is a null result.
type command func(positionals []string, opts options) (*string, error)

var commands = map[string]command{
	"age":      cmdAge,
	"stage":    cmdStage,
	"date":     cmdDate,
	"relative": cmdRelative,
	"time":     cmdTime,
	"duration": cmdDuration,
	"since":    cmdSince,
	"until":    cmdUntil,
}

func dispatch(argv []string, out io.Writer) (int, error) {
	name, positionals, opts, err := parseArgs(argv)
	if err != nil {
		return 2, err
	}

	switch name {
	case "":
		fmt.Fprintln(out, helpText)
		return 2, nil
	case "help":
		fmt.Fprintln(out, helpText)
		return 0, nil
	case "version":
		fmt.Fprintf(out, "sayable %s\n", version)
		return 0, nil
	case "locales":
		cmdLocales(out)
		return 0, nil
	}

	cmd, ok := commands[name]
	if !ok {
		return 2, usageErrorf("unknown command '%s'", name)
	}
	result, err := cmd(positionals, opts)
	if err != nil {
		return 2, err
	}
	if result == nil {
		return 1, nil
	}
	fmt.Fprintln(out, *result)
	return 0, nil
}

// repl answers one tab-separated request per input line (see cli/SPEC.md).
func repl(in io.Reader, out io.Writer) {
	scanner := bufio.NewScanner(in)
	scanner.Buffer(make([]byte, 0, 64*1024), 16*1024*1024)
	writer := bufio.NewWriter(out)
	for scanner.Scan() {
		request := strings.TrimSuffix(scanner.Text(), "\r")
		code, output := answer(strings.Split(request, "\t"))
		fmt.Fprintf(writer, "%d\t%s\n", code, output)
		_ = writer.Flush()
	}
}

// answer runs one request and returns its exit code and flattened output.
// A panic, which would crash a one-shot run with a failure exit, answers 1
// instead of ending the REPL.
func answer(argv []string) (code int, output string) {
	defer func() {
		if r := recover(); r != nil {
			fmt.Fprintf(os.Stderr, "error: %v\n", r)
			code, output = 1, ""
		}
	}()
	var captured strings.Builder
	code = run(argv, &captured)
	output = strings.ReplaceAll(strings.TrimRight(captured.String(), "\n"), "\n", "\t")
	return code, output
}

// parseArgs parses CLI arguments into (command, positionals, options).
func parseArgs(argv []string) (string, []string, options, error) {
	if len(argv) == 0 {
		return "", nil, options{}, nil
	}

	// Global flags that can appear as the first argument
	switch argv[0] {
	case "-h", "--help", "help":
		return "help", nil, options{}, nil
	case "-v", "--version", "version":
		return "version", nil, options{}, nil
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
					return "", nil, options{}, usageErrorf("'%s' requires a value", arg)
				}
				i++
				opts.locale = argv[i]
			case "-d", "--as-of":
				if i+1 >= len(argv) {
					return "", nil, options{}, usageErrorf("'%s' requires a value", arg)
				}
				i++
				opts.asOf = argv[i]
				opts.hasAsOf = true
			case "-g", "--gender":
				if i+1 >= len(argv) {
					return "", nil, options{}, usageErrorf("'%s' requires a value", arg)
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
				return "help", nil, options{}, nil
			case "-v", "--version":
				return "version", nil, options{}, nil
			default:
				return "", nil, options{}, usageErrorf("unknown option '%s'", arg)
			}
		} else {
			positionals = append(positionals, arg)
		}

		i++
	}

	return command, positionals, opts, nil
}

// nullify converts the CLI "null" sentinel to empty string (signaling nil).
// Returns the value and whether it was null.
func nullify(value string) (string, bool) {
	if value == "null" {
		return "", true
	}
	return value, false
}

// usageError is a usage mistake: reported on stderr, exit code 2.
type usageError struct{ msg string }

func (e usageError) Error() string { return e.msg }

func usageErrorf(format string, args ...any) error {
	return usageError{fmt.Sprintf(format, args...)}
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

func cmdAge(positionals []string, opts options) (*string, error) {
	if len(positionals) == 0 {
		return nil, usageErrorf("age requires a date-of-birth argument")
	}
	dob, isNull := nullify(positionals[0])

	locale := agelocales.GetLocale(opts.locale)
	if locale == nil {
		return nil, usageErrorf("unknown locale '%s'", opts.locale)
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

	return result, nil
}

func cmdStage(positionals []string, opts options) (*string, error) {
	if len(positionals) == 0 {
		return nil, usageErrorf("stage requires a date-of-birth argument")
	}
	dob, isNull := nullify(positionals[0])

	locale := agelocales.GetLocale(opts.locale)
	if locale == nil {
		return nil, usageErrorf("unknown locale '%s'", opts.locale)
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

	return result, nil
}

func cmdDate(positionals []string, opts options) (*string, error) {
	if len(positionals) == 0 {
		return nil, usageErrorf("date requires a date argument")
	}
	dateVal, isNull := nullify(positionals[0])

	locale := datelocales.GetLocale(opts.locale)
	if locale == nil {
		return nil, usageErrorf("unknown locale '%s'", opts.locale)
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

	return result, nil
}

func cmdRelative(positionals []string, opts options) (*string, error) {
	if len(positionals) == 0 {
		return nil, usageErrorf("relative requires a date argument")
	}
	dateVal, isNull := nullify(positionals[0])

	if !opts.hasAsOf {
		return nil, usageErrorf("relative requires --as-of / -d option")
	}
	asOf, asOfNull := nullify(opts.asOf)

	locale := datelocales.GetLocale(opts.locale)
	if locale == nil {
		return nil, usageErrorf("unknown locale '%s'", opts.locale)
	}

	formatter := sayabledate.NewSayableDate(*locale, dateCompactness(opts.compactness))

	var result *string
	if isNull || asOfNull {
		result = formatter.FormatRelative("", "")
	} else {
		result = formatter.FormatRelative(dateVal, asOf)
	}

	return result, nil
}

func cmdTime(positionals []string, opts options) (*string, error) {
	if len(positionals) == 0 {
		return nil, usageErrorf("time requires a time argument")
	}
	timeVal, isNull := nullify(positionals[0])

	locale := timelocales.GetLocale(opts.locale)
	if locale == nil {
		return nil, usageErrorf("unknown locale '%s'", opts.locale)
	}

	formatter := sayabletime.NewSayableTime(*locale, timeCompactness(opts.compactness))

	var result *string
	if isNull {
		result = formatter.FormatTime("")
	} else {
		result = formatter.FormatTime(timeVal)
	}

	return result, nil
}

func cmdDuration(positionals []string, opts options) (*string, error) {
	if len(positionals) == 0 {
		return nil, usageErrorf("duration requires a value argument")
	}
	value, isNull := nullify(positionals[0])

	locale := durationlocales.GetLocale(opts.locale)
	if locale == nil {
		return nil, usageErrorf("unknown locale '%s'", opts.locale)
	}

	formatter := sayableduration.NewSayableDuration(*locale, durationCompactness(opts.compactness))

	var result *string
	if isNull {
		// null input: pass -1 to get nil result
		result = formatter.FormatDurationSeconds(-1)
	} else if isInteger(value) {
		result = formatSeconds(formatter, value)
	} else {
		// Timestamp mode: need an end argument
		if len(positionals) < 2 {
			return nil, usageErrorf("duration with timestamps requires start and end arguments")
		}
		end, _ := nullify(positionals[1])
		result = formatter.FormatDurationISO(value, end)
	}

	return result, nil
}

func cmdSince(positionals []string, opts options) (*string, error) {
	if len(positionals) == 0 {
		return nil, usageErrorf("since requires a start timestamp argument")
	}
	start, isNull := nullify(positionals[0])

	if !opts.hasAsOf {
		return nil, usageErrorf("since requires --as-of / -d option")
	}
	asOf, asOfNull := nullify(opts.asOf)

	locale := durationlocales.GetLocale(opts.locale)
	if locale == nil {
		return nil, usageErrorf("unknown locale '%s'", opts.locale)
	}

	formatter := sayableduration.NewSayableDuration(*locale, durationCompactness(opts.compactness))

	var result *string
	if isNull || asOfNull {
		result = formatter.FormatSince("", "")
	} else {
		result = formatter.FormatSince(start, asOf)
	}

	return result, nil
}

func cmdUntil(positionals []string, opts options) (*string, error) {
	if len(positionals) == 0 {
		return nil, usageErrorf("until requires a target timestamp argument")
	}
	target, isNull := nullify(positionals[0])

	if !opts.hasAsOf {
		return nil, usageErrorf("until requires --as-of / -d option")
	}
	asOf, asOfNull := nullify(opts.asOf)

	locale := durationlocales.GetLocale(opts.locale)
	if locale == nil {
		return nil, usageErrorf("unknown locale '%s'", opts.locale)
	}

	formatter := sayableduration.NewSayableDuration(*locale, durationCompactness(opts.compactness))

	var result *string
	if isNull || asOfNull {
		result = formatter.FormatUntil("", "")
	} else {
		result = formatter.FormatUntil(target, asOf)
	}

	return result, nil
}

// allLocaleCodes returns all supported locale codes, sorted alphabetically.
var allLocaleCodes = []string{
	"af", "ak", "am", "ar", "ay", "az",
	"bci", "be", "bem", "bg", "bi", "bm", "bn", "br", "bs",
	"ca", "cak", "ceb", "cs", "cy",
	"da", "de", "din", "dje", "dv", "dyu", "dz",
	"ee", "el", "en", "es", "et", "eu",
	"fa", "fan", "ff", "fi", "fil", "fj", "fon", "fr",
	"ga", "gd", "gl", "gn", "gu", "gv",
	"ha", "he", "hi", "hmn", "hr", "ht", "hu", "hy",
	"id", "ig", "is", "it",
	"ja", "jv",
	"ka", "kbp", "kek", "ki", "kk", "kl", "km", "kn", "ko", "kpe", "kri", "ktu", "ku", "kw", "ky",
	"lb", "lg", "ln", "lo", "lt", "luo", "lv",
	"mam", "men", "mfe", "mg", "mi", "mk", "ml", "mn", "mnk", "mos", "mr", "ms", "mt", "my",
	"nb", "nd", "ne", "ng", "nl", "nr", "nso", "nus", "ny",
	"om", "or",
	"pa", "pis", "pl", "pov", "ps", "pt",
	"qu", "quc",
	"ro", "ru", "rw",
	"sar", "sd", "sg", "shi", "shn", "si", "sk", "sl", "sn", "snk", "so", "sq", "sr", "ss", "st", "su", "suk", "sv", "sw",
	"ta", "te", "tem", "tet", "tg", "th", "ti", "tig", "tk", "tn", "tpi", "tr", "ts", "tum", "tzm",
	"uk", "umb", "ur", "uz",
	"ve", "vi", "vmw",
	"wo",
	"xh",
	"yao", "yo", "yue",
	"zdj", "zh", "zu",
}

func cmdLocales(out io.Writer) {
	sorted := make([]string, len(allLocaleCodes))
	copy(sorted, allLocaleCodes)
	sort.Strings(sorted)
	for _, code := range sorted {
		fmt.Fprintln(out, code)
	}
}

// isInteger reports whether s is digits after any leading minus signs: the
// reference CLI's test for seconds mode.
func isInteger(s string) bool {
	digits := strings.TrimLeft(s, "-")
	if digits == "" {
		return false
	}
	for i := 0; i < len(digits); i++ {
		if digits[i] < '0' || digits[i] > '9' {
			return false
		}
	}
	return true
}

// formatSeconds formats seconds mode; a value that isn't a 64-bit integer has
// no value, since it is far beyond the 500-year ceiling (or malformed).
func formatSeconds(formatter *sayableduration.SayableDuration, value string) *string {
	seconds, err := strconv.ParseInt(value, 10, 64)
	if err != nil {
		return nil
	}
	return formatter.FormatDurationSeconds(seconds)
}
