require "spec"
require "../src/sayable_time"

# All tests use explicit inputs for determinism.
# Canonical test IDs from time/config/tests.json

# ================================================================
# Section 1: Null / edge cases
# ================================================================
describe "Null / edge cases" do
  # 1.1
  it "returns nil for null input" do
    SayableTime.format_time(nil).should be_nil
  end

  # 1.2
  it "returns nil for empty string" do
    SayableTime.format_time("").should be_nil
  end

  # 1.3
  it "returns nil for invalid string" do
    SayableTime.format_time("invalid").should be_nil
  end

  # 1.4
  it "returns nil for out-of-range hour" do
    SayableTime.format_time("25:00").should be_nil
  end
end

# ================================================================
# Section 2: Clock time (normal compactness)
# ================================================================
describe "Clock time — normal compactness" do
  formatter = SayableTime::Formatter.new(SayableTime::Locales::EN)

  # 2.1
  it "formats midnight" do
    formatter.format_time("00:00").should eq "midnight"
  end

  # 2.2
  it "formats noon" do
    formatter.format_time("12:00").should eq "noon"
  end

  # 2.3
  it "formats three o'clock" do
    formatter.format_time("15:00").should eq "three o'clock"
  end

  # 2.4
  it "formats a quarter past two" do
    formatter.format_time("14:15").should eq "a quarter past two"
  end

  # 2.5
  it "formats half past nine" do
    formatter.format_time("09:30").should eq "half past nine"
  end

  # 2.6
  it "formats a quarter to eleven" do
    formatter.format_time("10:45").should eq "a quarter to eleven"
  end

  # 2.7
  it "formats five past eight" do
    formatter.format_time("08:05").should eq "five past eight"
  end

  # 2.8
  it "formats five to five" do
    formatter.format_time("16:55").should eq "five to five"
  end

  # 2.9
  it "rounds 23:58 to midnight" do
    formatter.format_time("23:58").should eq "midnight"
  end

  # 2.10
  it "rounds 07:22 to twenty past seven" do
    formatter.format_time("07:22").should eq "twenty past seven"
  end

  # 2.11
  it "handles ISO datetime input" do
    formatter.format_time("2025-01-15T14:15:00").should eq "a quarter past two"
  end
end

# ================================================================
# Section 3: Clock time (short compactness)
# ================================================================
describe "Clock time — short compactness" do
  formatter = SayableTime::Formatter.new(SayableTime::Locales::EN, :short)

  # 3.1
  it "formats 14:15 as 2:15 PM" do
    formatter.format_time("14:15").should eq "2:15 PM"
  end

  # 3.2
  it "formats 09:30 as 9:30 AM" do
    formatter.format_time("09:30").should eq "9:30 AM"
  end

  # 3.3
  it "formats 00:00 as 12:00 AM" do
    formatter.format_time("00:00").should eq "12:00 AM"
  end

  # 3.4
  it "formats 12:00 as 12:00 PM" do
    formatter.format_time("12:00").should eq "12:00 PM"
  end
end

# ================================================================
# Section 4: Clock time (compact)
# ================================================================
describe "Clock time — compact" do
  formatter = SayableTime::Formatter.new(SayableTime::Locales::EN, :compact)

  # 4.1
  it "formats 14:15 as 2:15p" do
    formatter.format_time("14:15").should eq "2:15p"
  end

  # 4.2
  it "formats 09:30 as 9:30a" do
    formatter.format_time("09:30").should eq "9:30a"
  end
end

# ================================================================
# Section 5: Locale — German
# ================================================================
describe "Locale — German" do
  formatter = SayableTime::Formatter.new(SayableTime::Locales::DE)

  # 5.1
  it "formats 15:30 as halb vier" do
    formatter.format_time("15:30").should eq "halb vier"
  end
end

