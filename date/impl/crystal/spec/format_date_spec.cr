require "spec"
require "../src/sayable_date"

# All tests use explicit (date, asOf) pairs for determinism.
# Canonical test IDs from date/config/tests.json

# ================================================================
# Section 1: Null / edge cases
# ================================================================
describe "Null / edge cases" do
  # 1.1
  it "returns nil for null date" do
    SayableDate.format_date(nil).should be_nil
  end

  # 1.2
  it "returns nil for empty string" do
    SayableDate.format_date("").should be_nil
  end

  # 1.3
  it "returns nil for invalid string" do
    SayableDate.format_date("invalid").should be_nil
  end

  # 1.4
  it "returns nil when format_relative has null asOf" do
    SayableDate.format_relative("2025-03-15", nil).should be_nil
  end

  # 1.5
  it "returns nil when format_relative has null date" do
    SayableDate.format_relative(nil, "2025-03-15").should be_nil
  end
end

# ================================================================
# Section 2: format_date — normal compactness (English)
# ================================================================
describe "format_date — normal compactness (English)" do
  formatter = SayableDate::Formatter.new(SayableDate::Locales::EN)

  # 2.1
  it "formats March 15th" do
    formatter.format_date("2025-03-15").should eq "March 15th"
  end

  # 2.2
  it "formats January 1st" do
    formatter.format_date("2025-01-01").should eq "January 1st"
  end

  # 2.3
  it "formats May 22nd" do
    formatter.format_date("2025-05-22").should eq "May 22nd"
  end

  # 2.4
  it "formats July 3rd" do
    formatter.format_date("2025-07-03").should eq "July 3rd"
  end

  # 2.5
  it "formats December 31st" do
    formatter.format_date("2025-12-31").should eq "December 31st"
  end

  # 2.6
  it "formats June 11th" do
    formatter.format_date("2025-06-11").should eq "June 11th"
  end

  # 2.7
  it "handles ISO datetime input" do
    formatter.format_date("2025-03-15T14:30:00").should eq "March 15th"
  end
end

# ================================================================
# Section 3: format_date — short compactness (English)
# ================================================================
describe "format_date — short compactness (English)" do
  formatter = SayableDate::Formatter.new(SayableDate::Locales::EN, :short)

  # 3.1
  it "formats Mar 15" do
    formatter.format_date("2025-03-15").should eq "Mar 15"
  end

  # 3.2
  it "formats Jan 1" do
    formatter.format_date("2025-01-01").should eq "Jan 1"
  end

  # 3.3
  it "formats Dec 25" do
    formatter.format_date("2025-12-25").should eq "Dec 25"
  end
end

# ================================================================
# Section 4: format_date — compact (English)
# ================================================================
describe "format_date — compact (English)" do
  formatter = SayableDate::Formatter.new(SayableDate::Locales::EN, :compact)

  # 4.1
  it "formats 3/15" do
    formatter.format_date("2025-03-15").should eq "3/15"
  end

  # 4.2
  it "formats 1/1" do
    formatter.format_date("2025-01-01").should eq "1/1"
  end
end

# ================================================================
# Section 5: format_relative — proximity tiers (English)
# ================================================================
describe "format_relative — proximity tiers (English)" do
  formatter = SayableDate::Formatter.new(SayableDate::Locales::EN)

  # 5.1
  it "formats today" do
    formatter.format_relative("2025-03-15", "2025-03-15").should eq "today"
  end

  # 5.2
  it "formats tomorrow" do
    formatter.format_relative("2025-03-16", "2025-03-15").should eq "tomorrow"
  end

  # 5.3
  it "formats yesterday" do
    formatter.format_relative("2025-03-14", "2025-03-15").should eq "yesterday"
  end

  # 5.4
  it "formats the day after tomorrow" do
    formatter.format_relative("2025-03-17", "2025-03-15").should eq "the day after tomorrow"
  end

  # 5.5
  it "formats the day before yesterday" do
    formatter.format_relative("2025-03-13", "2025-03-15").should eq "the day before yesterday"
  end

  # 5.6
  it "formats this Wednesday (+4 days)" do
    formatter.format_relative("2025-03-19", "2025-03-15").should eq "this Wednesday"
  end

  # 5.7
  it "formats this Thursday (+5 days)" do
    formatter.format_relative("2025-03-20", "2025-03-15").should eq "this Thursday"
  end

  # 5.8
  it "formats last Tuesday (-4 days)" do
    formatter.format_relative("2025-03-11", "2025-03-15").should eq "last Tuesday"
  end

  # 5.9
  it "formats next Saturday (+7 days)" do
    formatter.format_relative("2025-03-22", "2025-03-15").should eq "next Saturday"
  end

  # 5.10
  it "formats next Thursday (+12 days)" do
    formatter.format_relative("2025-03-27", "2025-03-15").should eq "next Thursday"
  end

  # 5.11
  it "formats calendar fallback for same year (-14 days)" do
    formatter.format_relative("2025-03-01", "2025-03-15").should eq "March 1st"
  end

  # 5.12
  it "formats calendar fallback for same year (+26 days)" do
    formatter.format_relative("2025-04-10", "2025-03-15").should eq "April 10th"
  end

  # 5.13
  it "formats calendar with year for different year" do
    formatter.format_relative("2026-01-05", "2025-03-15").should eq "January 5th, 2026"
  end

  # 5.14
  it "formats calendar with year for past year" do
    formatter.format_relative("2024-12-25", "2025-03-15").should eq "December 25th, 2024"
  end
