/**
 * Sayable CLI — Elm implementation runner.
 *
 * Loads the compiled Elm app, passes command data via flags,
 * and receives the result via a port.
 *
 * See cli/SPEC.md for the full specification.
 */

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

const path = require('path');
const readline = require('readline');

/** Ends a request with exit code 2 after `message` is written to stderr. */
class CliError extends Error {}

function error(msg) {
  throw new CliError(`error: ${msg}\nRun 'sayable help' for usage.\n`);
}

function getToday() {
  const now = new Date();
  const y = now.getFullYear();
  const m = String(now.getMonth() + 1).padStart(2, '0');
  const d = String(now.getDate()).padStart(2, '0');
  return `${y}-${m}-${d}`;
}

function nullify(value) {
  return value === 'null' ? null : value;
}

function parseArgs(argv) {
  if (argv.length === 0) {
    return { command: null, positionals: [], options: defaultOptions() };
  }

  if (argv[0] === '-h' || argv[0] === '--help' || argv[0] === 'help') {
    return { command: 'help', positionals: [], options: defaultOptions() };
  }
  if (argv[0] === '-v' || argv[0] === '--version' || argv[0] === 'version') {
    return { command: 'version', positionals: [], options: defaultOptions() };
  }

  const command = argv[0];
  const positionals = [];
  const options = defaultOptions();

  let i = 1;
  let stopOpts = false;

  while (i < argv.length) {
    const arg = argv[i];

    if (arg === '--' && !stopOpts) {
      stopOpts = true;
      i++;
      continue;
    }

    if (!stopOpts && arg.startsWith('-')) {
      if (arg === '-l' || arg === '--locale') {
        if (i + 1 >= argv.length) error(`'${arg}' requires a value`);
        i++;
        options.locale = argv[i];
      } else if (arg === '-d' || arg === '--as-of') {
        if (i + 1 >= argv.length) error(`'${arg}' requires a value`);
        i++;
        options.asOf = argv[i];
      } else if (arg === '-g' || arg === '--gender') {
        if (i + 1 >= argv.length) error(`'${arg}' requires a value`);
        i++;
        options.gender = argv[i];
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

function defaultOptions() {
  return {
    locale: 'en',
    asOf: null,
    compactness: 'normal',
    gender: null,
    withYear: false,
  };
}

const VALID_COMMANDS = ['age', 'stage', 'date', 'relative', 'time', 'duration', 'since', 'until', 'locales', 'version', 'help'];

function loadElm() {
  const elmJsPath = path.join(__dirname, 'build', 'elm.js');

  let elmModule;
  try {
    elmModule = require(elmJsPath);
  } catch (e) {
    throw new CliError("error: Elm compiled JS not found. Run 'elm make' first.\n");
  }

  const Elm = elmModule.Elm;
  if (!Elm || !Elm.Main) {
    throw new CliError('error: Elm.Main not found in compiled JS.\n');
  }
  return Elm;
}

/** A fresh Elm worker per request, so no state carries over between REPL requests. */
function runElm(flags) {
  return new Promise((resolve) => {
    const app = loadElm().Main.init({ flags: flags });
    app.ports.sendResult.subscribe(resolve);
  });
}

/**
 * Runs one command. Resolves to the exit code and the stdout text without
 * its trailing newline (null when nothing is printed).
 */
async function run(argv) {
  try {
    return await dispatch(argv);
  } catch (e) {
    if (!(e instanceof CliError)) throw e;
    process.stderr.write(e.message);
    return { exitCode: 2, output: null };
  }
}

async function dispatch(argv) {
  const { command, positionals, options } = parseArgs(argv);

  if (command === null) {
    return { exitCode: 2, output: HELP };
  }

  if (command === 'help') {
    return { exitCode: 0, output: HELP };
  }

  if (command === 'version') {
    return { exitCode: 0, output: `sayable ${VERSION}` };
  }

  if (!VALID_COMMANDS.includes(command)) {
    error(`unknown command '${command}'`);
  }
  // Validate command-specific requirements before calling Elm
  if (['age', 'stage'].includes(command)) {
    if (positionals.length === 0) error(`${command} requires a date-of-birth argument`);
  }
  if (command === 'date' && positionals.length === 0) error('date requires a date argument');
  if (command === 'relative') {
    if (positionals.length === 0) error('relative requires a date argument');
    if (options.asOf === null) error('relative requires --as-of / -d option');
  }
  if (command === 'time' && positionals.length === 0) error('time requires a time argument');
  if (command === 'duration' && positionals.length === 0) error('duration requires a value argument');
  if (command === 'since') {
    if (positionals.length === 0) error('since requires a start timestamp argument');
    if (options.asOf === null) error('since requires --as-of / -d option');
  }
  if (command === 'until') {
    if (positionals.length === 0) error('until requires a target timestamp argument');
    if (options.asOf === null) error('until requires --as-of / -d option');
  }

  // Process null values and prepare args for Elm
  const elmArgs = positionals.map(p => {
    const v = nullify(p);
    return v === null ? '' : v;
  });

  // Handle null positional → pass empty string as sentinel for null
  // The Elm side treats empty string as null for most commands
  if (positionals.length > 0 && nullify(positionals[0]) === null) {
    elmArgs[0] = '';
  }

  // Determine asOf
  let asOf = '';
  if (options.asOf !== null) {
    const v = nullify(options.asOf);
    asOf = v === null ? '' : v;
  } else if (['age', 'stage'].includes(command)) {
    asOf = getToday();
  }

  // Handle duration with negative numbers: detect and handle "-1" etc.
  // Duration command: if first arg is a negative integer, pass it as-is
  // The Elm code will handle it via String.toInt returning Just negativeValue
  if (command === 'duration' && positionals.length > 0) {
    const val = nullify(positionals[0]);
    if (val !== null) {
      elmArgs[0] = val;
    }
    // If timestamp mode, need end arg
    if (val !== null && !/^-?\d+$/.test(val)) {
      if (positionals.length < 2) error('duration with timestamps requires start and end arguments');
    }
  }

  const flags = {
    command: command,
    args: elmArgs,
    locale: options.locale,
    asOf: asOf,
    compactness: options.compactness,
    gender: options.gender || '',
    withYear: options.withYear,
  };

  const result = await runElm(flags);
  return { exitCode: result.exitCode, output: result.exitCode === 0 ? result.output : null };
}

/** A crashed one-shot run exits 1, so a crashed request answers 1 and the REPL keeps serving. */
async function runIsolated(argv) {
  try {
    return await run(argv);
  } catch (e) {
    process.stderr.write(`error: ${e && e.stack ? e.stack : e}\n`);
    return { exitCode: 1, output: null };
  }
}

/** Answers one tab-separated request per stdin line (see cli/SPEC.md). */
async function repl() {
  const lines = readline.createInterface({ input: process.stdin, crlfDelay: Infinity });
  for await (const line of lines) {
    const { exitCode, output } = await runIsolated(line.split('\t'));
    process.stdout.write(`${exitCode}\t${(output ?? '').replace(/\n/g, '\t')}\n`);
  }
}

async function main() {
  const argv = process.argv.slice(2);
  if (argv.length === 1 && argv[0] === '--repl') {
    await repl();
    return;
  }

  const { exitCode, output } = await run(argv);
  if (output !== null) {
    process.stdout.write(output + '\n');
  }
  process.exit(exitCode);
}

main();
