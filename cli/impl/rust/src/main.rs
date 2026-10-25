use std::env;
use std::io::{self, BufRead, Write};
use std::process;

use sayable_age::{Compactness as AgeCompactness, Gender, SayableAge};
use sayable_date::{Compactness as DateCompactness, SayableDate};
use sayable_duration::types::Compactness as DurationCompactness;
use sayable_duration::SayableDuration;
use sayable_time::{Compactness as TimeCompactness, SayableTime};

const VERSION: &str = "0.5.0";

const HELP: &str = "\
Usage: sayable <command> [arguments] [options]

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
  -v, --version          Show version";

/// Parsed CLI options.
struct Options {
    locale: String,
    as_of: Option<String>,
    compactness: String,
    gender: Option<String>,
    with_year: bool,
}

/// A usage error: reported on stderr, exit code 2.
struct UsageError(String);

/// A command's result: `Ok(Some(text))` prints text, `Ok(None)` is a null result.
type CmdResult = Result<Option<String>, UsageError>;

fn error(msg: &str) -> UsageError {
    UsageError(msg.to_string())
}

/// Convert the CLI "null" sentinel to None.
fn nullify(value: &str) -> Option<&str> {
    if value == "null" {
        None
    } else {
        Some(value)
    }
}

/// Parse CLI arguments into (command, positionals, options).
type Parsed<'a> = (Option<&'a str>, Vec<&'a str>, Options);

fn parse_args(args: &[String]) -> Result<Parsed<'_>, UsageError> {
    if args.is_empty() {
        return Ok((
            None,
            Vec::new(),
            Options {
                locale: "en".to_string(),
                as_of: None,
                compactness: "normal".to_string(),
                gender: None,
                with_year: false,
            },
        ));
    }

    // Global flags that can appear as the first argument
    let first = args[0].as_str();
    if matches!(first, "-h" | "--help" | "help") {
        return Ok((
            Some("help"),
            Vec::new(),
            Options {
                locale: "en".to_string(),
                as_of: None,
                compactness: "normal".to_string(),
                gender: None,
                with_year: false,
            },
        ));
    }
    if matches!(first, "-v" | "--version" | "version") {
        return Ok((
            Some("version"),
            Vec::new(),
            Options {
                locale: "en".to_string(),
                as_of: None,
                compactness: "normal".to_string(),
                gender: None,
                with_year: false,
            },
        ));
    }

    let command = args[0].as_str();
    let mut positionals: Vec<&str> = Vec::new();
    let mut opts = Options {
        locale: "en".to_string(),
        as_of: None,
        compactness: "normal".to_string(),
        gender: None,
        with_year: false,
    };

    let mut i = 1;
    let mut stop_opts = false;

    while i < args.len() {
        let arg = args[i].as_str();

        if arg == "--" && !stop_opts {
            stop_opts = true;
            i += 1;
            continue;
        }

        if !stop_opts && arg.starts_with('-') {
            match arg {
                "-l" | "--locale" => {
                    if i + 1 >= args.len() {
                        return Err(error(&format!("'{arg}' requires a value")));
                    }
                    i += 1;
                    opts.locale = args[i].clone();
                }
                "-d" | "--as-of" => {
                    if i + 1 >= args.len() {
                        return Err(error(&format!("'{arg}' requires a value")));
                    }
                    i += 1;
                    opts.as_of = Some(args[i].clone());
                }
                "-g" | "--gender" => {
                    if i + 1 >= args.len() {
                        return Err(error(&format!("'{arg}' requires a value")));
                    }
                    i += 1;
                    opts.gender = Some(args[i].clone());
                }
                "--short" => {
                    opts.compactness = "short".to_string();
                }
                "--compact" => {
                    opts.compactness = "compact".to_string();
                }
                "--with-year" => {
                    opts.with_year = true;
                }
                "-h" | "--help" => {
                    return Ok((Some("help"), Vec::new(), opts));
                }
                "-v" | "--version" => {
                    return Ok((Some("version"), Vec::new(), opts));
                }
                _ => {
                    return Err(error(&format!("unknown option '{arg}'")));
                }
            }
        } else {
            positionals.push(args[i].as_str());
        }

        i += 1;
    }

    Ok((Some(command), positionals, opts))
}

