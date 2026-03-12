/**
 * Sayable CLI — unified command-line interface to all four Sayable components.
 *
 * See cli/SPEC.md for the full specification.
 */

import { SayableAge } from '../../../age/impl/typescript/src/format-age.js';
import { getLocale as getAgeLocale } from '../../../age/impl/typescript/src/locales/index.js';
import type { Compactness as AgeCompactness, Gender } from '../../../age/impl/typescript/src/locale.js';

import { SayableDate } from '../../../date/impl/typescript/src/format-date.js';
import { getLocale as getDateLocale } from '../../../date/impl/typescript/src/locales/index.js';
import type { Compactness as DateCompactness } from '../../../date/impl/typescript/src/locale.js';

import { SayableTime } from '../../../time/impl/typescript/src/format-time.js';
import { getLocale as getTimeLocale } from '../../../time/impl/typescript/src/locales/index.js';
import type { Compactness as TimeCompactness } from '../../../time/impl/typescript/src/locale.js';

import { SayableDuration } from '../../../duration/impl/typescript/src/format-duration.js';
import { getLocale as getDurationLocale } from '../../../duration/impl/typescript/src/locales/index.js';
import type { Compactness as DurationCompactness } from '../../../duration/impl/typescript/src/locale.js';

const VERSION = '0.5.0';

const HELP = `Usage: sayable <command> [arguments] [options]

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
  -v, --version          Show version`;

interface Options {
  locale: string;
  asOf: string | null;
  compactness: 'normal' | 'short' | 'compact';
  gender: string | null;
  withYear: boolean;
}

function error(msg: string): never {
  process.stderr.write(`error: ${msg}\n`);
  process.stderr.write("Run 'sayable help' for usage.\n");
  process.exit(2);
}

function nullify(value: string): string | null {
  return value === 'null' ? null : value;
}

/**
 * Validate that a string looks like YYYY-MM-DD.
 * The TypeScript age library doesn't reject malformed dates (e.g. "undefined"),
 * so the CLI must guard against them to match cross-language behavior.
 */
function isValidDate(s: string | null): boolean {
  if (!s) return false;
  const parts = s.split('-');
  if (parts.length !== 3) return false;
  return parts.every(p => p.length > 0 && !isNaN(Number(p)));
}

function getToday(): string {
  const now = new Date();
  const y = now.getFullYear();
  const m = String(now.getMonth() + 1).padStart(2, '0');
  const d = String(now.getDate()).padStart(2, '0');
  return `${y}-${m}-${d}`;
}

function parseArgs(argv: string[]): { command: string | null; positionals: string[]; options: Options } {
  if (argv.length === 0) {
    return { command: null, positionals: [], options: defaultOptions() };
  }

  if (argv[0] === '-h' || argv[0] === '--help' || argv[0] === 'help') {
    return { command: 'help', positionals: [], options: defaultOptions() };
  }
  if (argv[0] === '-v' || argv[0] === '--version' || argv[0] === 'version') {
    return { command: 'version', positionals: [], options: defaultOptions() };
  }

  const command = argv[0]!;
  const positionals: string[] = [];
  const options = defaultOptions();

  let i = 1;
  let stopOpts = false;

  while (i < argv.length) {
    const arg = argv[i]!;

    if (arg === '--' && !stopOpts) {
      stopOpts = true;
      i++;
      continue;
    }

    if (!stopOpts && arg.startsWith('-')) {
      if (arg === '-l' || arg === '--locale') {
        if (i + 1 >= argv.length) error(`'${arg}' requires a value`);
        i++;
        options.locale = argv[i]!;
      } else if (arg === '-d' || arg === '--as-of') {
        if (i + 1 >= argv.length) error(`'${arg}' requires a value`);
        i++;
        options.asOf = argv[i]!;
      } else if (arg === '-g' || arg === '--gender') {
        if (i + 1 >= argv.length) error(`'${arg}' requires a value`);
        i++;
        options.gender = argv[i]!;
      } else if (arg === '--short') {
        options.compactness = 'short';
      } else if (arg === '--compact') {
        options.compactness = 'compact';
      } else if (arg === '--with-year') {
        options.withYear = true;
      } else if (arg === '-h' || arg === '--help') {
        return { command: 'help', positionals: [], options: defaultOptions() };
      } else if (arg === '-v' || arg === '--version') {
        return { command: 'version', positionals: [], options: defaultOptions() };
      } else {
        error(`unknown option '${arg}'`);
      }
    } else {
      positionals.push(arg);
    }

    i++;
  }

  return { command, positionals, options };
}

