# frozen_string_literal: true

require 'minitest/autorun'
require 'sayable_duration'

# All tests use explicit inputs for determinism.

# ================================================================
# Section 1: Null / edge cases
# ================================================================
class TestNullEdgeCases < Minitest::Test
  # 1.1
  def test_format_duration_nil
    assert_nil SayableDuration.format_duration(nil)
  end

  # 1.2
  def test_format_duration_negative
    assert_nil SayableDuration.format_duration(-1)
  end

  # 1.3
  def test_format_since_nil_start
    assert_nil SayableDuration.format_since(nil, '2025-01-15T10:00:00')
  end

  # 1.4
  def test_format_until_nil_target
    assert_nil SayableDuration.format_until(nil, '2025-01-15T10:00:00')
  end

  # 1.5
  def test_format_since_future_start
    assert_nil SayableDuration.format_since('2025-01-15T10:00:00', '2025-01-15T09:00:00')
  end

  # 1.6
  def test_format_until_past_target
    assert_nil SayableDuration.format_until('2025-01-15T09:00:00', '2025-01-15T10:00:00')
  end
end

# ================================================================
# Section 2: Duration — seconds tier (0-59s)
# ================================================================
class TestDurationSeconds < Minitest::Test
  # 2.1
  def test_zero
    assert_equal 'just now', SayableDuration.format_duration(0)
  end

  # 2.2
  def test_one_second
    assert_equal '1 second', SayableDuration.format_duration(1)
  end

  # 2.3
  def test_45_seconds
    assert_equal '45 seconds', SayableDuration.format_duration(45)
  end

  # 2.4
  def test_59_seconds
    assert_equal '59 seconds', SayableDuration.format_duration(59)
  end
end

# ================================================================
# Section 3: Duration — minutes + seconds tier (1-4 min)
# ================================================================
class TestDurationMinutesSeconds < Minitest::Test
  # 3.1
  def test_one_minute
    assert_equal '1 minute', SayableDuration.format_duration(60)
  end

  # 3.2
  def test_one_minute_thirty
    assert_equal '1 minute, 30 seconds', SayableDuration.format_duration(90)
  end

  # 3.3
  def test_four_minutes
    assert_equal '4 minutes', SayableDuration.format_duration(240)
  end

  # 3.4
  def test_four_minutes_thirty
    assert_equal '4 minutes, 30 seconds', SayableDuration.format_duration(270)
  end
end

# ================================================================
# Section 4: Duration — minutes tier (5-59 min)
# ================================================================
class TestDurationMinutes < Minitest::Test
  # 4.1
  def test_five_minutes
    assert_equal '5 minutes', SayableDuration.format_duration(300)
  end

  # 4.2
  def test_25_minutes
    assert_equal '25 minutes', SayableDuration.format_duration(1500)
  end

  # 4.3
  def test_59_minutes
    assert_equal '59 minutes', SayableDuration.format_duration(3540)
  end
end

# ================================================================
# Section 5: Duration — hours + minutes tier (1-5 hr)
# ================================================================
class TestDurationHoursMinutes < Minitest::Test
  # 5.1
  def test_one_hour
    assert_equal '1 hour', SayableDuration.format_duration(3600)
  end

  # 5.2
  def test_one_and_half_hours
    assert_equal "1\u00BD hours", SayableDuration.format_duration(5400)
  end

  # 5.3
  def test_two_hours_15_minutes
    assert_equal '2 hours, 15 minutes', SayableDuration.format_duration(8100)
  end

  # 5.4
  def test_five_hours
    assert_equal '5 hours', SayableDuration.format_duration(18_000)
  end
end

# ================================================================
# Section 6: Duration — hours tier (6-23 hr)
# ================================================================
class TestDurationHours < Minitest::Test
  # 6.1
  def test_eight_hours
    assert_equal '8 hours', SayableDuration.format_duration(28_800)
  end

  # 6.2
  def test_23_hours
    assert_equal '23 hours', SayableDuration.format_duration(82_800)
  end
end

# ================================================================
# Section 7: Duration — days tier
# ================================================================
class TestDurationDays < Minitest::Test
  # 7.1
  def test_one_day
    assert_equal '1 day', SayableDuration.format_duration(86_400)
  end

  # 7.2
  def test_one_day_three_hours
    assert_equal '1 day, 3 hours', SayableDuration.format_duration(97_200)
  end

  # 7.3
  def test_one_and_half_days
    assert_equal "1\u00BD days", SayableDuration.format_duration(129_600)
  end

  # 7.4
  def test_five_days
    assert_equal '5 days', SayableDuration.format_duration(432_000)
  end

  # 7.5
  def test_two_days
    assert_equal '2 days', SayableDuration.format_duration(172_800)
  end
end

# ================================================================
# Section 8: Duration — weeks tier
# ================================================================
class TestDurationWeeks < Minitest::Test
  # 8.1
  def test_one_week
    assert_equal '1 week', SayableDuration.format_duration(604_800)
  end

  # 8.2
  def test_two_weeks_one_day
    assert_equal '2 weeks, 1 day', SayableDuration.format_duration(1_296_000)
  end

  # 8.3
  def test_four_weeks
    assert_equal '4 weeks', SayableDuration.format_duration(2_419_200)
  end
