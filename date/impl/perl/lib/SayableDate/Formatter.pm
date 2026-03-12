use strict;
use warnings;
use utf8;

package SayableDate::Formatter;

use SayableDate::Locale;

our $VERSION = '0.5.0';

sub new {
  my ($class, $locale, %opts) = @_;
  my $compactness = $opts{compactness} || 'normal';

  my $ovr;
  if ($compactness eq 'short') {
    $ovr = $locale->{short};
  } elsif ($compactness eq 'compact') {
    $ovr = $locale->{compact};
  }

  my $months = SayableDate::Locale::pick($ovr, 'months', $locale->{months});
  my $months_in_date = SayableDate::Locale::pick($ovr, 'months_in_date', $locale->{months_in_date});
  my $weekdays = SayableDate::Locale::pick($ovr, 'weekdays', $locale->{weekdays});
  my $day_format = SayableDate::Locale::pick($ovr, 'day_format', $locale->{day_format});

  my $day_format_exceptions;
  if (defined $ovr && exists $ovr->{day_format} && !exists $ovr->{day_format_exceptions}) {
    $day_format_exceptions = {};
  } else {
    $day_format_exceptions = SayableDate::Locale::pick($ovr, 'day_format_exceptions', $locale->{day_format_exceptions});
  }

  my $date_pattern = SayableDate::Locale::pick($ovr, 'date_pattern', $locale->{date_pattern});
  my $date_pattern_with_year = SayableDate::Locale::pick($ovr, 'date_pattern_with_year', $locale->{date_pattern_with_year});
  my $today = SayableDate::Locale::pick($ovr, 'today', $locale->{today});
  my $tomorrow = SayableDate::Locale::pick($ovr, 'tomorrow', $locale->{tomorrow});
  my $yesterday = SayableDate::Locale::pick($ovr, 'yesterday', $locale->{yesterday});

  my $self = bless {
    locale => $locale,
    compactness => $compactness,
    months => $months,
    months_in_date => $months_in_date,
    weekdays => $weekdays,
    day_format => $day_format,
    day_format_exceptions => $day_format_exceptions,
    date_pattern => $date_pattern,
    date_pattern_with_year => $date_pattern_with_year,
    today => $today,
    tomorrow => $tomorrow,
    yesterday => $yesterday,
  }, $class;

  return $self;
}

sub format_date {
  my ($self, $date) = @_;
  return undef unless defined $date && $date ne '';
  my $parsed = _parse_date($date);
  return undef unless defined $parsed;
  my ($year, $month, $day) = @$parsed;
  return _format_absolute($self, $year, $month, $day, 0);
}

sub format_date_with_year {
  my ($self, $date) = @_;
  return undef unless defined $date && $date ne '';
  my $parsed = _parse_date($date);
  return undef unless defined $parsed;
  my ($year, $month, $day) = @$parsed;
  return _format_absolute($self, $year, $month, $day, 1);
}