function defaultOptions(): Options {
  return {
    locale: 'en',
    asOf: null,
    compactness: 'normal',
    gender: null,
    withYear: false,
  };
}

function cmdAge(positionals: string[], options: Options): void {
  if (positionals.length === 0) error('age requires a date-of-birth argument');
  const dob = nullify(positionals[0]!);

  // Guard: the TypeScript age library doesn't reject malformed date strings
  if (dob !== null && !isValidDate(dob)) process.exit(1);

  const locale = getAgeLocale(options.locale);
  if (!locale) error(`unknown locale '${options.locale}'`);

  let asOf: string | undefined;
  if (options.asOf !== null) {
    const v = nullify(options.asOf);
    asOf = v ?? undefined;
  } else {
    asOf = getToday();
  }

  const formatter = new SayableAge(locale, options.compactness as AgeCompactness);
  const result = formatter.formatAge(dob, asOf);

  if (result === null) process.exit(1);
  console.log(result);
}

function cmdStage(positionals: string[], options: Options): void {
  if (positionals.length === 0) error('stage requires a date-of-birth argument');
  const dob = nullify(positionals[0]!);

  // Guard: the TypeScript age library doesn't reject malformed date strings
  if (dob !== null && !isValidDate(dob)) process.exit(1);

  const locale = getAgeLocale(options.locale);
  if (!locale) error(`unknown locale '${options.locale}'`);

  let asOf: string | undefined;
  if (options.asOf !== null) {
    const v = nullify(options.asOf);
    asOf = v ?? undefined;
  } else {
    asOf = getToday();
  }

  const gender = options.gender as Gender | undefined;

  const formatter = new SayableAge(locale, options.compactness as AgeCompactness);
  const result = formatter.formatStage(dob, asOf, gender ?? undefined);

  if (result === null) process.exit(1);
  console.log(result);
}

function cmdDate(positionals: string[], options: Options): void {
  if (positionals.length === 0) error('date requires a date argument');
  const dateVal = nullify(positionals[0]!);

  const locale = getDateLocale(options.locale);
  if (!locale) error(`unknown locale '${options.locale}'`);

  const formatter = new SayableDate(locale, options.compactness as DateCompactness);

  let result: string | null;
  if (options.withYear) {
    result = formatter.formatDateWithYear(dateVal);
  } else {
    result = formatter.formatDate(dateVal);
  }

  if (result === null) process.exit(1);
  console.log(result);
}

function cmdRelative(positionals: string[], options: Options): void {
  if (positionals.length === 0) error('relative requires a date argument');
  const dateVal = nullify(positionals[0]!);

  if (options.asOf === null) error('relative requires --as-of / -d option');
  const asOf = nullify(options.asOf);

  const locale = getDateLocale(options.locale);
  if (!locale) error(`unknown locale '${options.locale}'`);

  const formatter = new SayableDate(locale, options.compactness as DateCompactness);
  const result = formatter.formatRelative(dateVal, asOf);

  if (result === null) process.exit(1);
  console.log(result);
}

function cmdTime(positionals: string[], options: Options): void {
  if (positionals.length === 0) error('time requires a time argument');
  const timeVal = nullify(positionals[0]!);

  const locale = getTimeLocale(options.locale);
  if (!locale) error(`unknown locale '${options.locale}'`);

  const formatter = new SayableTime(locale, options.compactness as TimeCompactness);
  const result = formatter.formatTime(timeVal);

  if (result === null) process.exit(1);
  console.log(result);
}

function cmdDuration(positionals: string[], options: Options): void {
  if (positionals.length === 0) error('duration requires a value argument');
  const value = nullify(positionals[0]!);

  const locale = getDurationLocale(options.locale);
  if (!locale) error(`unknown locale '${options.locale}'`);

  const formatter = new SayableDuration(locale, options.compactness as DurationCompactness);

  let result: string | null;
  if (value === null) {
    result = formatter.formatDuration(null);
  } else if (/^-?\d+$/.test(value)) {
    result = formatter.formatDuration(parseInt(value, 10));
  } else {
    // Timestamp mode: need an end argument
    if (positionals.length < 2) error('duration with timestamps requires start and end arguments');
    const end = nullify(positionals[1]!);
    result = formatter.formatDuration(value, end ?? undefined);
  }

  if (result === null) process.exit(1);
  console.log(result);
}

