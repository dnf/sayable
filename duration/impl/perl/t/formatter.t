use strict;
use warnings;
use utf8;
use Test::More;

binmode STDOUT, ':encoding(UTF-8)';
binmode STDERR, ':encoding(UTF-8)';

use SayableDuration;
use SayableDuration::Formatter;
use SayableDuration::Locales;

# All tests use explicit inputs for determinism.

# ================================================================
# Null / edge cases
# ================================================================
# 1.1
is(SayableDuration->format_duration(undef), undef, '1.1 null input');
# 1.2
is(SayableDuration->format_duration(-1), undef, '1.2 negative');
# 1.3
is(SayableDuration->format_since(undef, '2025-01-15T10:00:00'), undef, '1.3 null start');
# 1.4
is(SayableDuration->format_until(undef, '2025-01-15T10:00:00'), undef, '1.4 null target');
# 1.5
is(SayableDuration->format_since('2025-01-15T10:00:00', '2025-01-15T09:00:00'), undef, '1.5 asOf before start');
# 1.6
is(SayableDuration->format_until('2025-01-15T09:00:00', '2025-01-15T10:00:00'), undef, '1.6 target in past');

# ================================================================
# Duration — seconds tier (0-59s)
# ================================================================
{
  my $fmt = SayableDuration::Formatter->new(SayableDuration::Locales->get('en'));
  # 2.1
  is($fmt->format_duration(0), 'just now', '2.1 zero seconds');
  # 2.2
  is($fmt->format_duration(1), '1 second', '2.2 one second');
  # 2.3
  is($fmt->format_duration(45), '45 seconds', '2.3 45 seconds');
  # 2.4
  is($fmt->format_duration(59), '59 seconds', '2.4 59 seconds');
}

# ================================================================
# Duration — minutes + seconds tier (1-4 min)
# ================================================================
{
  my $fmt = SayableDuration::Formatter->new(SayableDuration::Locales->get('en'));
  # 3.1
  is($fmt->format_duration(60), '1 minute', '3.1 one minute');
  # 3.2
  is($fmt->format_duration(90), '1 minute, 30 seconds', '3.2 1m30s');
  # 3.3
  is($fmt->format_duration(240), '4 minutes', '3.3 4 minutes');
  # 3.4
  is($fmt->format_duration(270), '4 minutes, 30 seconds', '3.4 4m30s');
}

# ================================================================
# Duration — minutes tier (5-59 min)
# ================================================================
{
  my $fmt = SayableDuration::Formatter->new(SayableDuration::Locales->get('en'));
  # 4.1
  is($fmt->format_duration(300), '5 minutes', '4.1 5 minutes');
  # 4.2
  is($fmt->format_duration(1500), '25 minutes', '4.2 25 minutes');
  # 4.3
  is($fmt->format_duration(3540), '59 minutes', '4.3 59 minutes');
}

# ================================================================
# Duration — hours + minutes tier (1-5 hr)
# ================================================================
{
  my $fmt = SayableDuration::Formatter->new(SayableDuration::Locales->get('en'));
  # 5.1
  is($fmt->format_duration(3600), '1 hour', '5.1 one hour');
  # 5.2
  is($fmt->format_duration(5400), "1\x{BD} hours", '5.2 half marker');
  # 5.3
  is($fmt->format_duration(8100), '2 hours, 15 minutes', '5.3 2h15m');
  # 5.4
  is($fmt->format_duration(18000), '5 hours', '5.4 5 hours');
}

# ================================================================
# Duration — hours tier (6-23 hr)
# ================================================================
{
  my $fmt = SayableDuration::Formatter->new(SayableDuration::Locales->get('en'));
  # 6.1
  is($fmt->format_duration(28800), '8 hours', '6.1 8 hours');
  # 6.2
  is($fmt->format_duration(82800), '23 hours', '6.2 23 hours');
}

# ================================================================
# Duration — days tier
# ================================================================
{
  my $fmt = SayableDuration::Formatter->new(SayableDuration::Locales->get('en'));
  # 7.1
  is($fmt->format_duration(86400), '1 day', '7.1 one day');
  # 7.2
  is($fmt->format_duration(97200), '1 day, 3 hours', '7.2 1d3h');
  # 7.3
  is($fmt->format_duration(129600), "1\x{BD} days", '7.3 half marker');
  # 7.4
  is($fmt->format_duration(432000), '5 days', '7.4 5 days');
  # 7.5
  is($fmt->format_duration(172800), '2 days', '7.5 2 days');
}

# ================================================================
# Duration — weeks tier
# ================================================================
{
  my $fmt = SayableDuration::Formatter->new(SayableDuration::Locales->get('en'));
  # 8.1
  is($fmt->format_duration(604800), '1 week', '8.1 one week');
  # 8.2
  is($fmt->format_duration(1296000), '2 weeks, 1 day', '8.2 2w1d');
  # 8.3
  is($fmt->format_duration(2419200), '4 weeks', '8.3 4 weeks');
}

