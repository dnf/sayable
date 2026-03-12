% Return the number of days in a given month.

function d = days_in_month(year, month)
  if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12)
    d = 31;
  elseif (month == 4 || month == 6 || month == 9 || month == 11)
    d = 30;
  elseif (is_leap_year(year))
    d = 29;
  else
    d = 28;
  endif
endfunction