end

# ================================================================
# Section 6: format_relative — compact skips weekday tiers
# ================================================================
describe "format_relative — compact skips weekday tiers" do
  formatter = SayableDate::Formatter.new(SayableDate::Locales::EN, :compact)

  # 6.1
  it "formats today" do
    formatter.format_relative("2025-03-15", "2025-03-15").should eq "today"
  end

  # 6.2
  it "formats tomorrow" do
    formatter.format_relative("2025-03-16", "2025-03-15").should eq "tomorrow"
  end

  # 6.3
  it "compact goes straight to numeric" do
    formatter.format_relative("2025-03-19", "2025-03-15").should eq "3/19"
  end

  # 6.4
  it "compact different year" do
    formatter.format_relative("2026-01-05", "2025-03-15").should eq "1/5/26"
  end
end

# ================================================================
# Section 7: Locale — German
# ================================================================
describe "Locale — German" do
  formatter = SayableDate::Formatter.new(SayableDate::Locales::DE)

  # 7.1
  it "formats 15. März" do
    formatter.format_date("2025-03-15").should eq "15. März"
  end

  # 7.2
  it "formats morgen" do
    formatter.format_relative("2025-03-16", "2025-03-15").should eq "morgen"
  end

  # 7.3
  it "formats übermorgen" do
    formatter.format_relative("2025-03-17", "2025-03-15").should eq "übermorgen"
  end

  # 7.4
  it "formats diesen Mittwoch" do
    formatter.format_relative("2025-03-19", "2025-03-15").should eq "diesen Mittwoch"
  end
end

# ================================================================
# Section 8: Locale — French
# ================================================================
describe "Locale — French" do
  formatter = SayableDate::Formatter.new(SayableDate::Locales::FR)

  # 8.1
  it "formats 1er mars" do
    formatter.format_date("2025-03-01").should eq "1er mars"
  end

  # 8.2
  it "formats 15 mars" do
    formatter.format_date("2025-03-15").should eq "15 mars"
  end

  # 8.3
  it "formats demain" do
    formatter.format_relative("2025-03-16", "2025-03-15").should eq "demain"
  end
end

# ================================================================
# Section 9: Locale — Japanese
# ================================================================
describe "Locale — Japanese" do
  formatter = SayableDate::Formatter.new(SayableDate::Locales::JA)

  # 9.1
  it "formats 3月15日" do
    formatter.format_date("2025-03-15").should eq "3月15日"
  end

  # 9.2
  it "formats 明日" do
    formatter.format_relative("2025-03-16", "2025-03-15").should eq "明日"
  end

  # 9.3
  it "formats 今度の水曜日" do
    formatter.format_relative("2025-03-19", "2025-03-15").should eq "今度の水曜日"
  end
end

# ================================================================
# Section 10: Locale — Russian (genitive months)
# ================================================================
describe "Locale — Russian" do
  formatter = SayableDate::Formatter.new(SayableDate::Locales::RU)

  # 10.1
  it "formats 15 марта (genitive)" do
    formatter.format_date("2025-03-15").should eq "15 марта"
  end

  # 10.2
  it "formats завтра" do
    formatter.format_relative("2025-03-16", "2025-03-15").should eq "завтра"
  end
end

# ================================================================
# Section 11: Locale — Arabic
# ================================================================
describe "Locale — Arabic" do
  formatter = SayableDate::Formatter.new(SayableDate::Locales::AR)

  # 11.1
  it "formats 15 مارس" do
    formatter.format_date("2025-03-15").should eq "15 مارس"
  end

  # 11.2
  it "formats غداً" do
    formatter.format_relative("2025-03-16", "2025-03-15").should eq "غداً"
  end
end

# ================================================================
# Section 12: Locale — Spanish
# ================================================================
describe "Locale — Spanish" do
  formatter = SayableDate::Formatter.new(SayableDate::Locales::ES)

  # 12.1
  it "formats 15 de marzo" do
    formatter.format_date("2025-03-15").should eq "15 de marzo"
  end

  # 12.2
  it "formats pasado mañana" do
    formatter.format_relative("2025-03-17", "2025-03-15").should eq "pasado mañana"
  end
