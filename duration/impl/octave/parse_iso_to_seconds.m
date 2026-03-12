% Parse ISO datetime string to epoch-ish seconds for diffing.
% Returns [] on failure.

function result = parse_iso_to_seconds(iso_str)
  if (isempty(iso_str) || !ischar(iso_str))
    result = [];
    return;
  endif
  t_idx = strfind(iso_str, 'T');
  if (isempty(t_idx))
    result = [];
    return;
  endif
  date_part = iso_str(1:t_idx(1) - 1);
  time_part = iso_str(t_idx(1) + 1:end);

  dp = strsplit(date_part, '-');
  if (length(dp) != 3)
    result = [];
    return;
  endif
  year = str2double(dp{1});
  month = str2double(dp{2});
  day = str2double(dp{3});
  if (isnan(year) || isnan(month) || isnan(day))
    result = [];
    return;
  endif
  year = floor(year);
  month = floor(month);
  day = floor(day);

  % Strip timezone
  plus_idx = strfind(time_part, '+');
  if (!isempty(plus_idx))
    time_part = time_part(1:plus_idx(1) - 1);
  endif
  z_idx = strfind(time_part, 'Z');
  if (!isempty(z_idx))
    time_part = time_part(1:z_idx(1) - 1);
  endif

  tp = strsplit(time_part, ':');
  hour = str2double(tp{1});
  if (length(tp) > 1)
    minute = str2double(tp{2});
  else
    minute = 0;
  endif
  if (length(tp) > 2)
    % Handle fractional seconds
    sec_parts = strsplit(tp{3}, '.');
    second = str2double(sec_parts{1});
  else
    second = 0;
  endif
  if (isnan(hour) || isnan(minute) || isnan(second))
    result = [];
    return;
  endif
  hour = floor(hour);
  minute = floor(minute);
  second = floor(second);

  days = days_since_epoch(year, month, day);
  result = days * 86400 + hour * 3600 + minute * 60 + second;
endfunction
