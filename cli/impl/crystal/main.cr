# Sayable CLI -- unified command-line interface to all four Sayable components.
#
# See cli/SPEC.md for the full specification.

# Require all four component libraries (relative to this file's location)
require "../../../age/impl/crystal/src/sayable_age"
require "../../../date/impl/crystal/src/sayable_date"
require "../../../time/impl/crystal/src/sayable_time"
require "../../../duration/impl/crystal/src/sayable_duration"

VERSION = "0.5.0"

HELP = <<-HELP
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
  -v, --version          Show version
HELP

def cli_error(msg : String)
  STDERR.puts "error: #{msg}"
  STDERR.puts "Run 'sayable help' for usage."
  exit 2
end

def nullify(value : String) : String?
  value == "null" ? nil : value
end

def get_today : String
  now = Time.local
  "%04d-%02d-%02d" % {now.year, now.month, now.day}
end

def parse_args(argv : Array(String)) : Tuple(String?, Array(String), Hash(String, String | Bool | Nil))
  if argv.empty?
    return {nil, [] of String, {} of String => String | Bool | Nil}
  end

  # Global flags that can appear as the first argument
  if ["-h", "--help", "help"].includes?(argv[0])
    return {"help", [] of String, {} of String => String | Bool | Nil}
  end
  if ["-v", "--version", "version"].includes?(argv[0])
    return {"version", [] of String, {} of String => String | Bool | Nil}
  end

  command = argv[0]
  positionals = [] of String
  options = {
    "locale"      => "en" .as(String | Bool | Nil),
    "as_of"       => nil   .as(String | Bool | Nil),
    "compactness" => "normal" .as(String | Bool | Nil),
    "gender"      => nil   .as(String | Bool | Nil),
    "with_year"   => false .as(String | Bool | Nil),
  }

  i = 1
  stop_opts = false
  while i < argv.size
    arg = argv[i]

    if arg == "--" && !stop_opts
      stop_opts = true
      i += 1
      next
    end

    if !stop_opts && arg.starts_with?("-")
      case arg
      when "-l", "--locale"
        cli_error("'#{arg}' requires a value") if i + 1 >= argv.size
        i += 1
        options["locale"] = argv[i]
      when "-d", "--as-of"
        cli_error("'#{arg}' requires a value") if i + 1 >= argv.size
        i += 1
        options["as_of"] = argv[i]
      when "-g", "--gender"
        cli_error("'#{arg}' requires a value") if i + 1 >= argv.size
        i += 1
        options["gender"] = argv[i]
      when "--short"
        options["compactness"] = "short"
      when "--compact"
        options["compactness"] = "compact"
      when "--with-year"
        options["with_year"] = true
      when "-h", "--help"
        return {"help", [] of String, {} of String => String | Bool | Nil}
      when "-v", "--version"
        return {"version", [] of String, {} of String => String | Bool | Nil}
      else
        cli_error("unknown option '#{arg}'")
      end
    else
      positionals << arg
    end

    i += 1
  end

  {command, positionals, options}
end

def compactness_symbol(options : Hash(String, String | Bool | Nil)) : Symbol
  case options["compactness"]
  when "short"   then :short
  when "compact" then :compact
  else                :normal
  end
end

def cmd_age(positionals : Array(String), options : Hash(String, String | Bool | Nil))
  cli_error("age requires a date-of-birth argument") if positionals.empty?
  dob = nullify(positionals[0])

  locale_code = options["locale"].as(String)
  locale = SayableAge::Locales.get(locale_code)
  cli_error("unknown locale '#{locale_code}'") if locale.nil?

  as_of_raw = options["as_of"]
  as_of = if as_of_raw.is_a?(String)
            nullify(as_of_raw)
          else
            get_today
          end

  formatter = SayableAge::Formatter.new(locale.not_nil!, compactness: compactness_symbol(options))
  result = formatter.format_age(dob, as_of)

  if result.nil?
    exit 1
  end
  puts result
end

def cmd_stage(positionals : Array(String), options : Hash(String, String | Bool | Nil))
  cli_error("stage requires a date-of-birth argument") if positionals.empty?
  dob = nullify(positionals[0])

  locale_code = options["locale"].as(String)
  locale = SayableAge::Locales.get(locale_code)
  cli_error("unknown locale '#{locale_code}'") if locale.nil?

  as_of_raw = options["as_of"]
  as_of = if as_of_raw.is_a?(String)
            nullify(as_of_raw)
          else
            get_today
          end

  gender_raw = options["gender"]
  gender = gender_raw.is_a?(String) ? gender_raw : nil

  formatter = SayableAge::Formatter.new(locale.not_nil!, compactness: compactness_symbol(options))
  result = formatter.format_stage(dob, as_of, gender: gender)

  if result.nil?
    exit 1
  end
  puts result
end

def cmd_date(positionals : Array(String), options : Hash(String, String | Bool | Nil))
  cli_error("date requires a date argument") if positionals.empty?
  date_val = nullify(positionals[0])

  locale_code = options["locale"].as(String)
  locale = SayableDate::Locales.get(locale_code)
  cli_error("unknown locale '#{locale_code}'") if locale.nil?

  formatter = SayableDate::Formatter.new(locale.not_nil!, compactness: compactness_symbol(options))

  result = if options["with_year"] == true
             formatter.format_date_with_year(date_val)
           else
             formatter.format_date(date_val)
           end

  if result.nil?
    exit 1
  end
  puts result
