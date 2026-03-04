use strict;
use warnings;
use utf8;

package SayableAge::Formatter;

use Time::Local qw(timegm);
use SayableAge::Locale;

our $VERSION = '0.5.0';

my $MAX_AGE_MONTHS = 6000;

sub new {
  my ($class, $locale, %opts) = @_;
  my $compactness = $opts{compactness} || 'normal';

  my $ovr;
  if ($compactness eq 'short') {
    $ovr = $locale->{short};
  } elsif ($compactness eq 'compact') {
    $ovr = $locale->{compact};
  }

  my $self = bless {
    locale    => $locale,
    day       => ($ovr && $ovr->{units} && $ovr->{units}{day})   || $locale->{units}{day},
    week      => ($ovr && $ovr->{units} && $ovr->{units}{week})  || $locale->{units}{week},
    month     => ($ovr && $ovr->{units} && $ovr->{units}{month}) || $locale->{units}{month},
    year      => ($ovr && $ovr->{units} && $ovr->{units}{year})  || $locale->{units}{year},
    half      => ($ovr && exists $ovr->{half})      ? $ovr->{half}      : $locale->{half},
    delimiter => ($ovr && exists $ovr->{delimiter}) ? $ovr->{delimiter} : $locale->{delimiter},
    just_born => ($ovr && exists $ovr->{just_born}) ? $ovr->{just_born} : $locale->{just_born},
  }, $class;

  return $self;
}

sub format_age {
  my ($self, $date_of_birth, $as_of) = @_;

  my $age = _parse_age($date_of_birth, $as_of);
  return undef unless defined $age;

  my ($months, $diff_days) = @$age;

  # Tier 1: 0 days
  return $self->{just_born} if $diff_days == 0;

  # Tier 1b: 1-6 days
  if ($diff_days < 7) {
    return SayableAge::Locale::resolve_unit($diff_days, $self->{day}, $self->{locale});
  }

  # Tier 2: weeks + days until 3 calendar months
  if ($months < 3) {
    my $weeks = int($diff_days / 7);
    my $days = $diff_days % 7;
    my $result = SayableAge::Locale::resolve_unit($weeks, $self->{week}, $self->{locale});
    if ($days > 0) {
      $result .= $self->{delimiter} . SayableAge::Locale::resolve_unit($days, $self->{day}, $self->{locale});
    }
    return $result;
  }

  # Tier 3: 3-23 months
  if ($months < 24) {
    return SayableAge::Locale::resolve_unit($months, $self->{month}, $self->{locale});
  }

  # Tier 4: 24-35 months -> years + months
  if ($months < 36) {
    my $years = int($months / 12);
    my $rem = $months % 12;
    if ($rem == 0) {
      return SayableAge::Locale::resolve_unit($years, $self->{year}, $self->{locale});
    }
    return SayableAge::Locale::resolve_unit($years, $self->{year}, $self->{locale})
      . $self->{delimiter}
      . SayableAge::Locale::resolve_unit($rem, $self->{month}, $self->{locale});
  }

  # Tier 5: 3-6 years -> years with half marker
  if ($months < 84) {
    my $years = int($months / 12);
    my $rem = $months % 12;
    if ($rem >= 6) {
      return SayableAge::Locale::resolve_unit($years, $self->{year}, $self->{locale}, $self->{half});
    }
    return SayableAge::Locale::resolve_unit($years, $self->{year}, $self->{locale});
  }

  # Tier 6: 7+ years
  my $years = int($months / 12);
  return SayableAge::Locale::resolve_unit($years, $self->{year}, $self->{locale});
}

sub format_stage {
  my ($self, $date_of_birth, $as_of, %opts) = @_;
  my $gender = $opts{gender};

  my $age = _parse_age($date_of_birth, $as_of);
  return undef unless defined $age;

  my ($months) = @$age;
  my $key = _stage_key($months);
  return SayableAge::Locale::resolve_stage($self->{locale}{stages}{$key}, $gender);
}

sub _parse_age {
  my ($date_of_birth, $as_of) = @_;
  return undef unless defined $date_of_birth && $date_of_birth ne '';

  my ($dob_y, $dob_m, $dob_d) = split(/-/, $date_of_birth);
  $dob_y += 0; $dob_m += 0; $dob_d += 0;

  my ($ref_y, $ref_m, $ref_d);
  if (defined $as_of && $as_of ne '') {
    ($ref_y, $ref_m, $ref_d) = split(/-/, $as_of);
    $ref_y += 0; $ref_m += 0; $ref_d += 0;
  } else {
    my @t = localtime();
    $ref_y = $t[5] + 1900;
    $ref_m = $t[4] + 1;
    $ref_d = $t[3];
  }

  # Calculate diff_days using timegm
  my $dob_epoch = timegm(0, 0, 0, $dob_d, $dob_m - 1, $dob_y);
  my $ref_epoch = timegm(0, 0, 0, $ref_d, $ref_m - 1, $ref_y);
  my $diff_days = int(($ref_epoch - $dob_epoch) / 86400);
  return undef if $diff_days < 0;

  # Calendar months with day-of-month clamping
  my $last_day = _days_in_month($ref_y, $ref_m);
  my $clamped_birthday = $dob_d < $last_day ? $dob_d : $last_day;
  my $months = ($ref_y - $dob_y) * 12 + ($ref_m - $dob_m);
  $months-- if $ref_d < $clamped_birthday;
  return undef if $months > $MAX_AGE_MONTHS;

  return [$months, $diff_days];
}

sub _stage_key {
  my ($months) = @_;
  if    ($months < 2)   { return 'newborn' }
  elsif ($months < 12)  { return 'infant' }
  elsif ($months < 36)  { return 'toddler' }
  elsif ($months < 156) { return 'child' }
  elsif ($months < 216) { return 'teenager' }
  else                  { return 'adult' }
}

sub _days_in_month {
  my ($y, $m) = @_;
  my @days = (0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
  if ($m == 2 && ($y % 4 == 0 && ($y % 100 != 0 || $y % 400 == 0))) {
    return 29;
  }
  return $days[$m];
}

1;
