% Parse YYYY-MM-DD, optionally followed by T and a time, into a struct with
% .year, .month, .day fields. Only the first ten characters are read, and
% they must name a real calendar day (docs/input-formats.md).
% Returns [] on invalid input.

function result = parse_date_str(s)
  result = [];
  if (!ischar(s) || length(s) < 10 || (length(s) > 10 && s(11) != 'T'))
    return;
  endif
  if (s(5) != '-' || s(8) != '-')
    return;
  endif
  digit_positions = [1:4, 6:7, 9:10];
  if (!all(s(digit_positions) >= '0' & s(digit_positions) <= '9'))
    return;
  endif
  y = str2double(s(1:4));
  m = str2double(s(6:7));
  d = str2double(s(9:10));
  if (m < 1 || m > 12 || d < 1 || d > month_length(y, m))
    return;
  endif
  result.year = y;
  result.month = m;
  result.day = d;
endfunction

function n = month_length(year, month)
  lengths = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  n = lengths(month);
  is_leap = (mod(year, 4) == 0 && mod(year, 100) != 0) || mod(year, 400) == 0;
  if (month == 2 && is_leap)
    n = 29;
  endif
endfunction
