% Parse a YYYY-MM-DD string into a struct with .year, .month, .day fields.
% Returns [] on invalid input.

function result = parse_date_str(s)
  if (isempty(s) || !ischar(s))
    result = [];
    return;
  endif
  parts = strsplit(s, '-');
  if (length(parts) != 3)
    result = [];
    return;
  endif
  y = str2double(parts{1});
  m = str2double(parts{2});
  d = str2double(parts{3});
  if (isnan(y) || isnan(m) || isnan(d))
    result = [];
    return;
  endif
  result.year = floor(y);
  result.month = floor(m);
  result.day = floor(d);
endfunction
