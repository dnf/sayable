use strict;
use warnings;
use utf8;
use Test::More;

binmode STDOUT, ':encoding(UTF-8)';
binmode STDERR, ':encoding(UTF-8)';

use SayableTime;
use SayableTime::Formatter;
use SayableTime::Locales;

# All tests use explicit inputs for determinism.

# ================================================================
# Null / edge cases
# ================================================================
# 1.1
is(SayableTime->format_time(undef), undef, '1.1 null input');
# 1.2
is(SayableTime->format_time(''), undef, '1.2 empty string');
# 1.3
is(SayableTime->format_time('invalid'), undef, '1.3 invalid input');
# 1.4
is(SayableTime->format_time('25:00'), undef, '1.4 invalid hour');

# ================================================================
# Clock time (normal compactness)
# ================================================================
{
  my $fmt = SayableTime::Formatter->new(SayableTime::Locales->get('en'));
  # 2.1
  is($fmt->format_time('00:00'), 'midnight', '2.1 midnight');
  # 2.2
  is($fmt->format_time('12:00'), 'noon', '2.2 noon');
  # 2.3
  is($fmt->format_time('15:00'), "three o'clock", '2.3 three oclock');
  # 2.4
  is($fmt->format_time('14:15'), 'a quarter past two', '2.4 quarter past');
  # 2.5
  is($fmt->format_time('09:30'), 'half past nine', '2.5 half past');
  # 2.6
  is($fmt->format_time('10:45'), 'a quarter to eleven', '2.6 quarter to');
  # 2.7
  is($fmt->format_time('08:05'), 'five past eight', '2.7 five past');
  # 2.8
  is($fmt->format_time('16:55'), 'five to five', '2.8 five to five');
  # 2.9
  is($fmt->format_time('23:58'), 'midnight', '2.9 rounds to midnight');
  # 2.10
  is($fmt->format_time('07:22'), 'twenty past seven', '2.10 rounds to 20');
  # 2.11
  is($fmt->format_time('2025-01-15T14:15:00'), 'a quarter past two', '2.11 ISO datetime');
}

# ================================================================
# Clock time (short compactness)
# ================================================================
{
  my $fmt = SayableTime::Formatter->new(SayableTime::Locales->get('en'), compactness => 'short');
  # 3.1
  is($fmt->format_time('14:15'), '2:15 PM', '3.1 short pm');
  # 3.2
  is($fmt->format_time('09:30'), '9:30 AM', '3.2 short am');
  # 3.3
  is($fmt->format_time('00:00'), '12:00 AM', '3.3 short midnight');
  # 3.4
  is($fmt->format_time('12:00'), '12:00 PM', '3.4 short noon');
}

# ================================================================
# Clock time (compact)
# ================================================================
{
  my $fmt = SayableTime::Formatter->new(SayableTime::Locales->get('en'), compactness => 'compact');
  # 4.1
  is($fmt->format_time('14:15'), '2:15p', '4.1 compact pm');
  # 4.2
  is($fmt->format_time('09:30'), '9:30a', '4.2 compact am');
}

# ================================================================
# Locale — German
# ================================================================
{
  my $fmt = SayableTime::Formatter->new(SayableTime::Locales->get('de'));
  # 5.1
  is($fmt->format_time('15:30'), 'halb vier', '5.1 de half past');
}

# ================================================================
# Locale — French
# ================================================================
{
  my $fmt = SayableTime::Formatter->new(SayableTime::Locales->get('fr'));
  # 6.1
  is($fmt->format_time('15:15'), 'trois heures et quart', '6.1 fr quarter past');
}

# ================================================================
# Locale — Japanese
# ================================================================
{
  my $fmt = SayableTime::Formatter->new(SayableTime::Locales->get('ja'));
  # 7.1
  is($fmt->format_time('15:30'), "\x{4E09}\x{6642}\x{534A}", '7.1 ja half past');
}


# ================================================================
# Locale — Finnish (dot separator, short)
# ================================================================
{
  my $fmt = SayableTime::Formatter->new(SayableTime::Locales->get('fi'), compactness => 'short');
  # 8.1
  is($fmt->format_time('14:15'), '14.15', '8.1 fi dot separator');
  # 8.2
  is($fmt->format_time('00:00'), '0.00', '8.2 fi midnight dot');
}

# ================================================================
# Sections 9-10: minutes in short/compact, input validation
# ================================================================
# 9.1
is(SayableTime::Formatter->new(SayableTime::Locales->get('en'), compactness => 'short')->format_time('18:01'), '6:01 PM', '9.1 digital modes keep the exact minute');
# 9.2
is(SayableTime::Formatter->new(SayableTime::Locales->get('en'), compactness => 'compact')->format_time('19:05'), '7:05p', '9.2 digital modes keep the exact minute');
# 10.1
is(SayableTime::Formatter->new(SayableTime::Locales->get('en'))->format_time('9:30'), 'half past nine', '10.1 one-digit hour');
# 10.2
is(SayableTime::Formatter->new(SayableTime::Locales->get('en'))->format_time('09:30'), 'half past nine', '10.2 two-digit hour');
# 10.3
is(SayableTime::Formatter->new(SayableTime::Locales->get('en'))->format_time(' 9:30'), undef, '10.3 leading whitespace');
# 10.4
is(SayableTime::Formatter->new(SayableTime::Locales->get('en'))->format_time('9:30 '), undef, '10.4 trailing whitespace');
# 10.5
is(SayableTime::Formatter->new(SayableTime::Locales->get('en'))->format_time('9:5'), undef, '10.5 minutes need two digits');
# 10.6
is(SayableTime::Formatter->new(SayableTime::Locales->get('en'))->format_time('24:00'), undef, '10.6 hour out of range');
# 10.7
is(SayableTime::Formatter->new(SayableTime::Locales->get('en'))->format_time('14:15:30'), 'a quarter past two', '10.7 seconds are allowed and ignored');
# 10.8
is(SayableTime::Formatter->new(SayableTime::Locales->get('en'))->format_time('2025-01-15T14:15:00Z'), 'a quarter past two', '10.8 ISO datetime with zone suffix (ignored)');
# 10.9
is(SayableTime::Formatter->new(SayableTime::Locales->get('en'))->format_time('2025-02-30T14:15:00'), undef, '10.9 ISO datetime with an impossible date');

done_testing();
