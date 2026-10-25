% Calculate the number of days since 2000-01-01 (negative before it), from
% the proleptic Gregorian day number, so every four-digit year costs the same.

function days = days_since_epoch(year, month, day)
  days = day_number(year, month, day) - day_number(2000, 1, 1);
endfunction

function n = day_number(year, month, day)
  a = floor((14 - month) / 12);
  y = year + 4800 - a;
  m = month + 12 * a - 3;
  n = day + floor((153 * m + 2) / 5) + 365 * y + floor(y / 4) - floor(y / 100) + floor(y / 400) - 32045;
endfunction
