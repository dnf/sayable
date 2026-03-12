use v6.d;

use SayableDate::Locale;

unit class SayableDate::Formatter;

our $VERSION = '0.5.0';

has %.locale;
has @.months;
has @.months-in-date;
has @.weekdays;
has $.day-format;
has %.day-format-exceptions;
has $.date-pattern;
has $.date-pattern-with-year;
has $.today-str;
has $.tomorrow-str;
has $.yesterday-str;
has $.compactness;

method new(%locale, Str :$compactness = 'normal') {
    my $ovr;
    if $compactness eq 'short' {
        $ovr = %locale<short>;
    } elsif $compactness eq 'compact' {
        $ovr = %locale<compact>;
    }

    my @months = SayableDate::Locale::pick($ovr, 'months', %locale<months>).list;
    my @months-in-date;
    if $ovr.defined && ($ovr<months-in-date>:exists) {
        @months-in-date = $ovr<months-in-date>.list;
    } elsif (%locale<months-in-date>:exists) && %locale<months-in-date>.defined {
        @months-in-date = %locale<months-in-date>.list;
    }
    my @weekdays = SayableDate::Locale::pick($ovr, 'weekdays', %locale<weekdays>).list;
    my $day-format = SayableDate::Locale::pick($ovr, 'day-format', %locale<day-format>);

    my %day-format-exceptions;
    if $ovr.defined && ($ovr<day-format>:exists) && !($ovr<day-format-exceptions>:exists) {
        %day-format-exceptions = ();
    } else {
        my $exc = SayableDate::Locale::pick($ovr, 'day-format-exceptions', %locale<day-format-exceptions>);
        %day-format-exceptions = $exc.defined ?? $exc !! ();
    }

    my $date-pattern = SayableDate::Locale::pick($ovr, 'date-pattern', %locale<date-pattern>);
    my $date-pattern-with-year = SayableDate::Locale::pick($ovr, 'date-pattern-with-year', %locale<date-pattern-with-year>);
    my $today-str = SayableDate::Locale::pick($ovr, 'today', %locale<today>);
    my $tomorrow-str = SayableDate::Locale::pick($ovr, 'tomorrow', %locale<tomorrow>);
    my $yesterday-str = SayableDate::Locale::pick($ovr, 'yesterday', %locale<yesterday>);

    self.bless(
        locale               => %locale,
        months               => @months,
        months-in-date       => @months-in-date,
        weekdays             => @weekdays,
        day-format           => $day-format,
        day-format-exceptions => %day-format-exceptions,
        date-pattern         => $date-pattern,
        date-pattern-with-year => $date-pattern-with-year,
        today-str            => $today-str,
        tomorrow-str         => $tomorrow-str,
        yesterday-str        => $yesterday-str,
        compactness          => $compactness,
    );
}

method format-date(Str $date? --> Str) {
    return Nil unless $date.defined && $date ne '';
    my $parsed = self!parse-date($date);
    return Nil unless $parsed.defined;
    return self!format-absolute($parsed[0], $parsed[1], $parsed[2], False);
}

method format-date-with-year(Str $date? --> Str) {
    return Nil unless $date.defined && $date ne '';
    my $parsed = self!parse-date($date);
    return Nil unless $parsed.defined;
    return self!format-absolute($parsed[0], $parsed[1], $parsed[2], True);
}

