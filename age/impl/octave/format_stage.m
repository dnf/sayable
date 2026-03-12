% Format a developmental stage label.

function result = format_stage(date_of_birth, as_of, gender, locale, compactness)
  if (nargin < 2)
    as_of = '';
  endif
  if (nargin < 3)
    gender = '';
  endif
  if (nargin < 4 || isempty(locale))
    locale = default_locale();
  endif
  if (nargin < 5)
    compactness = 'normal';
  endif
  sa = sayable_age_new(locale, compactness);
  result = sa.format_stage(date_of_birth, as_of, gender);
endfunction
