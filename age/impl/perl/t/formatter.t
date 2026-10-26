use strict;
use warnings;
use utf8;
use Test::More;
use SayableAge;
use SayableAge::Formatter;
use SayableAge::Locales;
use SayableAge::Locale;

# All tests use explicit (dob, as_of) pairs for determinism.

# ================================================================
# Null / edge cases
# ================================================================
# 1.1
is(SayableAge->format_age(undef, '2025-06-15'), undef, '1.1 nil input');
# 1.3
is(SayableAge->format_age('', '2025-06-15'), undef, '1.3 empty string');
# 1.4
is(SayableAge->format_age('2025-07-01', '2025-06-15'), undef, '1.4 future dob');
# 1.5
is(SayableAge->format_age('1525-06-15', '2025-06-15'), '500 years', '1.5 exactly 500 years');
# 1.6
is(SayableAge->format_age('1524-06-15', '2025-06-15'), undef, '1.6 501 years exceeds max');
# 1.7
is(SayableAge->format_age('1025-06-15', '2025-06-15'), undef, '1.7 1000 years exceeds max');

# ================================================================
# Days tier: 0-6 days
# ================================================================
# 2.1
is(SayableAge->format_age('2025-06-15', '2025-06-15'), 'Newborn', '2.1 born today');
# 2.2
is(SayableAge->format_age('2025-06-14', '2025-06-15'), '1 day', '2.2 1 day');
# 2.3
is(SayableAge->format_age('2025-06-12', '2025-06-15'), '3 days', '2.3 3 days');
# 2.4
is(SayableAge->format_age('2025-06-09', '2025-06-15'), '6 days', '2.4 6 days');
# 2.5
is(SayableAge->format_age('2025-06-08', '2025-06-15'), '1 week', '2.5 7 days becomes 1 week');

# ================================================================
# Weeks+days tier: 7 days to <3 months
# ================================================================
# 3.1
is(SayableAge->format_age('2025-06-08', '2025-06-15'), '1 week', '3.1 7 days');
# 3.2
is(SayableAge->format_age('2025-06-07', '2025-06-15'), '1 week, 1 day', '3.2 8 days');
# 3.3
is(SayableAge->format_age('2025-06-06', '2025-06-15'), '1 week, 2 days', '3.3 9 days');
# 3.4
is(SayableAge->format_age('2025-06-02', '2025-06-15'), '1 week, 6 days', '3.4 13 days');
# 3.5
is(SayableAge->format_age('2025-06-01', '2025-06-15'), '2 weeks', '3.5 14 days');
# 3.6
is(SayableAge->format_age('2025-05-31', '2025-06-15'), '2 weeks, 1 day', '3.6 15 days');
# 3.7
is(SayableAge->format_age('2025-05-26', '2025-06-15'), '2 weeks, 6 days', '3.7 20 days');
# 3.8
is(SayableAge->format_age('2025-05-25', '2025-06-15'), '3 weeks', '3.8 21 days');
# 3.9
is(SayableAge->format_age('2025-05-15', '2025-06-15'), '4 weeks, 3 days', '3.9 at 1 cal month still weeks');
# 3.10
is(SayableAge->format_age('2025-04-15', '2025-06-15'), '8 weeks, 5 days', '3.10 at 2 cal months still weeks');
# 3.11
is(SayableAge->format_age('2025-03-15', '2025-06-14'), '13 weeks', '3.11 one day before 3mo');
# 3.12
is(SayableAge->format_age('2025-03-15', '2025-06-15'), '3 months', '3.12 on 3mo birthday switches');

# ================================================================
# Month boundaries: standard months
# ================================================================
# 4.1
is(SayableAge->format_age('2025-01-01', '2025-04-01'), '3 months', '4.1 jan1-apr1');
# 4.2
like(SayableAge->format_age('2025-01-01', '2025-03-31'), qr/weeks/, '4.2 jan1-mar31 still weeks');
# 4.3
is(SayableAge->format_age('2025-06-15', '2025-09-15'), '3 months', '4.3 jun15-sep15');
# 4.4
like(SayableAge->format_age('2025-06-15', '2025-09-14'), qr/weeks/, '4.4 jun15-sep14 still weeks');
# 4.5
is(SayableAge->format_age('2025-06-15', '2025-12-15'), '6 months', '4.5 jun15-dec15');

# ================================================================
# Month boundaries: February non-leap
# ================================================================
# 5.1
is(SayableAge->format_age('2025-01-31', '2025-02-28'), '4 weeks', '5.1 jan31-feb28 non-leap');
# 5.2
is(SayableAge->format_age('2025-01-31', '2025-04-30'), '3 months', '5.2 jan31-apr30 clamped');
# 5.3
like(SayableAge->format_age('2025-01-31', '2025-04-29'), qr/weeks/, '5.3 jan31-apr29 still weeks');
# 5.4
is(SayableAge->format_age('2025-02-01', '2025-05-01'), '3 months', '5.4 feb1-may1');
# 5.5
like(SayableAge->format_age('2025-02-01', '2025-04-30'), qr/weeks/, '5.5 feb1-apr30 still weeks');

# ================================================================
# Month boundaries: February leap year
# ================================================================
# 6.1
is(SayableAge->format_age('2024-01-31', '2024-02-29'), '4 weeks, 1 day', '6.1 jan31-feb29 leap');
# 6.2
is(SayableAge->format_age('2024-01-31', '2024-02-28'), '4 weeks', '6.2 jan31-feb28 leap');
# 6.3
is(SayableAge->format_age('2024-01-31', '2024-04-30'), '3 months', '6.3 jan31-apr30 leap');
# 6.4
like(SayableAge->format_age('2024-01-30', '2024-02-29'), qr/weeks/, '6.4 jan30-feb29 leap still weeks');
# 6.5
like(SayableAge->format_age('2024-01-30', '2024-02-28'), qr/weeks/, '6.5 jan30-feb28 leap still weeks');

