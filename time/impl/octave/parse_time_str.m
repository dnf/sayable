% Parse a clock time (H:MM or HH:MM, optional :SS and fraction, optional zone
% suffix, which is ignored), alone or after the T of an ISO datetime whose
% date part is a real calendar day (docs/input-formats.md).
% Returns [hour, minute], or [] on failure.

function result = parse_time_str(input_str)
  result = [];
  if (isempty(input_str) || !ischar(input_str))
    return;
  endif
  clock_str = input_str;
  t_idx = find(input_str == 'T', 1);
  if (!isempty(t_idx))
    if (!is_real_date(input_str(1:t_idx - 1)))
      return;
    endif
    clock_str = input_str(t_idx + 1:end);
  endif
  clock_pattern = '^(?<h>[0-9]{1,2}):(?<m>[0-9]{2})(:(?<s>[0-9]{2})(\.[0-9]+)?)?(Z|[+-][0-9]{2}:[0-9]{2})?\z';
  parts = regexp(clock_str, clock_pattern, 'names', 'once');
  if (isempty(parts) || isempty(fieldnames(parts)))
    return;
  endif
  hour = str2double(parts.h);
  minute = str2double(parts.m);
  second = 0;
  if (!isempty(parts.s))
    second = str2double(parts.s);
  endif
  if (hour > 23 || minute > 59 || second > 59)
    return;
  endif
  result = [hour, minute];
endfunction

function ok = is_real_date(s)
  ok = false;
  parts = regexp(s, '^(?<y>[0-9]{4})-(?<m>[0-9]{2})-(?<d>[0-9]{2})\z', 'names', 'once');
  if (isempty(parts) || isempty(fieldnames(parts)))
    return;
  endif
  year = str2double(parts.y);
  month = str2double(parts.m);
  day = str2double(parts.d);
  if (month < 1 || month > 12)
    return;
  endif
  lengths = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  month_length = lengths(month);
  if (month == 2 && ((mod(year, 4) == 0 && mod(year, 100) != 0) || mod(year, 400) == 0))
    month_length = 29;
  endif
  ok = day >= 1 && day <= month_length;
endfunction
