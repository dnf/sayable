use v6.d;

use SayableTime::Locale;
use SayableTime::Formatter;
use SayableTime::Locales::Registry;

unit module SayableTime;

my $default-formatter;

sub get-default() {
    unless $default-formatter.defined {
        my %en = SayableTime::Locales::Registry::get-locale('en');
        $default-formatter = SayableTime::Formatter.new(%en);
    }
    return $default-formatter;
}

our sub format-time(Str $input? --> Str) is export {
    return get-default().format-time($input);
}