# ================================================================
# Month boundaries: 30-day months
# ================================================================
# 7.1
is(SayableAge->format_age('2025-03-31', '2025-06-30'), '3 months', '7.1 mar31-jun30');
# 7.2
like(SayableAge->format_age('2025-03-31', '2025-06-29'), qr/weeks/, '7.2 mar31-jun29 still weeks');
# 7.3
is(SayableAge->format_age('2025-08-31', '2025-11-30'), '3 months', '7.3 aug31-nov30');
# 7.4
like(SayableAge->format_age('2025-08-31', '2025-11-29'), qr/weeks/, '7.4 aug31-nov29 still weeks');

# ================================================================
# Month boundaries: leap year baby (born Feb 29)
# ================================================================
# 8.1
is(SayableAge->format_age('2024-02-29', '2024-05-29'), '3 months', '8.1 feb29-may29');
# 8.2
like(SayableAge->format_age('2024-02-29', '2024-05-28'), qr/weeks/, '8.2 feb29-may28 still weeks');
# 8.3
is(SayableAge->format_age('2024-02-29', '2025-02-28'), '12 months', '8.3 feb29-feb28 next year');
# 8.4
is(SayableAge->format_age('2024-02-29', '2025-03-01'), '12 months', '8.4 feb29-mar1 next year');

# ================================================================
# Months tier: 3-23 months
# ================================================================
# 9.1
is(SayableAge->format_age('2025-01-15', '2025-04-15'), '3 months', '9.1 3 months at transition');
# 9.2
is(SayableAge->format_age('2025-01-15', '2025-07-15'), '6 months', '9.2 6 months');
# 9.3
is(SayableAge->format_age('2024-06-15', '2025-06-15'), '12 months', '9.3 12 months not 1 year');
# 9.4
is(SayableAge->format_age('2024-01-15', '2025-12-15'), '23 months', '9.4 23 months upper boundary');
# 9.5
is(SayableAge->format_age('2025-01-15', '2025-07-14'), '5 months', '9.5 one day before month boundary');
# 9.6
is(SayableAge->format_age('2024-11-10', '2025-04-10'), '5 months', '9.6 crossing year boundary');

# ================================================================
# Years+months tier: 24-35 months
# ================================================================
# 10.1
is(SayableAge->format_age('2023-06-15', '2025-06-15'), '2 years', '10.1 2 years at 24mo');
# 10.2
is(SayableAge->format_age('2023-06-15', '2025-07-15'), '2 years, 1 month', '10.2 2y1m');
# 10.3
is(SayableAge->format_age('2023-06-15', '2025-12-15'), '2 years, 6 months', '10.3 2y6m');
# 10.4
is(SayableAge->format_age('2023-06-15', '2026-05-15'), '2 years, 11 months', '10.4 2y11m');
# 10.5
is(SayableAge->format_age('2023-06-15', '2025-06-14'), '23 months', '10.5 one day before 24mo');

# ================================================================
# Half-year tier: 3-6 years
# ================================================================
# 11.1
is(SayableAge->format_age('2022-06-15', '2025-06-15'), '3 years', '11.1 3 years exactly');
# 11.2
is(SayableAge->format_age('2022-06-15', '2025-11-15'), '3 years', '11.2 3y5m');
# 11.3
is(SayableAge->format_age('2022-06-15', '2025-12-15'), "3\x{BD} years", '11.3 3.5y at 3y6m');
# 11.4
is(SayableAge->format_age('2022-06-15', '2026-05-15'), "3\x{BD} years", '11.4 3.5y at 3y11m');
# 11.5
is(SayableAge->format_age('2021-06-15', '2025-06-15'), '4 years', '11.5 4 years');
# 11.6
is(SayableAge->format_age('2021-06-15', '2025-12-15'), "4\x{BD} years", '11.6 4.5y');
# 11.7
is(SayableAge->format_age('2020-06-15', '2025-06-15'), '5 years', '11.7 5 years');
# 11.8
is(SayableAge->format_age('2020-06-15', '2026-02-15'), "5\x{BD} years", '11.8 5.5y at 5y8m');
# 11.9
is(SayableAge->format_age('2019-06-15', '2025-06-15'), '6 years', '11.9 6 years');
# 11.10
is(SayableAge->format_age('2019-06-15', '2025-12-15'), "6\x{BD} years", '11.10 6.5y');
# 11.11
is(SayableAge->format_age('2019-06-15', '2026-05-15'), "6\x{BD} years", '11.11 6.5y at 6y11m');
# 11.12
is(SayableAge->format_age('2022-06-15', '2025-06-14'), '2 years, 11 months', '11.12 one day before 3rd bday');

# ================================================================
# Integer tier: 7+ years
# ================================================================
# 12.1
is(SayableAge->format_age('2018-06-15', '2025-06-15'), '7 years', '12.1 7 years');
# 12.2
is(SayableAge->format_age('2018-03-20', '2025-06-15'), '7 years', '12.2 7y6m no half');
# 12.3
is(SayableAge->format_age('1980-01-01', '2025-06-15'), '45 years', '12.3 45 years');

# ================================================================
# Cross-year transitions with Feb
# ================================================================
# 13.1
is(SayableAge->format_age('2024-12-31', '2025-03-31'), '3 months', '13.1 dec31-mar31');
# 13.2
like(SayableAge->format_age('2024-12-31', '2025-03-30'), qr/weeks/, '13.2 dec31-mar30 still weeks');
# 13.3
is(SayableAge->format_age('2024-11-30', '2025-02-28'), '3 months', '13.3 nov30-feb28');
# 13.4
like(SayableAge->format_age('2024-11-30', '2025-02-27'), qr/weeks/, '13.4 nov30-feb27 still weeks');

