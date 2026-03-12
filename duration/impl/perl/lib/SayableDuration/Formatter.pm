use strict;
use warnings;
use utf8;

package SayableDuration::Formatter;

use SayableDuration::Locale;

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

  my $ovr_units = ($ovr && $ovr->{units}) ? $ovr->{units} : undef;
  my %units;
  for my $k (qw(second minute hour day week month year)) {
    $units{$k} = ($ovr_units && $ovr_units->{$k}) ? $ovr_units->{$k} : $locale->{units}{$k};
  }

  my $self = bless {
    locale => $locale,
    units => \%units,
    half => _pick($ovr, 'half', $locale->{half}),
    delimiter => _pick($ovr, 'delimiter', $locale->{delimiter}),
    just_now => $locale->{just_now},
    ago => _pick($ovr, 'ago', $locale->{ago}),
    in_future => _pick($ovr, 'in_future', $locale->{in_future}),
  }, $class;

  return $self;
}

sub _pick {
  my ($ovr, $key, $default) = @_;
  if (defined $ovr && exists $ovr->{$key}) {
    return $ovr->{$key};
  }
  return $default;
}

sub format_duration {
  my ($self, $start_or_seconds, $end) = @_;

  return undef unless defined $start_or_seconds;

  my $total_seconds;
  if ($start_or_seconds =~ /^\-?\d+$/) {
    $total_seconds = int($start_or_seconds);
  } else {
    return undef unless defined $end;
    my $s = _parse_iso_to_seconds($start_or_seconds);
    my $e = _parse_iso_to_seconds($end);
    return undef unless defined $s && defined $e;
    $total_seconds = abs($e - $s);
  }

  return undef if $total_seconds < 0;

  return _format_duration_seconds($self, $total_seconds);
}

sub format_since {
  my ($self, $start, $as_of) = @_;
  return undef unless defined $start && $start ne '';
  return undef unless defined $as_of && $as_of ne '';
  my $s = _parse_iso_to_seconds($start);
  my $a = _parse_iso_to_seconds($as_of);
  return undef unless defined $s && defined $a;
  my $diff = $a - $s;
  return undef if $diff < 0;
  return $self->{just_now} if $diff == 0;
  my $dur = _format_duration_seconds($self, $diff);
  my $result = $self->{ago};
  $result =~ s/\{0\}/$dur/;
  return $result;
}

sub format_until {
  my ($self, $target, $as_of) = @_;
  return undef unless defined $target && $target ne '';
  return undef unless defined $as_of && $as_of ne '';
  my $t = _parse_iso_to_seconds($target);
  my $a = _parse_iso_to_seconds($as_of);
  return undef unless defined $t && defined $a;
  my $diff = $t - $a;
  return undef if $diff < 0;
  return $self->{just_now} if $diff == 0;
  my $dur = _format_duration_seconds($self, $diff);
  my $result = $self->{in_future};
  $result =~ s/\{0\}/$dur/;
  return $result;
}

