% Parse date-of-birth and as-of dates into months and elapsed days.
%
% Returns a struct with .months and .diff_days, or [] on invalid input.

function result = parse_age(date_of_birth, as_of)
  if (nargin < 2)
    as_of = '';
  endif

  if (isempty(date_of_birth) || !ischar(date_of_birth))
    result = [];
    return;
  endif

  dob = parse_age_date(date_of_birth);
  if (isempty(dob))
    result = [];
    return;
  endif

  if (!isempty(as_of) && ischar(as_of))
    ref = parse_age_date(as_of);
    if (isempty(ref))
      result = [];
      return;
    endif
  else
    v = clock();
    ref.year = floor(v(1));
    ref.month = floor(v(2));
    ref.day = floor(v(3));
  endif

  diff_days = days_between(dob.year, dob.month, dob.day, ref.year, ref.month, ref.day);
  if (diff_days < 0)
    result = [];
    return;
  endif

  last_day = days_in_month(ref.year, ref.month);
  clamped_birthday = min(dob.day, last_day);
  months = (ref.year - dob.year) * 12 + (ref.month - dob.month);
  if (ref.day < clamped_birthday)
    months = months - 1;
  endif

  if (months > 6000)
    result = [];
    return;
  endif

  result.months = months;
  result.diff_days = diff_days;
endfunction