end

# ================================================================
# Section 9: Duration — months and years tier
# ================================================================
class TestDurationMonthsYears < Minitest::Test
  # 9.1
  def test_one_month
    assert_equal '1 month', SayableDuration.format_duration(2_678_400)
  end

  # 9.2
  def test_three_months
    assert_equal '3 months', SayableDuration.format_duration(7_884_000)
  end

  # 9.3
  def test_one_year
    assert_equal '1 year', SayableDuration.format_duration(31_536_000)
  end

  # 9.4
  def test_one_year_three_months
    assert_equal '1 year, 3 months', SayableDuration.format_duration(39_420_000)
  end
end

# ================================================================
# Section 10: Duration from ISO timestamps
# ================================================================
class TestDurationISO < Minitest::Test
  # 10.1
  def test_iso_one_and_half_hours
    assert_equal "1\u00BD hours", SayableDuration.format_duration('2025-01-15T10:00:00', '2025-01-15T11:30:00')
  end

  # 10.2
  def test_iso_45_minutes
    assert_equal '45 minutes', SayableDuration.format_duration('2025-01-15T10:00:00', '2025-01-15T10:45:00')
  end
end

# ================================================================
# Section 11: Relative time — since
# ================================================================
class TestFormatSince < Minitest::Test
  # 11.1
  def test_just_now
    assert_equal 'just now', SayableDuration.format_since('2025-01-15T10:00:00', '2025-01-15T10:00:00')
  end

  # 11.2
  def test_30_seconds_ago
    assert_equal '30 seconds ago', SayableDuration.format_since('2025-01-15T10:00:00', '2025-01-15T10:00:30')
  end

  # 11.3
  def test_45_minutes_ago
    assert_equal '45 minutes ago', SayableDuration.format_since('2025-01-15T10:00:00', '2025-01-15T10:45:00')
  end

  # 11.4
  def test_three_hours_ago
    assert_equal '3 hours ago', SayableDuration.format_since('2025-01-15T10:00:00', '2025-01-15T13:00:00')
  end
end

# ================================================================
# Section 12: Relative time — until
# ================================================================
class TestFormatUntil < Minitest::Test
  # 12.1
  def test_just_now
    assert_equal 'just now', SayableDuration.format_until('2025-01-15T10:00:00', '2025-01-15T10:00:00')
  end

  # 12.2
  def test_in_20_minutes
    assert_equal 'in 20 minutes', SayableDuration.format_until('2025-01-15T10:20:00', '2025-01-15T10:00:00')
  end

  # 12.3
  def test_in_3_hours
    assert_equal 'in 3 hours', SayableDuration.format_until('2025-01-15T13:00:00', '2025-01-15T10:00:00')
  end
end

# ================================================================
# Section 13: Locale — German
# ================================================================
class TestLocaleGerman < Minitest::Test
  def setup
    @sd = SayableDuration::Formatter.new(SayableDuration::Locales::DE)
  end

  # 13.1
  def test_duration_one_hour
    assert_equal '1 Stunde', @sd.format_duration(3600)
  end

  # 13.2
  def test_since
    result = @sd.format_since('2025-01-15T10:00:00', '2025-01-15T10:05:00')
    assert_equal 'vor 5 Minuten', result
  end
end

# ================================================================
# Section 14: Locale — French
# ================================================================
class TestLocaleFrench < Minitest::Test
  def setup
    @sd = SayableDuration::Formatter.new(SayableDuration::Locales::FR)
  end

  # 14.1
  def test_duration_two_hours
    assert_equal '2 heures', @sd.format_duration(7200)
  end
end

# ================================================================
# Section 15: Locale — Japanese
# ================================================================
class TestLocaleJapanese < Minitest::Test
  def setup
    @sd = SayableDuration::Formatter.new(SayableDuration::Locales::JA)
  end

  # 15.1
  def test_duration_two_minutes
    assert_equal "2\u5206", @sd.format_duration(120)
  end

  # 15.2
  def test_since_one_hour
    result = @sd.format_since('2025-01-15T10:00:00', '2025-01-15T11:00:00')
    assert_equal "1\u6642\u9593\u524D", result
  end
end

# ================================================================
# Section 16: Short compactness — duration
# ================================================================
class TestShortDuration < Minitest::Test
  def setup
    @sd = SayableDuration::Formatter.new(SayableDuration::Locales::EN, compactness: :short)
  end

  # 16.1
  def test_one_hour
    assert_equal '1h', @sd.format_duration(3600)
  end

  # 16.2
  def test_one_minute_thirty_seconds
    assert_equal '1m, 30s', @sd.format_duration(90)
  end
end

# ================================================================
# Section 17: Compact compactness — duration
# ================================================================
class TestCompactDuration < Minitest::Test
  def setup
    @sd = SayableDuration::Formatter.new(SayableDuration::Locales::EN, compactness: :compact)
  end

  # 17.1
  def test_one_hour
    assert_equal '1h', @sd.format_duration(3600)
  end

  # 17.2
  def test_one_minute_thirty_seconds
    assert_equal '1m30s', @sd.format_duration(90)
  end
end
