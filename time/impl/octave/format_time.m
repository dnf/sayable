% Human-friendly clock time formatting.
%
% Formats time the way people speak:
% "a quarter past three", "half past seven", "midnight".
% Zero runtime dependencies.

function result = format_time(input_str, locale, compactness)
  if (nargin < 2 || isempty(locale))
    locale = default_time_locale();
  endif
  if (nargin < 3)
    compactness = 'normal';
  endif
  st = sayable_time_new(locale, compactness);
  result = st.format_time(input_str);
endfunction
