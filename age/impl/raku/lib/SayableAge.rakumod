use v6.d;

use SayableAge::Locale;
use SayableAge::Formatter;
use SayableAge::Locales::Registry;

unit module SayableAge;

my $default-formatter;

sub get-default() {
    unless $default-formatter.defined {
        my %en = SayableAge::Locales::Registry::get-locale('en');
        $default-formatter = SayableAge::Formatter.new(%en);
    }
    return $default-formatter;
}

our sub format-age(Str $date-of-birth?, Str $as-of? --> Str) is export {
    return get-default().format-age($date-of-birth, $as-of);
}

our sub format-stage(Str $date-of-birth?, Str $as-of?, Str :$gender = '' --> Str) is export {
    return get-default().format-stage($date-of-birth, $as-of, :$gender);
}