# ================================================================
# Born-on-31st progression
# ================================================================
# 14.1
is(SayableAge->format_age('2025-01-31', '2025-04-30'), '3 months', '14.1 jan31-apr30');
# 14.2
is(SayableAge->format_age('2025-01-31', '2025-05-31'), '4 months', '14.2 jan31-may31');
# 14.3
is(SayableAge->format_age('2025-01-31', '2025-06-30'), '5 months', '14.3 jan31-jun30 clamped');
# 14.4
is(SayableAge->format_age('2025-01-31', '2025-07-01'), '5 months', '14.4 jan31-jul1');
# 14.5
is(SayableAge->format_age('2025-01-31', '2025-07-31'), '6 months', '14.5 jan31-jul31');

# ================================================================
# Default as_of (uses current date) — tests 15.1, 15.2, 23.1-23.3
# There is no way to inject "today", so the dates are derived from the real
# current date (local time, like the library) to keep the canonical outputs.
# ================================================================
use POSIX qw(mktime strftime);

sub date_ago {
  my ($years, $days) = @_;
  my @now = localtime();
  my $day = $now[3] - $days;
  my $noon = mktime(0, 0, 12, $day, $now[4], $now[5] - $years);
  my @then = localtime($noon);
  # Feb 29 minus whole years can land on Mar 1; step back to keep the same month
  @then = localtime(mktime(0, 0, 12, 28, $now[4], $now[5] - $years)) if $years && $then[4] != $now[4];
  return strftime('%Y-%m-%d', @then);
}

# 15.1
is(SayableAge->format_age(date_ago(5, 0)), '5 years', '15.1 default as_of 5 years');
# 15.2
is(SayableAge->format_age(date_ago(0, 5)), '5 days', '15.2 default as_of 5 days');

# ================================================================
# formatStage
# ================================================================
# 16.1
is(SayableAge->format_stage(undef, '2025-06-15'), undef, '16.1 nil returns undef');
# 16.3
is(SayableAge->format_stage('', '2025-06-15'), undef, '16.3 empty returns undef');
# 16.4
is(SayableAge->format_stage('2025-07-01', '2025-06-15'), undef, '16.4 future returns undef');
# 16.5
is(SayableAge->format_stage('1525-06-15', '2025-06-15'), 'Adult', '16.5 500y returns adult');
# 16.6
is(SayableAge->format_stage('1524-06-15', '2025-06-15'), undef, '16.6 501y exceeds max');

# 23.1
is(SayableAge->format_stage(date_ago(0, 0)), 'Newborn', '23.1 default as_of newborn');
# 23.2
is(SayableAge->format_stage(date_ago(5, 0)), 'Child', '23.2 default as_of child');
# 23.3
is(SayableAge->format_stage(date_ago(45, 0)), 'Adult', '23.3 default as_of adult');

# Newborn: 0-1 months
# 17.1
is(SayableAge->format_stage('2025-06-15', '2025-06-15'), 'Newborn', '17.1 born today');
# 17.2
is(SayableAge->format_stage('2025-06-14', '2025-06-15'), 'Newborn', '17.2 1 day');
# 17.3
is(SayableAge->format_stage('2025-05-25', '2025-06-15'), 'Newborn', '17.3 3 weeks');
# 17.4
is(SayableAge->format_stage('2025-05-15', '2025-06-15'), 'Newborn', '17.4 1 month');
# 17.5
is(SayableAge->format_stage('2025-04-16', '2025-06-15'), 'Newborn', '17.5 1m29d');
# 17.6
is(SayableAge->format_stage('2025-04-15', '2025-06-15'), 'Infant', '17.6 exactly 2 months');

# Infant: 2-11 months
# 18.1
is(SayableAge->format_stage('2025-04-15', '2025-06-15'), 'Infant', '18.1 2 months');
# 18.2
is(SayableAge->format_stage('2024-12-15', '2025-06-15'), 'Infant', '18.2 6 months');
# 18.3
is(SayableAge->format_stage('2024-07-15', '2025-06-15'), 'Infant', '18.3 11 months');
# 18.4
is(SayableAge->format_stage('2024-06-15', '2025-06-15'), 'Toddler', '18.4 exactly 12 months');

# Toddler: 12-35 months
# 19.1
is(SayableAge->format_stage('2024-06-15', '2025-06-15'), 'Toddler', '19.1 12 months');
# 19.2
is(SayableAge->format_stage('2024-01-15', '2025-07-15'), 'Toddler', '19.2 18 months');
# 19.3
is(SayableAge->format_stage('2023-06-15', '2025-06-15'), 'Toddler', '19.3 24 months');
# 19.4
is(SayableAge->format_stage('2023-06-15', '2026-05-15'), 'Toddler', '19.4 35 months');
# 19.5
is(SayableAge->format_stage('2022-06-15', '2025-06-15'), 'Child', '19.5 exactly 36 months');

# Child: 36-155 months
# 20.1
is(SayableAge->format_stage('2022-06-15', '2025-06-15'), 'Child', '20.1 3 years');
# 20.2
is(SayableAge->format_stage('2021-06-15', '2025-06-15'), 'Child', '20.2 4 years');
# 20.3
is(SayableAge->format_stage('2019-06-15', '2025-06-15'), 'Child', '20.3 6 years');
# 20.4
is(SayableAge->format_stage('2016-06-15', '2025-06-15'), 'Child', '20.4 9 years');
# 20.5
is(SayableAge->format_stage('2013-06-15', '2026-05-15'), 'Child', '20.5 12y11m');
# 20.6
is(SayableAge->format_stage('2012-06-15', '2025-06-15'), 'Teenager', '20.6 exactly 13 years');

