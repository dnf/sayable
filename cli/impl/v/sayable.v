// Sayable CLI — unified command-line interface to all four Sayable components.
// See cli/SPEC.md for the full specification.
//
// V's module system requires all files in a directory to share the same module
// name. Since the four Sayable components each have their own `locales` module,
// build.sh copies each component's locales into a uniquely-named module
// directory (age_locales, date_locales, duration_locales, time_locales) before
// compilation.
module main

import os
import age_locales
import date_locales
import duration_locales
import time_locales

const cli_version = '0.5.0'

const help_text = 'Usage: sayable <command> [arguments] [options]

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

struct CliOptions {
mut:
	locale      string = 'en'
	as_of       string
	compactness string = 'normal'
	gender      string
	with_year   bool
}

// Outcome is what one invocation produces: its exit code and stdout text.
struct Outcome {
	code   int
	output string
}

fn usage_error(msg string) Outcome {
	eprintln('error: ${msg}')
	return Outcome{
		code: 2
	}
}

fn null_result() Outcome {
	return Outcome{
		code: 1
	}
}

fn printed(text string) Outcome {
	return Outcome{
		code:   0
		output: text + '\n'
	}
}

fn is_null_arg(s string) bool {
	return s == 'null'
}

fn today_str() string {
	r := os.execute('date +%Y-%m-%d')
	if r.exit_code == 0 {
		return r.output.trim_space()
	}
	return ''
}

fn is_integer(s string) bool {
	if s.len == 0 {
		return false
	}
	mut start := 0
	if s[0] == `-` {
		if s.len == 1 {
			return false
		}
		start = 1
	}
	for i in start .. s.len {
		if s[i] < `0` || s[i] > `9` {
			return false
		}
	}
	return true
}

// Parsed holds the parsed arguments, or the outcome when parsing already
// finished the invocation (help, version, or a usage error).
struct Parsed {
	positionals []string
	opts        CliOptions
	finished    bool
	outcome     Outcome
}

fn finished(outcome Outcome) Parsed {
	return Parsed{
		finished: true
		outcome:  outcome
	}
}

fn parse_options(args []string) Parsed {
	mut opts := CliOptions{}
	mut positionals := []string{}
	mut i := 0
	mut stop_opts := false

	for i < args.len {
		a := args[i]
		if a == '--' && !stop_opts {
			stop_opts = true
			i++
			continue
		}
		if !stop_opts && a.starts_with('-') {
			if a in ['-l', '--locale'] {
				if i + 1 >= args.len {
					return finished(usage_error("'${a}' requires a value"))
				}
				i++
				opts.locale = args[i]
				i++
				continue
			}
			if a in ['-d', '--as-of'] {
				if i + 1 >= args.len {
					return finished(usage_error("'${a}' requires a value"))
				}
				i++
				opts.as_of = args[i]
				i++
				continue
			}
			if a in ['-g', '--gender'] {
				if i + 1 >= args.len {
					return finished(usage_error("'${a}' requires a value"))
				}
				i++
				opts.gender = args[i]
				i++
				continue
			}
			if a == '--short' {
				opts.compactness = 'short'
				i++
				continue
			}
			if a == '--compact' {
				opts.compactness = 'compact'
				i++
				continue
			}
			if a == '--with-year' {
				opts.with_year = true
				i++
				continue
			}
			if a in ['-h', '--help'] {
				return finished(printed(help_text))
			}
			if a in ['-v', '--version'] {
				return finished(printed('sayable ${cli_version}'))
			}
			// Check for negative numbers
			if a.len > 1 && a[0] == `-` {
				if is_integer(a) {
					positionals << a
					i++
					continue
				}
			}
			return finished(usage_error("unknown option '${a}'"))
		}
		positionals << a
		i++
	}
	return Parsed{
		positionals: positionals
		opts:        opts
	}
}

// run executes one invocation (`args` excludes the program name).
fn run(args []string) Outcome {
	if args.len == 0 {
		return printed(help_text)
	}

	first := args[0]
	if first in ['-h', '--help', 'help'] {
		return printed(help_text)
	}
	if first in ['-v', '--version', 'version'] {
		return printed('sayable ${cli_version}')
	}

	if first == 'locales' {
		return cmd_locales()
	}

	command := first
	parsed := parse_options(args[1..])
	if parsed.finished {
		return parsed.outcome
	}
	positionals, opts := parsed.positionals, parsed.opts

	return match command {
		'age' { cmd_age(positionals, opts) }
		'stage' { cmd_stage(positionals, opts) }
		'date' { cmd_date(positionals, opts) }
		'relative' { cmd_relative(positionals, opts) }
		'time' { cmd_time(positionals, opts) }
		'duration' { cmd_duration(positionals, opts) }
		'since' { cmd_since(positionals, opts) }
		'until' { cmd_until(positionals, opts) }
		else { usage_error("unknown command '${command}'") }
	}
}