method format-relative(Str $date?, Str :$as-of --> Str) {
    return Nil unless $date.defined && $date ne '';
    return Nil unless $as-of.defined && $as-of ne '';
    my $parsed-date = self!parse-date($date);
    my $parsed-asof = self!parse-date($as-of);
    return Nil unless $parsed-date.defined && $parsed-asof.defined;

    my ($dy, $dm, $dd) = $parsed-date.list;
    my ($ay, $am, $ad) = $parsed-asof.list;

    my $date-jdn = to-jdn($dy, $dm, $dd);
    my $asof-jdn = to-jdn($ay, $am, $ad);
    my $diff = $date-jdn - $asof-jdn;

    return $.today-str if $diff == 0;
    return $.tomorrow-str if $diff == 1;
    return $.yesterday-str if $diff == -1;

    my $is-compact = $.compactness eq 'compact';

    # Day after tomorrow
    if $diff == 2 && (%.locale<day-after-tomorrow>:exists) && %.locale<day-after-tomorrow>.defined && !$is-compact {
        return %.locale<day-after-tomorrow>;
    }

    # Day before yesterday
    if $diff == -2 && (%.locale<day-before-yesterday>:exists) && %.locale<day-before-yesterday>.defined && !$is-compact {
        return %.locale<day-before-yesterday>;
    }

    # Compact: skip weekday references
    if $is-compact {
        my $include-year = $dy != $ay;
        return self!format-absolute($dy, $dm, $dd, $include-year);
    }

    # This weekday (+2 to +6)
    if 2 <= $diff <= 6 && (%.locale<this-weekday>:exists) && %.locale<this-weekday>.defined {
        my $dow = weekday($dy, $dm, $dd);
        my $weekday-name = @.weekdays[$dow];
        return %.locale<this-weekday>.subst('{weekday}', $weekday-name);
    }

    # Last weekday (-6 to -2)
    if -6 <= $diff <= -2 && (%.locale<last-weekday>:exists) && %.locale<last-weekday>.defined {
        my $dow = weekday($dy, $dm, $dd);
        my $weekday-name = @.weekdays[$dow];
        return %.locale<last-weekday>.subst('{weekday}', $weekday-name);
    }

    # Next weekday (+7 to +13)
    if 7 <= $diff <= 13 && (%.locale<next-weekday>:exists) && %.locale<next-weekday>.defined {
        my $dow = weekday($dy, $dm, $dd);
        my $weekday-name = @.weekdays[$dow];
        return %.locale<next-weekday>.subst('{weekday}', $weekday-name);
    }

    # Calendar fallback
    my $include-year = $dy != $ay;
    return self!format-absolute($dy, $dm, $dd, $include-year);
}

method !format-absolute(Int $year, Int $month, Int $day, Bool $include-year --> Str) {
    my $day-str = ~$day;
    my $fmt;
    if (%.day-format-exceptions{$day-str}:exists) {
        $fmt = %.day-format-exceptions{$day-str};
    } else {
        $fmt = $.day-format;
    }
    my $formatted-day = $fmt.subst('{n}', $day-str);

    my @month-names = @.months-in-date.elems > 0 ?? @.months-in-date !! @.months;
    my $month-name = @month-names[$month - 1];

    my $pattern = $include-year ?? $.date-pattern-with-year !! $.date-pattern;
    my $result = $pattern.subst('{month}', $month-name);
    $result = $result.subst('{day}', $formatted-day);
    $result = $result.subst('{d}', ~$day);
    $result = $result.subst('{m}', ~$month);
    if $include-year {
        $result = $result.subst('{year}', ~$year);
        $result = $result.subst('{yy}', ($year mod 100).fmt('%02d'));
    }

    return $result;
}

method !parse-date(Str $s) {
    return Nil unless $s.defined && $s ne '';
    my $date-part = $s;
    $date-part = $s.split('T')[0] if $s.contains('T');
    my @parts = $date-part.split('-');
    return Nil unless @parts.elems == 3;
    my Int $year;
    my Int $month;
    my Int $day;
    try {
        $year = @parts[0].Int;
        $month = @parts[1].Int;
        $day = @parts[2].Int;
        CATCH { default { return Nil } }
    }
    return Nil if $month < 1 || $month > 12 || $day < 1 || $day > 31;
    return [$year, $month, $day];
}

sub to-jdn(Int $year, Int $month, Int $day --> Int) {
    my $a = (14 - $month) div 12;
    my $y = $year + 4800 - $a;
    my $m = $month + 12 * $a - 3;
    return $day + (153 * $m + 2) div 5 + 365 * $y + $y div 4 - $y div 100 + $y div 400 - 32045;
}

sub weekday(Int $year, Int $month, Int $day --> Int) {
    my $jdn = to-jdn($year, $month, $day);
    return ($jdn + 1) mod 7;
}
