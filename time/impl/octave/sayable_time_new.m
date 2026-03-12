% Create a new SayableTime formatter.
%
% Parameters:
%   locale      - A locale struct (e.g., locale_en())
%   compactness - 'normal', 'short', or 'compact' (default: 'normal')
%
% Returns a struct with a format_time function handle.

function st = sayable_time_new(locale, compactness)
  if (nargin < 2)
    compactness = 'normal';
  endif

  short_clock = [];
  if (strcmp(compactness, 'short') && isfield(locale, 'short') && isfield(locale.short, 'clock'))
    short_clock = locale.short.clock;
  elseif (strcmp(compactness, 'compact') && isfield(locale, 'compact') && isfield(locale.compact, 'clock'))
    short_clock = locale.compact.clock;
  endif

  st.format_time = @(s) do_format_time(s, locale, compactness, short_clock);
endfunction

function result = do_format_time(input_str, locale, compactness, short_clock)
  if (isempty(input_str) || !ischar(input_str))
    result = [];
    return;
  endif
  parsed = parse_time_str(input_str);
  if (isempty(parsed))
    result = [];
    return;
  endif
  hour = parsed(1);
  minute = parsed(2);

  if (!strcmp(compactness, 'normal') && !isempty(short_clock))
    result = format_digital(hour, minute, short_clock);
  else
    result = format_natural(hour, minute, locale);
  endif
endfunction

function result = format_natural(hour, minute, locale)
  clock = locale.clock;
  rounded = round_to_5(minute);
  h = hour;
  if (rounded == 60)
    rounded = 0;
    h = mod(h + 1, 24);
  endif
  if (rounded == 0)
    if (h == 0)
      result = clock.midnight;
      return;
    endif
    if (h == 12)
      result = clock.noon;
      return;
    endif
  endif
  h12 = mod(h, 12);
  next_h12 = mod(h + 1, 12);
  h_name = clock.hours{h12 + 1};
  next_h_name = clock.hours{next_h12 + 1};

  key = sprintf('p%d', rounded);
  if (isfield(clock.patterns, key))
    pattern = clock.patterns.(key);
  elseif (isfield(clock.patterns, 'p0'))
    pattern = clock.patterns.p0;
  else
    pattern = '{h}';
  endif

  result = strrep(pattern, '{h}', h_name);
  result = strrep(result, '{next_h}', next_h_name);
endfunction

function result = format_digital(hour, minute, short_clock)
  fmt = short_clock.format;
  if (short_clock.use24h)
    result = strrep(fmt, '{h}', num2str(hour));
    result = strrep(result, '{mm}', sprintf('%02d', minute));
  else
    h12 = mod(hour, 12);
    if (h12 == 0)
      h12 = 12;
    endif
    if (!isempty(short_clock.am_pm) && iscell(short_clock.am_pm) && length(short_clock.am_pm) >= 2)
      if (hour < 12)
        ampm_str = short_clock.am_pm{1};
      else
        ampm_str = short_clock.am_pm{2};
      endif
    else
      if (hour < 12)
        ampm_str = 'AM';
      else
        ampm_str = 'PM';
      endif
    endif
    result = strrep(fmt, '{h}', num2str(h12));
    result = strrep(result, '{mm}', sprintf('%02d', minute));
    result = strrep(result, '{ampm}', ampm_str);
  endif
endfunction
