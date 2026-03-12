use strict;
use warnings;
use utf8;
use Test::More;

binmode STDOUT, ':encoding(UTF-8)';
binmode STDERR, ':encoding(UTF-8)';

use SayableDate;
use SayableDate::Formatter;
use SayableDate::Locales;

# All tests use explicit (date, asOf) pairs for determinism.

# ================================================================
# Null / edge cases
# ================================================================
# 1.1
is(SayableDate->format_date(undef), undef, '1.1 null input');
# 1.2
is(SayableDate->format_date(''), undef, '1.2 empty string');
# 1.3
is(SayableDate->format_date('invalid'), undef, '1.3 invalid input');
# 1.4
is(SayableDate->format_relative('2025-03-15', as_of => undef), undef, '1.4 null asOf');
# 1.5
is(SayableDate->format_relative(undef, as_of => '2025-03-15'), undef, '1.5 null date');

# ================================================================
# format_date — normal compactness (English)
# ================================================================
{
  my $fmt = SayableDate::Formatter->new(SayableDate::Locales->get('en'));
  # 2.1
  is($fmt->format_date('2025-03-15'), 'March 15th', '2.1 march 15');
  # 2.2
  is($fmt->format_date('2025-01-01'), 'January 1st', '2.2 jan 1');
  # 2.3
  is($fmt->format_date('2025-05-22'), 'May 22nd', '2.3 may 22');
  # 2.4
  is($fmt->format_date('2025-07-03'), 'July 3rd', '2.4 jul 3');
  # 2.5
  is($fmt->format_date('2025-12-31'), 'December 31st', '2.5 dec 31');
  # 2.6
  is($fmt->format_date('2025-06-11'), 'June 11th', '2.6 jun 11');
  # 2.7
  is($fmt->format_date('2025-03-15T14:30:00'), 'March 15th', '2.7 ISO datetime');
}

# ================================================================
# format_date — short compactness (English)
# ================================================================
{
  my $fmt = SayableDate::Formatter->new(SayableDate::Locales->get('en'), compactness => 'short');
  # 3.1
  is($fmt->format_date('2025-03-15'), 'Mar 15', '3.1 short mar 15');
  # 3.2
  is($fmt->format_date('2025-01-01'), 'Jan 1', '3.2 short jan 1');
  # 3.3
  is($fmt->format_date('2025-12-25'), 'Dec 25', '3.3 short dec 25');
}

# ================================================================
# format_date — compact (English)
# ================================================================
{
  my $fmt = SayableDate::Formatter->new(SayableDate::Locales->get('en'), compactness => 'compact');
  # 4.1
  is($fmt->format_date('2025-03-15'), '3/15', '4.1 compact mar 15');
  # 4.2
  is($fmt->format_date('2025-01-01'), '1/1', '4.2 compact jan 1');
}

# ================================================================
# format_relative — proximity tiers (English)
# ================================================================
{
  my $fmt = SayableDate::Formatter->new(SayableDate::Locales->get('en'));
  # 5.1
  is($fmt->format_relative('2025-03-15', as_of => '2025-03-15'), 'today', '5.1 today');
  # 5.2
  is($fmt->format_relative('2025-03-16', as_of => '2025-03-15'), 'tomorrow', '5.2 tomorrow');
  # 5.3
  is($fmt->format_relative('2025-03-14', as_of => '2025-03-15'), 'yesterday', '5.3 yesterday');
  # 5.4
  is($fmt->format_relative('2025-03-17', as_of => '2025-03-15'), 'the day after tomorrow', '5.4 day after tomorrow');
  # 5.5
  is($fmt->format_relative('2025-03-13', as_of => '2025-03-15'), 'the day before yesterday', '5.5 day before yesterday');
  # 5.6
  is($fmt->format_relative('2025-03-19', as_of => '2025-03-15'), 'this Wednesday', '5.6 this weekday');
  # 5.7
  is($fmt->format_relative('2025-03-20', as_of => '2025-03-15'), 'this Thursday', '5.7 this weekday');
  # 5.8
  is($fmt->format_relative('2025-03-11', as_of => '2025-03-15'), 'last Tuesday', '5.8 last weekday');
  # 5.9
  is($fmt->format_relative('2025-03-22', as_of => '2025-03-15'), 'next Saturday', '5.9 next weekday');
  # 5.10
  is($fmt->format_relative('2025-03-27', as_of => '2025-03-15'), 'next Thursday', '5.10 next weekday');
  # 5.11
  is($fmt->format_relative('2025-03-01', as_of => '2025-03-15'), 'March 1st', '5.11 calendar fallback same year');
  # 5.12
  is($fmt->format_relative('2025-04-10', as_of => '2025-03-15'), 'April 10th', '5.12 calendar fallback same year');
  # 5.13
  is($fmt->format_relative('2026-01-05', as_of => '2025-03-15'), 'January 5th, 2026', '5.13 different year');
  # 5.14
  is($fmt->format_relative('2024-12-25', as_of => '2025-03-15'), 'December 25th, 2024', '5.14 past year');
}