end

def cmd_relative(positionals : Array(String), options : Hash(String, String | Bool | Nil))
  cli_error("relative requires a date argument") if positionals.empty?
  date_val = nullify(positionals[0])

  as_of_raw = options["as_of"]
  cli_error("relative requires --as-of / -d option") unless as_of_raw.is_a?(String)
  as_of = nullify(as_of_raw)

  locale_code = options["locale"].as(String)
  locale = SayableDate::Locales.get(locale_code)
  cli_error("unknown locale '#{locale_code}'") if locale.nil?

  formatter = SayableDate::Formatter.new(locale.not_nil!, compactness: compactness_symbol(options))
  result = formatter.format_relative(date_val, as_of)

  if result.nil?
    exit 1
  end
  puts result
end

def cmd_time(positionals : Array(String), options : Hash(String, String | Bool | Nil))
  cli_error("time requires a time argument") if positionals.empty?
  time_val = nullify(positionals[0])

  locale_code = options["locale"].as(String)
  locale = SayableTime::Locales.get(locale_code)
  cli_error("unknown locale '#{locale_code}'") if locale.nil?

  formatter = SayableTime::Formatter.new(locale.not_nil!, compactness: compactness_symbol(options))
  result = formatter.format_time(time_val)

  if result.nil?
    exit 1
  end
  puts result
end

def cmd_duration(positionals : Array(String), options : Hash(String, String | Bool | Nil))
  cli_error("duration requires a value argument") if positionals.empty?
  value = nullify(positionals[0])

  locale_code = options["locale"].as(String)
  locale = SayableDuration::Locales.get(locale_code)
  cli_error("unknown locale '#{locale_code}'") if locale.nil?

  formatter = SayableDuration::Formatter.new(locale.not_nil!, compactness: compactness_symbol(options))

  result = if value.nil?
             formatter.format_duration(nil.as(Int32?))
           elsif value.lstrip('-').chars.all?(&.ascii_number?)
             formatter.format_duration(value.to_i)
           else
             cli_error("duration with timestamps requires start and end arguments") if positionals.size < 2
             end_val = nullify(positionals[1])
             formatter.format_duration(value, end_val)
           end

  if result.nil?
    exit 1
  end
  puts result
end

def cmd_since(positionals : Array(String), options : Hash(String, String | Bool | Nil))
  cli_error("since requires a start timestamp argument") if positionals.empty?
  start = nullify(positionals[0])

  as_of_raw = options["as_of"]
  cli_error("since requires --as-of / -d option") unless as_of_raw.is_a?(String)
  as_of = nullify(as_of_raw)

  locale_code = options["locale"].as(String)
  locale = SayableDuration::Locales.get(locale_code)
  cli_error("unknown locale '#{locale_code}'") if locale.nil?

  formatter = SayableDuration::Formatter.new(locale.not_nil!, compactness: compactness_symbol(options))
  result = formatter.format_since(start, as_of)

  if result.nil?
    exit 1
  end
  puts result
end

def cmd_until(positionals : Array(String), options : Hash(String, String | Bool | Nil))
  cli_error("until requires a target timestamp argument") if positionals.empty?
  target = nullify(positionals[0])

  as_of_raw = options["as_of"]
  cli_error("until requires --as-of / -d option") unless as_of_raw.is_a?(String)
  as_of = nullify(as_of_raw)

  locale_code = options["locale"].as(String)
  locale = SayableDuration::Locales.get(locale_code)
  cli_error("unknown locale '#{locale_code}'") if locale.nil?

  formatter = SayableDuration::Formatter.new(locale.not_nil!, compactness: compactness_symbol(options))
  result = formatter.format_until(target, as_of)

  if result.nil?
    exit 1
  end
  puts result
end

def cmd_locales
  codes = [] of String
  # Use age locales as the canonical list
  %w[af ak am ar az bci be bem bg bi bm bn br bs ca ceb cs cy da de din dje dyu ee el en es et eu fa fan ff fi fil fj fon fr ga gd gl gn gu gv ha he hi hr ht hu hy id ig is it ja jv ka kbp kk km kn ko kpe ktu ku kw ky lg ln lo lt lv men mfe mg mi mk ml mn mnk mos mr ms mt my nb nd ne ng nl nso nus ny om or pa pis pl pov ps pt qu ro ru rw sar sd sg shi si sk sl sn snk so sq sr ss st su suk sv sw ta te tem tg th ti tig tk tn tpi tr ts tzm uk umb ur uz vi vmw wo xh yo yue zdj zh zu].each do |code|
    locale = SayableAge::Locales.get(code)
    codes << code if locale
  end
  codes.sort.each { |code| puts code }
end

command, positionals, options = parse_args(ARGV.to_a)

if command.nil?
  puts HELP
  exit 2
end

case command
when "help"
  puts HELP
  exit 0
when "version"
  puts "sayable #{VERSION}"
  exit 0
when "locales"
  cmd_locales
  exit 0
when "age"
  cmd_age(positionals, options)
when "stage"
  cmd_stage(positionals, options)
when "date"
  cmd_date(positionals, options)
when "relative"
  cmd_relative(positionals, options)
when "time"
  cmd_time(positionals, options)
when "duration"
  cmd_duration(positionals, options)
when "since"
  cmd_since(positionals, options)
when "until"
  cmd_until(positionals, options)
else
  cli_error("unknown command '#{command}'")
end
