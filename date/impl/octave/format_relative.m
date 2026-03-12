% Format a date relative to a reference date.

function result = format_relative(date_str, as_of, locale, compactness)
  if (nargin < 3 || isempty(locale))
    locale = default_date_locale();
  endif
  if (nargin < 4)
    compactness = 'normal';
  endif
  sd = sayable_date_new(locale, compactness);
  result = sd.format_relative(date_str, as_of);
endfunction
