use v6.d;

use SayableDuration::Locale;
use SayableDuration::Formatter;
use SayableDuration::Locales::Registry;

unit module SayableDuration;

my $default-formatter;

sub get-default() {
    unless $default-formatter.defined {
        my %en = SayableDuration::Locales::Registry::get-locale('en');
        $default-formatter = SayableDuration::Formatter.new(%en);
    }
    return $default-formatter;
}

our sub format-duration($start-or-seconds?, Str $end? --> Str) is export {
    return get-default().format-duration($start-or-seconds, $end);
}

our sub format-since(Str $start?, Str $as-of? --> Str) is export {
    return get-default().format-since($start, $as-of);
}

our sub format-until(Str $target?, Str $as-of? --> Str) is export {
    return get-default().format-until($target, $as-of);
}