// repl answers one tab-separated request per stdin line (see cli/SPEC.md).
fn repl() {
	for {
		line := os.get_raw_line()
		if line.len == 0 {
			break
		}
		request := line.trim_right('\n').trim_right('\r')
		outcome := run(request.split('\t'))
		flat := outcome.output.trim_right('\n').replace('\n', '\t')
		print('${outcome.code}\t${flat}\n')
		flush_stdout()
	}
}

fn main() {
	args := os.args[1..]
	if args == ['--repl'] {
		repl()
		return
	}
	outcome := run(args)
	print(outcome.output)
	exit(outcome.code)
}

// --- Age commands ---

fn age_compactness(s string) age_locales.Compactness {
	return match s {
		'short' { .short }
		'compact' { .compact }
		else { .normal }
	}
}

fn cmd_age(positionals []string, opts CliOptions) Outcome {
	if positionals.len < 1 {
		return usage_error("'age' requires a date of birth argument")
	}
	if is_null_arg(positionals[0]) {
		return null_result()
	}
	locale := age_locales.get_locale(opts.locale) or {
		return usage_error("unknown locale '${opts.locale}'")
	}
	as_of := if opts.as_of.len > 0 { opts.as_of } else { today_str() }
	sa := age_locales.new_sayable_age(&locale, age_compactness(opts.compactness))
	result := sa.format_age(positionals[0], as_of) or { return null_result() }
	return printed(result)
}

fn cmd_stage(positionals []string, opts CliOptions) Outcome {
	if positionals.len < 1 {
		return usage_error("'stage' requires a date of birth argument")
	}
	if is_null_arg(positionals[0]) {
		return null_result()
	}
	locale := age_locales.get_locale(opts.locale) or {
		return usage_error("unknown locale '${opts.locale}'")
	}
	as_of := if opts.as_of.len > 0 { opts.as_of } else { today_str() }
	sa := age_locales.new_sayable_age(&locale, age_compactness(opts.compactness))
	result := sa.format_stage(positionals[0], as_of, opts.gender) or { return null_result() }
	return printed(result)
}

// --- Date commands ---

fn date_compactness(s string) date_locales.Compactness {
	return match s {
		'short' { .short }
		'compact' { .compact }
		else { .normal }
	}
}

fn cmd_date(positionals []string, opts CliOptions) Outcome {
	if positionals.len < 1 {
		return usage_error("'date' requires a date argument")
	}
	if is_null_arg(positionals[0]) {
		return null_result()
	}
	locale := date_locales.get_date_locale(opts.locale) or {
		return usage_error("unknown locale '${opts.locale}'")
	}
	sd := date_locales.new_sayable_date(&locale, date_compactness(opts.compactness))
	if opts.with_year {
		result := sd.format_date_with_year(positionals[0]) or { return null_result() }
		return printed(result)
	} else {
		result := sd.format_date(positionals[0]) or { return null_result() }
		return printed(result)
	}
}

fn cmd_relative(positionals []string, opts CliOptions) Outcome {
	if positionals.len < 1 {
		return usage_error("'relative' requires a date argument")
	}
	if opts.as_of.len == 0 {
		return usage_error("'relative' requires --as-of (-d) option")
	}
	if is_null_arg(positionals[0]) {
		return null_result()
	}
	locale := date_locales.get_date_locale(opts.locale) or {
		return usage_error("unknown locale '${opts.locale}'")
	}
	sd := date_locales.new_sayable_date(&locale, date_compactness(opts.compactness))
	result := sd.format_relative(positionals[0], opts.as_of) or { return null_result() }
	return printed(result)
}

// --- Time commands ---

fn time_compactness(s string) time_locales.Compactness {
	return match s {
		'short' { .short }
		'compact' { .compact }
		else { .normal }
	}
}

fn cmd_time(positionals []string, opts CliOptions) Outcome {
	if positionals.len < 1 {
		return usage_error("'time' requires a time argument")
	}
	if is_null_arg(positionals[0]) {
		return null_result()
	}
	locale := time_locales.get_time_locale(opts.locale) or {
		return usage_error("unknown locale '${opts.locale}'")
	}
	st := time_locales.new_sayable_time(&locale, time_compactness(opts.compactness))
	result := st.format_time(positionals[0]) or { return null_result() }
	return printed(result)
}

