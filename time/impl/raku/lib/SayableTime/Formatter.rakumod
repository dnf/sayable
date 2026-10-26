use v6.d;

unit class SayableTime::Formatter;

our $VERSION = '0.5.0';

# Placeholders are matched on code points, not graphemes. Raku strings are
# graphemes, and a placeholder followed by a combining mark (Tamil "{h}" then
# U+0BC1) is the single grapheme "}" + U+0BC1, which .subst and .contains never
# match. Every occurrence is replaced, as in the other implementations.
my sub replace-placeholder(Str $template, Str $placeholder, Str $value --> Str) {
    my @text = $template.ords;
    my @hole = $placeholder.ords;
    my @out;
    my $i = 0;
    while $i < @text.elems {
        if $i + @hole.elems <= @text.elems && @text[$i ..^ $i + @hole.elems] eqv @hole.List {
            @out.append: $value.ords;
            $i += @hole.elems;
        }
        else {
            @out.push: @text[$i++];
        }
    }
    @out.chrs
}

my sub has-placeholder(Str $template, Str $placeholder --> Bool) {
    (',' ~ $template.ords.join(',') ~ ',').contains(',' ~ $placeholder.ords.join(',') ~ ',')
}

has %.locale;
has $.compactness;
has $.short-clock;

method new(%locale, Str :$compactness = 'normal') {
    my $ovr;
    if $compactness eq 'short' {
        $ovr = %locale<short>;
    } elsif $compactness eq 'compact' {
        $ovr = %locale<compact>;
    }

    my $short-clock = $ovr.defined ?? $ovr<clock> !! Nil;

    self.bless(
        locale      => %locale,
        compactness => $compactness,
        short-clock => $short-clock,
    );
}

method format-time(Str $input? --> Str) {
    return Nil unless $input.defined && $input ne '';
    my $parsed = self!parse-time($input);
    return Nil unless $parsed.defined;
    my ($hour, $minute) = $parsed.list;

    if $.compactness ne 'normal' && $.short-clock.defined {
        return self!format-digital($hour, $minute);
    }
    return self!format-natural($hour, $minute);
}

method !format-natural(Int $hour, Int $minute --> Str) {
    my %clock = %.locale<clock>;
    my $rounded = round-to-five($minute);
    my $h = $hour;
    if $rounded == 60 {
        $rounded = 0;
        $h = ($h + 1) mod 24;
    }
    if $rounded == 0 {
        return %clock<midnight> if $h == 0;
        return %clock<noon> if $h == 12;
    }
    my $h12 = $h mod 12;
    my $next-h12 = ($h + 1) mod 12;
    my $h-name = %clock<hours>[$h12];
    my $next-h-name = %clock<hours>[$next-h12];
    my $pattern = %clock<patterns>{$rounded} // %clock<patterns>{0} // '{h}';
    return replace-placeholder(replace-placeholder($pattern, '{h}', $h-name), '{next_h}', $next-h-name);
}

method !format-digital(Int $hour, Int $minute --> Str) {
    my %sc = $.short-clock;
    my $fmt = %sc<format>;
    if %sc<use24h> eq 'True' || %sc<use24h> === True {
        return replace-placeholder(replace-placeholder($fmt, '{h}', ~$hour), '{mm}', $minute.fmt('%02d'));
    }
    my $h12 = $hour mod 12;
    $h12 = 12 if $h12 == 0;
    my @am-pm = %sc<am-pm>.defined ?? %sc<am-pm>.list !! ('AM', 'PM');
    my $ampm-str = $hour < 12 ?? @am-pm[0] !! @am-pm[1];
    return replace-placeholder(replace-placeholder(replace-placeholder($fmt, '{h}', ~$h12), '{mm}', $minute.fmt('%02d')), '{ampm}', $ampm-str);
}

#| A clock time (H:MM or HH:MM, optional :SS and fraction, optional zone
#| suffix, which is ignored), alone or after the T of an ISO datetime.
my regex clock-time {
    ^ [ $<year>=[<[0..9]> ** 4] '-' $<month>=[<[0..9]> ** 2] '-' $<day>=[<[0..9]> ** 2] 'T' ]?
    $<hour>=[<[0..9]> ** 1..2] ':' $<minute>=[<[0..9]> ** 2]
    [ ':' $<second>=[<[0..9]> ** 2] [ '.' <[0..9]>+ ]? ]?
    [ 'Z' | <[+-]> <[0..9]> ** 2 ':' <[0..9]> ** 2 ]? $
}

method !parse-time(Str $input) {
    return Nil unless $input.defined;
    my $m = $input ~~ &clock-time;
    return Nil unless $m;
    if $m<year> {
        my ($year, $month, $day) = $m<year>.Int, $m<month>.Int, $m<day>.Int;
        return Nil unless 1 <= $month <= 12 && 1 <= $day <= days-in-month($year, $month);
    }
    my ($hour, $minute) = $m<hour>.Int, $m<minute>.Int;
    my $second = $m<second> ?? $m<second>.Int !! 0;
    return Nil if $hour > 23 || $minute > 59 || $second > 59;
    return [$hour, $minute];
}

sub days-in-month(Int $year, Int $month --> Int) {
    return 30 if $month == 4 | 6 | 9 | 11;
    return 31 unless $month == 2;
    return ($year %% 4 && !($year %% 100)) || $year %% 400 ?? 29 !! 28;
}

sub round-to-five(Int $minute --> Int) {
    return (($minute + 2) div 5) * 5;
}
