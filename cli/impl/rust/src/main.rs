use std::env;
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

/// Print error to stderr and exit with code 2.
fn error(msg: &str) -> ! {
    eprintln!("error: {msg}");
    eprintln!("Run 'sayable help' for usage.");
    process::exit(2);
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
fn parse_args(args: &[String]) -> (Option<&str>, Vec<&str>, Options) {
    if args.is_empty() {
        return (
            None,
            Vec::new(),
            Options {
                locale: "en".to_string(),
                as_of: None,
                compactness: "normal".to_string(),
                gender: None,
                with_year: false,
            },
        );
    }

    // Global flags that can appear as the first argument
    let first = args[0].as_str();
    if matches!(first, "-h" | "--help" | "help") {
        return (
            Some("help"),
            Vec::new(),
            Options {
                locale: "en".to_string(),
                as_of: None,
                compactness: "normal".to_string(),
                gender: None,
                with_year: false,
            },
        );
    }
    if matches!(first, "-v" | "--version" | "version") {
        return (
            Some("version"),
            Vec::new(),
            Options {
                locale: "en".to_string(),
                as_of: None,
                compactness: "normal".to_string(),
                gender: None,
                with_year: false,
            },
        );
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
                        error(&format!("'{arg}' requires a value"));
                    }
                    i += 1;
                    opts.locale = args[i].clone();
                }
                "-d" | "--as-of" => {
                    if i + 1 >= args.len() {
                        error(&format!("'{arg}' requires a value"));
                    }
                    i += 1;
                    opts.as_of = Some(args[i].clone());
                }
                "-g" | "--gender" => {
                    if i + 1 >= args.len() {
                        error(&format!("'{arg}' requires a value"));
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
                    return (
                        Some("help"),
                        Vec::new(),
                        opts,
                    );
                }
                "-v" | "--version" => {
                    return (
                        Some("version"),
                        Vec::new(),
                        opts,
                    );
                }
                _ => {
                    error(&format!("unknown option '{arg}'"));
                }
            }
        } else {
            positionals.push(args[i].as_str());
        }

        i += 1;
    }

    (Some(command), positionals, opts)
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

fn cmd_age(positionals: &[&str], opts: &Options) {
    if positionals.is_empty() {
        error("age requires a date-of-birth argument");
    }
    let dob = nullify(positionals[0]);

    let locale = sayable_age::locales::get(&opts.locale)
        .unwrap_or_else(|| error(&format!("unknown locale '{}'", opts.locale)));

    let as_of = match &opts.as_of {
        Some(v) => match nullify(v) {
            Some(s) => s.to_string(),
            None => get_today(),
        },
        None => get_today(),
    };

    let formatter = SayableAge::new(locale, age_compactness(&opts.compactness));

    match dob {
        Some(dob_str) => {
            let result = formatter.format_age(dob_str, Some(&as_of));
            match result {
                Some(s) => println!("{s}"),
                None => process::exit(1),
            }
        }
        None => process::exit(1),
    }
}

fn cmd_stage(positionals: &[&str], opts: &Options) {
    if positionals.is_empty() {
        error("stage requires a date-of-birth argument");
    }
    let dob = nullify(positionals[0]);

    let locale = sayable_age::locales::get(&opts.locale)
        .unwrap_or_else(|| error(&format!("unknown locale '{}'", opts.locale)));

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
        Some(dob_str) => {
            let result = formatter.format_stage(dob_str, Some(&as_of), gender);
            match result {
                Some(s) => println!("{s}"),
                None => process::exit(1),
            }
        }
        None => process::exit(1),
    }
}

fn cmd_date(positionals: &[&str], opts: &Options) {
    if positionals.is_empty() {
        error("date requires a date argument");
    }
    let date_val = nullify(positionals[0]);

    let locale = sayable_date::locales::get(&opts.locale)
        .unwrap_or_else(|| error(&format!("unknown locale '{}'", opts.locale)));

    let formatter = SayableDate::new(locale, date_compactness(&opts.compactness));

    match date_val {
        Some(d) => {
            let result = if opts.with_year {
                formatter.format_date_with_year(d)
            } else {
                formatter.format_date(d)
            };
            match result {
                Some(s) => println!("{s}"),
                None => process::exit(1),
            }
        }
        None => process::exit(1),
    }
}

fn cmd_relative(positionals: &[&str], opts: &Options) {
    if positionals.is_empty() {
        error("relative requires a date argument");
    }
    let date_val = nullify(positionals[0]);

    let as_of_raw = match &opts.as_of {
        Some(v) => v.as_str(),
        None => error("relative requires --as-of / -d option"),
    };
    let as_of = nullify(as_of_raw);

    let locale = sayable_date::locales::get(&opts.locale)
        .unwrap_or_else(|| error(&format!("unknown locale '{}'", opts.locale)));

    let formatter = SayableDate::new(locale, date_compactness(&opts.compactness));

    match (date_val, as_of) {
        (Some(d), Some(a)) => {
            let result = formatter.format_relative(d, a);
            match result {
                Some(s) => println!("{s}"),
                None => process::exit(1),
            }
        }
        _ => process::exit(1),
    }
}

