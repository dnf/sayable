use v6.d;

use SayableAge::Locale;

unit class SayableAge::Formatter;

our $VERSION = '0.5.0';

has %.locale;
has $.day;
has $.week;
has $.month;
has $.year;
has $.half;
has $.delimiter;
has $.just-born;

my constant MAX-AGE-MONTHS = 6000;

method new(%locale, Str :$compactness = 'normal') {
    my $ovr;
    if $compactness eq 'short' {
        $ovr = %locale<short>;
    } elsif $compactness eq 'compact' {
        $ovr = %locale<compact>;
    }

    my $day;
    my $week;
    my $month-unit;
    my $year;
    my $half;
    my $delimiter;
    my $just-born;

    if $ovr.defined && $ovr<units>.defined {
        $day   = $ovr<units><day>   // %locale<units><day>;
        $week  = $ovr<units><week>  // %locale<units><week>;
        $month-unit = $ovr<units><month> // %locale<units><month>;
        $year  = $ovr<units><year>  // %locale<units><year>;
    } else {
        $day   = %locale<units><day>;
        $week  = %locale<units><week>;
        $month-unit = %locale<units><month>;
        $year  = %locale<units><year>;
    }

    if $ovr.defined && ($ovr<half>:exists) {
        $half = $ovr<half>;
    } else {
        $half = %locale<half>;
    }

    if $ovr.defined && ($ovr<delimiter>:exists) {
        $delimiter = $ovr<delimiter>;
    } else {
        $delimiter = %locale<delimiter>;
    }

    if $ovr.defined && ($ovr<just-born>:exists) {
        $just-born = $ovr<just-born>;
    } else {
        $just-born = %locale<just-born>;
    }

    self.bless(
        locale    => %locale,
        day       => $day,
        week      => $week,
        month     => $month-unit,
        year      => $year,
        half      => $half,
        delimiter => $delimiter,
        just-born => $just-born,
    );
}

method format-age(Str $date-of-birth?, Str $as-of? --> Str) {
    my $age = self!parse-age($date-of-birth, $as-of);
    return Nil unless $age.defined;

    my $months = $age[0];
    my $diff-days = $age[1];

    # Tier 1: 0 days
    return $.just-born if $diff-days == 0;

    # Tier 1b: 1-6 days
    if $diff-days < 7 {
        return SayableAge::Locale::resolve-unit($diff-days, $.day, %.locale);
    }

    # Tier 2: weeks + days until 3 calendar months
    if $months < 3 {
        my $weeks = $diff-days div 7;
        my $days = $diff-days mod 7;
        my $result = SayableAge::Locale::resolve-unit($weeks, $.week, %.locale);
        if $days > 0 {
            $result = $result ~ $.delimiter ~ SayableAge::Locale::resolve-unit($days, $.day, %.locale);
        }
        return $result;
    }

    # Tier 3: 3-23 months
    if $months < 24 {
        return SayableAge::Locale::resolve-unit($months, $.month, %.locale);
    }

    # Tier 4: 24-35 months -> years + months
    if $months < 36 {
        my $years = $months div 12;
        my $rem = $months mod 12;
        if $rem == 0 {
            return SayableAge::Locale::resolve-unit($years, $.year, %.locale);
        }
        return SayableAge::Locale::resolve-unit($years, $.year, %.locale)
            ~ $.delimiter
            ~ SayableAge::Locale::resolve-unit($rem, $.month, %.locale);
    }

    # Tier 5: 3-6 years -> years with half marker
    if $months < 84 {
        my $years = $months div 12;
        my $rem = $months mod 12;
        if $rem >= 6 {
            return SayableAge::Locale::resolve-unit($years, $.year, %.locale, $.half);
        }
        return SayableAge::Locale::resolve-unit($years, $.year, %.locale);
    }

    # Tier 6: 7+ years
    my $years = $months div 12;
    return SayableAge::Locale::resolve-unit($years, $.year, %.locale);
}

method format-stage(Str $date-of-birth?, Str $as-of?, Str :$gender = '' --> Str) {
    my $age = self!parse-age($date-of-birth, $as-of);
    return Nil unless $age.defined;

    my $months = $age[0];
    my $key = stage-key($months);
    return SayableAge::Locale::resolve-stage(%.locale<stages>{$key}, $gender);
}

method !parse-age(Str $date-of-birth?, Str $as-of?) {
    return Nil unless $date-of-birth.defined && $date-of-birth ne '';

    my $dob = parse-date($date-of-birth);
    my $ref = ($as-of.defined && $as-of ne '') ?? parse-date($as-of) !! today-parts();
    return Nil unless $dob.defined && $ref.defined;
    my ($dob-y, $dob-m, $dob-d) = @$dob;
    my ($ref-y, $ref-m, $ref-d) = @$ref;

    my $dob-date = Date.new($dob-y, $dob-m, $dob-d);
    my $ref-date = Date.new($ref-y, $ref-m, $ref-d);
    my $diff-days = $ref-date.daycount - $dob-date.daycount;
    return Nil if $diff-days < 0;

    # Calendar months with day-of-month clamping
    my $last-day = days-in-month($ref-y, $ref-m);
    my $clamped-birthday = $dob-d < $last-day ?? $dob-d !! $last-day;
    my $months = ($ref-y - $dob-y) * 12 + ($ref-m - $dob-m);
    $months = $months - 1 if $ref-d < $clamped-birthday;
    return Nil if $months > MAX-AGE-MONTHS;

    return [$months, $diff-days];
}

#| Parse exactly YYYY-MM-DD naming a real calendar day into [y, m, d], else Nil.
sub parse-date(Str $s) {
    return Nil unless $s ~~ /^ (<[0..9]> ** 4) '-' (<[0..9]> ** 2) '-' (<[0..9]> ** 2) $/;
    my ($y, $m, $d) = $0.Int, $1.Int, $2.Int;
    return Nil unless 1 <= $m <= 12 && 1 <= $d <= days-in-month($y, $m);
    return [$y, $m, $d];
}

sub today-parts() {
    my $now = Date.today;
    return [$now.year, $now.month, $now.day];
}

sub stage-key(Int $months --> Str) {
    if    $months < 2   { 'newborn' }
    elsif $months < 12  { 'infant' }
    elsif $months < 36  { 'toddler' }
    elsif $months < 156 { 'child' }
    elsif $months < 216 { 'teenager' }
    else                { 'adult' }
}

sub days-in-month(Int $y, Int $m --> Int) {
    my @days = 0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31;
    if $m == 2 && ($y %% 4 && (!($y %% 100) || $y %% 400)) {
        return 29;
    }
    return @days[$m];
}