/// Get today's date as YYYY-MM-DD.
fn get_today() -> String {
    use std::time::{SystemTime, UNIX_EPOCH};
    let secs = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs() as i64;
    let days = (secs / 86400) as i32;
    let z = days + 719468;
    let era = if z >= 0 { z } else { z - 146096 } / 146097;
    let doe = z - era * 146097;
    let yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365;
    let y = yoe + era * 400;
    let doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
    let mp = (5 * doy + 2) / 153;
    let d = doy - (153 * mp + 2) / 5 + 1;
    let m = if mp < 10 { mp + 3 } else { mp - 9 };
    let y = if m <= 2 { y + 1 } else { y };
    format!("{y:04}-{m:02}-{d:02}")
}

fn age_compactness(s: &str) -> AgeCompactness {
    match s {
        "short" => AgeCompactness::Short,
        "compact" => AgeCompactness::Compact,
        _ => AgeCompactness::Normal,
    }
}

fn date_compactness(s: &str) -> DateCompactness {
    match s {
        "short" => DateCompactness::Short,
        "compact" => DateCompactness::Compact,
        _ => DateCompactness::Normal,
    }
}

fn time_compactness(s: &str) -> TimeCompactness {
    match s {
        "short" => TimeCompactness::Short,
        "compact" => TimeCompactness::Compact,
        _ => TimeCompactness::Normal,
    }
}

fn duration_compactness(s: &str) -> DurationCompactness {
    match s {
        "short" => DurationCompactness::Short,
        "compact" => DurationCompactness::Compact,
        _ => DurationCompactness::Normal,
    }
}

fn cmd_age(positionals: &[&str], opts: &Options) -> CmdResult {
    if positionals.is_empty() {
        return Err(error("age requires a date-of-birth argument"));
    }
    let dob = nullify(positionals[0]);

    let locale = sayable_age::locales::get(&opts.locale)
        .ok_or_else(|| error(&format!("unknown locale '{}'", opts.locale)))?;

    let as_of = match &opts.as_of {
        Some(v) => match nullify(v) {
            Some(s) => s.to_string(),
            None => get_today(),
        },
        None => get_today(),
    };

    let formatter = SayableAge::new(locale, age_compactness(&opts.compactness));

    match dob {
        Some(dob_str) => Ok(formatter.format_age(dob_str, Some(&as_of))),
        None => Ok(None),
    }
}

fn cmd_stage(positionals: &[&str], opts: &Options) -> CmdResult {
    if positionals.is_empty() {
        return Err(error("stage requires a date-of-birth argument"));
    }
    let dob = nullify(positionals[0]);

    let locale = sayable_age::locales::get(&opts.locale)
        .ok_or_else(|| error(&format!("unknown locale '{}'", opts.locale)))?;

    let as_of = match &opts.as_of {
        Some(v) => match nullify(v) {
            Some(s) => s.to_string(),
            None => get_today(),
        },
        None => get_today(),
    };

    let gender = opts.gender.as_ref().map(|g| match g.as_str() {
        "f" | "F" => Gender::F,
        _ => Gender::M,
    });

    let formatter = SayableAge::new(locale, age_compactness(&opts.compactness));

    match dob {
        Some(dob_str) => Ok(formatter.format_stage(dob_str, Some(&as_of), gender)),
        None => Ok(None),
    }
}

fn cmd_date(positionals: &[&str], opts: &Options) -> CmdResult {
    if positionals.is_empty() {
        return Err(error("date requires a date argument"));
    }
    let date_val = nullify(positionals[0]);

    let locale = sayable_date::locales::get(&opts.locale)
        .ok_or_else(|| error(&format!("unknown locale '{}'", opts.locale)))?;

    let formatter = SayableDate::new(locale, date_compactness(&opts.compactness));

    match date_val {
        Some(d) => {
            if opts.with_year {
                Ok(formatter.format_date_with_year(d))
            } else {
                Ok(formatter.format_date(d))
            }
        }
        None => Ok(None),
    }
}

fn cmd_relative(positionals: &[&str], opts: &Options) -> CmdResult {
    if positionals.is_empty() {
        return Err(error("relative requires a date argument"));
    }
    let date_val = nullify(positionals[0]);

    let as_of_raw = match &opts.as_of {
        Some(v) => v.as_str(),
        None => return Err(error("relative requires --as-of / -d option")),
    };
    let as_of = nullify(as_of_raw);

    let locale = sayable_date::locales::get(&opts.locale)
        .ok_or_else(|| error(&format!("unknown locale '{}'", opts.locale)))?;

    let formatter = SayableDate::new(locale, date_compactness(&opts.compactness));

    match (date_val, as_of) {
        (Some(d), Some(a)) => Ok(formatter.format_relative(d, a)),
        _ => Ok(None),
    }
}

