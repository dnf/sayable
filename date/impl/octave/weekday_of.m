% Return day of week: 0=Sunday, 1=Monday, ..., 6=Saturday.

function dow = weekday_of(year, month, day)
  jdn = to_jdn(year, month, day);
  dow = mod(jdn + 1, 7);
endfunction
