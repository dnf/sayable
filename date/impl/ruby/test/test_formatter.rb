# frozen_string_literal: true

require 'minitest/autorun'
require 'sayable_date'

# All tests use explicit (date, as_of) pairs for determinism.

# ================================================================
# Section 1: Null / edge cases
# ================================================================
class TestNullEdgeCases < Minitest::Test
  # 1.1
  def test_format_date_null
    assert_nil SayableDate.format_date(nil)
  end

  # 1.2
  def test_format_date_empty
    assert_nil SayableDate.format_date('')
  end

  # 1.3
  def test_format_date_invalid
    assert_nil SayableDate.format_date('invalid')
  end

  # 1.4
  def test_format_relative_null_as_of
    assert_nil SayableDate.format_relative('2025-03-15', nil)
  end

  # 1.5
  def test_format_relative_null_date
    assert_nil SayableDate.format_relative(nil, '2025-03-15')
  end
end

# ================================================================
# Section 2: format_date — normal compactness (English)
# ================================================================
class TestFormatDateNormalEnglish < Minitest::Test
  def setup
    @f = SayableDate::Formatter.new(SayableDate::Locales::EN)
  end

  # 2.1
  def test_march_15th
    assert_equal 'March 15th', @f.format_date('2025-03-15')
  end

  # 2.2
  def test_january_1st
    assert_equal 'January 1st', @f.format_date('2025-01-01')
  end

  # 2.3
  def test_may_22nd
    assert_equal 'May 22nd', @f.format_date('2025-05-22')
  end

  # 2.4
  def test_july_3rd
    assert_equal 'July 3rd', @f.format_date('2025-07-03')
  end

  # 2.5
  def test_december_31st
    assert_equal 'December 31st', @f.format_date('2025-12-31')
  end

  # 2.6
  def test_june_11th
    assert_equal 'June 11th', @f.format_date('2025-06-11')
  end

  # 2.7
  def test_iso_datetime_input
    assert_equal 'March 15th', @f.format_date('2025-03-15T14:30:00')
  end
end

# ================================================================
# Section 3: format_date — short compactness (English)
# ================================================================
class TestFormatDateShortEnglish < Minitest::Test
  def setup
    @f = SayableDate::Formatter.new(SayableDate::Locales::EN, compactness: :short)
  end

  # 3.1
  def test_mar_fifteenth
    assert_equal 'Mar 15', @f.format_date('2025-03-15')
  end

  # 3.2
  def test_jan_first
    assert_equal 'Jan 1', @f.format_date('2025-01-01')
  end

  # 3.3
  def test_dec_twenty_fifth
    assert_equal 'Dec 25', @f.format_date('2025-12-25')
  end
end

# ================================================================
# Section 4: format_date — compact (English)
# ================================================================
class TestFormatDateCompactEnglish < Minitest::Test
  def setup
    @f = SayableDate::Formatter.new(SayableDate::Locales::EN, compactness: :compact)
  end

  # 4.1
  def test_numeric_march_fifteenth
    assert_equal '3/15', @f.format_date('2025-03-15')
  end

  # 4.2
  def test_numeric_january_first
    assert_equal '1/1', @f.format_date('2025-01-01')
  end
end

