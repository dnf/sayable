% Load the default English time locale.

function loc = default_time_locale()
  persistent cached_locale;
  if (!isempty(cached_locale))
    loc = cached_locale;
    return;
  endif
  this_dir = fileparts(mfilename('fullpath'));
  if (isempty(this_dir))
    this_dir = '.';
  endif
  loc_dir = fullfile(this_dir, 'locales');
  old_path = path();
  addpath(loc_dir);
  loc = locale_en();
  path(old_path);
  cached_locale = loc;
endfunction