# ================================================================
# format_relative — compact skips weekday tiers
# ================================================================
{
  my $fmt = SayableDate::Formatter->new(SayableDate::Locales->get('en'), compactness => 'compact');
  # 6.1
  is($fmt->format_relative('2025-03-15', as_of => '2025-03-15'), 'today', '6.1 compact today');
  # 6.2
  is($fmt->format_relative('2025-03-16', as_of => '2025-03-15'), 'tomorrow', '6.2 compact tomorrow');
  # 6.3
  is($fmt->format_relative('2025-03-19', as_of => '2025-03-15'), '3/19', '6.3 compact numeric');
  # 6.4
  is($fmt->format_relative('2026-01-05', as_of => '2025-03-15'), '1/5/26', '6.4 compact diff year');
}

# ================================================================
# Locale — German
# ================================================================
{
  my $fmt = SayableDate::Formatter->new(SayableDate::Locales->get('de'));
  # 7.1
  is($fmt->format_date('2025-03-15'), "15. M\x{E4}rz", '7.1 de date');
  # 7.2
  is($fmt->format_relative('2025-03-16', as_of => '2025-03-15'), 'morgen', '7.2 de tomorrow');
  # 7.3
  is($fmt->format_relative('2025-03-17', as_of => '2025-03-15'), "\x{FC}bermorgen", '7.3 de day after tomorrow');
  # 7.4
  is($fmt->format_relative('2025-03-19', as_of => '2025-03-15'), 'diesen Mittwoch', '7.4 de this weekday');
}

# ================================================================
# Locale — French
# ================================================================
{
  my $fmt = SayableDate::Formatter->new(SayableDate::Locales->get('fr'));
  # 8.1
  is($fmt->format_date('2025-03-01'), '1er mars', '8.1 fr first');
  # 8.2
  is($fmt->format_date('2025-03-15'), '15 mars', '8.2 fr date');
  # 8.3
  is($fmt->format_relative('2025-03-16', as_of => '2025-03-15'), 'demain', '8.3 fr tomorrow');
}

# ================================================================
# Locale — Japanese
# ================================================================
{
  my $fmt = SayableDate::Formatter->new(SayableDate::Locales->get('ja'));
  # 9.1
  is($fmt->format_date('2025-03-15'), "3\x{6708}15\x{65E5}", '9.1 ja date');
  # 9.2
  is($fmt->format_relative('2025-03-16', as_of => '2025-03-15'), "\x{660E}\x{65E5}", '9.2 ja tomorrow');
  # 9.3
  is($fmt->format_relative('2025-03-19', as_of => '2025-03-15'), "\x{4ECA}\x{5EA6}\x{306E}\x{6C34}\x{66DC}\x{65E5}", '9.3 ja this weekday');
}

# ================================================================
# Locale — Russian (genitive months)
# ================================================================
{
  my $fmt = SayableDate::Formatter->new(SayableDate::Locales->get('ru'));
  # 10.1
  is($fmt->format_date('2025-03-15'), "15 \x{43C}\x{430}\x{440}\x{442}\x{430}", '10.1 ru genitive');
  # 10.2
  is($fmt->format_relative('2025-03-16', as_of => '2025-03-15'), "\x{437}\x{430}\x{432}\x{442}\x{440}\x{430}", '10.2 ru tomorrow');
}

# ================================================================
# Locale — Arabic
# ================================================================
{
  my $fmt = SayableDate::Formatter->new(SayableDate::Locales->get('ar'));
  # 11.1
  is($fmt->format_date('2025-03-15'), "15 \x{645}\x{627}\x{631}\x{633}", '11.1 ar date');
  # 11.2
  is($fmt->format_relative('2025-03-16', as_of => '2025-03-15'), "\x{63A}\x{62F}\x{627}\x{64B}", '11.2 ar tomorrow');
}

# ================================================================
# Locale — Spanish
# ================================================================
{
  my $fmt = SayableDate::Formatter->new(SayableDate::Locales->get('es'));
  # 12.1
  is($fmt->format_date('2025-03-15'), '15 de marzo', '12.1 es date');
  # 12.2
  is($fmt->format_relative('2025-03-17', as_of => '2025-03-15'), "pasado ma\x{F1}ana", '12.2 es day after tomorrow');
}

done_testing();