# ================================================================
# Section 5: format_relative — proximity tiers (English)
# ================================================================
class TestFormatRelativeEnglish < Minitest::Test
  def setup
    @f = SayableDate::Formatter.new(SayableDate::Locales::EN)
  end

  # 5.1
  def test_today
    assert_equal 'today', @f.format_relative('2025-03-15', '2025-03-15')
  end

  # 5.2
  def test_tomorrow
    assert_equal 'tomorrow', @f.format_relative('2025-03-16', '2025-03-15')
  end

  # 5.3
  def test_yesterday
    assert_equal 'yesterday', @f.format_relative('2025-03-14', '2025-03-15')
  end

  # 5.4
  def test_day_after_tomorrow
    assert_equal 'the day after tomorrow', @f.format_relative('2025-03-17', '2025-03-15')
  end

  # 5.5
  def test_day_before_yesterday
    assert_equal 'the day before yesterday', @f.format_relative('2025-03-13', '2025-03-15')
  end

  # 5.6
  def test_this_wednesday
    assert_equal 'this Wednesday', @f.format_relative('2025-03-19', '2025-03-15')
  end

  # 5.7
  def test_this_thursday
    assert_equal 'this Thursday', @f.format_relative('2025-03-20', '2025-03-15')
  end

  # 5.8
  def test_last_tuesday
    assert_equal 'last Tuesday', @f.format_relative('2025-03-11', '2025-03-15')
  end

  # 5.9
  def test_next_saturday
    assert_equal 'next Saturday', @f.format_relative('2025-03-22', '2025-03-15')
  end

  # 5.10
  def test_next_thursday
    assert_equal 'next Thursday', @f.format_relative('2025-03-27', '2025-03-15')
  end

  # 5.11
  def test_calendar_same_year_past
    assert_equal 'March 1st', @f.format_relative('2025-03-01', '2025-03-15')
  end

  # 5.12
  def test_calendar_same_year_future
    assert_equal 'April 10th', @f.format_relative('2025-04-10', '2025-03-15')
  end

  # 5.13
  def test_different_year_future
    assert_equal 'January 5th, 2026', @f.format_relative('2026-01-05', '2025-03-15')
  end

  # 5.14
  def test_different_year_past
    assert_equal 'December 25th, 2024', @f.format_relative('2024-12-25', '2025-03-15')
  end
end

# ================================================================
# Section 6: format_relative — compact skips weekday tiers
# ================================================================
class TestFormatRelativeCompactEnglish < Minitest::Test
  def setup
    @f = SayableDate::Formatter.new(SayableDate::Locales::EN, compactness: :compact)
  end

  # 6.1
  def test_today
    assert_equal 'today', @f.format_relative('2025-03-15', '2025-03-15')
  end

  # 6.2
  def test_tomorrow
    assert_equal 'tomorrow', @f.format_relative('2025-03-16', '2025-03-15')
  end

  # 6.3
  def test_compact_numeric
    assert_equal '3/19', @f.format_relative('2025-03-19', '2025-03-15')
  end

  # 6.4
  def test_compact_different_year
    assert_equal '1/5/26', @f.format_relative('2026-01-05', '2025-03-15')
  end
end

# ================================================================
# Section 7: Locale — German
# ================================================================
class TestLocaleGerman < Minitest::Test
  def setup
    @f = SayableDate::Formatter.new(SayableDate::Locales::DE)
  end

  # 7.1
  def test_format_date
    assert_equal '15. März', @f.format_date('2025-03-15')
  end

  # 7.2
  def test_tomorrow
    assert_equal 'morgen', @f.format_relative('2025-03-16', '2025-03-15')
  end

  # 7.3
  def test_day_after_tomorrow
    assert_equal 'übermorgen', @f.format_relative('2025-03-17', '2025-03-15')
  end

  # 7.4
  def test_this_wednesday
    assert_equal 'diesen Mittwoch', @f.format_relative('2025-03-19', '2025-03-15')
  end
end

# ================================================================
# Section 8: Locale — French
# ================================================================
class TestLocaleFrench < Minitest::Test
  def setup
    @f = SayableDate::Formatter.new(SayableDate::Locales::FR)
  end

  # 8.1
  def test_format_date_first
    assert_equal '1er mars', @f.format_date('2025-03-01')
  end

  # 8.2
  def test_format_date
    assert_equal '15 mars', @f.format_date('2025-03-15')
  end

  # 8.3
  def test_tomorrow
    assert_equal 'demain', @f.format_relative('2025-03-16', '2025-03-15')
  end
end

# ================================================================
# Section 9: Locale — Japanese
# ================================================================
class TestLocaleJapanese < Minitest::Test
  def setup
    @f = SayableDate::Formatter.new(SayableDate::Locales::JA)
  end

  # 9.1
  def test_format_date
    assert_equal "3\u670815\u65E5", @f.format_date('2025-03-15')
  end

  # 9.2
  def test_tomorrow
    assert_equal "\u660E\u65E5", @f.format_relative('2025-03-16', '2025-03-15')
  end

  # 9.3
  def test_this_wednesday
    assert_equal "\u4ECA\u5EA6\u306E\u6C34\u66DC\u65E5", @f.format_relative('2025-03-19', '2025-03-15')
  end