# Teenager: 156-215 months
# 21.1
is(SayableAge->format_stage('2012-06-15', '2025-06-15'), 'Teenager', '21.1 13 years');
# 21.2
is(SayableAge->format_stage('2010-06-15', '2025-06-15'), 'Teenager', '21.2 15 years');
# 21.3
is(SayableAge->format_stage('2008-06-15', '2026-05-15'), 'Teenager', '21.3 17y11m');
# 21.4
is(SayableAge->format_stage('2007-06-15', '2025-06-15'), 'Adult', '21.4 exactly 18 years');

# Adult: 216+ months
# 22.1
is(SayableAge->format_stage('2007-06-15', '2025-06-15'), 'Adult', '22.1 18 years');
# 22.2
is(SayableAge->format_stage('2000-06-15', '2025-06-15'), 'Adult', '22.2 25 years');
# 22.3
is(SayableAge->format_stage('1980-01-01', '2025-06-15'), 'Adult', '22.3 45 years');

# ================================================================
# SayableAge::Formatter class
# ================================================================
{
  my $pt = SayableAge::Formatter->new(SayableAge::Locales->get('en'));
  # 24.1, 24.2, 24.3, 24.4, 24.5, 24.6, 24.7
  is($pt->format_age('2025-06-15', '2025-06-15'), 'Newborn', '24.1');
  is($pt->format_age('2025-06-12', '2025-06-15'), '3 days', '24.2');
  is($pt->format_age('2025-06-07', '2025-06-15'), '1 week, 1 day', '24.3');
  is($pt->format_age('2025-01-15', '2025-07-15'), '6 months', '24.4');
  is($pt->format_age('2023-06-15', '2025-07-15'), '2 years, 1 month', '24.5');
  is($pt->format_age('2022-06-15', '2025-12-15'), "3\x{BD} years", '24.6');
  is($pt->format_age('2018-06-15', '2025-06-15'), '7 years', '24.7');

  # 24.8, 24.9, 24.10, 24.11, 24.12, 24.13
  is($pt->format_stage('2025-06-15', '2025-06-15'), 'Newborn', '24.8');
  is($pt->format_stage('2025-01-15', '2025-06-15'), 'Infant', '24.9');
  is($pt->format_stage('2024-06-15', '2025-06-15'), 'Toddler', '24.10');
  is($pt->format_stage('2022-06-15', '2025-06-15'), 'Child', '24.11');
  is($pt->format_stage('2012-06-15', '2025-06-15'), 'Teenager', '24.12');
  is($pt->format_stage('2007-06-15', '2025-06-15'), 'Adult', '24.13');

  # 24.14, 24.15
  is($pt->format_age(undef, '2025-06-15'), undef, '24.14');
  is($pt->format_stage(undef, '2025-06-15'), undef, '24.15');
  is($pt->format_age('', '2025-06-15'), undef, '24.14b');
}

# ================================================================
# Spanish-like locale (inline)
# ================================================================
{
  my $es = {
    code => 'es',
    plural => sub { my ($n) = @_; $n == 1 ? 'one' : 'other' },
    units => {
      day   => { one => '{n} d' . "\x{ED}" . 'a', other => '{n} d' . "\x{ED}" . 'as' },
      week  => { one => '{n} semana', other => '{n} semanas' },
      month => { one => '{n} mes', other => '{n} meses' },
      year  => { one => '{n} a' . "\x{F1}" . 'o', other => '{n} a' . "\x{F1}" . 'os' },
    },
    half => '{0} y medio',
    delimiter => ', ',
    just_born => "Reci\x{E9}n nacido",
    stages => {
      newborn  => "Reci\x{E9}n nacido",
      infant   => "Beb\x{E9}",
      toddler  => "Ni\x{F1}o peque\x{F1}o",
      child    => "Ni\x{F1}o",
      teenager => 'Adolescente',
      adult    => 'Adulto',
    },
  };

  my $pt = SayableAge::Formatter->new($es);

  # 25.1..25.20
  is($pt->format_age('2025-06-15', '2025-06-15'), "Reci\x{E9}n nacido", '25.1');
  is($pt->format_age('2025-06-14', '2025-06-15'), "1 d\x{ED}a", '25.2');
  is($pt->format_age('2025-06-12', '2025-06-15'), "3 d\x{ED}as", '25.3');
  is($pt->format_age('2025-06-08', '2025-06-15'), '1 semana', '25.4');
  is($pt->format_age('2025-06-07', '2025-06-15'), "1 semana, 1 d\x{ED}a", '25.5');
  is($pt->format_age('2025-05-26', '2025-06-15'), "2 semanas, 6 d\x{ED}as", '25.6');
  is($pt->format_age('2025-01-15', '2025-07-15'), '6 meses', '25.7');
  is($pt->format_age('2023-06-15', '2025-07-15'), "2 a\x{F1}os, 1 mes", '25.8');
  is($pt->format_age('2023-06-15', '2025-12-15'), "2 a\x{F1}os, 6 meses", '25.9');
  is($pt->format_age('2022-06-15', '2025-12-15'), "3 a\x{F1}os y medio", '25.10');
  is($pt->format_age('2022-06-15', '2025-06-15'), "3 a\x{F1}os", '25.11');
  is($pt->format_age('2018-06-15', '2025-06-15'), "7 a\x{F1}os", '25.12');
  is($pt->format_stage('2025-06-15', '2025-06-15'), "Reci\x{E9}n nacido", '25.13');
  is($pt->format_stage('2025-01-15', '2025-06-15'), "Beb\x{E9}", '25.14');
  is($pt->format_stage('2024-06-15', '2025-06-15'), "Ni\x{F1}o peque\x{F1}o", '25.15');
  is($pt->format_stage('2022-06-15', '2025-06-15'), "Ni\x{F1}o", '25.16');
  is($pt->format_stage('2012-06-15', '2025-06-15'), 'Adolescente', '25.17');
  is($pt->format_stage('2007-06-15', '2025-06-15'), 'Adulto', '25.18');
  is($pt->format_age(undef, '2025-06-15'), undef, '25.19');
  is($pt->format_stage(undef, '2025-06-15'), undef, '25.20');
}

