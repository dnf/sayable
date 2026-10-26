% Parse an ISO timestamp (YYYY-MM-DDTHH:MM, optional :SS, fraction and zone
% suffix, which is ignored) to seconds for diffing (docs/input-formats.md).
% Returns [] if malformed or if the date or clock time doesn't exist.

function result = parse_iso_to_seconds(iso_str)
  result = [];
  if (isempty(iso_str) || !ischar(iso_str))
    return;
  endif
  timestamp_pattern = ['^(?<year>[0-9]{4})-(?<month>[0-9]{2})-(?<day>[0-9]{2})', ...
                       'T(?<hour>[0-9]{1,2}):(?<minute>[0-9]{2})', ...
                       '(:(?<second>[0-9]{2})(\.[0-9]+)?)?(Z|[+-][0-9]{2}:[0-9]{2})?\z'];
  parts = regexp(iso_str, timestamp_pattern, 'names', 'once');
  if (isempty(parts) || isempty(fieldnames(parts)))
    return;
  endif
  year = str2double(parts.year);
  month = str2double(parts.month);
  day = str2double(parts.day);
  hour = str2double(parts.hour);
  minute = str2double(parts.minute);
  second = 0;
  if (!isempty(parts.second))
    second = str2double(parts.second);
  endif
  if (month < 1 || month > 12 || day < 1 || day > days_in_month(year, month))
    return;
  endif
  if (hour > 23 || minute > 59 || second > 59)
    return;
  endif
  days = days_since_epoch(year, month, day);
  result = days * 86400 + hour * 3600 + minute * 60 + second;
endfunction
