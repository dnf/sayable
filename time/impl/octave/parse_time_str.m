% Parse HH:MM or ISO datetime to [hour, minute].
% Returns [] on failure.

function result = parse_time_str(input_str)
  if (isempty(input_str) || !ischar(input_str))
    result = [];
    return;
  endif
  t = input_str;
  % Strip date part from ISO datetime
  t_idx = strfind(t, 'T');
  if (!isempty(t_idx))
    t = t(t_idx(1) + 1:end);
  endif
  % Strip timezone
  plus_idx = strfind(t, '+');
  if (!isempty(plus_idx))
    t = t(1:plus_idx(1) - 1);
  endif
  z_idx = strfind(t, 'Z');
  if (!isempty(z_idx))
    t = t(1:z_idx(1) - 1);
  endif
  parts = strsplit(t, ':');
  if (length(parts) < 2)
    result = [];
    return;
  endif
  % Handle fractional seconds in minutes part
  min_parts = strsplit(parts{2}, '.');
  hour = str2double(parts{1});
  minute = str2double(min_parts{1});
  if (isnan(hour) || isnan(minute))
    result = [];
    return;
  endif
  hour = floor(hour);
  minute = floor(minute);
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59)
    result = [];
    return;
  endif
  result = [hour, minute];
endfunction
