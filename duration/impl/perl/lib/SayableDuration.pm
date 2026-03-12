use strict;
use warnings;
use utf8;

package SayableDuration;

use SayableDuration::Locale;
use SayableDuration::Formatter;
use SayableDuration::Locales;

my $_default_formatter;

sub _default {
  $_default_formatter ||= SayableDuration::Formatter->new(SayableDuration::Locales->get('en'));
  return $_default_formatter;
}

sub format_duration {
  my ($class, $start_or_seconds, $end) = @_;
  return _default()->format_duration($start_or_seconds, $end);
}

sub format_since {
  my ($class, $start, $as_of) = @_;
  return _default()->format_since($start, $as_of);
}

sub format_until {
  my ($class, $target, $as_of) = @_;
  return _default()->format_until($target, $as_of);
}

1;
