% Return the number of days in a given month/year.

function d = days_in_month(y, m)
  lengths = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  if (m == 2 && is_leap_year(y))
    d = 29;
  else
    d = lengths(m);
  endif
endfunction