fn cmd_time(positionals: &[&str], opts: &Options) -> CmdResult {
    if positionals.is_empty() {
        return Err(error("time requires a time argument"));
    }
    let time_val = nullify(positionals[0]);

    let locale = sayable_time::locales::get(&opts.locale)
        .ok_or_else(|| error(&format!("unknown locale '{}'", opts.locale)))?;

    let formatter = SayableTime::new(locale, time_compactness(&opts.compactness));

    match time_val {
        Some(t) => Ok(formatter.format_time(t)),
        None => Ok(None),
    }
}

/// Check if a string is an integer (possibly negative).
fn is_integer(s: &str) -> bool {
    if s.is_empty() {
        return false;
    }
    let bytes = s.as_bytes();
    let start = if bytes[0] == b'-' { 1 } else { 0 };
    if start >= bytes.len() {
        return false;
    }
    bytes[start..].iter().all(|b| b.is_ascii_digit())
}

fn cmd_duration(positionals: &[&str], opts: &Options) -> CmdResult {
    if positionals.is_empty() {
        return Err(error("duration requires a value argument"));
    }
    let value = nullify(positionals[0]);

    let locale = sayable_duration::locales::get(&opts.locale)
        .ok_or_else(|| error(&format!("unknown locale '{}'", opts.locale)))?;

    let formatter = SayableDuration::new(locale, duration_compactness(&opts.compactness));

    match value {
        None => Ok(None),
        Some(v) => {
            if is_integer(v) {
                // Seconds mode
                let seconds: i32 = v.parse().unwrap_or(-1);
                Ok(formatter.format_duration_seconds(seconds))
            } else {
                // Timestamp mode: need an end argument
                if positionals.len() < 2 {
                    return Err(error(
                        "duration with timestamps requires start and end arguments",
                    ));
                }
                let end = nullify(positionals[1]);
                match end {
                    Some(e) => Ok(formatter.format_duration_iso(v, e)),
                    None => Ok(None),
                }
            }
        }
    }
}

fn cmd_since(positionals: &[&str], opts: &Options) -> CmdResult {
    if positionals.is_empty() {
        return Err(error("since requires a start timestamp argument"));
    }
    let start = nullify(positionals[0]);

    let as_of_raw = match &opts.as_of {
        Some(v) => v.as_str(),
        None => return Err(error("since requires --as-of / -d option")),
    };
    let as_of = nullify(as_of_raw);

    let locale = sayable_duration::locales::get(&opts.locale)
        .ok_or_else(|| error(&format!("unknown locale '{}'", opts.locale)))?;

    let formatter = SayableDuration::new(locale, duration_compactness(&opts.compactness));

    match (start, as_of) {
        (Some(s), Some(a)) => Ok(formatter.format_since(s, a)),
        _ => Ok(None),
    }
}

fn cmd_until(positionals: &[&str], opts: &Options) -> CmdResult {
    if positionals.is_empty() {
        return Err(error("until requires a target timestamp argument"));
    }
    let target = nullify(positionals[0]);

    let as_of_raw = match &opts.as_of {
        Some(v) => v.as_str(),
        None => return Err(error("until requires --as-of / -d option")),
    };
    let as_of = nullify(as_of_raw);

    let locale = sayable_duration::locales::get(&opts.locale)
        .ok_or_else(|| error(&format!("unknown locale '{}'", opts.locale)))?;

    let formatter = SayableDuration::new(locale, duration_compactness(&opts.compactness));

    match (target, as_of) {
        (Some(t), Some(a)) => Ok(formatter.format_until(t, a)),
        _ => Ok(None),
    }
}

