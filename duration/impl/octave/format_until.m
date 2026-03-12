% Format time until a future event as 'in X'.

function result = format_until(target, as_of, locale, compactness)
  if (nargin < 3 || isempty(locale))
    locale = default_duration_locale();
  endif
  if (nargin < 4)
    compactness = 'normal';
  endif
  sd = sayable_duration_new(locale, compactness);
  result = sd.format_until(target, as_of);
endfunction
