use v6.d;

use SayableDate::Locale;
use SayableDate::Formatter;
use SayableDate::Locales::Registry;

unit module SayableDate;

my $default-formatter;

sub get-default() {
    unless $default-formatter.defined {
        my %en = SayableDate::Locales::Registry::get-locale('en');
        $default-formatter = SayableDate::Formatter.new(%en);
    }
    return $default-formatter;
}

our sub format-date(Str $date? --> Str) is export {
    return get-default().format-date($date);
}

our sub format-date-with-year(Str $date? --> Str) is export {
    return get-default().format-date-with-year($date);
}

our sub format-relative(Str $date?, Str :$as-of --> Str) is export {
    return get-default().format-relative($date, :$as-of);
}
