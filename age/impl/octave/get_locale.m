% Look up a locale by its code string.

function loc = get_locale(code)
  if (isempty(code) || !ischar(code))
    loc = [];
    return;
  endif
  this_dir = fileparts(mfilename('fullpath'));
  if (isempty(this_dir))
    this_dir = '.';
  endif
  loc_dir = fullfile(this_dir, 'locales');
  old_path = path();
  addpath(loc_dir);
  try
    loc = get_age_locale(code);
  catch
    loc = [];
  end
  path(old_path);
endfunction
