% Human-friendly date formatting.
%
% Formats dates the way people reference them in conversation:
% "today", "next Thursday", "March 15th", "April 10, 2024".
% Zero runtime dependencies.

function result = format_date(date_str, locale, compactness)
  if (nargin < 2 || isempty(locale))
    locale = default_date_locale();
  endif
  if (nargin < 3)
    compactness = 'normal';
  endif
  sd = sayable_date_new(locale, compactness);
  result = sd.format_date(date_str);
endfunction
