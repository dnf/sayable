% Create a new SayableDate formatter.
%
% Parameters:
%   locale      - A locale struct (e.g., locale_en())
%   compactness - 'normal', 'short', or 'compact' (default: 'normal')
%
% Returns a struct with format_date and format_relative function handles.

function sd = sayable_date_new(locale, compactness)
  if (nargin < 2)
    compactness = 'normal';
  endif

  ovr = [];
  if (strcmp(compactness, 'short') && isfield(locale, 'short'))
    ovr = locale.short;
  elseif (strcmp(compactness, 'compact') && isfield(locale, 'compact'))
    ovr = locale.compact;
  endif

  months = pick_field(ovr, 'months', locale.months);
  months_in_date = pick_field(ovr, 'months_in_date', locale.months_in_date);
  weekdays = pick_field(ovr, 'weekdays', locale.weekdays);
  day_format = pick_field(ovr, 'day_format', locale.day_format);

  % When override specifies day_format but not exceptions, clear exceptions
  if (!isempty(ovr) && isstruct(ovr) && isfield(ovr, 'day_format') && !isfield(ovr, 'day_format_exceptions'))
    day_format_exceptions = struct();
  else
    day_format_exceptions = pick_field(ovr, 'day_format_exceptions', locale.day_format_exceptions);
  endif

  date_pattern = pick_field(ovr, 'date_pattern', locale.date_pattern);
  date_pattern_with_year = pick_field(ovr, 'date_pattern_with_year', locale.date_pattern_with_year);
  today_str = pick_field(ovr, 'today', locale.today);
  tomorrow_str = pick_field(ovr, 'tomorrow', locale.tomorrow);
  yesterday_str = pick_field(ovr, 'yesterday', locale.yesterday);

  sd.format_date = @(d) do_format_date(d, months, months_in_date, day_format, day_format_exceptions, date_pattern);
  sd.format_date_with_year = @(d) do_format_date_year(d, months, months_in_date, day_format, day_format_exceptions, date_pattern_with_year);
  sd.format_relative = @(d, ao) do_format_relative(d, ao, locale, compactness, months, months_in_date, weekdays, day_format, day_format_exceptions, date_pattern, date_pattern_with_year, today_str, tomorrow_str, yesterday_str);
endfunction

function result = do_format_date(date_str, months, months_in_date, day_format, day_format_exceptions, date_pattern)
  if (isempty(date_str) || !ischar(date_str))
    result = [];
    return;
  endif
  parsed = parse_date_str(date_str);
  if (isempty(parsed))
    result = [];
    return;
  endif
  result = format_absolute(parsed.year, parsed.month, parsed.day, false, months, months_in_date, day_format, day_format_exceptions, date_pattern, '');
endfunction

function result = do_format_date_year(date_str, months, months_in_date, day_format, day_format_exceptions, date_pattern_with_year)
  if (isempty(date_str) || !ischar(date_str))
    result = [];
    return;
  endif
  parsed = parse_date_str(date_str);
  if (isempty(parsed))
    result = [];
    return;
  endif
  result = format_absolute(parsed.year, parsed.month, parsed.day, true, months, months_in_date, day_format, day_format_exceptions, '', date_pattern_with_year);
endfunction

function result = do_format_relative(date_str, as_of, locale, compactness, months, months_in_date, weekdays, day_format, day_format_exceptions, date_pattern, date_pattern_with_year, today_str, tomorrow_str, yesterday_str)
  if (isempty(date_str) || !ischar(date_str) || isempty(as_of) || !ischar(as_of))
    result = [];
    return;
  endif
  parsed_date = parse_date_str(date_str);
  parsed_asof = parse_date_str(as_of);
  if (isempty(parsed_date) || isempty(parsed_asof))
    result = [];
    return;
  endif

  dy = parsed_date.year; dm = parsed_date.month; dd = parsed_date.day;
  ay = parsed_asof.year; am = parsed_asof.month; ad = parsed_asof.day;

  date_jdn = to_jdn(dy, dm, dd);
  asof_jdn = to_jdn(ay, am, ad);
  diff = date_jdn - asof_jdn;

  % Today
  if (diff == 0)
    result = today_str;
    return;
  endif

  % Tomorrow
  if (diff == 1)
    result = tomorrow_str;
    return;
  endif

  % Yesterday
  if (diff == -1)
    result = yesterday_str;
    return;
  endif

  is_compact = strcmp(compactness, 'compact');

  % Day after tomorrow (optional)
  if (diff == 2 && isfield(locale, 'day_after_tomorrow') && !isempty(locale.day_after_tomorrow) && !is_compact)
    result = locale.day_after_tomorrow;
    return;
  endif

  % Day before yesterday (optional)
  if (diff == -2 && isfield(locale, 'day_before_yesterday') && !isempty(locale.day_before_yesterday) && !is_compact)
    result = locale.day_before_yesterday;
    return;
  endif

  % Compact mode: skip weekday references
  if (is_compact)
    include_year = dy != ay;
    result = format_absolute(dy, dm, dd, include_year, months, months_in_date, day_format, day_format_exceptions, date_pattern, date_pattern_with_year);
    return;
  endif

  % This weekday (+2 to +6)
  if (diff >= 2 && diff <= 6 && isfield(locale, 'this_weekday') && !isempty(locale.this_weekday))
    dow = weekday_of(dy, dm, dd);
    weekday_name = weekdays{dow + 1};
    result = strrep(locale.this_weekday, '{weekday}', weekday_name);
    return;
  endif

  % Last weekday (-2 to -6)
  if (diff >= -6 && diff <= -2 && isfield(locale, 'last_weekday') && !isempty(locale.last_weekday))
    dow = weekday_of(dy, dm, dd);
    weekday_name = weekdays{dow + 1};
    result = strrep(locale.last_weekday, '{weekday}', weekday_name);
    return;
  endif

  % Next weekday (+7 to +13)
  if (diff >= 7 && diff <= 13 && isfield(locale, 'next_weekday') && !isempty(locale.next_weekday))
    dow = weekday_of(dy, dm, dd);
    weekday_name = weekdays{dow + 1};
    result = strrep(locale.next_weekday, '{weekday}', weekday_name);
    return;
  endif

  % Calendar fallback
  include_year = dy != ay;
  result = format_absolute(dy, dm, dd, include_year, months, months_in_date, day_format, day_format_exceptions, date_pattern, date_pattern_with_year);
endfunction

function result = format_absolute(year, month, day, include_year, months, months_in_date, day_format, day_format_exceptions, date_pattern, date_pattern_with_year)
  day_str = num2str(day);
  if (isstruct(day_format_exceptions) && isfield(day_format_exceptions, day_str))
    fmt = day_format_exceptions.(day_str);
  else
    fmt = day_format;
  endif
  formatted_day = strrep(fmt, '{n}', day_str);

  if (!isempty(months_in_date) && iscell(months_in_date) && length(months_in_date) >= month)
    month_name = months_in_date{month};
  else
    month_name = months{month};
  endif

  if (include_year)
    pattern = date_pattern_with_year;
  else
    pattern = date_pattern;
  endif

  result = strrep(pattern, '{month}', month_name);
  result = strrep(result, '{day}', formatted_day);
  result = strrep(result, '{d}', num2str(day));
  result = strrep(result, '{m}', num2str(month));
  if (include_year)
    result = strrep(result, '{year}', num2str(year));
    yy_str = sprintf('%02d', mod(year, 100));
    result = strrep(result, '{yy}', yy_str);
  endif
endfunction
