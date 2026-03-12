% Resolve a stage label, handling gendered labels.

function result = resolve_stage(label, gender)
  if (nargin < 2)
    gender = '';
  endif
  if (ischar(label))
    result = label;
    return;
  endif
  if (isstruct(label))
    if (!isempty(gender) && strcmp(gender, 'f'))
      result = label.f;
    else
      result = label.m;
    endif
    return;
  endif
  result = label;
endfunction