// --- Duration commands ---

fn duration_compactness(s string) duration_locales.Compactness {
	return match s {
		'short' { .short }
		'compact' { .compact }
		else { .normal }
	}
}

fn cmd_duration(positionals []string, opts CliOptions) Outcome {
	if positionals.len < 1 {
		return usage_error("'duration' requires a value argument")
	}
	if is_null_arg(positionals[0]) {
		return null_result()
	}
	locale := duration_locales.get_duration_locale(opts.locale) or {
		return usage_error("unknown locale '${opts.locale}'")
	}
	sd := duration_locales.new_sayable_duration(&locale, duration_compactness(opts.compactness))
	val := positionals[0]
	if is_integer(val) {
		secs := val.int()
		result := sd.format_duration(secs) or { return null_result() }
		return printed(result)
	} else {
		if positionals.len < 2 {
			return usage_error("'duration' with timestamps requires start and end arguments")
		}
		result := sd.format_duration_iso(val, positionals[1]) or { return null_result() }
		return printed(result)
	}
}

fn cmd_since(positionals []string, opts CliOptions) Outcome {
	if positionals.len < 1 {
		return usage_error("'since' requires a start argument")
	}
	if opts.as_of.len == 0 {
		return usage_error("'since' requires --as-of (-d) option")
	}
	if is_null_arg(positionals[0]) {
		return null_result()
	}
	locale := duration_locales.get_duration_locale(opts.locale) or {
		return usage_error("unknown locale '${opts.locale}'")
	}
	sd := duration_locales.new_sayable_duration(&locale, duration_compactness(opts.compactness))
	result := sd.format_since(positionals[0], opts.as_of) or { return null_result() }
	return printed(result)
}

fn cmd_until(positionals []string, opts CliOptions) Outcome {
	if positionals.len < 1 {
		return usage_error("'until' requires a target argument")
	}
	if opts.as_of.len == 0 {
		return usage_error("'until' requires --as-of (-d) option")
	}
	if is_null_arg(positionals[0]) {
		return null_result()
	}
	locale := duration_locales.get_duration_locale(opts.locale) or {
		return usage_error("unknown locale '${opts.locale}'")
	}
	sd := duration_locales.new_sayable_duration(&locale, duration_compactness(opts.compactness))
	result := sd.format_until(positionals[0], opts.as_of) or { return null_result() }
	return printed(result)
}

// --- Locales command ---

fn cmd_locales() Outcome {
	codes := ['af', 'ak', 'am', 'ar', 'ay', 'az', 'bci', 'be', 'bem', 'bg', 'bi', 'bm', 'bn', 'br',
		'bs', 'ca', 'cak', 'ceb', 'cs', 'cy', 'da', 'de', 'din', 'dje', 'dv', 'dyu', 'dz', 'ee',
		'el', 'en', 'es', 'et', 'eu', 'fa', 'fan', 'ff', 'fi', 'fil', 'fj', 'fon', 'fr', 'ga',
		'gd', 'gl', 'gn', 'gu', 'gv', 'ha', 'he', 'hi', 'hmn', 'hr', 'ht', 'hu', 'hy', 'id', 'ig',
		'is', 'it', 'ja', 'jv', 'ka', 'kbp', 'kek', 'ki', 'kk', 'kl', 'km', 'kn', 'ko', 'kpe',
		'kri', 'ktu', 'ku', 'kw', 'ky', 'lb', 'lg', 'ln', 'lo', 'lt', 'luo', 'lv', 'mam', 'men',
		'mfe', 'mg', 'mi', 'mk', 'ml', 'mn', 'mnk', 'mos', 'mr', 'ms', 'mt', 'my', 'nb', 'nd',
		'ne', 'ng', 'nl', 'nr', 'nso', 'nus', 'ny', 'om', 'or', 'pa', 'pis', 'pl', 'pov', 'ps',
		'pt', 'qu', 'quc', 'ro', 'ru', 'rw', 'sar', 'sd', 'sg', 'shi', 'shn', 'si', 'sk', 'sl',
		'sn', 'snk', 'so', 'sq', 'sr', 'ss', 'st', 'su', 'suk', 'sv', 'sw', 'ta', 'te', 'tem',
		'tet', 'tg', 'th', 'ti', 'tig', 'tk', 'tn', 'tpi', 'tr', 'ts', 'tum', 'tzm', 'uk', 'umb',
		'ur', 'uz', 've', 'vi', 'vmw', 'wo', 'xh', 'yao', 'yo', 'yue', 'zdj', 'zh', 'zu']
	return printed(codes.join('\n'))
}
