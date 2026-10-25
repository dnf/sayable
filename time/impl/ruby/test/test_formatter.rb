# frozen_string_literal: true

require 'minitest/autorun'
require 'sayable_time'

# All tests use explicit inputs for determinism.

class TestFormatTime < Minitest::Test
  # ================================================================
  # Section 1: Null / edge cases
  # ================================================================
  # 1.1
  def test_format_time_nil
    assert_nil SayableTime.format_time(nil)
  end

  # 1.2
  def test_format_time_empty
    assert_nil SayableTime.format_time('')
  end

  # 1.3
  def test_format_time_invalid
    assert_nil SayableTime.format_time('invalid')
  end

  # 1.4
  def test_format_time_out_of_range
    assert_nil SayableTime.format_time('25:00')
  end

  # ================================================================
  # Section 2: Clock time (normal compactness)
  # ================================================================
  # 2.1
  def test_midnight
    st = SayableTime::Formatter.new(SayableTime::Locales::EN)
    assert_equal 'midnight', st.format_time('00:00')
  end

  # 2.2
  def test_noon
    st = SayableTime::Formatter.new(SayableTime::Locales::EN)
    assert_equal 'noon', st.format_time('12:00')
  end

  # 2.3
  def test_oclock
    st = SayableTime::Formatter.new(SayableTime::Locales::EN)
    assert_equal "three o'clock", st.format_time('15:00')
  end

  # 2.4
  def test_quarter_past
    st = SayableTime::Formatter.new(SayableTime::Locales::EN)
    assert_equal 'a quarter past two', st.format_time('14:15')
  end

  # 2.5
  def test_half_past
    st = SayableTime::Formatter.new(SayableTime::Locales::EN)
    assert_equal 'half past nine', st.format_time('09:30')
  end

  # 2.6
  def test_quarter_to
    st = SayableTime::Formatter.new(SayableTime::Locales::EN)
    assert_equal 'a quarter to eleven', st.format_time('10:45')
  end

  # 2.7
  def test_five_past
    st = SayableTime::Formatter.new(SayableTime::Locales::EN)
    assert_equal 'five past eight', st.format_time('08:05')
  end

  # 2.8
  def test_five_to
    st = SayableTime::Formatter.new(SayableTime::Locales::EN)
    assert_equal 'five to five', st.format_time('16:55')
  end

  # 2.9 — rounds to 0:00 of next day
  def test_rounds_to_midnight
    st = SayableTime::Formatter.new(SayableTime::Locales::EN)
    assert_equal 'midnight', st.format_time('23:58')
  end

  # 2.10 — 22 rounds to 20
  def test_rounds_to_twenty
    st = SayableTime::Formatter.new(SayableTime::Locales::EN)
    assert_equal 'twenty past seven', st.format_time('07:22')
  end

  # 2.11 — ISO datetime input
  def test_iso_datetime_input
    st = SayableTime::Formatter.new(SayableTime::Locales::EN)
    assert_equal 'a quarter past two', st.format_time('2025-01-15T14:15:00')
  end

  # ================================================================
  # Section 3: Clock time (short compactness)
  # ================================================================
  # 3.1
  def test_short_pm
    st = SayableTime::Formatter.new(SayableTime::Locales::EN, :short)
    assert_equal '2:15 PM', st.format_time('14:15')
  end

  # 3.2
  def test_short_am
    st = SayableTime::Formatter.new(SayableTime::Locales::EN, :short)
    assert_equal '9:30 AM', st.format_time('09:30')
  end

  # 3.3
  def test_short_midnight
    st = SayableTime::Formatter.new(SayableTime::Locales::EN, :short)
    assert_equal '12:00 AM', st.format_time('00:00')
  end

  # 3.4
  def test_short_noon
    st = SayableTime::Formatter.new(SayableTime::Locales::EN, :short)
    assert_equal '12:00 PM', st.format_time('12:00')
  end

  # ================================================================
  # Section 4: Clock time (compact)
  # ================================================================
  # 4.1
  def test_compact_pm
    st = SayableTime::Formatter.new(SayableTime::Locales::EN, :compact)
    assert_equal '2:15p', st.format_time('14:15')
  end

  # 4.2
  def test_compact_am
    st = SayableTime::Formatter.new(SayableTime::Locales::EN, :compact)
    assert_equal '9:30a', st.format_time('09:30')
  end

  # ================================================================
  # Section 5: Locale — German
  # ================================================================
  # 5.1 — German half-to pattern
  def test_german_half_to
    st = SayableTime::Formatter.new(SayableTime::Locales::DE)
    assert_equal 'halb vier', st.format_time('15:30')
  end

  # ================================================================
  # Section 6: Locale — French
  # ================================================================
  # 6.1
  def test_french_quarter_past
    st = SayableTime::Formatter.new(SayableTime::Locales::FR)
    assert_equal 'trois heures et quart', st.format_time('15:15')
  end

  # ================================================================
  # Section 7: Locale — Japanese
  # ================================================================
  # 7.1
  def test_japanese_half_past
    st = SayableTime::Formatter.new(SayableTime::Locales::JA)
    assert_equal "\u4E09\u6642\u534A", st.format_time('15:30')
  end

  # ================================================================
  # Section 8: Locale — Finnish (dot separator, short)
  # ================================================================
  # 8.1
  def test_finnish_dot_separator
    st = SayableTime::Formatter.new(SayableTime::Locales::FI, :short)
    assert_equal '14.15', st.format_time('14:15')
  end

  # 8.2
  def test_finnish_midnight_dot
    st = SayableTime::Formatter.new(SayableTime::Locales::FI, :short)
    assert_equal '0.00', st.format_time('00:00')
  end
