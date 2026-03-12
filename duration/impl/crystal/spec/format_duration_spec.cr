require "spec"
require "../src/sayable_duration"

# All tests use explicit inputs for determinism.
# Canonical test IDs from duration/config/tests.json

# ================================================================
# Section 1: Null / edge cases
# ================================================================
describe "Null / edge cases" do
  # 1.1
  it "returns nil for null seconds" do
    SayableDuration.format_duration(nil).should be_nil
  end

  # 1.2
  it "returns nil for negative seconds" do
    SayableDuration.format_duration(-1).should be_nil
  end

  # 1.3
  it "returns nil when format_since has null start" do
    SayableDuration.format_since(nil, "2025-01-15T10:00:00").should be_nil
  end

  # 1.4
  it "returns nil when format_until has null target" do
    SayableDuration.format_until(nil, "2025-01-15T10:00:00").should be_nil
  end

  # 1.5
  it "returns nil when asOf is before start" do
    SayableDuration.format_since("2025-01-15T10:00:00", "2025-01-15T09:00:00").should be_nil
  end

  # 1.6
  it "returns nil when target is in the past" do
    SayableDuration.format_until("2025-01-15T09:00:00", "2025-01-15T10:00:00").should be_nil
  end
end

# ================================================================
# Section 2: Duration — seconds tier (0-59s)
# ================================================================
describe "Duration — seconds tier" do
  formatter = SayableDuration::Formatter.new(SayableDuration::Locales::EN)

  # 2.1
  it "formats 0 seconds as just now" do
    formatter.format_duration(0).should eq "just now"
  end

  # 2.2
  it "formats 1 second" do
    formatter.format_duration(1).should eq "1 second"
  end

  # 2.3
  it "formats 45 seconds" do
    formatter.format_duration(45).should eq "45 seconds"
  end

  # 2.4
  it "formats 59 seconds" do
    formatter.format_duration(59).should eq "59 seconds"
  end
end

# ================================================================
# Section 3: Duration — minutes + seconds tier (1-4 min)
# ================================================================
describe "Duration — minutes + seconds tier" do
  formatter = SayableDuration::Formatter.new(SayableDuration::Locales::EN)

  # 3.1
  it "formats 60 seconds as 1 minute" do
    formatter.format_duration(60).should eq "1 minute"
  end

  # 3.2
  it "formats 90 seconds as 1 minute, 30 seconds" do
    formatter.format_duration(90).should eq "1 minute, 30 seconds"
  end

  # 3.3
  it "formats 240 seconds as 4 minutes" do
    formatter.format_duration(240).should eq "4 minutes"
  end

  # 3.4
  it "formats 270 seconds as 4 minutes, 30 seconds" do
    formatter.format_duration(270).should eq "4 minutes, 30 seconds"
  end
end

# ================================================================
# Section 4: Duration — minutes tier (5-59 min)
# ================================================================
describe "Duration — minutes tier" do
  formatter = SayableDuration::Formatter.new(SayableDuration::Locales::EN)

  # 4.1
  it "formats 300 seconds as 5 minutes" do
    formatter.format_duration(300).should eq "5 minutes"
  end

  # 4.2
  it "formats 1500 seconds as 25 minutes" do
    formatter.format_duration(1500).should eq "25 minutes"
  end

  # 4.3
  it "formats 3540 seconds as 59 minutes" do
    formatter.format_duration(3540).should eq "59 minutes"
  end
end

# ================================================================
# Section 5: Duration — hours + minutes tier (1-5 hr)
# ================================================================
describe "Duration — hours + minutes tier" do
  formatter = SayableDuration::Formatter.new(SayableDuration::Locales::EN)

  # 5.1
  it "formats 3600 seconds as 1 hour" do
    formatter.format_duration(3600).should eq "1 hour"
  end

  # 5.2
  it "formats 5400 seconds as 1½ hours (half marker)" do
    formatter.format_duration(5400).should eq "1½ hours"
  end

  # 5.3
  it "formats 8100 seconds as 2 hours, 15 minutes" do
    formatter.format_duration(8100).should eq "2 hours, 15 minutes"
  end

  # 5.4
  it "formats 18000 seconds as 5 hours" do
    formatter.format_duration(18000).should eq "5 hours"
  end
end

# ================================================================
# Section 6: Duration — hours tier (6-23 hr)
# ================================================================
describe "Duration — hours tier" do
  formatter = SayableDuration::Formatter.new(SayableDuration::Locales::EN)

  # 6.1
  it "formats 28800 seconds as 8 hours" do
    formatter.format_duration(28800).should eq "8 hours"
  end

  # 6.2
  it "formats 82800 seconds as 23 hours" do
    formatter.format_duration(82800).should eq "23 hours"
  end
end

# ================================================================
# Section 7: Duration — days tier
# ================================================================
describe "Duration — days tier" do
  formatter = SayableDuration::Formatter.new(SayableDuration::Locales::EN)

  # 7.1
  it "formats 86400 seconds as 1 day" do
    formatter.format_duration(86400).should eq "1 day"
  end

  # 7.2
  it "formats 97200 seconds as 1 day, 3 hours" do
    formatter.format_duration(97200).should eq "1 day, 3 hours"
  end

  # 7.3
  it "formats 129600 seconds as 1½ days (half marker)" do
    formatter.format_duration(129600).should eq "1½ days"
  end

  # 7.4
  it "formats 432000 seconds as 5 days" do
    formatter.format_duration(432000).should eq "5 days"
  end

  # 7.5
  it "formats 172800 seconds as 2 days" do
    formatter.format_duration(172800).should eq "2 days"
  end
end

