% Human-friendly age formatting for young children.
%
% Formats ages the way parents and pediatricians talk:
% "6 weeks", "14 months", "3½ years".
% Zero runtime dependencies.

function result = format_age(date_of_birth, as_of, locale, compactness)
  if (nargin < 2)
    as_of = '';
  endif
  if (nargin < 3 || isempty(locale))
    locale = default_locale();
  endif
  if (nargin < 4)
    compactness = 'normal';
  endif
  sa = sayable_age_new(locale, compactness);
  result = sa.format_age(date_of_birth, as_of);
endfunction