function cmdSince(positionals: string[], options: Options): void {
  if (positionals.length === 0) error('since requires a start timestamp argument');
  const start = nullify(positionals[0]!);

  if (options.asOf === null) error('since requires --as-of / -d option');
  const asOf = nullify(options.asOf);

  const locale = getDurationLocale(options.locale);
  if (!locale) error(`unknown locale '${options.locale}'`);

  const formatter = new SayableDuration(locale, options.compactness as DurationCompactness);
  const result = formatter.formatSince(start, asOf);

  if (result === null) process.exit(1);
  console.log(result);
}

function cmdUntil(positionals: string[], options: Options): void {
  if (positionals.length === 0) error('until requires a target timestamp argument');
  const target = nullify(positionals[0]!);

  if (options.asOf === null) error('until requires --as-of / -d option');
  const asOf = nullify(options.asOf);

  const locale = getDurationLocale(options.locale);
  if (!locale) error(`unknown locale '${options.locale}'`);

  const formatter = new SayableDuration(locale, options.compactness as DurationCompactness);
  const result = formatter.formatUntil(target, asOf);

  if (result === null) process.exit(1);
  console.log(result);
}

function cmdLocales(): void {
  // Collect all locale codes from the age locales index (canonical set)
  const allLocales = new Set<string>();
  // Import all locales dynamically by checking what getAgeLocale accepts
  // Since we have the _ALL map, we need to iterate it — but we don't have direct access.
  // Instead, we use the known list of locale codes by probing the getLocale function.
  // The most reliable approach: import the barrel and check each export's code property.
  // For simplicity, we use a known approach matching the Python reference:
  // use the age locales index which exports all locales.
  const knownCodes = [
    'af', 'ak', 'am', 'ar', 'az', 'bci', 'be', 'bem', 'bg', 'bm', 'bn', 'br', 'bs',
    'ca', 'ceb', 'cs', 'cy', 'da', 'de', 'din', 'dje', 'dyu', 'ee', 'el', 'en', 'es',
    'et', 'eu', 'fa', 'fan', 'ff', 'fi', 'fil', 'fon', 'fr', 'ga', 'gd', 'gl', 'gn',
    'gu', 'gv', 'ha', 'he', 'hi', 'hr', 'ht', 'hu', 'hy', 'id', 'ig', 'is', 'it',
    'ja', 'jv', 'ka', 'kbp', 'kk', 'km', 'kn', 'ko', 'kpe', 'ktu', 'ku', 'kw', 'ky',
    'lg', 'ln', 'lo', 'lt', 'lv', 'men', 'mfe', 'mg', 'mi', 'mk', 'ml', 'mn', 'mnk',
    'mos', 'mr', 'ms', 'mt', 'my', 'nb', 'nd', 'ne', 'ng', 'nl', 'nso', 'nus', 'ny',
    'om', 'or', 'pa', 'pl', 'pov', 'ps', 'pt', 'qu', 'ro', 'ru', 'rw', 'sar', 'sd',
    'sg', 'shi', 'si', 'sk', 'sl', 'sn', 'snk', 'so', 'sq', 'sr', 'ss', 'st', 'su',
    'suk', 'sv', 'sw', 'ta', 'te', 'tem', 'tg', 'th', 'ti', 'tig', 'tk', 'tn', 'tr',
    'ts', 'tzm', 'uk', 'umb', 'ur', 'uz', 'vi', 'vmw', 'wo', 'xh', 'yo', 'yue', 'zdj',
    'zh', 'zu',
  ];

  for (const code of knownCodes) {
    if (getAgeLocale(code)) {
      allLocales.add(code);
    }
  }

  const sorted = [...allLocales].sort();
  for (const code of sorted) {
    console.log(code);
  }
}

const COMMANDS: Record<string, (positionals: string[], options: Options) => void> = {
  age: cmdAge,
  stage: cmdStage,
  date: cmdDate,
  relative: cmdRelative,
  time: cmdTime,
  duration: cmdDuration,
  since: cmdSince,
  until: cmdUntil,
};

function main(): void {
  const argv = process.argv.slice(2);
  const { command, positionals, options } = parseArgs(argv);

  if (command === null) {
    console.log(HELP);
    process.exit(2);
  }

  if (command === 'help') {
    console.log(HELP);
    process.exit(0);
  }

  if (command === 'version') {
    console.log(`sayable ${VERSION}`);
    process.exit(0);
  }

  if (command === 'locales') {
    cmdLocales();
    process.exit(0);
  }

  const handler = COMMANDS[command];
  if (!handler) {
    error(`unknown command '${command}'`);
  }

  handler(positionals, options);
}

main();