# ================================================================
# Compactness: short
# ================================================================
{
  my $pt = SayableAge::Formatter->new(SayableAge::Locales->get('en'), compactness => 'short');
  # 26.1..26.9
  is($pt->format_age('2025-06-12', '2025-06-15'), '3 d', '26.1');
  is($pt->format_age('2025-06-08', '2025-06-15'), '1 wk', '26.2');
  is($pt->format_age('2025-06-07', '2025-06-15'), '1 wk, 1 d', '26.3');
  is($pt->format_age('2025-01-15', '2025-07-15'), '6 mo', '26.4');
  is($pt->format_age('2023-06-15', '2025-07-15'), '2 yr, 1 mo', '26.5');
  is($pt->format_age('2022-06-15', '2025-12-15'), "3\x{BD} yr", '26.6');
  is($pt->format_age('2018-06-15', '2025-06-15'), '7 yr', '26.7');
  is($pt->format_age('2025-06-15', '2025-06-15'), 'Newborn', '26.8');
  is($pt->format_stage('2025-01-15', '2025-06-15'), 'Infant', '26.9');
}

# ================================================================
# Compactness: compact
# ================================================================
{
  my $pt = SayableAge::Formatter->new(SayableAge::Locales->get('en'), compactness => 'compact');
  # 27.1..27.8
  is($pt->format_age('2025-06-12', '2025-06-15'), '3d', '27.1');
  is($pt->format_age('2025-06-08', '2025-06-15'), '1w', '27.2');
  is($pt->format_age('2025-06-07', '2025-06-15'), '1w1d', '27.3');
  is($pt->format_age('2025-01-15', '2025-07-15'), '6m', '27.4');
  is($pt->format_age('2023-06-15', '2025-07-15'), '2y1m', '27.5');
  is($pt->format_age('2022-06-15', '2025-12-15'), "3\x{BD}y", '27.6');
  is($pt->format_age('2018-06-15', '2025-06-15'), '7y', '27.7');
  is($pt->format_age('2025-06-15', '2025-06-15'), 'Newborn', '27.8');
}

# ================================================================
# Gender support for format_stage
# ================================================================

# English stages are plain strings — gender param is ignored
{
  my $pt = SayableAge::Formatter->new(SayableAge::Locales->get('en'));
  is($pt->format_stage('2025-06-15', '2025-06-15', gender => 'm'), 'Newborn', '28.1 en gender m');
  is($pt->format_stage('2025-06-15', '2025-06-15', gender => 'f'), 'Newborn', '28.2 en gender f');
  is($pt->format_stage('2025-06-15', '2025-06-15'), 'Newborn', '28.3 en gender nil');
  is($pt->format_stage('2007-06-15', '2025-06-15', gender => 'f'), 'Adult', '28.4 en adult gender f');
}

# Spanish: gendered stages
{
  my $pt = SayableAge::Formatter->new(SayableAge::Locales->get('es'));
  is($pt->format_stage('2025-06-15', '2025-06-15'), "Reci\x{E9}n nacido", '28.5 es newborn default');
  is($pt->format_stage('2025-06-15', '2025-06-15', gender => 'm'), "Reci\x{E9}n nacido", '28.6 es newborn m');
  is($pt->format_stage('2025-06-15', '2025-06-15', gender => 'f'), "Reci\x{E9}n nacida", '28.7 es newborn f');
  is($pt->format_stage('2025-01-15', '2025-06-15', gender => 'f'), "Beb\x{E9}", '28.8 es infant f');
  is($pt->format_stage('2025-01-15', '2025-06-15', gender => 'm'), "Beb\x{E9}", '28.9 es infant m');
  is($pt->format_stage('2024-06-15', '2025-06-15', gender => 'm'), "Ni\x{F1}o peque\x{F1}o", '28.10 es toddler m');
  is($pt->format_stage('2024-06-15', '2025-06-15', gender => 'f'), "Ni\x{F1}a peque\x{F1}a", '28.11 es toddler f');
  is($pt->format_stage('2022-06-15', '2025-06-15', gender => 'm'), "Ni\x{F1}o", '28.12 es child m');
  is($pt->format_stage('2022-06-15', '2025-06-15', gender => 'f'), "Ni\x{F1}a", '28.13 es child f');
  is($pt->format_stage('2012-06-15', '2025-06-15', gender => 'f'), 'Adolescente', '28.14 es teenager f');
  is($pt->format_stage('2007-06-15', '2025-06-15', gender => 'm'), 'Adulto', '28.15 es adult m');
  is($pt->format_stage('2007-06-15', '2025-06-15', gender => 'f'), 'Adulta', '28.16 es adult f');
}

