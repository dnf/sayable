use strict;
use warnings;
use utf8;

package SayableDate::Locale;

sub pick {
  my ($ovr, $key, $default) = @_;
  if (defined $ovr && exists $ovr->{$key}) {
    return $ovr->{$key};
  }
  return $default;
}

1;
