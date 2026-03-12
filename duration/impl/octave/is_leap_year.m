% Check if a year is a leap year.

function result = is_leap_year(year)
  result = (mod(year, 4) == 0 && mod(year, 100) != 0) || mod(year, 400) == 0;
endfunction
