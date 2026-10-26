use v6.d;

use SayableDuration::Locale;

unit class SayableDuration::Formatter;

our $VERSION = '0.5.0';

my constant MAX-DURATION-MONTHS = 6000;  # 500 years, the same ceiling as sayable-age

has %.locale;
has %.units;
has $.half;
has $.delimiter;
has $.just-now;
has $.ago;
has $.in-future;

method new(%locale, Str :$compactness = 'normal') {
    my $ovr;
    if $compactness eq 'short' {
        $ovr = %locale<short>;
    } elsif $compactness eq 'compact' {
        $ovr = %locale<compact>;
    }

    my %units;
    my $ovr-units = $ovr.defined ?? $ovr<units> !! Nil;
    for <second minute hour day week month year> -> $k {
        if $ovr-units.defined && ($ovr-units{$k}:exists) {
            %units{$k} = $ovr-units{$k};
        } else {
            %units{$k} = %locale<units>{$k};
        }
    }

    my $half = pick($ovr, 'half', %locale<half>);
    my $delimiter = pick($ovr, 'delimiter', %locale<delimiter>);
    my $just-now = %locale<just-now>;
    my $ago = pick($ovr, 'ago', %locale<ago>);
    my $in-future = pick($ovr, 'in-future', %locale<in-future>);

    self.bless(
        locale    => %locale,
        units     => %units,
        half      => $half,
        delimiter => $delimiter,
        just-now  => $just-now,
        ago       => $ago,
        in-future => $in-future,
    );
}

sub pick($override, Str $key, $default) {
    if $override.defined && ($override{$key}:exists) {
        return $override{$key};
    }
    return $default;
}

method format-duration($start-or-seconds?, Str $end? --> Str) {
    return Nil unless $start-or-seconds.defined;

    my Int $total-seconds;
    if $start-or-seconds ~~ Int {
        $total-seconds = $start-or-seconds;
    } elsif $start-or-seconds ~~ Str {
        return Nil unless $end.defined;
        my $s = parse-iso-to-seconds($start-or-seconds);
        my $e = parse-iso-to-seconds($end);
        return Nil unless $s.defined && $e.defined;
        $total-seconds = abs($e - $s);
    } else {
        return Nil;
    }

    return Nil if $total-seconds < 0;
    return self!format-duration-seconds($total-seconds);
}

method !format-duration-seconds(Int $total --> Str) {
    # 0 seconds
    return $.just-now if $total == 0;

    # 1-59 seconds
    if $total < 60 {
        return SayableDuration::Locale::resolve-unit($total, %.units<second>, %.locale);
    }

    my $total-minutes = $total div 60;
    my $remainder-seconds = $total mod 60;

    # 1-4 minutes: minutes + seconds
    if $total-minutes < 5 {
        my $result = SayableDuration::Locale::resolve-unit($total-minutes, %.units<minute>, %.locale);
        if $remainder-seconds > 0 {
            $result = $result ~ $.delimiter ~ SayableDuration::Locale::resolve-unit($remainder-seconds, %.units<second>, %.locale);
        }
        return $result;
    }

    # 5-59 minutes
    if $total-minutes < 60 {
        return SayableDuration::Locale::resolve-unit($total-minutes, %.units<minute>, %.locale);
    }

    my $total-hours = $total div 3600;
    my $remainder-minutes = ($total mod 3600) div 60;

    # 1-5 hours: hours + minutes (with half marker)
    if $total-hours <= 5 {
        if $remainder-minutes == 30 {
            return SayableDuration::Locale::resolve-unit($total-hours, %.units<hour>, %.locale, $.half);
        }
        my $result = SayableDuration::Locale::resolve-unit($total-hours, %.units<hour>, %.locale);
        if $remainder-minutes > 0 {
            $result = $result ~ $.delimiter ~ SayableDuration::Locale::resolve-unit($remainder-minutes, %.units<minute>, %.locale);
        }
        return $result;
    }

    # 6-23 hours
    if $total-hours < 24 {
        return SayableDuration::Locale::resolve-unit($total-hours, %.units<hour>, %.locale);
    }

    my $total-days = $total div 86400;
    my $remainder-hours = ($total mod 86400) div 3600;

    # 1-2 days: days + hours (with half marker)
    if $total-days <= 2 {
        if $remainder-hours == 12 {
            return SayableDuration::Locale::resolve-unit($total-days, %.units<day>, %.locale, $.half);
        }
        my $result = SayableDuration::Locale::resolve-unit($total-days, %.units<day>, %.locale);
        if $remainder-hours > 0 {
            $result = $result ~ $.delimiter ~ SayableDuration::Locale::resolve-unit($remainder-hours, %.units<hour>, %.locale);
        }
        return $result;
    }

    # 3-6 days
    if $total-days < 7 {
        return SayableDuration::Locale::resolve-unit($total-days, %.units<day>, %.locale);
    }

    my $total-weeks = $total-days div 7;
    my $remainder-days = $total-days mod 7;

    # 1-4 weeks (up to 29 days)
    if $total-days < 30 {
        my $result = SayableDuration::Locale::resolve-unit($total-weeks, %.units<week>, %.locale);
        if $remainder-days > 0 {
            $result = $result ~ $.delimiter ~ SayableDuration::Locale::resolve-unit($remainder-days, %.units<day>, %.locale);
        }
        return $result;
    }

    # Approximate months (30.44 days average)
    my $total-months = ($total-days / 30.44).round;
    return Nil if $total-months > MAX-DURATION-MONTHS;

    # 1-11 months
    if $total-months < 12 {
        $total-months = 1 if $total-months == 0;
        return SayableDuration::Locale::resolve-unit($total-months, %.units<month>, %.locale);
    }

    # 12+ months: years + months
    my $total-years = $total-months div 12;
    my $remainder-months = $total-months mod 12;
    my $result = SayableDuration::Locale::resolve-unit($total-years, %.units<year>, %.locale);
    if $remainder-months > 0 {
        $result = $result ~ $.delimiter ~ SayableDuration::Locale::resolve-unit($remainder-months, %.units<month>, %.locale);
    }
    return $result;
}