sub format_relative {
  my ($self, $date, %opts) = @_;
  my $as_of = $opts{as_of};
  return undef unless defined $date && $date ne '';
  return undef unless defined $as_of && $as_of ne '';

  my $parsed_date = _parse_date($date);
  my $parsed_as_of = _parse_date($as_of);
  return undef unless defined $parsed_date && defined $parsed_as_of;

  my ($dy, $dm, $dd) = @$parsed_date;
  my ($ay, $am, $ad) = @$parsed_as_of;

  my $date_jdn = _to_jdn($dy, $dm, $dd);
  my $asof_jdn = _to_jdn($ay, $am, $ad);
  my $diff = $date_jdn - $asof_jdn;

  # Today
  return $self->{today} if $diff == 0;

  # Tomorrow
  return $self->{tomorrow} if $diff == 1;

  # Yesterday
  return $self->{yesterday} if $diff == -1;

  my $loc = $self->{locale};
  my $is_compact = $self->{compactness} eq 'compact';

  # Day after tomorrow
  if ($diff == 2 && $loc->{day_after_tomorrow} && !$is_compact) {
    return $loc->{day_after_tomorrow};
  }

  # Day before yesterday
  if ($diff == -2 && $loc->{day_before_yesterday} && !$is_compact) {
    return $loc->{day_before_yesterday};
  }

  # Compact mode: skip weekday references
  if ($is_compact) {
    my $include_year = $dy != $ay ? 1 : 0;
    return _format_absolute($self, $dy, $dm, $dd, $include_year);
  }

  # This weekday (+2 to +6)
  if ($diff >= 2 && $diff <= 6 && $loc->{this_weekday}) {
    my $dow = _weekday($dy, $dm, $dd);
    my $weekday_name = $self->{weekdays}[$dow];
    my $result = $loc->{this_weekday};
    $result =~ s/\{weekday\}/$weekday_name/;
    return $result;
  }

  # Last weekday (-2 to -6)
  if ($diff >= -6 && $diff <= -2 && $loc->{last_weekday}) {
    my $dow = _weekday($dy, $dm, $dd);
    my $weekday_name = $self->{weekdays}[$dow];
    my $result = $loc->{last_weekday};
    $result =~ s/\{weekday\}/$weekday_name/;
    return $result;
  }

  # Next weekday (+7 to +13)
  if ($diff >= 7 && $diff <= 13 && $loc->{next_weekday}) {
    my $dow = _weekday($dy, $dm, $dd);
    my $weekday_name = $self->{weekdays}[$dow];
    my $result = $loc->{next_weekday};
    $result =~ s/\{weekday\}/$weekday_name/;
    return $result;
  }

  # Calendar fallback
  my $include_year = $dy != $ay ? 1 : 0;
  return _format_absolute($self, $dy, $dm, $dd, $include_year);
}

sub _format_absolute {
  my ($self, $year, $month, $day, $include_year) = @_;
  my $day_str = "$day";
  my $fmt = $self->{day_format_exceptions}{$day_str} // $self->{day_format};
  my $formatted_day = $fmt;
  $formatted_day =~ s/\{n\}/$day_str/;

  my $month_names = $self->{months_in_date} || $self->{months};
  my $month_name = $month_names->[$month - 1];

  my $pattern = $include_year ? $self->{date_pattern_with_year} : $self->{date_pattern};
  my $result = $pattern;
  $result =~ s/\{month\}/$month_name/;
  $result =~ s/\{day\}/$formatted_day/;
  $result =~ s/\{d\}/$day/;
  $result =~ s/\{m\}/$month/;
  if ($include_year) {
    $result =~ s/\{year\}/$year/;
    my $yy = sprintf('%02d', $year % 100);
    $result =~ s/\{yy\}/$yy/;
  }

  return $result;
}

sub _parse_date {
  my ($s) = @_;
  return undef unless defined $s && $s ne '';
  my $date_part = $s;
  if (index($s, 'T') != -1) {
    $date_part = (split(/T/, $s))[0];
  }
  my @parts = split(/-/, $date_part);
  return undef unless scalar @parts == 3;
  my $year = int($parts[0]);
  my $month = int($parts[1]);
  my $day = int($parts[2]);
  return undef if $month < 1 || $month > 12 || $day < 1 || $day > 31;
  return [$year, $month, $day];
}

sub _to_jdn {
  my ($year, $month, $day) = @_;
  my $a = int((14 - $month) / 12);
  my $y = $year + 4800 - $a;
  my $m = $month + 12 * $a - 3;
  return $day + int((153 * $m + 2) / 5) + 365 * $y + int($y / 4) - int($y / 100) + int($y / 400) - 32045;
}

sub _weekday {
  my ($year, $month, $day) = @_;
  my $jdn = _to_jdn($year, $month, $day);
  return ($jdn + 1) % 7;
}

1;