end

# ================================================================
# Section 10: Locale — Russian (genitive months)
# ================================================================
class TestLocaleRussian < Minitest::Test
  def setup
    @f = SayableDate::Formatter.new(SayableDate::Locales::RU)
  end

  # 10.1
  def test_format_date_genitive
    assert_equal "15 \u043C\u0430\u0440\u0442\u0430", @f.format_date('2025-03-15')
  end

  # 10.2
  def test_tomorrow
    assert_equal "\u0437\u0430\u0432\u0442\u0440\u0430", @f.format_relative('2025-03-16', '2025-03-15')
  end
end

# ================================================================
# Section 11: Locale — Arabic
# ================================================================
class TestLocaleArabic < Minitest::Test
  def setup
    @f = SayableDate::Formatter.new(SayableDate::Locales::AR)
  end

  # 11.1
  def test_format_date
    assert_equal "15 \u0645\u0627\u0631\u0633", @f.format_date('2025-03-15')
  end

  # 11.2
  def test_tomorrow
    assert_equal "\u063A\u062F\u0627\u064B", @f.format_relative('2025-03-16', '2025-03-15')
  end
end

# ================================================================
# Section 12: Locale — Spanish
# ================================================================
class TestLocaleSpanish < Minitest::Test
  def setup
    @f = SayableDate::Formatter.new(SayableDate::Locales::ES)
  end

  # 12.1
  def test_format_date
    assert_equal '15 de marzo', @f.format_date('2025-03-15')
  end

  # 12.2
  def test_day_after_tomorrow
    assert_equal "pasado ma\u00F1ana", @f.format_relative('2025-03-17', '2025-03-15')
  end
end

# ================================================================
# Version
# ================================================================
class TestVersion < Minitest::Test
  def test_version
    assert_equal '0.5.0', SayableDate::VERSION
  end
end

# ================================================================
# Locale lookup by code string
# ================================================================
class TestLocaleLookup < Minitest::Test
  def test_get_locale_en
    loc = SayableDate::Locales.get('en')
    refute_nil loc
    assert_equal 'en', loc.code
  end

  def test_get_locale_fr
    loc = SayableDate::Locales.get('fr')
    refute_nil loc
    assert_equal 'fr', loc.code
  end

  def test_get_locale_unknown
    assert_nil SayableDate::Locales.get('xx')
  end

  def test_get_locale_empty
    assert_nil SayableDate::Locales.get('')
  end

  def test_get_locale_case_sensitive
    assert_nil SayableDate::Locales.get('EN')
  end
end

# ================================================================
# format_date_with_year
# ================================================================
class TestFormatDateWithYear < Minitest::Test
  def setup
    @f = SayableDate::Formatter.new(SayableDate::Locales::EN)
  end

  def test_with_year
    assert_equal 'March 15th, 2025', @f.format_date_with_year('2025-03-15')
  end

  def test_with_year_nil
    assert_nil @f.format_date_with_year(nil)
  end

  def test_with_year_empty
    assert_nil @f.format_date_with_year('')
  end

  def test_with_year_invalid
    assert_nil @f.format_date_with_year('invalid')
  end
end

# ================================================================
# Module-level convenience methods
# ================================================================
class TestModuleLevelMethods < Minitest::Test
  def test_module_format_date
    assert_equal 'March 15th', SayableDate.format_date('2025-03-15')
  end

  def test_module_format_relative
    assert_equal 'today', SayableDate.format_relative('2025-03-15', '2025-03-15')
  end

  def test_module_format_date_with_year
    assert_equal 'March 15th, 2025', SayableDate.format_date_with_year('2025-03-15')
  end
end