method format-since(Str $start?, Str $as-of? --> Str) {
    return Nil unless $start.defined && $start ne '';
    return Nil unless $as-of.defined && $as-of ne '';
    my $s = parse-iso-to-seconds($start);
    my $a = parse-iso-to-seconds($as-of);
    return Nil unless $s.defined && $a.defined;
    my $diff = $a - $s;
    return Nil if $diff < 0;
    return $.just-now if $diff == 0;
    my $dur = self!format-duration-seconds($diff);
    return Nil unless $dur.defined;
    return SayableDuration::Locale::replace-placeholder($.ago, '{0}', $dur);
}

method format-until(Str $target?, Str $as-of? --> Str) {
    return Nil unless $target.defined && $target ne '';
    return Nil unless $as-of.defined && $as-of ne '';
    my $t = parse-iso-to-seconds($target);
    my $a = parse-iso-to-seconds($as-of);
    return Nil unless $t.defined && $a.defined;
    my $diff = $t - $a;
    return Nil if $diff < 0;
    return $.just-now if $diff == 0;
    my $dur = self!format-duration-seconds($diff);
    return Nil unless $dur.defined;
    return SayableDuration::Locale::replace-placeholder($.in-future, '{0}', $dur);
}

#| YYYY-MM-DDTHH:MM with optional :SS, fraction and zone suffix (ignored).
my regex timestamp {
    ^ (<[0..9]> ** 4) '-' (<[0..9]> ** 2) '-' (<[0..9]> ** 2) 'T'
    (<[0..9]> ** 1..2) ':' (<[0..9]> ** 2)
    [ ':' (<[0..9]> ** 2) [ '.' <[0..9]>+ ]? ]?
    [ 'Z' | <[+-]> <[0..9]> ** 2 ':' <[0..9]> ** 2 ]? $
}

sub parse-iso-to-seconds(Str $iso-str --> Int) {
    return Nil unless $iso-str.defined;
    my $m = $iso-str ~~ &timestamp;
    return Nil unless $m;
    my ($year, $month, $day, $hour, $minute) = $m[0..4]».Int;
    my $second = $m[5] ?? $m[5].Int !! 0;
    return Nil unless 1 <= $month <= 12 && 1 <= $day <= days-in-month($year, $month);
    return Nil if $hour > 23 || $minute > 59 || $second > 59;

    my $days = days-since-epoch($year, $month, $day);
    return $days * 86400 + $hour * 3600 + $minute * 60 + $second;
}

sub is-leap-year(Int $year --> Bool) {
    return ($year %% 4 && !($year %% 100)) || $year %% 400;
}

sub days-in-month(Int $year, Int $month --> Int) {
    my @days = 0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31;
    return 29 if $month == 2 && is-leap-year($year);
    return @days[$month];
}

sub days-since-epoch(Int $year, Int $month, Int $day --> Int) {
    my $days = 0;
    if $year >= 2000 {
        for 2000 ..^ $year -> $y {
            $days += is-leap-year($y) ?? 366 !! 365;
        }
    } else {
        for $year ..^ 2000 -> $y {
            $days -= is-leap-year($y) ?? 366 !! 365;
        }
    }
    for 1 ..^ $month -> $m {
        $days += days-in-month($year, $m);
    }
    $days += $day - 1;
    return $days;
}