fn cmd_locales() -> String {
    // All components share the same locale set; use age as canonical source
    let codes = [
        "af", "ak", "am", "ar", "az", "bci", "be", "bem", "bg", "bm",
        "bn", "br", "bs", "ca", "ceb", "cs", "cy", "da", "de", "din",
        "dje", "dyu", "ee", "el", "en", "es", "et", "eu", "fa", "fan",
        "ff", "fi", "fil", "fon", "fr", "ga", "gd", "gl", "gn", "gu",
        "gv", "ha", "he", "hi", "hr", "ht", "hu", "hy", "id", "ig",
        "is", "it", "ja", "jv", "ka", "kbp", "kk", "km", "kn", "ko",
        "kpe", "ktu", "ku", "kw", "ky", "lg", "ln", "lo", "lt", "lv",
        "men", "mfe", "mg", "mi", "mk", "ml", "mn", "mnk", "mos", "mr",
        "ms", "mt", "my", "nb", "nd", "ne", "ng", "nl", "nso", "nus",
        "ny", "om", "or", "pa", "pl", "pov", "ps", "pt", "qu", "ro",
        "ru", "rw", "sar", "sd", "sg", "shi", "si", "sk", "sl", "sn",
        "snk", "so", "sq", "sr", "ss", "st", "su", "suk", "sv", "sw",
        "ta", "te", "tem", "tg", "th", "ti", "tig", "tk", "tn", "tr",
        "ts", "tzm", "uk", "umb", "ur", "uz", "vi", "vmw", "wo", "xh",
        "yo", "yue", "zdj", "zh", "zu",
    ];
    codes.map(|code| format!("{code}\n")).concat()
}

/// What one invocation produces: its exit code and the text it prints to stdout.
struct Outcome {
    code: i32,
    output: String,
}

impl Outcome {
    fn printed(text: String) -> Self {
        Outcome {
            code: 0,
            output: format!("{text}\n"),
        }
    }

    fn from_result(result: Option<String>) -> Self {
        match result {
            Some(text) => Outcome::printed(text),
            None => Outcome {
                code: 1,
                output: String::new(),
            },
        }
    }
}

fn dispatch(args: &[String]) -> Result<Outcome, UsageError> {
    let (command, positionals, opts) = parse_args(args)?;

    let result = match command {
        None => {
            return Ok(Outcome {
                code: 2,
                output: format!("{HELP}\n"),
            })
        }
        Some("help") => return Ok(Outcome::printed(HELP.to_string())),
        Some("version") => return Ok(Outcome::printed(format!("sayable {VERSION}"))),
        Some("locales") => {
            return Ok(Outcome {
                code: 0,
                output: cmd_locales(),
            })
        }
        Some("age") => cmd_age(&positionals, &opts)?,
        Some("stage") => cmd_stage(&positionals, &opts)?,
        Some("date") => cmd_date(&positionals, &opts)?,
        Some("relative") => cmd_relative(&positionals, &opts)?,
        Some("time") => cmd_time(&positionals, &opts)?,
        Some("duration") => cmd_duration(&positionals, &opts)?,
        Some("since") => cmd_since(&positionals, &opts)?,
        Some("until") => cmd_until(&positionals, &opts)?,
        Some(cmd) => return Err(error(&format!("unknown command '{cmd}'"))),
    };
    Ok(Outcome::from_result(result))
}

/// Runs one invocation; usage errors are reported on stderr here.
fn run(args: &[String]) -> Outcome {
    dispatch(args).unwrap_or_else(|UsageError(msg)| {
        eprintln!("error: {msg}");
        eprintln!("Run 'sayable help' for usage.");
        Outcome {
            code: 2,
            output: String::new(),
        }
    })
}

/// Trailing newline dropped, inner newlines become tabs: one response line.
fn flatten(output: &str) -> String {
    output.trim_end_matches('\n').replace('\n', "\t")
}

/// Answers one tab-separated request per stdin line (see cli/SPEC.md).
fn repl() -> io::Result<()> {
    let stdin = io::stdin();
    let mut stdout = io::stdout().lock();
    for line in stdin.lock().lines() {
        let line = line?;
        let request = line.strip_suffix('\r').unwrap_or(&line);
        let args: Vec<String> = request.split('\t').map(str::to_string).collect();
        // A panic would crash a one-shot run (exit 1); here it must not end the REPL.
        let outcome = std::panic::catch_unwind(|| run(&args)).unwrap_or(Outcome {
            code: 1,
            output: String::new(),
        });
        writeln!(stdout, "{}\t{}", outcome.code, flatten(&outcome.output))?;
        stdout.flush()?;
    }
    Ok(())
}

fn main() {
    let args: Vec<String> = env::args().skip(1).collect();
    if args == ["--repl"] {
        if let Err(e) = repl() {
            eprintln!("error: {e}");
            process::exit(1);
        }
        return;
    }
    let outcome = run(&args);
    print!("{}", outcome.output);
    process::exit(outcome.code);
}
