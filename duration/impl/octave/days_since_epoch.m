% Calculate days since a reference epoch (2000-01-01).

function days = days_since_epoch(year, month, day)
  days = 0;
  if (year >= 2000)
    for y = 2000:(year - 1)
      if (is_leap_year(y))
        days += 366;
      else
        days += 365;
      endif
    endfor
  else
    for y = year:1999
      if (is_leap_year(y))
        days -= 366;
      else
        days -= 365;
      endif
    endfor
  endif
  for m = 1:(month - 1)
    days += days_in_month(year, m);
  endfor
  days += day - 1;
endfunction
