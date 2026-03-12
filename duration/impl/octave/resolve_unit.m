% Format a count with the appropriate unit form.

function result = resolve_unit(count, unit_forms, locale, half)
  if (nargin < 4)
    half = '';
  endif

  base_n = num2str(count);
  if (isfield(locale, 'format_number'))
    base_n = locale.format_number(count);
  endif

  n = base_n;
  if (!isempty(half) && !isempty(strfind(half, '{n}')))
    n = strrep(half, '{n}', base_n);
  endif

  if (ischar(unit_forms))
    template = unit_forms;
  else
    if (!isempty(half))
      category = 'other';
    else
      category = locale.plural(count);
    endif
    if (isfield(unit_forms, category))
      template = unit_forms.(category);
    else
      template = unit_forms.other;
    endif
  endif

  result = strrep(template, '{n}', n);

  if (isfield(locale, 'format_unit'))
    result = locale.format_unit(count, result);
  endif

  if (!isempty(half) && !isempty(strfind(half, '{0}')))
    result = strrep(half, '{0}', result);
  endif
endfunction