# ================================================================
# Section 6: Locale — French
# ================================================================
describe "Locale — French" do
  formatter = SayableTime::Formatter.new(SayableTime::Locales::FR)

  # 6.1
  it "formats 15:15 as trois heures et quart" do
    formatter.format_time("15:15").should eq "trois heures et quart"
  end

  # 6.2
  it "formats 13:00 as une heure" do
    formatter.format_time("13:00").should eq "une heure"
  end

  # 6.3
  it "formats 13:30 as une heure et demie" do
    formatter.format_time("13:30").should eq "une heure et demie"
  end

  # 6.4
  it "formats 14:45 as trois heures moins le quart" do
    formatter.format_time("14:45").should eq "trois heures moins le quart"
  end

  # 6.5
  it "formats 14:50 as trois heures moins dix" do
    formatter.format_time("14:50").should eq "trois heures moins dix"
  end
end

# ================================================================
# Section 7: Locale — Japanese
# ================================================================
describe "Locale — Japanese" do
  formatter = SayableTime::Formatter.new(SayableTime::Locales::JA)

  # 7.1
  it "formats 15:30 as 三時半" do
    formatter.format_time("15:30").should eq "三時半"
  end
end

# ================================================================
# Section 8: Locale — Finnish (dot separator, short)
# ================================================================
describe "Locale — Finnish (dot separator, short)" do
  formatter = SayableTime::Formatter.new(SayableTime::Locales::FI, :short)

  # 8.1
  it "formats 14:15 as 14.15" do
    formatter.format_time("14:15").should eq "14.15"
  end

  # 8.2
  it "formats 00:00 as 0.00" do
    formatter.format_time("00:00").should eq "0.00"
  end
end

# ================================================================
# Section 9: Minutes in short and compact modes
# ================================================================
describe "Minutes in short and compact modes" do
  # 9.1
  it "digital modes keep the exact minute" do
    SayableTime::Formatter.new(SayableTime::Locales.get("en").not_nil!, :short).format_time("18:01").should eq "6:01 PM"
  end

  # 9.2
  it "digital modes keep the exact minute" do
    SayableTime::Formatter.new(SayableTime::Locales.get("en").not_nil!, :compact).format_time("19:05").should eq "7:05p"
  end
end

# ================================================================
# Section 10: Input validation
# ================================================================
describe "Input validation" do
  # 10.1
  it "one-digit hour" do
    SayableTime::Formatter.new(SayableTime::Locales.get("en").not_nil!, :normal).format_time("9:30").should eq "half past nine"
  end

  # 10.2
  it "two-digit hour" do
    SayableTime::Formatter.new(SayableTime::Locales.get("en").not_nil!, :normal).format_time("09:30").should eq "half past nine"
  end

  # 10.3
  it "leading whitespace" do
    SayableTime::Formatter.new(SayableTime::Locales.get("en").not_nil!, :normal).format_time(" 9:30").should be_nil
  end

  # 10.4
  it "trailing whitespace" do
    SayableTime::Formatter.new(SayableTime::Locales.get("en").not_nil!, :normal).format_time("9:30 ").should be_nil
  end

  # 10.5
  it "minutes need two digits" do
    SayableTime::Formatter.new(SayableTime::Locales.get("en").not_nil!, :normal).format_time("9:5").should be_nil
  end

  # 10.6
  it "hour out of range" do
    SayableTime::Formatter.new(SayableTime::Locales.get("en").not_nil!, :normal).format_time("24:00").should be_nil
  end

  # 10.7
  it "seconds are allowed and ignored" do
    SayableTime::Formatter.new(SayableTime::Locales.get("en").not_nil!, :normal).format_time("14:15:30").should eq "a quarter past two"
  end

  # 10.8
  it "ISO datetime with zone suffix (ignored)" do
    SayableTime::Formatter.new(SayableTime::Locales.get("en").not_nil!, :normal).format_time("2025-01-15T14:15:00Z").should eq "a quarter past two"
  end

  # 10.9
  it "ISO datetime with an impossible date" do
    SayableTime::Formatter.new(SayableTime::Locales.get("en").not_nil!, :normal).format_time("2025-02-30T14:15:00").should be_nil
  end
end