# ================================================================
# Duration — months and years tier
# ================================================================
{
  my $fmt = SayableDuration::Formatter->new(SayableDuration::Locales->get('en'));
  # 9.1
  is($fmt->format_duration(2678400), '1 month', '9.1 ~31 days');
  # 9.2
  is($fmt->format_duration(7884000), '3 months', '9.2 ~91 days');
  # 9.3
  is($fmt->format_duration(31536000), '1 year', '9.3 365 days');
  # 9.4
  is($fmt->format_duration(39420000), '1 year, 3 months', '9.4 ~456 days');
}

# ================================================================
# Duration from ISO timestamps
# ================================================================
{
  my $fmt = SayableDuration::Formatter->new(SayableDuration::Locales->get('en'));
  # 10.1
  is($fmt->format_duration('2025-01-15T10:00:00', '2025-01-15T11:30:00'), "1\x{BD} hours", '10.1 ISO 1.5h');
  # 10.2
  is($fmt->format_duration('2025-01-15T10:00:00', '2025-01-15T10:45:00'), '45 minutes', '10.2 ISO 45m');
}

# ================================================================
# Relative time — since
# ================================================================
{
  my $fmt = SayableDuration::Formatter->new(SayableDuration::Locales->get('en'));
  # 11.1
  is($fmt->format_since('2025-01-15T10:00:00', '2025-01-15T10:00:00'), 'just now', '11.1 since just now');
  # 11.2
  is($fmt->format_since('2025-01-15T10:00:00', '2025-01-15T10:00:30'), '30 seconds ago', '11.2 since 30s');
  # 11.3
  is($fmt->format_since('2025-01-15T10:00:00', '2025-01-15T10:45:00'), '45 minutes ago', '11.3 since 45m');
  # 11.4
  is($fmt->format_since('2025-01-15T10:00:00', '2025-01-15T13:00:00'), '3 hours ago', '11.4 since 3h');
}

# ================================================================
# Relative time — until
# ================================================================
{
  my $fmt = SayableDuration::Formatter->new(SayableDuration::Locales->get('en'));
  # 12.1
  is($fmt->format_until('2025-01-15T10:00:00', '2025-01-15T10:00:00'), 'just now', '12.1 until just now');
  # 12.2
  is($fmt->format_until('2025-01-15T10:20:00', '2025-01-15T10:00:00'), 'in 20 minutes', '12.2 until 20m');
  # 12.3
  is($fmt->format_until('2025-01-15T13:00:00', '2025-01-15T10:00:00'), 'in 3 hours', '12.3 until 3h');
}

# ================================================================
# Locale — German
# ================================================================
{
  my $fmt = SayableDuration::Formatter->new(SayableDuration::Locales->get('de'));
  # 13.1
  is($fmt->format_duration(3600), '1 Stunde', '13.1 de 1 hour');
  # 13.2
  is($fmt->format_since('2025-01-15T10:00:00', '2025-01-15T10:05:00'), 'vor 5 Minuten', '13.2 de since 5m');
}

# ================================================================
# Locale — French
# ================================================================
{
  my $fmt = SayableDuration::Formatter->new(SayableDuration::Locales->get('fr'));
  # 14.1
  is($fmt->format_duration(7200), '2 heures', '14.1 fr 2 hours');
}

# ================================================================
# Locale — Japanese
# ================================================================
{
  my $fmt = SayableDuration::Formatter->new(SayableDuration::Locales->get('ja'));
  # 15.1
  is($fmt->format_duration(120), "2\x{5206}", '15.1 ja 2 min');
  # 15.2
  is($fmt->format_since('2025-01-15T10:00:00', '2025-01-15T11:00:00'), "1\x{6642}\x{9593}\x{524D}", '15.2 ja since 1h');
}

# ================================================================
# Short compactness — duration
# ================================================================
{
  my $fmt = SayableDuration::Formatter->new(SayableDuration::Locales->get('en'), compactness => 'short');
  # 16.1
  is($fmt->format_duration(3600), '1h', '16.1 short 1h');
  # 16.2
  is($fmt->format_duration(90), '1m, 30s', '16.2 short 1m30s');
}

# ================================================================
# Compact compactness — duration
# ================================================================
{
  my $fmt = SayableDuration::Formatter->new(SayableDuration::Locales->get('en'), compactness => 'compact');
  # 17.1
  is($fmt->format_duration(3600), '1h', '17.1 compact 1h');
  # 17.2
  is($fmt->format_duration(90), '1m30s', '17.2 compact 1m30s');
}

done_testing();
