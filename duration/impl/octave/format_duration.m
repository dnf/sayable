% Human-friendly duration formatting.
%
% Formats durations the way people speak:
% "just now", "3 minutes, 42 seconds", "2½ hours".
% Zero runtime dependencies.

function result = format_duration(start_or_seconds, end_str, locale, compactness)
  if (nargin < 2)
    end_str = '';
  endif
  if (nargin < 3 || isempty(locale))
    locale = default_duration_locale();
  endif
  if (nargin < 4)
    compactness = 'normal';
  endif
  sd = sayable_duration_new(locale, compactness);
  result = sd.format_duration(start_or_seconds, end_str);
endfunction
