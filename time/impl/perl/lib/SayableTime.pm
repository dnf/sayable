use strict;
use warnings;
use utf8;

package SayableTime;

use SayableTime::Locale;
use SayableTime::Formatter;
use SayableTime::Locales;

my $_default_formatter;

sub _default {
  $_default_formatter ||= SayableTime::Formatter->new(SayableTime::Locales->get('en'));
  return $_default_formatter;
}

sub format_time {
  my ($class, $input_str) = @_;
  return _default()->format_time($input_str);
}

1;
