use strict;
use warnings;
use utf8;

package SayableAge;

use SayableAge::Locale;
use SayableAge::Formatter;
use SayableAge::Locales;

my $_default_formatter;

sub _default {
  $_default_formatter ||= SayableAge::Formatter->new(SayableAge::Locales->get('en'));
  return $_default_formatter;
}

sub format_age {
  my ($class, $date_of_birth, $as_of) = @_;
  return _default()->format_age($date_of_birth, $as_of);
}

sub format_stage {
  my ($class, $date_of_birth, $as_of, %opts) = @_;
  return _default()->format_stage($date_of_birth, $as_of, %opts);
}

1;
