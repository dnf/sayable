% Round minute to nearest 5.

function result = round_to_5(minute)
  result = floor((minute + 2) / 5) * 5;
endfunction
