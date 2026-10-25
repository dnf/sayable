% Create a new SayableAge formatter.
%
% Parameters:
%   locale     - A locale struct (e.g., locale_en())
%   compactness - 'normal', 'short', or 'compact' (default: 'normal')
%
% Returns a struct with format_age and format_stage function handles.

function sa = sayable_age_new(locale, compactness)
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
  for k = {'day', 'week', 'month', 'year'}
    unit_name = k{1};
    if (!isempty(ovr_units) && isfield(ovr_units, unit_name))
      units.(unit_name) = ovr_units.(unit_name);
    else
      units.(unit_name) = locale.units.(unit_name);
    endif
  endfor

  half = pick_field(ovr, 'half', locale.half);
  delimiter = pick_field(ovr, 'delimiter', locale.delimiter);
  just_born = pick_field(ovr, 'just_born', locale.just_born);

  sa.format_age = @(dob, ao) do_format_age(dob, ao, locale, units, half, delimiter, just_born);
  sa.format_stage = @(dob, ao, g) do_format_stage(dob, ao, g, locale);
endfunction

function result = do_format_age(date_of_birth, as_of, locale, units, half, delimiter, just_born)
  parsed = parse_age(date_of_birth, as_of);
  if (isempty(parsed))
    result = [];
    return;
  endif

  months = parsed.months;
  diff_days = parsed.diff_days;

  % Tier 1: 0-6 days
  if (diff_days == 0)
    result = just_born;
    return;
  endif
  if (diff_days < 7)
    result = resolve_age_unit(diff_days, units.day, locale);
    return;
  endif

  % Tier 2: weeks + days until 3 calendar months
  if (months < 3)
    weeks = floor(diff_days / 7);
    days = mod(diff_days, 7);
    result = resolve_age_unit(weeks, units.week, locale);
    if (days > 0)
      result = [result delimiter resolve_age_unit(days, units.day, locale)];
    endif
    return;
  endif

  % Tier 3: 3-23 months
  if (months < 24)
    result = resolve_age_unit(months, units.month, locale);
    return;
  endif

  % Tier 4: 24-35 months -> years + months
  if (months < 36)
    years = floor(months / 12);
    rem = mod(months, 12);
    if (rem == 0)
      result = resolve_age_unit(years, units.year, locale);
      return;
    endif
    result = [resolve_age_unit(years, units.year, locale) delimiter resolve_age_unit(rem, units.month, locale)];
    return;
  endif

  % Tier 5: 3-6 years -> years with half marker
  if (months < 84)
    years = floor(months / 12);
    rem = mod(months, 12);
    if (rem >= 6)
      result = resolve_age_unit(years, units.year, locale, half);
      return;
    endif
    result = resolve_age_unit(years, units.year, locale);
    return;
  endif

  % Tier 6: 7+ years
  result = resolve_age_unit(floor(months / 12), units.year, locale);
endfunction

function result = do_format_stage(date_of_birth, as_of, gender, locale)
  parsed = parse_age(date_of_birth, as_of);
  if (isempty(parsed))
    result = [];
    return;
  endif
  key = stage_key(parsed.months);
  label = locale.stages.(key);
  result = resolve_stage(label, gender);
endfunction
