% Return true if the given year is a leap year.

function result = is_leap_year(y)
  result = (mod(y, 4) == 0 && mod(y, 100) != 0) || mod(y, 400) == 0;
endfunction
