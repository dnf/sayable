% Map calendar months to a stage key.

function key = stage_key(months)
  if (months < 2)
    key = 'newborn';
  elseif (months < 12)
    key = 'infant';
  elseif (months < 36)
    key = 'toddler';
  elseif (months < 156)
    key = 'child';
  elseif (months < 216)
    key = 'teenager';
  else
    key = 'adult';
  endif
endfunction