fn cmd_time(positionals: &[&str], opts: &Options) {
    if positionals.is_empty() {
        error("time requires a time argument");
    }
    let time_val = nullify(positionals[0]);

    let locale = sayable_time::locales::get(&opts.locale)
        .unwrap_or_else(|| error(&format!("unknown locale '{}'", opts.locale)));

    let formatter = SayableTime::new(locale, time_compactness(&opts.compactness));

    match time_val {
        Some(t) => {
            let result = formatter.format_time(t);
            match result {
                Some(s) => println!("{s}"),
                None => process::exit(1),
            }
        }
        None => process::exit(1),
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

fn cmd_duration(positionals: &[&str], opts: &Options) {
    if positionals.is_empty() {
        error("duration requires a value argument");
    }
    let value = nullify(positionals[0]);

    let locale = sayable_duration::locales::get(&opts.locale)
        .unwrap_or_else(|| error(&format!("unknown locale '{}'", opts.locale)));

    let formatter = SayableDuration::new(locale, duration_compactness(&opts.compactness));

    match value {
        None => {
            // null input
            process::exit(1);
        }
        Some(v) => {
            if is_integer(v) {
                // Seconds mode
                let seconds: i32 = v.parse().unwrap_or(-1);
                let result = formatter.format_duration_seconds(seconds);
                match result {
                    Some(s) => println!("{s}"),
                    None => process::exit(1),
                }
            } else {
                // Timestamp mode: need an end argument
                if positionals.len() < 2 {
                    error("duration with timestamps requires start and end arguments");
                }
                let end = nullify(positionals[1]);
                match end {
                    Some(e) => {
                        let result = formatter.format_duration_iso(v, e);
                        match result {
                            Some(s) => println!("{s}"),
                            None => process::exit(1),
                        }
                    }
                    None => process::exit(1),
                }
            }
        }
    }
}

fn cmd_since(positionals: &[&str], opts: &Options) {
    if positionals.is_empty() {
        error("since requires a start timestamp argument");
    }
    let start = nullify(positionals[0]);

    let as_of_raw = match &opts.as_of {
        Some(v) => v.as_str(),
        None => error("since requires --as-of / -d option"),
    };
    let as_of = nullify(as_of_raw);

    let locale = sayable_duration::locales::get(&opts.locale)
        .unwrap_or_else(|| error(&format!("unknown locale '{}'", opts.locale)));

    let formatter = SayableDuration::new(locale, duration_compactness(&opts.compactness));

    match (start, as_of) {
        (Some(s), Some(a)) => {
            let result = formatter.format_since(s, a);
            match result {
                Some(out) => println!("{out}"),
                None => process::exit(1),
            }
        }
        _ => process::exit(1),
    }
}

fn cmd_until(positionals: &[&str], opts: &Options) {
    if positionals.is_empty() {
        error("until requires a target timestamp argument");
    }
    let target = nullify(positionals[0]);

    let as_of_raw = match &opts.as_of {
        Some(v) => v.as_str(),
        None => error("until requires --as-of / -d option"),
    };
    let as_of = nullify(as_of_raw);

    let locale = sayable_duration::locales::get(&opts.locale)
        .unwrap_or_else(|| error(&format!("unknown locale '{}'", opts.locale)));

    let formatter = SayableDuration::new(locale, duration_compactness(&opts.compactness));

    match (target, as_of) {
        (Some(t), Some(a)) => {
            let result = formatter.format_until(t, a);
            match result {
                Some(out) => println!("{out}"),
                None => process::exit(1),
            }
        }
        _ => process::exit(1),
    }
}

fn cmd_locales() {
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
    for code in codes {
        println!("{code}");
    }
}

fn main() {
    let args: Vec<String> = env::args().skip(1).collect();
    let (command, positionals, opts) = parse_args(&args);

    match command {
        None => {
            println!("{HELP}");
            process::exit(2);
        }
        Some("help") => {
            println!("{HELP}");
        }
        Some("version") => {
            println!("sayable {VERSION}");
        }
        Some("locales") => {
            cmd_locales();
        }
        Some("age") => cmd_age(&positionals, &opts),
        Some("stage") => cmd_stage(&positionals, &opts),
        Some("date") => cmd_date(&positionals, &opts),
        Some("relative") => cmd_relative(&positionals, &opts),
        Some("time") => cmd_time(&positionals, &opts),
        Some("duration") => cmd_duration(&positionals, &opts),
        Some("since") => cmd_since(&positionals, &opts),
        Some("until") => cmd_until(&positionals, &opts),
        Some(cmd) => {
            error(&format!("unknown command '{cmd}'"));
        }
    }
}
