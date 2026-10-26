% Create a new SayableDuration formatter.
%
% Parameters:
%   locale      - A locale struct (e.g., locale_en())
%   compactness - 'normal', 'short', or 'compact' (default: 'normal')
%
% Returns a struct with format_duration, format_since, format_until handles.

function sd = sayable_duration_new(locale, compactness)
  if (nargin < 2)
    compactness = 'normal';
  endif

  ovr = [];
  if (strcmp(compactness, 'short') && isfield(locale, 'short'))
    ovr = locale.short;
  elseif (strcmp(compactness, 'compact') && isfield(locale, 'compact'))
    ovr = locale.compact;
  endif

  ovr_units = [];
  if (!isempty(ovr) && isfield(ovr, 'units'))
    ovr_units = ovr.units;
  endif

  units = struct();
  for k = {'second', 'minute', 'hour', 'day', 'week', 'month', 'year'}
    unit_name = k{1};
    if (!isempty(ovr_units) && isfield(ovr_units, unit_name))
      units.(unit_name) = ovr_units.(unit_name);
    else
      units.(unit_name) = locale.units.(unit_name);
    endif
  endfor

  half = pick_field(ovr, 'half', locale.half);
  delimiter = pick_field(ovr, 'delimiter', locale.delimiter);
  just_now = locale.just_now;
  ago = pick_field(ovr, 'ago', locale.ago);
  in_future = pick_field(ovr, 'in_future', locale.in_future);

  sd.format_duration = @(sos, e) do_format_duration(sos, e, locale, units, half, delimiter, just_now);
  sd.format_since = @(start, ao) do_format_since(start, ao, locale, units, half, delimiter, just_now, ago);
  sd.format_until = @(target, ao) do_format_until(target, ao, locale, units, half, delimiter, just_now, in_future);
endfunction

function result = do_format_duration(start_or_seconds, end_str, locale, units, half, delimiter, just_now)
  if (isempty(start_or_seconds))
    result = [];
    return;
  endif

  if (isnumeric(start_or_seconds))
    total_seconds = start_or_seconds;
    if (total_seconds < 0)
      result = [];
      return;
    endif
  elseif (ischar(start_or_seconds))
    if (isempty(end_str) || !ischar(end_str))
      result = [];
      return;
    endif
    s = parse_iso_to_seconds(start_or_seconds);
    e = parse_iso_to_seconds(end_str);
    if (isempty(s) || isempty(e))
      result = [];
      return;
    endif
    total_seconds = abs(e - s);
  else
    result = [];
    return;
  endif

  result = format_duration_seconds(total_seconds, locale, units, half, delimiter, just_now);
endfunction

function result = format_duration_seconds(total, locale, units, half, delimiter, just_now)
  % 0 seconds
  if (total == 0)
    result = just_now;
    return;
  endif

  % 1-59 seconds
  if (total < 60)
    result = resolve_unit(total, units.second, locale);
    return;
  endif

  total_minutes = floor(total / 60);
  remainder_seconds = mod(total, 60);

  % 1-4 minutes: minutes + seconds
  if (total_minutes < 5)
    result = resolve_unit(total_minutes, units.minute, locale);
    if (remainder_seconds > 0)
      result = [result delimiter resolve_unit(remainder_seconds, units.second, locale)];
    endif
    return;
  endif

  % 5-59 minutes
  if (total_minutes < 60)
    result = resolve_unit(total_minutes, units.minute, locale);
    return;
  endif

  total_hours = floor(total / 3600);
  remainder_minutes = floor(mod(total, 3600) / 60);

  % 1-5 hours: hours + minutes (with half marker)
  if (total_hours <= 5)
    if (remainder_minutes == 30)
      result = resolve_unit(total_hours, units.hour, locale, half);
      return;
    endif
    result = resolve_unit(total_hours, units.hour, locale);
    if (remainder_minutes > 0)
      result = [result delimiter resolve_unit(remainder_minutes, units.minute, locale)];
    endif
    return;
  endif

  % 6-23 hours
  if (total_hours < 24)
    result = resolve_unit(total_hours, units.hour, locale);
    return;
  endif

  total_days = floor(total / 86400);
  remainder_hours = floor(mod(total, 86400) / 3600);

  % 1-2 days: days + hours (with half marker)
  if (total_days <= 2)
    if (remainder_hours == 12)
      result = resolve_unit(total_days, units.day, locale, half);
      return;
    endif
    result = resolve_unit(total_days, units.day, locale);
    if (remainder_hours > 0)
      result = [result delimiter resolve_unit(remainder_hours, units.hour, locale)];
    endif
    return;
  endif

  % 3-6 days
  if (total_days < 7)
    result = resolve_unit(total_days, units.day, locale);
    return;
  endif

  total_weeks = floor(total_days / 7);
  remainder_days = mod(total_days, 7);

  % 1-4 weeks: weeks + days (up to 29 days; 30+ transitions to months)
  if (total_days < 30)
    result = resolve_unit(total_weeks, units.week, locale);
    if (remainder_days > 0)
      result = [result delimiter resolve_unit(remainder_days, units.day, locale)];
    endif
    return;
  endif

  % Approximate months (30.44 days average)
  total_months = round(total_days / 30.44);
  if (total_months > max_duration_months())
    result = [];
    return;
  endif

  % 1-11 months
  if (total_months < 12)
    if (total_months == 0)
      total_months = 1;
    endif
    result = resolve_unit(total_months, units.month, locale);
    return;
  endif

  % 12+ months: years + months
  total_years = floor(total_months / 12);
  remainder_months = mod(total_months, 12);
  result = resolve_unit(total_years, units.year, locale);
  if (remainder_months > 0)
    result = [result delimiter resolve_unit(remainder_months, units.month, locale)];
  endif
endfunction

function result = do_format_since(start, as_of, locale, units, half, delimiter, just_now, ago)
  if (isempty(start) || !ischar(start) || isempty(as_of) || !ischar(as_of))
    result = [];
    return;
  endif
  s = parse_iso_to_seconds(start);
  a = parse_iso_to_seconds(as_of);
  if (isempty(s) || isempty(a))
    result = [];
    return;
  endif
  diff = a - s;
  if (diff < 0)
    result = [];
    return;
  endif
  if (diff == 0)
    result = just_now;
    return;
  endif
  dur = format_duration_seconds(diff, locale, units, half, delimiter, just_now);
  if (isempty(dur))
    result = [];
    return;
  endif
  result = strrep(ago, '{0}', dur);
endfunction

function result = do_format_until(target, as_of, locale, units, half, delimiter, just_now, in_future)
  if (isempty(target) || !ischar(target) || isempty(as_of) || !ischar(as_of))
    result = [];
    return;
  endif
  t = parse_iso_to_seconds(target);
  a = parse_iso_to_seconds(as_of);
  if (isempty(t) || isempty(a))
    result = [];
    return;
  endif
  diff = t - a;
  if (diff < 0)
    result = [];
    return;
  endif
  if (diff == 0)
    result = just_now;
    return;
  endif
  dur = format_duration_seconds(diff, locale, units, half, delimiter, just_now);
  if (isempty(dur))
    result = [];
    return;
  endif
  result = strrep(in_future, '{0}', dur);
endfunction

% 500 years, the same ceiling as sayable-age.
function n = max_duration_months()
  n = 6000;
endfunction