end

# ================================================================
# Sections 9-10: minutes in short/compact, input validation
# ================================================================
class TestSpecSections9And10 < Minitest::Test
  # 9.1
  def test_9_1_digital_modes_keep_the_exact_minute
    assert_equal '6:01 PM', SayableTime::Formatter.new(SayableTime::Locales::EN, :short).format_time('18:01')
  end

  # 9.2
  def test_9_2_digital_modes_keep_the_exact_minute
    assert_equal '7:05p', SayableTime::Formatter.new(SayableTime::Locales::EN, :compact).format_time('19:05')
  end

  # 10.1
  def test_10_1_one_digit_hour
    assert_equal 'half past nine', SayableTime::Formatter.new(SayableTime::Locales::EN).format_time('9:30')
  end

  # 10.2
  def test_10_2_two_digit_hour
    assert_equal 'half past nine', SayableTime::Formatter.new(SayableTime::Locales::EN).format_time('09:30')
  end

  # 10.3
  def test_10_3_leading_whitespace
    assert_nil SayableTime::Formatter.new(SayableTime::Locales::EN).format_time(' 9:30')
  end

  # 10.4
  def test_10_4_trailing_whitespace
    assert_nil SayableTime::Formatter.new(SayableTime::Locales::EN).format_time('9:30 ')
  end

  # 10.5
  def test_10_5_minutes_need_two_digits
    assert_nil SayableTime::Formatter.new(SayableTime::Locales::EN).format_time('9:5')
  end

  # 10.6
  def test_10_6_hour_out_of_range
    assert_nil SayableTime::Formatter.new(SayableTime::Locales::EN).format_time('24:00')
  end

  # 10.7
  def test_10_7_seconds_are_allowed_and_ignored
    assert_equal 'a quarter past two', SayableTime::Formatter.new(SayableTime::Locales::EN).format_time('14:15:30')
  end

  # 10.8
  def test_10_8_iso_datetime_with_zone_suffix_ignored
    assert_equal 'a quarter past two', SayableTime::Formatter.new(SayableTime::Locales::EN).format_time('2025-01-15T14:15:00Z')
  end

  # 10.9
  def test_10_9_iso_datetime_with_an_impossible_date
    assert_nil SayableTime::Formatter.new(SayableTime::Locales::EN).format_time('2025-02-30T14:15:00')
  end
end
