use strict;
use warnings;
use utf8;

package SayableDate;

use SayableDate::Locale;
use SayableDate::Formatter;
use SayableDate::Locales;

my $_default_formatter;

sub _default {
  $_default_formatter ||= SayableDate::Formatter->new(SayableDate::Locales->get('en'));
  return $_default_formatter;
}

sub format_date {
  my ($class, $date) = @_;
  return _default()->format_date($date);
}

sub format_date_with_year {
  my ($class, $date) = @_;
  return _default()->format_date_with_year($date);
}

sub format_relative {
  my ($class, $date, %opts) = @_;
  return _default()->format_relative($date, %opts);
}

1;