# Arabic: all 6 stages are gendered
{
  my $pt = SayableAge::Formatter->new(SayableAge::Locales->get('ar'));
  is($pt->format_stage('2025-06-15', '2025-06-15', gender => 'm'), "\x{62D}\x{62F}\x{64A}\x{62B} \x{627}\x{644}\x{648}\x{644}\x{627}\x{62F}\x{629}", '28.17 ar newborn m');
  is($pt->format_stage('2025-06-15', '2025-06-15', gender => 'f'), "\x{62D}\x{62F}\x{64A}\x{62B}\x{629} \x{627}\x{644}\x{648}\x{644}\x{627}\x{62F}\x{629}", '28.18 ar newborn f');
  is($pt->format_stage('2025-01-15', '2025-06-15', gender => 'm'), "\x{631}\x{636}\x{64A}\x{639}", '28.19 ar infant m');
  is($pt->format_stage('2025-01-15', '2025-06-15', gender => 'f'), "\x{631}\x{636}\x{64A}\x{639}\x{629}", '28.20 ar infant f');
  is($pt->format_stage('2024-06-15', '2025-06-15', gender => 'm'), "\x{637}\x{641}\x{644} \x{635}\x{63A}\x{64A}\x{631}", '28.21 ar toddler m');
  is($pt->format_stage('2024-06-15', '2025-06-15', gender => 'f'), "\x{637}\x{641}\x{644}\x{629} \x{635}\x{63A}\x{64A}\x{631}\x{629}", '28.22 ar toddler f');
  is($pt->format_stage('2022-06-15', '2025-06-15', gender => 'm'), "\x{637}\x{641}\x{644}", '28.23 ar child m');
  is($pt->format_stage('2022-06-15', '2025-06-15', gender => 'f'), "\x{637}\x{641}\x{644}\x{629}", '28.24 ar child f');
  is($pt->format_stage('2012-06-15', '2025-06-15', gender => 'm'), "\x{645}\x{631}\x{627}\x{647}\x{642}", '28.25 ar teenager m');
  is($pt->format_stage('2012-06-15', '2025-06-15', gender => 'f'), "\x{645}\x{631}\x{627}\x{647}\x{642}\x{629}", '28.26 ar teenager f');
  is($pt->format_stage('2007-06-15', '2025-06-15', gender => 'm'), "\x{628}\x{627}\x{644}\x{63A}", '28.27 ar adult m');
  is($pt->format_stage('2007-06-15', '2025-06-15', gender => 'f'), "\x{628}\x{627}\x{644}\x{63A}\x{629}", '28.28 ar adult f');
}

# German: only adult is gendered
{
  my $pt = SayableAge::Formatter->new(SayableAge::Locales->get('de'));
  is($pt->format_stage('2007-06-15', '2025-06-15', gender => 'm'), 'Erwachsener', '28.29 de adult m');
  is($pt->format_stage('2007-06-15', '2025-06-15', gender => 'f'), 'Erwachsene', '28.30 de adult f');
  is($pt->format_stage('2007-06-15', '2025-06-15'), 'Erwachsener', '28.31 de adult default');
}

# French: gendered stages
{
  my $pt = SayableAge::Formatter->new(SayableAge::Locales->get('fr'));
  is($pt->format_stage('2025-06-15', '2025-06-15', gender => 'm'), "Nouveau-n\x{E9}", '28.32 fr newborn m');
  is($pt->format_stage('2025-06-15', '2025-06-15', gender => 'f'), "Nouveau-n\x{E9}e", '28.33 fr newborn f');
  is($pt->format_stage('2024-06-15', '2025-06-15'), 'Tout-petit', '28.34 fr toddler');
  is($pt->format_stage('2012-06-15', '2025-06-15', gender => 'm'), 'Adolescent', '28.35 fr teenager m');
  is($pt->format_stage('2012-06-15', '2025-06-15', gender => 'f'), 'Adolescente', '28.36 fr teenager f');
  is($pt->format_stage('2007-06-15', '2025-06-15', gender => 'f'), 'Adulte', '28.37 fr adult f');
}

# Module-level convenience with gender
is(SayableAge->format_stage('2007-06-15', '2025-06-15', gender => 'f'), 'Adult', '28.38 module level gender f');
is(SayableAge->format_stage('2007-06-15', '2025-06-15', gender => 'm'), 'Adult', '28.39 module level gender m');

# resolve_stage helper
is(SayableAge::Locale::resolve_stage('Adult', 'm'), 'Adult', '28.40 resolve_stage string m');
is(SayableAge::Locale::resolve_stage('Adult', 'f'), 'Adult', '28.41 resolve_stage string f');
is(SayableAge::Locale::resolve_stage('Adult', undef), 'Adult', '28.42 resolve_stage string nil');

{
  my $label = { m => 'Adulto', f => 'Adulta' };
  is(SayableAge::Locale::resolve_stage($label, 'm'), 'Adulto', '28.43 resolve_stage hash m');
  is(SayableAge::Locale::resolve_stage($label, 'f'), 'Adulta', '28.44 resolve_stage hash f');
  is(SayableAge::Locale::resolve_stage($label, undef), 'Adulto', '28.45 resolve_stage hash nil');
  is(SayableAge::Locale::resolve_stage($label), 'Adulto', '28.46 resolve_stage hash no arg');
}

# Nil handling with gender
{
  my $pt = SayableAge::Formatter->new(SayableAge::Locales->get('es'));
  is($pt->format_stage(undef, '2025-06-15', gender => 'f'), undef, '28.47 nil with gender f');
  is($pt->format_stage('', '2025-06-15', gender => 'm'), undef, '28.48 empty with gender m');
}

# ================================================================
# Section 29: Locale-specific edge cases — new plural rules
# ================================================================

