use v6.d;

unit class SayableTime::Formatter;

our $VERSION = '0.5.0';

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
    return $pattern.subst('{h}', $h-name).subst('{next_h}', $next-h-name);
}

method !format-digital(Int $hour, Int $minute --> Str) {
    my %sc = $.short-clock;
    my $fmt = %sc<format>;
    if %sc<use24h> eq 'True' || %sc<use24h> === True {
        return $fmt.subst('{h}', ~$hour).subst('{mm}', $minute.fmt('%02d'));
    }
    my $h12 = $hour mod 12;
    $h12 = 12 if $h12 == 0;
    my @am-pm = %sc<am-pm>.defined ?? %sc<am-pm>.list !! ('AM', 'PM');
    my $ampm-str = $hour < 12 ?? @am-pm[0] !! @am-pm[1];
    return $fmt.subst('{h}', ~$h12).subst('{mm}', $minute.fmt('%02d')).subst('{ampm}', $ampm-str);
}

method !parse-time(Str $input) {
    return Nil unless $input.defined && $input ne '';
    my $t = $input;
    $t = $t.split('T')[1] if $t.contains('T');
    $t = $t.split('+')[0] if $t.contains('+');
    $t = $t.split('Z')[0] if $t.contains('Z');
    my @parts = $t.split(':');
    return Nil unless @parts.elems >= 2;
    my Int $hour;
    my Int $minute;
    try {
        $hour = @parts[0].Int;
        $minute = @parts[1].split('.')[0].Int;
        CATCH { default { return Nil } }
    }
    return Nil if $hour < 0 || $hour > 23 || $minute < 0 || $minute > 59;
    return [$hour, $minute];
}

sub round-to-five(Int $minute --> Int) {
    return (($minute + 2) div 5) * 5;
}