# ================================================================
# Sections 13-16: with year, short months, short phrases, input validation
# ================================================================
class TestSpecInputFormats < Minitest::Test
  # 13.1
  def test_13_1_format_date_with_year
    assert_equal 'February 4th, 2018', SayableDate::Formatter.new(SayableDate::Locales::EN).format_date_with_year('2018-02-04')
  end

  # 13.2
  def test_13_2_format_date_with_year
    assert_equal 'Mar 15, 2025', SayableDate::Formatter.new(SayableDate::Locales::EN, compactness: :short).format_date_with_year('2025-03-15')
  end

  # 13.3
  def test_13_3_format_date_with_year
    assert_equal '1/21/97', SayableDate::Formatter.new(SayableDate::Locales::EN, compactness: :compact).format_date_with_year('1997-01-21')
  end

  # 13.4
  def test_13_4_two_digit_year_keeps_its_leading_zero
    assert_equal '20/5/07', SayableDate::Formatter.new(SayableDate::Locales::TG, compactness: :compact).format_date_with_year('2007-05-20')
  end

  # 13.5
  def test_13_5_format_date_with_year
    assert_equal '21. kesäkuuta 1996', SayableDate::Formatter.new(SayableDate::Locales::FI, compactness: :short).format_date_with_year('1996-06-21')
  end

  # 14.1
  def test_14_1_format_date
    assert_equal '15. februára', SayableDate::Formatter.new(SayableDate::Locales::SK, compactness: :short).format_date('2031-02-15')
  end

  # 14.2
  def test_14_2_format_date
    assert_equal '10. prosince', SayableDate::Formatter.new(SayableDate::Locales::CS, compactness: :short).format_date('2025-12-10')
  end

  # 14.3
  def test_14_3_format_date
    assert_equal '5 листопада', SayableDate::Formatter.new(SayableDate::Locales::UK, compactness: :short).format_date('2025-11-05')
  end

  # 14.4
  def test_14_4_format_relative
    assert_equal '8. elokuuta', SayableDate::Formatter.new(SayableDate::Locales::FI, compactness: :short).format_relative('1998-08-08', '1998-08-15')
  end

  # 15.1
  def test_15_1_day_after_tomorrow
    assert_equal 'an Mth ma', SayableDate::Formatter.new(SayableDate::Locales::KW, compactness: :short).format_relative('2035-12-04', '2035-12-02')
  end

  # 15.2
  def test_15_2_day_before_yesterday
    assert_equal 'Dom nchi\'j', SayableDate::Formatter.new(SayableDate::Locales::MAM, compactness: :short).format_relative('2000-01-23', '2000-01-25')
  end

  # 15.3
  def test_15_3_day_after_tomorrow
    assert_equal 'a\'in Vie', SayableDate::Formatter.new(SayableDate::Locales::KEK, compactness: :short).format_relative('2014-10-24', '2014-10-22')
  end

  # 16.1
  def test_16_1_february_30_doesn_t_exist
    assert_nil SayableDate::Formatter.new(SayableDate::Locales::EN).format_date('2025-02-30')
  end

  # 16.2
  def test_16_2_month_thirteen
    assert_nil SayableDate::Formatter.new(SayableDate::Locales::EN).format_date('2025-13-01')
  end

  # 16.3
  def test_16_3_unpadded_month_and_day
    assert_nil SayableDate::Formatter.new(SayableDate::Locales::EN).format_date('2025-6-1')
  end

  # 16.4
  def test_16_4_surrounding_whitespace
    assert_nil SayableDate::Formatter.new(SayableDate::Locales::EN).format_date(' 2025-06-01')
  end

  # 16.5
  def test_16_5_an_iso_datetime_only_the_date_part_is_used
    assert_equal 'June 1st', SayableDate::Formatter.new(SayableDate::Locales::EN).format_date('2025-06-01T10:00:00')
  end

  # 16.6
  def test_16_6_february_29_in_a_non_leap_year
    assert_nil SayableDate::Formatter.new(SayableDate::Locales::EN).format_date_with_year('2023-02-29')
  end

  # 16.7
  def test_16_7_invalid_asof
    assert_nil SayableDate::Formatter.new(SayableDate::Locales::EN).format_relative('2025-03-16', '2025-04-31')
  end
end