# Hebrew (he) — dual forms
{
  my $pt = SayableAge::Formatter->new(SayableAge::Locales->get('he'));
  # 29.1
  is($pt->format_age('2025-06-15', '2025-06-15'), "\x{5E8}\x{5E7} \x{5E0}\x{5D5}\x{5DC}\x{5D3}", '29.1 he just born');
  # 29.2
  is($pt->format_age('2025-06-14', '2025-06-15'), "\x{5D9}\x{5D5}\x{5DD}", '29.2 he one day');
  # 29.3
  is($pt->format_age('2025-06-12', '2025-06-15'), "3 \x{5D9}\x{5DE}\x{5D9}\x{5DD}", '29.3 he three days');
  # 29.4
  is($pt->format_age('2025-06-01', '2025-06-15'), "\x{5E9}\x{5D1}\x{5D5}\x{5E2}\x{5D9}\x{5D9}\x{5DD}", '29.4 he two weeks dual');
  # 29.5
  is($pt->format_age('2025-05-25', '2025-06-15'), "3 \x{5E9}\x{5D1}\x{5D5}\x{5E2}\x{5D5}\x{5EA}", '29.5 he three weeks');
  # 29.6
  is($pt->format_age('2025-01-15', '2025-07-15'), "6 \x{5D7}\x{5D5}\x{5D3}\x{5E9}\x{5D9}\x{5DD}", '29.6 he six months');
  # 29.7
  is($pt->format_age('2025-03-15', '2025-06-15'), "3 \x{5D7}\x{5D5}\x{5D3}\x{5E9}\x{5D9}\x{5DD}", '29.7 he three months');
  # 29.8
  is($pt->format_age('2023-06-15', '2025-07-15'), "\x{5E9}\x{5E0}\x{5EA}\x{5D9}\x{5D9}\x{5DD}, \x{5D7}\x{5D5}\x{5D3}\x{5E9}", '29.8 he two years dual one month');
  # 29.9
  is($pt->format_age('2022-06-15', '2025-12-15'), "3 \x{5E9}\x{5E0}\x{5D9}\x{5DD} \x{5D5}\x{5D7}\x{5E6}\x{5D9}", '29.9 he half years');
  # 29.10
  is($pt->format_age('2018-06-15', '2025-06-15'), "7 \x{5E9}\x{5E0}\x{5D9}\x{5DD}", '29.10 he seven years');
  # 29.11
  is($pt->format_stage('2025-06-15', '2025-06-15', gender => 'm'), "\x{5E8}\x{5E7} \x{5E0}\x{5D5}\x{5DC}\x{5D3}", '29.11 he stage m newborn');
  # 29.12
  is($pt->format_stage('2025-06-15', '2025-06-15', gender => 'f'), "\x{5E8}\x{5E7} \x{5E0}\x{5D5}\x{5DC}\x{5D3}\x{5D4}", '29.12 he stage f newborn');
  # 29.13
  is($pt->format_stage('2007-06-15', '2025-06-15', gender => 'm'), "\x{5DE}\x{5D1}\x{5D5}\x{5D2}\x{5E8}", '29.13 he stage m adult');
  # 29.14
  is($pt->format_stage('2007-06-15', '2025-06-15', gender => 'f'), "\x{5DE}\x{5D1}\x{5D5}\x{5D2}\x{5E8}\x{5EA}", '29.14 he stage f adult');
}

# Macedonian (mk) — mod10/mod100 rule
{
  my $pt = SayableAge::Formatter->new(SayableAge::Locales->get('mk'));
  # 29.15
  is($pt->format_age('2025-06-15', '2025-06-15'), "\x{41D}\x{43E}\x{432}\x{43E}\x{440}\x{43E}\x{434}\x{435}\x{43D}\x{447}\x{435}", '29.15 mk just born');
  # 29.16
  is($pt->format_age('2025-06-14', '2025-06-15'), "1 \x{434}\x{435}\x{43D}", '29.16 mk one day');
  # 29.17
  is($pt->format_age('2025-06-12', '2025-06-15'), "3 \x{434}\x{435}\x{43D}\x{430}", '29.17 mk three days');
  # 29.18
  is($pt->format_age('2025-01-15', '2025-07-15'), "6 \x{43C}\x{435}\x{441}\x{435}\x{446}\x{438}", '29.18 mk six months');
  # 29.19
  is($pt->format_age('2023-06-15', '2025-07-15'), "2 \x{433}\x{43E}\x{434}\x{438}\x{43D}\x{438}, 1 \x{43C}\x{435}\x{441}\x{435}\x{446}", '29.19 mk 2y1m');
  # 29.20
  is($pt->format_age('2022-06-15', '2025-12-15'), "3 \x{433}\x{43E}\x{434}\x{438}\x{43D}\x{438} \x{438} \x{43F}\x{43E}\x{43B}", '29.20 mk half years');
  # 29.21
  is($pt->format_age('2018-06-15', '2025-06-15'), "7 \x{433}\x{43E}\x{434}\x{438}\x{43D}\x{438}", '29.21 mk seven years');
}

# Swahili (sw) — noun class changes
{
  my $pt = SayableAge::Formatter->new(SayableAge::Locales->get('sw'));
  # 29.22
  is($pt->format_age('2025-06-15', '2025-06-15'), 'Mzaliwa mpya', '29.22 sw just born');
  # 29.23
  is($pt->format_age('2025-06-14', '2025-06-15'), 'siku 1', '29.23 sw one day');
  # 29.24
  is($pt->format_age('2025-06-12', '2025-06-15'), 'siku 3', '29.24 sw three days');
  # 29.25
  is($pt->format_age('2025-01-15', '2025-07-15'), 'miezi 6', '29.25 sw six months');
  # 29.26
  is($pt->format_age('2023-06-15', '2025-07-15'), 'miaka 2, mwezi 1', '29.26 sw 2y1m');
  # 29.27
  is($pt->format_age('2022-06-15', '2025-12-15'), 'miaka 3 na nusu', '29.27 sw half years');
}

# Indonesian (id) — other_only
{
  my $pt = SayableAge::Formatter->new(SayableAge::Locales->get('id'));
  # 29.28
  is($pt->format_age('2025-06-15', '2025-06-15'), 'Baru lahir', '29.28 id just born');
  # 29.29
  is($pt->format_age('2025-06-14', '2025-06-15'), '1 hari', '29.29 id one day');
  # 29.30
  is($pt->format_age('2025-06-12', '2025-06-15'), '3 hari', '29.30 id three days');
  # 29.31
  is($pt->format_age('2025-01-15', '2025-07-15'), '6 bulan', '29.31 id six months');
  # 29.32
  is($pt->format_age('2022-06-15', '2025-12-15'), '3 setengah tahun', '29.32 id half years');
  # 29.33
  is($pt->format_age('2018-06-15', '2025-06-15'), '7 tahun', '29.33 id seven years');
}