end

# ================================================================
# Section 13: format_date_with_year
# ================================================================
describe "format_date_with_year" do
  # 13.1
  it "format_date_with_year en normal" do
    SayableDate::Formatter.new(SayableDate::Locales.get("en").not_nil!, :normal).format_date_with_year("2018-02-04").should eq "February 4th, 2018"
  end

  # 13.2
  it "format_date_with_year en short" do
    SayableDate::Formatter.new(SayableDate::Locales.get("en").not_nil!, :short).format_date_with_year("2025-03-15").should eq "Mar 15, 2025"
  end

  # 13.3
  it "format_date_with_year en compact" do
    SayableDate::Formatter.new(SayableDate::Locales.get("en").not_nil!, :compact).format_date_with_year("1997-01-21").should eq "1/21/97"
  end

  # 13.4
  it "two-digit year keeps its leading zero" do
    SayableDate::Formatter.new(SayableDate::Locales.get("tg").not_nil!, :compact).format_date_with_year("2007-05-20").should eq "20/5/07"
  end

  # 13.5
  it "format_date_with_year fi short" do
    SayableDate::Formatter.new(SayableDate::Locales.get("fi").not_nil!, :short).format_date_with_year("1996-06-21").should eq "21. kesäkuuta 1996"
  end
end

# ================================================================
# Section 14: Short month names (locales that keep the full genitive)
# ================================================================
describe "Short month names (locales that keep the full genitive)" do
  # 14.1
  it "format_date sk short" do
    SayableDate::Formatter.new(SayableDate::Locales.get("sk").not_nil!, :short).format_date("2031-02-15").should eq "15. februára"
  end

  # 14.2
  it "format_date cs short" do
    SayableDate::Formatter.new(SayableDate::Locales.get("cs").not_nil!, :short).format_date("2025-12-10").should eq "10. prosince"
  end

  # 14.3
  it "format_date uk short" do
    SayableDate::Formatter.new(SayableDate::Locales.get("uk").not_nil!, :short).format_date("2025-11-05").should eq "5 листопада"
  end

  # 14.4
  it "format_relative fi short" do
    SayableDate::Formatter.new(SayableDate::Locales.get("fi").not_nil!, :short).format_relative("1998-08-08", "1998-08-15").should eq "8. elokuuta"
  end
end

# ================================================================
# Section 15: format_relative — short phrases
# ================================================================
describe "format_relative — short phrases" do
  # 15.1
  it "day after tomorrow" do
    SayableDate::Formatter.new(SayableDate::Locales.get("kw").not_nil!, :short).format_relative("2035-12-04", "2035-12-02").should eq "an Mth ma"
  end

  # 15.2
  it "day before yesterday" do
    SayableDate::Formatter.new(SayableDate::Locales.get("mam").not_nil!, :short).format_relative("2000-01-23", "2000-01-25").should eq "Dom nchi'j"
  end

  # 15.3
  it "day after tomorrow" do
    SayableDate::Formatter.new(SayableDate::Locales.get("kek").not_nil!, :short).format_relative("2014-10-24", "2014-10-22").should eq "a'in Vie"
  end
end

# ================================================================
# Section 16: Input validation
# ================================================================
describe "Input validation" do
  # 16.1
  it "February 30 doesn't exist" do
    SayableDate::Formatter.new(SayableDate::Locales.get("en").not_nil!, :normal).format_date("2025-02-30").should be_nil
  end

  # 16.2
  it "Month 13" do
    SayableDate::Formatter.new(SayableDate::Locales.get("en").not_nil!, :normal).format_date("2025-13-01").should be_nil
  end

  # 16.3
  it "Unpadded month and day" do
    SayableDate::Formatter.new(SayableDate::Locales.get("en").not_nil!, :normal).format_date("2025-6-1").should be_nil
  end

  # 16.4
  it "Surrounding whitespace" do
    SayableDate::Formatter.new(SayableDate::Locales.get("en").not_nil!, :normal).format_date(" 2025-06-01").should be_nil
  end

  # 16.5
  it "An ISO datetime: only the date part is used" do
    SayableDate::Formatter.new(SayableDate::Locales.get("en").not_nil!, :normal).format_date("2025-06-01T10:00:00").should eq "June 1st"
  end

  # 16.6
  it "February 29 in a non-leap year" do
    SayableDate::Formatter.new(SayableDate::Locales.get("en").not_nil!, :normal).format_date_with_year("2023-02-29").should be_nil
  end

  # 16.7
  it "Invalid asOf" do
    SayableDate::Formatter.new(SayableDate::Locales.get("en").not_nil!, :normal).format_relative("2025-03-16", "2025-04-31").should be_nil
  end
end
