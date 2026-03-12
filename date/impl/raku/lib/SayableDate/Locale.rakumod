use v6.d;

unit module SayableDate::Locale;

our sub pick($override, Str $key, $default) {
    if $override.defined && ($override{$key}:exists) {
        return $override{$key};
    }
    return $default;
}
