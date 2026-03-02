use strict;
use warnings;
use utf8;

package ParentTime;

use ParentTime::Locale;
use ParentTime::Formatter;
use ParentTime::Locales;

my $_default_formatter;

sub _default {
  $_default_formatter ||= ParentTime::Formatter->new(ParentTime::Locales->get('en'));
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