# ================================================================
# Section 8: Duration — weeks tier
# ================================================================
describe "Duration — weeks tier" do
  formatter = SayableDuration::Formatter.new(SayableDuration::Locales::EN)

  # 8.1
  it "formats 604800 seconds as 1 week" do
    formatter.format_duration(604800).should eq "1 week"
  end

  # 8.2
  it "formats 1296000 seconds as 2 weeks, 1 day" do
    formatter.format_duration(1296000).should eq "2 weeks, 1 day"
  end

  # 8.3
  it "formats 2419200 seconds as 4 weeks" do
    formatter.format_duration(2419200).should eq "4 weeks"
  end
end

# ================================================================
# Section 9: Duration — months and years tier
# ================================================================
describe "Duration — months and years tier" do
  formatter = SayableDuration::Formatter.new(SayableDuration::Locales::EN)

  # 9.1
  it "formats ~31 days as 1 month" do
    formatter.format_duration(2678400).should eq "1 month"
  end

  # 9.2
  it "formats ~91 days as 3 months" do
    formatter.format_duration(7884000).should eq "3 months"
  end

  # 9.3
  it "formats 365 days as 1 year" do
    formatter.format_duration(31536000).should eq "1 year"
  end

  # 9.4
  it "formats ~456 days as 1 year, 3 months" do
    formatter.format_duration(39420000).should eq "1 year, 3 months"
  end
end

# ================================================================
# Section 10: Duration from ISO timestamps
# ================================================================
describe "Duration from ISO timestamps" do
  formatter = SayableDuration::Formatter.new(SayableDuration::Locales::EN)

  # 10.1
  it "formats 1.5 hours between timestamps" do
    formatter.format_duration("2025-01-15T10:00:00", "2025-01-15T11:30:00").should eq "1½ hours"
  end

  # 10.2
  it "formats 45 minutes between timestamps" do
    formatter.format_duration("2025-01-15T10:00:00", "2025-01-15T10:45:00").should eq "45 minutes"
  end
end

# ================================================================
# Section 11: Relative time — since
# ================================================================
describe "Relative time — since" do
  formatter = SayableDuration::Formatter.new(SayableDuration::Locales::EN)

  # 11.1
  it "formats just now for zero diff" do
    formatter.format_since("2025-01-15T10:00:00", "2025-01-15T10:00:00").should eq "just now"
  end

  # 11.2
  it "formats 30 seconds ago" do
    formatter.format_since("2025-01-15T10:00:00", "2025-01-15T10:00:30").should eq "30 seconds ago"
  end

  # 11.3
  it "formats 45 minutes ago" do
    formatter.format_since("2025-01-15T10:00:00", "2025-01-15T10:45:00").should eq "45 minutes ago"
  end

  # 11.4
  it "formats 3 hours ago" do
    formatter.format_since("2025-01-15T10:00:00", "2025-01-15T13:00:00").should eq "3 hours ago"
  end
end

# ================================================================
# Section 12: Relative time — until
# ================================================================
describe "Relative time — until" do
  formatter = SayableDuration::Formatter.new(SayableDuration::Locales::EN)

  # 12.1
  it "formats just now for zero diff" do
    formatter.format_until("2025-01-15T10:00:00", "2025-01-15T10:00:00").should eq "just now"
  end

  # 12.2
  it "formats in 20 minutes" do
    formatter.format_until("2025-01-15T10:20:00", "2025-01-15T10:00:00").should eq "in 20 minutes"
  end

  # 12.3
  it "formats in 3 hours" do
    formatter.format_until("2025-01-15T13:00:00", "2025-01-15T10:00:00").should eq "in 3 hours"
  end
end

# ================================================================
# Section 13: Locale — German
# ================================================================
describe "Locale — German" do
  formatter = SayableDuration::Formatter.new(SayableDuration::Locales::DE)

  # 13.1
  it "formats 1 Stunde" do
    formatter.format_duration(3600).should eq "1 Stunde"
  end

  # 13.2
  it "formats vor 5 Minuten" do
    formatter.format_since("2025-01-15T10:00:00", "2025-01-15T10:05:00").should eq "vor 5 Minuten"
  end
end

# ================================================================
# Section 14: Locale — French
# ================================================================
describe "Locale — French" do
  formatter = SayableDuration::Formatter.new(SayableDuration::Locales::FR)

  # 14.1
  it "formats 2 heures" do
    formatter.format_duration(7200).should eq "2 heures"
  end
end

# ================================================================
# Section 15: Locale — Japanese
# ================================================================
describe "Locale — Japanese" do
  formatter = SayableDuration::Formatter.new(SayableDuration::Locales::JA)

  # 15.1
  it "formats 2分" do
    formatter.format_duration(120).should eq "2分"
  end

  # 15.2
  it "formats 1時間前" do
    formatter.format_since("2025-01-15T10:00:00", "2025-01-15T11:00:00").should eq "1時間前"
  end
end

# ================================================================
# Section 16: Short compactness — duration
# ================================================================
describe "Short compactness — duration" do
  formatter = SayableDuration::Formatter.new(SayableDuration::Locales::EN, :short)

  # 16.1
  it "formats 1h" do
    formatter.format_duration(3600).should eq "1h"
  end

  # 16.2
  it "formats 1m, 30s" do
    formatter.format_duration(90).should eq "1m, 30s"
  end
end

# ================================================================
# Section 17: Compact compactness — duration
# ================================================================
describe "Compact compactness — duration" do
  formatter = SayableDuration::Formatter.new(SayableDuration::Locales::EN, :compact)

  # 17.1
  it "formats 1h" do
    formatter.format_duration(3600).should eq "1h"
  end

  # 17.2
  it "formats 1m30s" do
    formatter.format_duration(90).should eq "1m30s"
  end
end
