% Pick override value if set, else default.

function result = pick_field(override, field_name, default_val)
  if (!isempty(override) && isstruct(override) && isfield(override, field_name))
    result = override.(field_name);
  else
    result = default_val;
  endif
endfunction