# Amharic (am) — Ethiopic delimiter
{
  my $pt = SayableAge::Formatter->new(SayableAge::Locales->get('am'));
  # 29.34
  is($pt->format_age('2025-06-15', '2025-06-15'), "\x{12A0}\x{12F2}\x{1235} \x{12E8}\x{1270}\x{12C8}\x{1208}\x{12F0}", '29.34 am just born');
  # 29.35
  is($pt->format_age('2025-06-14', '2025-06-15'), "1 \x{1240}\x{1295}", '29.35 am one day');
  # 29.36
  is($pt->format_age('2025-06-12', '2025-06-15'), "3 \x{1240}\x{1293}\x{1275}", '29.36 am three days');
  # 29.37
  is($pt->format_age('2025-06-07', '2025-06-15'), "1 \x{1233}\x{121D}\x{1295}\x{1275}\x{1363} 1 \x{1240}\x{1295}", '29.37 am 1w1d ethiopic');
  # 29.38
  is($pt->format_age('2025-01-15', '2025-07-15'), "6 \x{12C8}\x{122B}\x{1275}", '29.38 am six months');
  # 29.39
  is($pt->format_age('2022-06-15', '2025-12-15'), "3 \x{12D3}\x{1218}\x{1273}\x{1275} \x{1270}\x{12A9}\x{120D}", '29.39 am half years');
}

# ================================================================
# Section 30: Locale lookup by code string
# ================================================================
# 30.1
{
  my $loc = SayableAge::Locales->get('en');
  ok(defined $loc, '30.1 get en');
  is($loc->{code}, 'en', '30.1 en code');
}
# 30.2
{
  my $loc = SayableAge::Locales->get('fr');
  ok(defined $loc, '30.2 get fr');
  is($loc->{code}, 'fr', '30.2 fr code');
}
# 30.3
is(SayableAge::Locales->get('xx'), undef, '30.3 unknown locale');
# 30.4
is(SayableAge::Locales->get(''), undef, '30.4 empty code');
# 30.5
is(SayableAge::Locales->get('EN'), undef, '30.5 case sensitive');

# ================================================================
# Sections 31-33: weeks+days across month ends, half-year plurals, input validation
# ================================================================
# 31.1
is(SayableAge::Formatter->new(SayableAge::Locales->get('en'))->format_age('2016-12-31', '2017-03-29'), '12 weeks, 4 days', '31.1 88 days across a 28-day February');
# 31.2
is(SayableAge::Formatter->new(SayableAge::Locales->get('en'))->format_age('1991-11-27', '1992-02-25'), '12 weeks, 6 days', '31.2 90 days across a year end into a leap year');
# 31.3
is(SayableAge::Formatter->new(SayableAge::Locales->get('en'))->format_age('2020-11-30', '2021-01-02'), '4 weeks, 5 days', '31.3 33 days across a year end');
# 31.4
is(SayableAge::Formatter->new(SayableAge::Locales->get('en'), compactness => 'compact')->format_age('2016-12-31', '2017-03-29'), '12w4d', '31.4 Compact form of 31.1');
# 32.1
is(SayableAge::Formatter->new(SayableAge::Locales->get('pl'))->format_age('2021-06-15', '2025-01-15'), '3 i pół lata', '32.1 Polish 3 is \'few\'');
# 32.2
is(SayableAge::Formatter->new(SayableAge::Locales->get('pl'), compactness => 'short')->format_age('2020-06-15', '2025-12-15'), '5 i pół lat', '32.2 Polish 5 is \'many\'');
# 32.3
is(SayableAge::Formatter->new(SayableAge::Locales->get('shi'))->format_age('2005-06-08', '2012-06-07'), '6 ⵉⵙⴳⴳⵯⴰⵙⵏ ⴷ ⵓⵣⴳⵏ', '32.3 Tachelhit 6 is \'few\'');
# 33.1
is(SayableAge::Formatter->new(SayableAge::Locales->get('en'))->format_age('2025-02-30', '2032-06-25'), undef, '33.1 February 30 doesn\'t exist');
# 33.2
is(SayableAge::Formatter->new(SayableAge::Locales->get('en'))->format_age('2025-13-01', '2027-01-31'), undef, '33.2 Month 13');
# 33.3
is(SayableAge::Formatter->new(SayableAge::Locales->get('en'))->format_age('2023-02-29', '2025-03-01'), undef, '33.3 February 29 in a non-leap year');
# 33.4
is(SayableAge::Formatter->new(SayableAge::Locales->get('en'))->format_age('2025-06-00', '2027-02-25'), undef, '33.4 Day 00');
# 33.5
is(SayableAge::Formatter->new(SayableAge::Locales->get('en'))->format_age('2025-6-1', '2027-02-25'), undef, '33.5 Unpadded month and day');
# 33.6
is(SayableAge::Formatter->new(SayableAge::Locales->get('en'))->format_age(' 2025-06-01', '2027-02-25'), undef, '33.6 Surrounding whitespace');
# 33.7
is(SayableAge::Formatter->new(SayableAge::Locales->get('en'))->format_age('2025-06-15T10:00:00', '2027-02-25'), undef, '33.7 A datetime is not a date');
# 33.8
is(SayableAge::Formatter->new(SayableAge::Locales->get('en'))->format_age('2020-01-01', '2025-04-31'), undef, '33.8 Invalid asOf');
# 33.9
is(SayableAge::Formatter->new(SayableAge::Locales->get('en'))->format_stage('2025-02-30', '2027-09-05'), undef, '33.9 formatStage validates too');
# 33.10
is(SayableAge::Formatter->new(SayableAge::Locales->get('en'))->format_age('2024-02-29', '2026-03-01'), '2 years', '33.10 February 29 in a leap year is valid');

done_testing();