sub _format_duration_seconds {
  my ($self, $total) = @_;
  my $loc = $self->{locale};

  # 0 seconds
  return $self->{just_now} if $total == 0;

  # 1-59 seconds
  if ($total < 60) {
    return SayableDuration::Locale::resolve_unit($total, $self->{units}{second}, $loc);
  }

  my $total_minutes = int($total / 60);
  my $remainder_seconds = $total % 60;

  # 1-4 minutes: minutes + seconds
  if ($total_minutes < 5) {
    my $result = SayableDuration::Locale::resolve_unit($total_minutes, $self->{units}{minute}, $loc);
    if ($remainder_seconds > 0) {
      $result .= $self->{delimiter} . SayableDuration::Locale::resolve_unit($remainder_seconds, $self->{units}{second}, $loc);
    }
    return $result;
  }

  # 5-59 minutes
  if ($total_minutes < 60) {
    return SayableDuration::Locale::resolve_unit($total_minutes, $self->{units}{minute}, $loc);
  }

  my $total_hours = int($total / 3600);
  my $remainder_minutes = int(($total % 3600) / 60);

  # 1-5 hours: hours + minutes (with half marker)
  if ($total_hours <= 5) {
    if ($remainder_minutes == 30) {
      return SayableDuration::Locale::resolve_unit($total_hours, $self->{units}{hour}, $loc, $self->{half});
    }
    my $result = SayableDuration::Locale::resolve_unit($total_hours, $self->{units}{hour}, $loc);
    if ($remainder_minutes > 0) {
      $result .= $self->{delimiter} . SayableDuration::Locale::resolve_unit($remainder_minutes, $self->{units}{minute}, $loc);
    }
    return $result;
  }

  # 6-23 hours
  if ($total_hours < 24) {
    return SayableDuration::Locale::resolve_unit($total_hours, $self->{units}{hour}, $loc);
  }

  my $total_days = int($total / 86400);
  my $remainder_hours = int(($total % 86400) / 3600);

  # 1-2 days: days + hours (with half marker)
  if ($total_days <= 2) {
    if ($remainder_hours == 12) {
      return SayableDuration::Locale::resolve_unit($total_days, $self->{units}{day}, $loc, $self->{half});
    }
    my $result = SayableDuration::Locale::resolve_unit($total_days, $self->{units}{day}, $loc);
    if ($remainder_hours > 0) {
      $result .= $self->{delimiter} . SayableDuration::Locale::resolve_unit($remainder_hours, $self->{units}{hour}, $loc);
    }
    return $result;
  }

  # 3-6 days
  if ($total_days < 7) {
    return SayableDuration::Locale::resolve_unit($total_days, $self->{units}{day}, $loc);
  }

  my $total_weeks = int($total_days / 7);
  my $remainder_days = $total_days % 7;

  # 1-4 weeks: weeks + days (up to 29 days; 30+ transitions to months)
  if ($total_days < 30) {
    my $result = SayableDuration::Locale::resolve_unit($total_weeks, $self->{units}{week}, $loc);
    if ($remainder_days > 0) {
      $result .= $self->{delimiter} . SayableDuration::Locale::resolve_unit($remainder_days, $self->{units}{day}, $loc);
    }
    return $result;
  }

  # Approximate months (30.44 days average)
  my $total_months = _round(($total_days / 30.44));

  # 1-11 months
  if ($total_months < 12) {
    $total_months = 1 if $total_months == 0;
    return SayableDuration::Locale::resolve_unit($total_months, $self->{units}{month}, $loc);
  }

  # 12+ months: years + months
  my $total_years = int($total_months / 12);
  my $remainder_months = $total_months % 12;
  my $result = SayableDuration::Locale::resolve_unit($total_years, $self->{units}{year}, $loc);
  if ($remainder_months > 0) {
    $result .= $self->{delimiter} . SayableDuration::Locale::resolve_unit($remainder_months, $self->{units}{month}, $loc);
  }
  return $result;
}

sub _round {
  my ($n) = @_;
  return int($n + 0.5);
}

sub _parse_iso_to_seconds {
  my ($iso_str) = @_;
  return undef unless defined $iso_str && $iso_str ne '';
  my @dt = split(/T/, $iso_str);
  return undef unless scalar @dt == 2;
  my ($date_part, $time_part) = @dt;

  my @dp = split(/-/, $date_part);
  return undef unless scalar @dp == 3;
  my ($year, $month, $day) = (int($dp[0]), int($dp[1]), int($dp[2]));

  my $time_str = $time_part;
  if (index($time_str, '+') != -1) {
    $time_str = (split(/\+/, $time_str))[0];
  }
  if (index($time_str, 'Z') != -1) {
    $time_str = (split(/Z/, $time_str))[0];
  }

  my @tp = split(/:/, $time_str);
  my $hour = int($tp[0]);
  my $minute = (scalar @tp > 1) ? int($tp[1]) : 0;
  my $second = 0;
  if (scalar @tp > 2) {
    $second = int((split(/\./, $tp[2]))[0]);
  }

  my $days = _days_since_epoch($year, $month, $day);
  return $days * 86400 + $hour * 3600 + $minute * 60 + $second;
}

sub _is_leap_year {
  my ($year) = @_;
  return ($year % 4 == 0 && $year % 100 != 0) || ($year % 400 == 0);
}

sub _days_in_month {
  my ($year, $month) = @_;
  my @dim = (0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
  if ($month == 2 && _is_leap_year($year)) {
    return 29;
  }
  return $dim[$month];
}

sub _days_since_epoch {
  my ($year, $month, $day) = @_;
  my $days = 0;
  if ($year >= 2000) {
    for my $y (2000 .. $year - 1) {
      $days += _is_leap_year($y) ? 366 : 365;
    }
  } else {
    for my $y ($year .. 1999) {
      $days -= _is_leap_year($y) ? 366 : 365;
    }
  }
  for my $m (1 .. $month - 1) {
    $days += _days_in_month($year, $m);
  }
  $days += $day - 1;
  return $days;
}

1;
