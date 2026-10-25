import 'dart:convert';
import 'dart:io';

import 'package:sayable_age/sayable_age.dart' as age;
import 'package:sayable_date/sayable_date.dart' as date;
import 'package:sayable_time/sayable_time.dart' as time;
import 'package:sayable_duration/sayable_duration.dart' as duration;

const _version = '0.5.0';

const _help = '''\
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
  -v, --version          Show version''';

/// A usage error: its message is already on stderr; the run exits 2.
class _UsageError implements Exception {}

/// The outcome of one command: what it would exit with and print to stdout.
typedef _RunResult = ({int code, String? output});

Never _error(String msg) {
  stderr.writeln('error: $msg');
  stderr.writeln("Run 'sayable help' for usage.");
  throw _UsageError();
}

String? _nullify(String value) => value == 'null' ? null : value;

String _getToday() {
  final now = DateTime.now();
  final y = now.year.toString().padLeft(4, '0');
  final m = now.month.toString().padLeft(2, '0');
  final d = now.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

age.Compactness _ageCompactness(String compactness) {
  switch (compactness) {
    case 'short':
      return age.Compactness.short;
    case 'compact':
      return age.Compactness.compact;
    default:
      return age.Compactness.normal;
  }
}

date.Compactness _dateCompactness(String compactness) {
  switch (compactness) {
    case 'short':
      return date.Compactness.short;
    case 'compact':
      return date.Compactness.compact;
    default:
      return date.Compactness.normal;
  }
}

time.Compactness _timeCompactness(String compactness) {
  switch (compactness) {
    case 'short':
      return time.Compactness.short;
    case 'compact':
      return time.Compactness.compact;
    default:
      return time.Compactness.normal;
  }
}

duration.Compactness _durationCompactness(String compactness) {
  switch (compactness) {
    case 'short':
      return duration.Compactness.short;
    case 'compact':
      return duration.Compactness.compact;
    default:
      return duration.Compactness.normal;
  }
}

({String? command, List<String> positionals, Map<String, Object> options})
    _parseArgs(List<String> argv) {
  if (argv.isEmpty) {
    return (command: null, positionals: <String>[], options: <String, Object>{});
  }

  if (argv[0] == '-h' || argv[0] == '--help' || argv[0] == 'help') {
    return (command: 'help', positionals: <String>[], options: <String, Object>{});
  }
  if (argv[0] == '-v' || argv[0] == '--version' || argv[0] == 'version') {
    return (command: 'version', positionals: <String>[], options: <String, Object>{});
  }

  final command = argv[0];
  final positionals = <String>[];
  final options = <String, Object>{
    'locale': 'en',
    'as_of': '',
    'compactness': 'normal',
    'gender': '',
    'with_year': false,
  };

  var i = 1;
  var stopOpts = false;
  while (i < argv.length) {
    final arg = argv[i];

    if (arg == '--' && !stopOpts) {
      stopOpts = true;
      i++;
      continue;
    }

    if (!stopOpts && arg.startsWith('-')) {
      if (arg == '-l' || arg == '--locale') {
        if (i + 1 >= argv.length) _error("'$arg' requires a value");
        i++;
        options['locale'] = argv[i];
      } else if (arg == '-d' || arg == '--as-of') {
        if (i + 1 >= argv.length) _error("'$arg' requires a value");
        i++;
        options['as_of'] = argv[i];
      } else if (arg == '-g' || arg == '--gender') {
        if (i + 1 >= argv.length) _error("'$arg' requires a value");
        i++;
        options['gender'] = argv[i];
      } else if (arg == '--short') {
        options['compactness'] = 'short';
      } else if (arg == '--compact') {
        options['compactness'] = 'compact';
      } else if (arg == '--with-year') {
        options['with_year'] = true;
      } else if (arg == '-h' || arg == '--help') {
        return (command: 'help', positionals: <String>[], options: <String, Object>{});
      } else if (arg == '-v' || arg == '--version') {
        return (command: 'version', positionals: <String>[], options: <String, Object>{});
      } else {
        _error("unknown option '$arg'");
      }
    } else {
      positionals.add(arg);
    }

    i++;
  }

  return (command: command, positionals: positionals, options: options);
}

String? _cmdAge(List<String> positionals, Map<String, Object> options) {
  if (positionals.isEmpty) _error('age requires a date-of-birth argument');
  final dob = _nullify(positionals[0]);

  final localeCode = options['locale'] as String;
  final locale = age.getLocale(localeCode);
  if (locale == null) _error("unknown locale '$localeCode'");

  var asOf = options['as_of'] as String;
  String? asOfVal;
  if (asOf.isNotEmpty) {
    asOfVal = _nullify(asOf);
  } else {
    asOfVal = _getToday();
  }

  final formatter = age.SayableAge(locale, _ageCompactness(options['compactness'] as String));
  final result = dob == null ? null : formatter.formatAge(dob, asOfVal);

  return result;
}

String? _cmdStage(List<String> positionals, Map<String, Object> options) {
  if (positionals.isEmpty) _error('stage requires a date-of-birth argument');
  final dob = _nullify(positionals[0]);

  final localeCode = options['locale'] as String;
  final locale = age.getLocale(localeCode);
  if (locale == null) _error("unknown locale '$localeCode'");

  var asOf = options['as_of'] as String;
  String? asOfVal;
  if (asOf.isNotEmpty) {
    asOfVal = _nullify(asOf);
  } else {
    asOfVal = _getToday();
  }

  final gender = options['gender'] as String;
  final genderVal = gender.isEmpty ? null : gender;

  final formatter = age.SayableAge(locale, _ageCompactness(options['compactness'] as String));
  final result = dob == null ? null : formatter.formatStage(dob, asOfVal, genderVal);

  return result;
}

String? _cmdDate(List<String> positionals, Map<String, Object> options) {
  if (positionals.isEmpty) _error('date requires a date argument');
  final dateVal = _nullify(positionals[0]);

  final localeCode = options['locale'] as String;
  final locale = date.getLocale(localeCode);
  if (locale == null) _error("unknown locale '$localeCode'");

  final formatter = date.SayableDate(locale, _dateCompactness(options['compactness'] as String));

  final withYear = options['with_year'] as bool;
  String? result;
  if (withYear) {
    result = formatter.formatDateWithYear(dateVal);
  } else {
    result = formatter.formatDate(dateVal);
  }

  return result;
}

String? _cmdRelative(List<String> positionals, Map<String, Object> options) {
  if (positionals.isEmpty) _error('relative requires a date argument');
  final dateVal = _nullify(positionals[0]);

  final asOf = options['as_of'] as String;
  if (asOf.isEmpty) _error('relative requires --as-of / -d option');
  final asOfVal = _nullify(asOf);

  final localeCode = options['locale'] as String;
  final locale = date.getLocale(localeCode);
  if (locale == null) _error("unknown locale '$localeCode'");

  final formatter = date.SayableDate(locale, _dateCompactness(options['compactness'] as String));
  final result = formatter.formatRelative(dateVal, asOf: asOfVal);

  return result;
}

String? _cmdTime(List<String> positionals, Map<String, Object> options) {
  if (positionals.isEmpty) _error('time requires a time argument');
  final timeVal = _nullify(positionals[0]);

  final localeCode = options['locale'] as String;
  final locale = time.getLocale(localeCode);
  if (locale == null) _error("unknown locale '$localeCode'");

  final formatter = time.SayableTime(locale, _timeCompactness(options['compactness'] as String));
  final result = formatter.formatTime(timeVal);

  return result;
}

String? _cmdDuration(List<String> positionals, Map<String, Object> options) {
  if (positionals.isEmpty) _error('duration requires a value argument');
  final value = _nullify(positionals[0]);

  final localeCode = options['locale'] as String;
  final locale = duration.getLocale(localeCode);
  if (locale == null) _error("unknown locale '$localeCode'");

  final formatter =
      duration.SayableDuration(locale, _durationCompactness(options['compactness'] as String));

  String? result;
  if (value == null) {
    result = formatter.formatDuration(null);
  } else if (_isInteger(value)) {
    result = formatter.formatDuration(int.parse(value));
  } else {
    // Timestamp mode: need an end argument
    if (positionals.length < 2) {
      _error('duration with timestamps requires start and end arguments');
    }
    final end = _nullify(positionals[1]);
    result = formatter.formatDuration(value, end);
  }

  return result;
}

bool _isInteger(String s) {
  if (s.isEmpty) return false;
  var start = 0;
  if (s[0] == '-') {
    if (s.length == 1) return false;
    start = 1;
  }
  for (var i = start; i < s.length; i++) {
    final c = s.codeUnitAt(i);
    if (c < 48 || c > 57) return false; // '0' = 48, '9' = 57
  }
  return true;
}

String? _cmdSince(List<String> positionals, Map<String, Object> options) {
  if (positionals.isEmpty) _error('since requires a start timestamp argument');
  final start = _nullify(positionals[0]);

  final asOf = options['as_of'] as String;
  if (asOf.isEmpty) _error('since requires --as-of / -d option');
  final asOfVal = _nullify(asOf);

  final localeCode = options['locale'] as String;
  final locale = duration.getLocale(localeCode);
  if (locale == null) _error("unknown locale '$localeCode'");

  final formatter =
      duration.SayableDuration(locale, _durationCompactness(options['compactness'] as String));
  final result = formatter.formatSince(start, asOfVal);

  return result;
}

String? _cmdUntil(List<String> positionals, Map<String, Object> options) {
  if (positionals.isEmpty) _error('until requires a target timestamp argument');
  final target = _nullify(positionals[0]);

  final asOf = options['as_of'] as String;
  if (asOf.isEmpty) _error('until requires --as-of / -d option');
  final asOfVal = _nullify(asOf);

  final localeCode = options['locale'] as String;
  final locale = duration.getLocale(localeCode);
  if (locale == null) _error("unknown locale '$localeCode'");

  final formatter =
      duration.SayableDuration(locale, _durationCompactness(options['compactness'] as String));
  final result = formatter.formatUntil(target, asOfVal);

  return result;
}

String _cmdLocales() {
  // Collect all locale codes from the age locale registry
  final codes = <String>[];
  const allCodes = [
    'af', 'ak', 'am', 'ar', 'az', 'bci', 'be', 'bem', 'bg', 'bm', 'bn',
    'br', 'bs', 'ca', 'ceb', 'cs', 'cy', 'da', 'de', 'din', 'dje', 'dyu',
    'ee', 'el', 'en', 'es', 'et', 'eu', 'fa', 'fan', 'ff', 'fi', 'fil',
    'fon', 'fr', 'ga', 'gd', 'gl', 'gn', 'gu', 'gv', 'ha', 'he', 'hi',
    'hr', 'ht', 'hu', 'hy', 'id', 'ig', 'is', 'it', 'ja', 'jv', 'ka',
    'kbp', 'kk', 'km', 'kn', 'ko', 'kpe', 'ktu', 'ku', 'kw', 'ky', 'lg',
    'ln', 'lo', 'lt', 'lv', 'men', 'mfe', 'mg', 'mi', 'mk', 'ml', 'mn',
    'mnk', 'mos', 'mr', 'ms', 'mt', 'my', 'nb', 'nd', 'ne', 'ng', 'nl',
    'nso', 'nus', 'ny', 'om', 'or', 'pa', 'pl', 'pov', 'ps', 'pt', 'qu',
    'ro', 'ru', 'rw', 'sar', 'sd', 'sg', 'shi', 'si', 'sk', 'sl', 'sn',
    'snk', 'so', 'sq', 'sr', 'ss', 'st', 'su', 'suk', 'sv', 'sw', 'ta',
    'te', 'tem', 'tg', 'th', 'ti', 'tig', 'tk', 'tn', 'tr', 'ts', 'tzm',
    'uk', 'umb', 'ur', 'uz', 'vi', 'vmw', 'wo', 'xh', 'yo', 'yue', 'zdj',
    'zh', 'zu',
  ];
  for (final code in allCodes) {
    if (age.getLocale(code) != null) {
      codes.add(code);
    }
  }
  codes.sort();
  return codes.join('\n');
}

_RunResult _dispatch(List<String> argv) {
  final parsed = _parseArgs(argv);
  final command = parsed.command;
  final positionals = parsed.positionals;
  final options = parsed.options;

  if (command == null) return (code: 2, output: _help);
  if (command == 'help') return (code: 0, output: _help);
  if (command == 'version') return (code: 0, output: 'sayable $_version');
  if (command == 'locales') return (code: 0, output: _cmdLocales());

  final String? result;
  switch (command) {
    case 'age':
      result = _cmdAge(positionals, options);
    case 'stage':
      result = _cmdStage(positionals, options);
    case 'date':
      result = _cmdDate(positionals, options);
    case 'relative':
      result = _cmdRelative(positionals, options);
    case 'time':
      result = _cmdTime(positionals, options);
    case 'duration':
      result = _cmdDuration(positionals, options);
    case 'since':
      result = _cmdSince(positionals, options);
    case 'until':
      result = _cmdUntil(positionals, options);
    default:
      _error("unknown command '$command'");
  }
  return result == null ? (code: 1, output: null) : (code: 0, output: result);
}

/// Runs one command as the one-shot CLI would, without printing or exiting.
_RunResult _run(List<String> argv) {
  try {
    return _dispatch(argv);
  } on _UsageError {
    return (code: 2, output: null);
  }
}

String _formatResponse(_RunResult result) {
  final output = (result.output ?? '').replaceFirst(RegExp(r'\n+$'), '').replaceAll('\n', '\t');
  return '${result.code}\t$output\n';
}

/// Answers one tab-separated request per stdin line (see cli/SPEC.md).
Future<void> _repl() async {
  final lines = stdin.transform(utf8.decoder).transform(const LineSplitter());
  await for (final line in lines) {
    _RunResult result;
    try {
      result = _run(line.split('\t'));
    } catch (err, stack) {
      // A crash exits non-zero in one-shot mode; keep serving.
      stderr.writeln('$err\n$stack');
      result = (code: 1, output: null);
    }
    stdout.write(_formatResponse(result));
    await stdout.flush();
  }
}

Future<void> main(List<String> argv) async {
  if (argv.length == 1 && argv[0] == '--repl') {
    stdout.encoding = utf8;
    await _repl();
    return;
  }

  final result = _run(argv);
  if (result.output != null) print(result.output);
  exitCode = result.code;
}
