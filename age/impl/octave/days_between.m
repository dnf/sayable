% Calculate the number of days between two dates.

function d = days_between(y1, m1, d1, y2, m2, d2)
  d = to_jdn(y2, m2, d2) - to_jdn(y1, m1, d1);
endfunction

function jdn = to_jdn(y, m, d)
  if (m <= 2)
    y = y - 1;
    m = m + 12;
  endif
  a = floor(y / 100);
  b = 2 - a + floor(a / 4);
  jdn = floor(365.25 * (y + 4716)) + floor(30.6001 * (m + 1)) + d + b - 1524;
endfunction
