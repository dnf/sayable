% Parse a YYYY-MM-DD or ISO datetime string into a struct.
% Returns [] on invalid input.

function result = parse_date_str(s)
  if (isempty(s) || !ischar(s))
    result = [];
    return;
  endif
  % Strip ISO datetime portion
  t_idx = strfind(s, 'T');
  if (!isempty(t_idx))
    s = s(1:t_idx(1) - 1);
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
  m = floor(m);
  d = floor(d);
  if (m < 1 || m > 12 || d < 1 || d > 31)
    result = [];
    return;
  endif
  result.year = floor(y);
  result.month = m;
  result.day = d;
endfunction
