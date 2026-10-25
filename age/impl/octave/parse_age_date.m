% Parse exactly YYYY-MM-DD naming a real calendar day into a struct with
% .year, .month, .day fields (docs/input-formats.md). Returns [] otherwise.
%
% Named parse_age_date rather than parse_date_str so the sayable-date helper
% of that name cannot shadow it when both components share the load path.

function result = parse_age_date(s)
  result = [];
  if (!ischar(s) || length(s) != 10 || s(5) != '-' || s(8) != '-')
    return;
  endif
  digit_positions = [1:4, 6:7, 9:10];
  if (!all(s(digit_positions) >= '0' & s(digit_positions) <= '9'))
    return;
  endif
  y = str2double(s(1:4));
  m = str2double(s(6:7));
  d = str2double(s(9:10));
  if (m < 1 || m > 12 || d < 1 || d > days_in_month(y, m))
    return;
  endif
  result.year = y;
  result.month = m;
  result.day = d;
endfunction
