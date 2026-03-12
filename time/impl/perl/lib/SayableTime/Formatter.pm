use strict;
use warnings;
use utf8;

package SayableTime::Formatter;

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

  my $short_clock = ($ovr && $ovr->{clock}) ? $ovr->{clock} : undef;

  my $self = bless {
    locale => $locale,
    compactness => $compactness,
    short_clock => $short_clock,
  }, $class;

  return $self;
}

sub format_time {
  my ($self, $input_str) = @_;
  return undef unless defined $input_str && $input_str ne '';
  my $parsed = _parse_time($input_str);
  return undef unless defined $parsed;
  my ($hour, $minute) = @$parsed;

  if ($self->{compactness} ne 'normal' && $self->{short_clock}) {
    return _format_digital($self, $hour, $minute);
  }
  return _format_natural($self, $hour, $minute);
}

sub _format_natural {
  my ($self, $hour, $minute) = @_;
  my $clock = $self->{locale}{clock};
  my $rounded = _round_to_5($minute);
  my $h = $hour;
  if ($rounded == 60) {
    $rounded = 0;
    $h = ($h + 1) % 24;
  }
  if ($rounded == 0) {
    return $clock->{midnight} if $h == 0;
    return $clock->{noon} if $h == 12;
  }
  my $h12 = $h % 12;
  my $next_h12 = ($h + 1) % 12;
  my $h_name = $clock->{hours}[$h12];
  my $next_h_name = $clock->{hours}[$next_h12];
  my $pattern = $clock->{patterns}{$rounded} // $clock->{patterns}{0} // '{h}';
  my $result = $pattern;
  $result =~ s/\{h\}/$h_name/;
  $result =~ s/\{next_h\}/$next_h_name/;
  return $result;
}

sub _format_digital {
  my ($self, $hour, $minute) = @_;
  my $sc = $self->{short_clock};
  my $fmt = $sc->{format};
  if ($sc->{use24h}) {
    my $mm = sprintf('%02d', $minute);
    my $result = $fmt;
    $result =~ s/\{h\}/$hour/;
    $result =~ s/\{mm\}/$mm/;
    return $result;
  }
  my $h12 = $hour % 12;
  $h12 = 12 if $h12 == 0;
  my $am_pm = $sc->{am_pm} || ['AM', 'PM'];
  my $ampm_str = $hour < 12 ? $am_pm->[0] : $am_pm->[1];
  my $mm = sprintf('%02d', $minute);
  my $result = $fmt;
  $result =~ s/\{h\}/$h12/;
  $result =~ s/\{mm\}/$mm/;
  $result =~ s/\{ampm\}/$ampm_str/;
  return $result;
}

sub _parse_time {
  my ($input_str) = @_;
  return undef unless defined $input_str && $input_str ne '';
  my $t = $input_str;
  if (index($t, 'T') != -1) {
    $t = (split(/T/, $t))[1];
  }
  if (index($t, '+') != -1) {
    $t = (split(/\+/, $t))[0];
  }
  if (index($t, 'Z') != -1) {
    $t = (split(/Z/, $t))[0];
  }
  my @parts = split(/:/, $t);
  return undef unless scalar @parts >= 2;
  my $hour_str = $parts[0];
  my $min_str = (split(/\./, $parts[1]))[0];
  my $hour = int($hour_str);
  my $minute = int($min_str);
  return undef if $hour < 0 || $hour > 23 || $minute < 0 || $minute > 59;
  return [$hour, $minute];
}

sub _round_to_5 {
  my ($minute) = @_;
  return int(($minute + 2) / 5) * 5;
}

1;
