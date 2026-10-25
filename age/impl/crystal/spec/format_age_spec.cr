require "spec"
require "../src/sayable_age"

# All tests use explicit (dateOfBirth, asOf) pairs for determinism.
# Canonical test IDs from age/config/tests.json

# Helper: weeks_pattern tests check that the output is in weeks+days format
# (i.e. contains "week" somewhere in the result).
def assert_weeks_pattern(result : String?)
  result.should_not be_nil
  result.not_nil!.should match(/week/)
end

# ================================================================
# Section 1: Null / edge cases
# ================================================================
describe "Null / edge cases" do
  # 1.1
  it "returns nil for null dateOfBirth" do
    SayableAge.format_age(nil).should be_nil
  end

  # 1.3
  it "returns nil for empty string" do
    SayableAge.format_age("").should be_nil
  end

  # 1.4
  it "returns nil for future DOB" do
    SayableAge.format_age("2025-07-01", "2025-06-15").should be_nil
  end

  # 1.5
  it "formats exactly 500 years" do
    SayableAge.format_age("1525-06-15", "2025-06-15").should eq "500 years"
  end

  # 1.6
  it "returns nil for 501 years" do
    SayableAge.format_age("1524-06-15", "2025-06-15").should be_nil
  end

  # 1.7
  it "returns nil for 1000 years" do
    SayableAge.format_age("1025-06-15", "2025-06-15").should be_nil
  end
end

# ================================================================
# Section 2: Days tier (0-6 days)
# ================================================================
describe "Days tier" do
  formatter = SayableAge::Formatter.new(SayableAge::Locales::EN)

  # 2.1
  it "formats 0 days as Newborn" do
    formatter.format_age("2025-06-15", "2025-06-15").should eq "Newborn"
  end

  # 2.2
  it "formats 1 day (singular)" do
    formatter.format_age("2025-06-14", "2025-06-15").should eq "1 day"
  end

  # 2.3
  it "formats 3 days (plural)" do
    formatter.format_age("2025-06-12", "2025-06-15").should eq "3 days"
  end

  # 2.4
  it "formats 6 days (max before weeks)" do
    formatter.format_age("2025-06-09", "2025-06-15").should eq "6 days"
  end

  # 2.5
  it "formats 7 days as 1 week" do
    formatter.format_age("2025-06-08", "2025-06-15").should eq "1 week"
  end
end

# ================================================================
# Section 3: Weeks+days tier (7 days to <3 calendar months)
# ================================================================
describe "Weeks+days tier" do
  formatter = SayableAge::Formatter.new(SayableAge::Locales::EN)

  # 3.1
  it "formats 7 days as 1 week" do
    formatter.format_age("2025-06-08", "2025-06-15").should eq "1 week"
  end

  # 3.2
  it "formats 8 days as 1 week, 1 day" do
    formatter.format_age("2025-06-07", "2025-06-15").should eq "1 week, 1 day"
  end

  # 3.3
  it "formats 9 days as 1 week, 2 days" do
    formatter.format_age("2025-06-06", "2025-06-15").should eq "1 week, 2 days"
  end

  # 3.4
  it "formats 13 days as 1 week, 6 days" do
    formatter.format_age("2025-06-02", "2025-06-15").should eq "1 week, 6 days"
  end

  # 3.5
  it "formats 14 days as 2 weeks" do
    formatter.format_age("2025-06-01", "2025-06-15").should eq "2 weeks"
  end

  # 3.6
  it "formats 15 days as 2 weeks, 1 day" do
    formatter.format_age("2025-05-31", "2025-06-15").should eq "2 weeks, 1 day"
  end

  # 3.7
  it "formats 20 days as 2 weeks, 6 days" do
    formatter.format_age("2025-05-26", "2025-06-15").should eq "2 weeks, 6 days"
  end

  # 3.8
  it "formats 21 days as 3 weeks" do
    formatter.format_age("2025-05-25", "2025-06-15").should eq "3 weeks"
  end

  # 3.9
  it "formats 1 calendar month as 4 weeks, 3 days" do
    formatter.format_age("2025-05-15", "2025-06-15").should eq "4 weeks, 3 days"
  end

  # 3.10
  it "formats 2 calendar months as 8 weeks, 5 days" do
    formatter.format_age("2025-04-15", "2025-06-15").should eq "8 weeks, 5 days"
  end

  # 3.11
  it "formats day before 3-month birthday as 13 weeks" do
    formatter.format_age("2025-03-15", "2025-06-14").should eq "13 weeks"
  end

  # 3.12
  it "formats exactly 3 months as transition" do
    formatter.format_age("2025-03-15", "2025-06-15").should eq "3 months"
  end
end

# ================================================================
# Section 4: Month boundaries — standard months
# ================================================================
describe "Month boundaries — standard months" do
  formatter = SayableAge::Formatter.new(SayableAge::Locales::EN)

  # 4.1
  it "formats standard 3-month boundary" do
    formatter.format_age("2025-01-01", "2025-04-01").should eq "3 months"
  end

  # 4.2
  it "not yet 3 months" do
    assert_weeks_pattern(formatter.format_age("2025-01-01", "2025-03-31"))
  end

  # 4.3
  it "mid-month boundary" do
    formatter.format_age("2025-06-15", "2025-09-15").should eq "3 months"
  end

  # 4.4
  it "day before 3-month mark" do
    assert_weeks_pattern(formatter.format_age("2025-06-15", "2025-09-14"))
  end

  # 4.5
  it "6 months" do
    formatter.format_age("2025-06-15", "2025-12-15").should eq "6 months"
  end
end

# ================================================================
# Section 5: Month boundaries — February non-leap year
# ================================================================
describe "Month boundaries — February non-leap year" do
  formatter = SayableAge::Formatter.new(SayableAge::Locales::EN)

  # 5.1
  it "1 cal month clamped to Feb 28" do
    formatter.format_age("2025-01-31", "2025-02-28").should eq "4 weeks"
  end

  # 5.2
  it "3 months with Apr clamp" do
    formatter.format_age("2025-01-31", "2025-04-30").should eq "3 months"
  end

  # 5.3
  it "day before 3-month mark" do
    assert_weeks_pattern(formatter.format_age("2025-01-31", "2025-04-29"))
  end

  # 5.4
  it "standard 3-month from Feb" do
    formatter.format_age("2025-02-01", "2025-05-01").should eq "3 months"
  end

  # 5.5
  it "day before 3 months from Feb" do
    assert_weeks_pattern(formatter.format_age("2025-02-01", "2025-04-30"))
  end
end

# ================================================================
# Section 6: Month boundaries — February leap year
# ================================================================
describe "Month boundaries — February leap year" do
  formatter = SayableAge::Formatter.new(SayableAge::Locales::EN)

  # 6.1
  it "leap year Feb 29" do
    formatter.format_age("2024-01-31", "2024-02-29").should eq "4 weeks, 1 day"
  end

  # 6.2
  it "28 days" do
    formatter.format_age("2024-01-31", "2024-02-28").should eq "4 weeks"
  end

  # 6.3
  it "3 months with Apr clamp" do
    formatter.format_age("2024-01-31", "2024-04-30").should eq "3 months"
  end

  # 6.4
  it "1 month clamped to 29" do
    assert_weeks_pattern(formatter.format_age("2024-01-30", "2024-02-29"))
  end

  # 6.5
  it "not yet 1 month" do
    assert_weeks_pattern(formatter.format_age("2024-01-30", "2024-02-28"))
  end
end

# ================================================================
# Section 7: Month boundaries — 30-day months
# ================================================================
describe "Month boundaries — 30-day months" do
  formatter = SayableAge::Formatter.new(SayableAge::Locales::EN)

  # 7.1
  it "Jun 30 is 3mo clamped from 31" do
    formatter.format_age("2025-03-31", "2025-06-30").should eq "3 months"
  end

  # 7.2
  it "day before 3-month mark" do
    assert_weeks_pattern(formatter.format_age("2025-03-31", "2025-06-29"))
  end

  # 7.3
  it "Nov 30 is 3mo clamped from 31" do
    formatter.format_age("2025-08-31", "2025-11-30").should eq "3 months"
  end

  # 7.4
  it "day before 3-month mark" do
    assert_weeks_pattern(formatter.format_age("2025-08-31", "2025-11-29"))
  end
end

# ================================================================
# Section 8: Month boundaries — leap year baby (born Feb 29)
# ================================================================
describe "Month boundaries — leap year baby" do
  formatter = SayableAge::Formatter.new(SayableAge::Locales::EN)

  # 8.1
  it "3 months from Feb 29" do
    formatter.format_age("2024-02-29", "2024-05-29").should eq "3 months"
  end

  # 8.2
  it "day before 3 months" do
    assert_weeks_pattern(formatter.format_age("2024-02-29", "2024-05-28"))
  end

  # 8.3
  it "non-leap: birthday clamps to 28" do
    formatter.format_age("2024-02-29", "2025-02-28").should eq "12 months"
  end

  # 8.4
  it "day after clamped birthday" do
    formatter.format_age("2024-02-29", "2025-03-01").should eq "12 months"
  end
end

# ================================================================
# Section 9: Months tier (3-23 months)
# ================================================================
describe "Months tier" do
  formatter = SayableAge::Formatter.new(SayableAge::Locales::EN)

  # 9.1
  it "transition point 3 months" do
    formatter.format_age("2025-01-15", "2025-04-15").should eq "3 months"
  end

  # 9.2
  it "6 months" do
    formatter.format_age("2025-01-15", "2025-07-15").should eq "6 months"
  end

  # 9.3
  it "12 months (not 1 year)" do
    formatter.format_age("2024-06-15", "2025-06-15").should eq "12 months"
  end

  # 9.4
  it "23 months upper boundary" do
    formatter.format_age("2024-01-15", "2025-12-15").should eq "23 months"
  end

  # 9.5
  it "day before boundary is 5 months" do
    formatter.format_age("2025-01-15", "2025-07-14").should eq "5 months"
  end

  # 9.6
  it "cross-year boundary 5 months" do
    formatter.format_age("2024-11-10", "2025-04-10").should eq "5 months"
  end
end

# ================================================================
# Section 10: Years+months tier (24-35 months)
# ================================================================
describe "Years+months tier" do
  formatter = SayableAge::Formatter.new(SayableAge::Locales::EN)

  # 10.1
  it "exactly 24 months = 2 years" do
    formatter.format_age("2023-06-15", "2025-06-15").should eq "2 years"
  end

  # 10.2
  it "singular month: 2 years, 1 month" do
    formatter.format_age("2023-06-15", "2025-07-15").should eq "2 years, 1 month"
  end

  # 10.3
  it "2 years, 6 months" do
    formatter.format_age("2023-06-15", "2025-12-15").should eq "2 years, 6 months"
  end

  # 10.4
  it "upper boundary: 2 years, 11 months" do
    formatter.format_age("2023-06-15", "2026-05-15").should eq "2 years, 11 months"
  end

  # 10.5
  it "day before 24 months is 23 months" do
    formatter.format_age("2023-06-15", "2025-06-14").should eq "23 months"
  end
end

# ================================================================
# Section 11: Half-year tier (3-6 years)
# ================================================================
describe "Half-year tier" do
  formatter = SayableAge::Formatter.new(SayableAge::Locales::EN)

  # 11.1
  it "exactly 3 years" do
    formatter.format_age("2022-06-15", "2025-06-15").should eq "3 years"
  end

  # 11.2
  it "3y5m (under half)" do
    formatter.format_age("2022-06-15", "2025-11-15").should eq "3 years"
  end

  # 11.3
  it "3y6m = 3½ years" do
    formatter.format_age("2022-06-15", "2025-12-15").should eq "3½ years"
  end

  # 11.4
  it "3y11m = 3½ years" do
    formatter.format_age("2022-06-15", "2026-05-15").should eq "3½ years"
  end

  # 11.5
  it "exactly 4 years" do
    formatter.format_age("2021-06-15", "2025-06-15").should eq "4 years"
  end

  # 11.6
  it "4y6m = 4½ years" do
    formatter.format_age("2021-06-15", "2025-12-15").should eq "4½ years"
  end

  # 11.7
  it "exactly 5 years" do
    formatter.format_age("2020-06-15", "2025-06-15").should eq "5 years"
  end

  # 11.8
  it "5y8m = 5½ years" do
    formatter.format_age("2020-06-15", "2026-02-15").should eq "5½ years"
  end

  # 11.9
  it "exactly 6 years" do
    formatter.format_age("2019-06-15", "2025-06-15").should eq "6 years"
  end

  # 11.10
  it "6y6m = 6½ years" do
    formatter.format_age("2019-06-15", "2025-12-15").should eq "6½ years"
  end

  # 11.11
  it "6y11m = 6½ years" do
    formatter.format_age("2019-06-15", "2026-05-15").should eq "6½ years"
  end

  # 11.12
  it "day before 3rd birthday = 2 years, 11 months" do
    formatter.format_age("2022-06-15", "2025-06-14").should eq "2 years, 11 months"
  end
end

# ================================================================
# Section 12: Integer tier (7+ years)
# ================================================================
describe "Integer tier" do
  formatter = SayableAge::Formatter.new(SayableAge::Locales::EN)

  # 12.1
  it "exactly 7 years" do
    formatter.format_age("2018-06-15", "2025-06-15").should eq "7 years"
  end

  # 12.2
  it "7y3m — no ½ at 7+" do
    formatter.format_age("2018-03-20", "2025-06-15").should eq "7 years"
  end

  # 12.3
  it "adult 45 years" do
    formatter.format_age("1980-01-01", "2025-06-15").should eq "45 years"
  end
end

# ================================================================
# Section 13: Cross-year transitions with February
# ================================================================
describe "Cross-year transitions with February" do
  formatter = SayableAge::Formatter.new(SayableAge::Locales::EN)

  # 13.1
  it "Dec→Jan→Feb(28)→Mar" do
    formatter.format_age("2024-12-31", "2025-03-31").should eq "3 months"
  end

  # 13.2
  it "day before 3mo from Dec 31" do
    assert_weeks_pattern(formatter.format_age("2024-12-31", "2025-03-30"))
  end

  # 13.3
  it "Nov→Dec→Jan→Feb(28 clamp)" do
    formatter.format_age("2024-11-30", "2025-02-28").should eq "3 months"
  end

  # 13.4
  it "day before 3mo from Nov 30" do
    assert_weeks_pattern(formatter.format_age("2024-11-30", "2025-02-27"))
  end
end

# ================================================================
# Section 14: Born-on-31st progression
# ================================================================
describe "Born-on-31st progression" do
  formatter = SayableAge::Formatter.new(SayableAge::Locales::EN)

  # 14.1
  it "Apr clamp" do
    formatter.format_age("2025-01-31", "2025-04-30").should eq "3 months"
  end

  # 14.2
  it "May has 31" do
    formatter.format_age("2025-01-31", "2025-05-31").should eq "4 months"
  end

  # 14.3
  it "Jun clamp" do
    formatter.format_age("2025-01-31", "2025-06-30").should eq "5 months"
  end

  # 14.4
  it "before Jul 31" do
    formatter.format_age("2025-01-31", "2025-07-01").should eq "5 months"
  end

  # 14.5
  it "Jul has 31" do
    formatter.format_age("2025-01-31", "2025-07-31").should eq "6 months"
  end
end

# ================================================================
# Section 15: Default asOf (current date)
# ================================================================
# Skipping 15.1 and 15.2 — they require mocking the system clock.
# Crystal's Time.local cannot be trivially stubbed in spec.
# The formatter's parse_age uses as_of parameter when provided,
# which is tested thoroughly by all other sections.

# ================================================================
# Section 16: formatStage — null / edge cases
# ================================================================
describe "formatStage — null / edge cases" do
  # 16.1
  it "returns nil for null dateOfBirth" do
    SayableAge.format_stage(nil).should be_nil
  end

  # 16.3
  it "returns nil for empty string" do
    SayableAge.format_stage("").should be_nil
  end

  # 16.4
  it "returns nil for future DOB" do
    SayableAge.format_stage("2025-07-01", "2025-06-15").should be_nil
  end

  # 16.5
  it "formats exactly 500 years as Adult" do
    SayableAge.format_stage("1525-06-15", "2025-06-15").should eq "Adult"
  end

  # 16.6
  it "returns nil for 501 years" do
    SayableAge.format_stage("1524-06-15", "2025-06-15").should be_nil
  end
end

# ================================================================
# Section 17: formatStage — Newborn (0-1 months)
# ================================================================
describe "formatStage — Newborn" do
  formatter = SayableAge::Formatter.new(SayableAge::Locales::EN)

  # 17.1
  it "born today" do
    formatter.format_stage("2025-06-15", "2025-06-15").should eq "Newborn"
  end

  # 17.2
  it "1 day" do
    formatter.format_stage("2025-06-14", "2025-06-15").should eq "Newborn"
  end

  # 17.3
  it "3 weeks" do
    formatter.format_stage("2025-05-25", "2025-06-15").should eq "Newborn"
  end

  # 17.4
  it "1 month" do
    formatter.format_stage("2025-05-15", "2025-06-15").should eq "Newborn"
  end

  # 17.5
  it "1 month 29 days" do
    formatter.format_stage("2025-04-16", "2025-06-15").should eq "Newborn"
  end

  # 17.6
  it "exactly 2 months = transition to Infant" do
    formatter.format_stage("2025-04-15", "2025-06-15").should eq "Infant"
  end
end

# ================================================================
# Section 18: formatStage — Infant (2-11 months)
# ================================================================
describe "formatStage — Infant" do
  formatter = SayableAge::Formatter.new(SayableAge::Locales::EN)

  # 18.1
  it "2 months" do
    formatter.format_stage("2025-04-15", "2025-06-15").should eq "Infant"
  end

  # 18.2
  it "6 months" do
    formatter.format_stage("2024-12-15", "2025-06-15").should eq "Infant"
  end

  # 18.3
  it "11 months" do
    formatter.format_stage("2024-07-15", "2025-06-15").should eq "Infant"
  end

  # 18.4
  it "12 months = transition to Toddler" do
    formatter.format_stage("2024-06-15", "2025-06-15").should eq "Toddler"
  end
end

# ================================================================
# Section 19: formatStage — Toddler (12-35 months)
# ================================================================
describe "formatStage — Toddler" do
  formatter = SayableAge::Formatter.new(SayableAge::Locales::EN)

  # 19.1
  it "12 months" do
    formatter.format_stage("2024-06-15", "2025-06-15").should eq "Toddler"
  end

  # 19.2
  it "18 months" do
    formatter.format_stage("2024-01-15", "2025-07-15").should eq "Toddler"
  end

  # 19.3
  it "24 months" do
    formatter.format_stage("2023-06-15", "2025-06-15").should eq "Toddler"
  end

  # 19.4
  it "35 months" do
    formatter.format_stage("2023-06-15", "2026-05-15").should eq "Toddler"
  end

  # 19.5
  it "36 months = transition to Child" do
    formatter.format_stage("2022-06-15", "2025-06-15").should eq "Child"
  end
end

# ================================================================
# Section 20: formatStage — Child (36-155 months)
# ================================================================
describe "formatStage — Child" do
  formatter = SayableAge::Formatter.new(SayableAge::Locales::EN)

  # 20.1
  it "3 years" do
    formatter.format_stage("2022-06-15", "2025-06-15").should eq "Child"
  end

  # 20.2
  it "4 years" do
    formatter.format_stage("2021-06-15", "2025-06-15").should eq "Child"
  end

  # 20.3
  it "6 years" do
    formatter.format_stage("2019-06-15", "2025-06-15").should eq "Child"
  end

  # 20.4
  it "9 years" do
    formatter.format_stage("2016-06-15", "2025-06-15").should eq "Child"
  end

  # 20.5
  it "12y11m" do
    formatter.format_stage("2013-06-15", "2026-05-15").should eq "Child"
  end

  # 20.6
  it "13 years = transition to Teenager" do
    formatter.format_stage("2012-06-15", "2025-06-15").should eq "Teenager"
  end
end

# ================================================================
# Section 21: formatStage — Teenager (156-215 months)
# ================================================================
describe "formatStage — Teenager" do
  formatter = SayableAge::Formatter.new(SayableAge::Locales::EN)

  # 21.1
  it "13 years" do
    formatter.format_stage("2012-06-15", "2025-06-15").should eq "Teenager"
  end

  # 21.2
  it "15 years" do
    formatter.format_stage("2010-06-15", "2025-06-15").should eq "Teenager"
  end

  # 21.3
  it "17y11m" do
    formatter.format_stage("2008-06-15", "2026-05-15").should eq "Teenager"
  end

  # 21.4
  it "18 years = transition to Adult" do
    formatter.format_stage("2007-06-15", "2025-06-15").should eq "Adult"
  end
end

# ================================================================
# Section 22: formatStage — Adult (216+ months)
# ================================================================
describe "formatStage — Adult" do
  formatter = SayableAge::Formatter.new(SayableAge::Locales::EN)

  # 22.1
  it "18 years" do
    formatter.format_stage("2007-06-15", "2025-06-15").should eq "Adult"
  end

  # 22.2
  it "25 years" do
    formatter.format_stage("2000-06-15", "2025-06-15").should eq "Adult"
  end

  # 22.3
  it "45 years" do
    formatter.format_stage("1980-01-01", "2025-06-15").should eq "Adult"
  end
end

# ================================================================
# Section 23: formatStage — default asOf
# ================================================================
# Skipping 23.1-23.3 — they require mocking the system clock.

# ================================================================
# Section 24: SayableAge class — English locale delegation
# ================================================================
describe "SayableAge class — English locale delegation" do
  formatter = SayableAge::Formatter.new(SayableAge::Locales::EN)

  # 24.1
  it "formatAge: Newborn" do
    formatter.format_age("2025-06-15", "2025-06-15").should eq "Newborn"
  end

  # 24.2
  it "formatAge: 3 days" do
    formatter.format_age("2025-06-12", "2025-06-15").should eq "3 days"
  end

  # 24.3
  it "formatAge: 1 week, 1 day" do
    formatter.format_age("2025-06-07", "2025-06-15").should eq "1 week, 1 day"
  end

  # 24.4
  it "formatAge: 6 months" do
    formatter.format_age("2025-01-15", "2025-07-15").should eq "6 months"
  end

  # 24.5
  it "formatAge: 2 years, 1 month" do
    formatter.format_age("2023-06-15", "2025-07-15").should eq "2 years, 1 month"
  end

  # 24.6
  it "formatAge: 3½ years" do
    formatter.format_age("2022-06-15", "2025-12-15").should eq "3½ years"
  end

  # 24.7
  it "formatAge: 7 years" do
    formatter.format_age("2018-06-15", "2025-06-15").should eq "7 years"
  end

  # 24.8
  it "formatStage: Newborn" do
    formatter.format_stage("2025-06-15", "2025-06-15").should eq "Newborn"
  end

  # 24.9
  it "formatStage: Infant" do
    formatter.format_stage("2025-01-15", "2025-06-15").should eq "Infant"
  end

  # 24.10
  it "formatStage: Toddler" do
    formatter.format_stage("2024-06-15", "2025-06-15").should eq "Toddler"
  end

  # 24.11
  it "formatStage: Child" do
    formatter.format_stage("2022-06-15", "2025-06-15").should eq "Child"
  end

  # 24.12
  it "formatStage: Teenager" do
    formatter.format_stage("2012-06-15", "2025-06-15").should eq "Teenager"
  end

  # 24.13
  it "formatStage: Adult" do
    formatter.format_stage("2007-06-15", "2025-06-15").should eq "Adult"
  end

  # 24.14
  it "formatAge: null" do
    formatter.format_age(nil, "2025-06-15").should be_nil
  end

  # 24.15
  it "formatStage: null" do
    formatter.format_stage(nil, "2025-06-15").should be_nil
  end
end

# ================================================================
# Section 25: i18n — Spanish locale
# ================================================================
describe "i18n — Spanish locale" do
  formatter = SayableAge::Formatter.new(SayableAge::Locales::ES)

  # 25.1
  it "justBorn" do
    formatter.format_age("2025-06-15", "2025-06-15").should eq "Recién nacido"
  end

  # 25.2
  it "singular day" do
    formatter.format_age("2025-06-14", "2025-06-15").should eq "1 día"
  end

  # 25.3
  it "plural days" do
    formatter.format_age("2025-06-12", "2025-06-15").should eq "3 días"
  end

  # 25.4
  it "singular week" do
    formatter.format_age("2025-06-08", "2025-06-15").should eq "1 semana"
  end

  # 25.5
  it "compound: 1 semana, 1 día" do
    formatter.format_age("2025-06-07", "2025-06-15").should eq "1 semana, 1 día"
  end

  # 25.6
  it "plural compound" do
    formatter.format_age("2025-05-26", "2025-06-15").should eq "2 semanas, 6 días"
  end

  # 25.7
  it "months" do
    formatter.format_age("2025-01-15", "2025-07-15").should eq "6 meses"
  end

  # 25.8
  it "singular month" do
    formatter.format_age("2023-06-15", "2025-07-15").should eq "2 años, 1 mes"
  end

  # 25.9
  it "years+months" do
    formatter.format_age("2023-06-15", "2025-12-15").should eq "2 años, 6 meses"
  end

  # 25.10
  it "half marker" do
    formatter.format_age("2022-06-15", "2025-12-15").should eq "3 y medio años"
  end

  # 25.11
  it "no half" do
    formatter.format_age("2022-06-15", "2025-06-15").should eq "3 años"
  end

  # 25.12
  it "7+ years" do
    formatter.format_age("2018-06-15", "2025-06-15").should eq "7 años"
  end

  # 25.13
  it "stage: Recién nacido" do
    formatter.format_stage("2025-06-15", "2025-06-15").should eq "Recién nacido"
  end

  # 25.14
  it "stage: Bebé" do
    formatter.format_stage("2025-01-15", "2025-06-15").should eq "Bebé"
  end

  # 25.15
  it "stage: Niño pequeño" do
    formatter.format_stage("2024-06-15", "2025-06-15").should eq "Niño pequeño"
  end

  # 25.16
  it "stage: Niño" do
    formatter.format_stage("2022-06-15", "2025-06-15").should eq "Niño"
  end

  # 25.17
  it "stage: Adolescente" do
    formatter.format_stage("2012-06-15", "2025-06-15").should eq "Adolescente"
  end

  # 25.18
  it "stage: Adulto" do
    formatter.format_stage("2007-06-15", "2025-06-15").should eq "Adulto"
  end

  # 25.19
  it "formatAge null handling" do
    formatter.format_age(nil, "2025-06-15").should be_nil
  end

  # 25.20
  it "formatStage null handling" do
    formatter.format_stage(nil, "2025-06-15").should be_nil
  end
end

# ================================================================
# Section 26: Compactness — short
# ================================================================
describe "Compactness — short" do
  formatter = SayableAge::Formatter.new(SayableAge::Locales::EN, :short)

  # 26.1
  it "short days" do
    formatter.format_age("2025-06-12", "2025-06-15").should eq "3 d"
  end

  # 26.2
  it "short week" do
    formatter.format_age("2025-06-08", "2025-06-15").should eq "1 wk"
  end

  # 26.3
  it "short compound" do
    formatter.format_age("2025-06-07", "2025-06-15").should eq "1 wk, 1 d"
  end

  # 26.4
  it "short months" do
    formatter.format_age("2025-01-15", "2025-07-15").should eq "6 mo"
  end

  # 26.5
  it "short years+months" do
    formatter.format_age("2023-06-15", "2025-07-15").should eq "2 yr, 1 mo"
  end

  # 26.6
  it "short half" do
    formatter.format_age("2022-06-15", "2025-12-15").should eq "3½ yr"
  end

  # 26.7
  it "short years" do
    formatter.format_age("2018-06-15", "2025-06-15").should eq "7 yr"
  end

  # 26.8
  it "justBorn unchanged" do
    formatter.format_age("2025-06-15", "2025-06-15").should eq "Newborn"
  end

  # 26.9
  it "stages unchanged" do
    formatter.format_stage("2025-01-15", "2025-06-15").should eq "Infant"
  end
end

# ================================================================
# Section 27: Compactness — compact
# ================================================================
describe "Compactness — compact" do
  formatter = SayableAge::Formatter.new(SayableAge::Locales::EN, :compact)

  # 27.1
  it "compact days" do
    formatter.format_age("2025-06-12", "2025-06-15").should eq "3d"
  end

  # 27.2
  it "compact week" do
    formatter.format_age("2025-06-08", "2025-06-15").should eq "1w"
  end

  # 27.3
  it "no delimiter" do
    formatter.format_age("2025-06-07", "2025-06-15").should eq "1w1d"
  end

  # 27.4
  it "compact months" do
    formatter.format_age("2025-01-15", "2025-07-15").should eq "6m"
  end

  # 27.5
  it "no delimiter" do
    formatter.format_age("2023-06-15", "2025-07-15").should eq "2y1m"
  end

  # 27.6
  it "compact half" do
    formatter.format_age("2022-06-15", "2025-12-15").should eq "3½y"
  end

  # 27.7
  it "compact years" do
    formatter.format_age("2018-06-15", "2025-06-15").should eq "7y"
  end

  # 27.8
  it "justBorn unchanged" do
    formatter.format_age("2025-06-15", "2025-06-15").should eq "Newborn"
  end
end

# ================================================================
# Section 29: Locale-specific edge cases — plural rules
# ================================================================
describe "Locale — Hebrew" do
  formatter = SayableAge::Formatter.new(SayableAge::Locales::HE)

  # 29.1
  it "justBorn" do
    formatter.format_age("2025-06-15", "2025-06-15").should eq "רק נולד"
  end

  # 29.2
  it "1 day — one form" do
    formatter.format_age("2025-06-14", "2025-06-15").should eq "יום 1"
  end

  # 29.3
  it "3 days — other form" do
    formatter.format_age("2025-06-12", "2025-06-15").should eq "3 ימים"
  end

  # 29.4
  it "2 weeks — dual form" do
    formatter.format_age("2025-06-01", "2025-06-15").should eq "שבועיים"
  end

  # 29.5
  it "3 weeks — other form" do
    formatter.format_age("2025-05-25", "2025-06-15").should eq "3 שבועות"
  end

  # 29.6
  it "6 months — other" do
    formatter.format_age("2025-01-15", "2025-07-15").should eq "6 חודשים"
  end

  # 29.7
  it "3 months — other" do
    formatter.format_age("2025-03-15", "2025-06-15").should eq "3 חודשים"
  end

  # 29.8
  it "2y dual + 1m one" do
    formatter.format_age("2023-06-15", "2025-07-15").should eq "שנתיים, חודש 1"
  end

  # 29.9
  it "3½ years — half marker" do
    formatter.format_age("2022-06-15", "2025-12-15").should eq "3 שנים וחצי"
  end

  # 29.10
  it "7+ years — other" do
    formatter.format_age("2018-06-15", "2025-06-15").should eq "7 שנים"
  end

  # 29.11
  it "masculine newborn stage" do
    formatter.format_stage("2025-06-15", "2025-06-15", "m").should eq "רק נולד"
  end

  # 29.12
  it "feminine newborn stage" do
    formatter.format_stage("2025-06-15", "2025-06-15", "f").should eq "רק נולדה"
  end

  # 29.13
  it "masculine adult stage" do
    formatter.format_stage("2007-06-15", "2025-06-15", "m").should eq "מבוגר"
  end

  # 29.14
  it "feminine adult stage" do
    formatter.format_stage("2007-06-15", "2025-06-15", "f").should eq "מבוגרת"
  end
end

describe "Locale — Macedonian" do
  formatter = SayableAge::Formatter.new(SayableAge::Locales::MK)

  # 29.15
  it "justBorn" do
    formatter.format_age("2025-06-15", "2025-06-15").should eq "Новороденче"
  end

  # 29.16
  it "1 day — one" do
    formatter.format_age("2025-06-14", "2025-06-15").should eq "1 ден"
  end

  # 29.17
  it "3 days — other" do
    formatter.format_age("2025-06-12", "2025-06-15").should eq "3 дена"
  end

  # 29.18
  it "6 months — other" do
    formatter.format_age("2025-01-15", "2025-07-15").should eq "6 месеци"
  end

  # 29.19
  it "2y1m — one for month" do
    formatter.format_age("2023-06-15", "2025-07-15").should eq "2 години, 1 месец"
  end

  # 29.20
  it "3½ years — half marker" do
    formatter.format_age("2022-06-15", "2025-12-15").should eq "3 години и пол"
  end

  # 29.21
  it "7+ years — other" do
    formatter.format_age("2018-06-15", "2025-06-15").should eq "7 години"
  end
end

describe "Locale — Swahili" do
  formatter = SayableAge::Formatter.new(SayableAge::Locales::SW)

  # 29.22
  it "justBorn" do
    formatter.format_age("2025-06-15", "2025-06-15").should eq "Mzaliwa mpya"
  end

  # 29.23
  it "1 day — one" do
    formatter.format_age("2025-06-14", "2025-06-15").should eq "siku 1"
  end

  # 29.24
  it "3 days — other" do
    formatter.format_age("2025-06-12", "2025-06-15").should eq "siku 3"
  end

  # 29.25
  it "6 months — other (noun class)" do
    formatter.format_age("2025-01-15", "2025-07-15").should eq "miezi 6"
  end

  # 29.26
  it "2y other + 1m one" do
    formatter.format_age("2023-06-15", "2025-07-15").should eq "miaka 2, mwezi 1"
  end

  # 29.27
  it "3½ years — half marker" do
    formatter.format_age("2022-06-15", "2025-12-15").should eq "miaka 3 na nusu"
  end
end

describe "Locale — Indonesian" do
  formatter = SayableAge::Formatter.new(SayableAge::Locales::ID)

  # 29.28
  it "justBorn" do
    formatter.format_age("2025-06-15", "2025-06-15").should eq "Baru lahir"
  end

  # 29.29
  it "1 day" do
    formatter.format_age("2025-06-14", "2025-06-15").should eq "1 hari"
  end

  # 29.30
  it "3 days (same unit)" do
    formatter.format_age("2025-06-12", "2025-06-15").should eq "3 hari"
  end

  # 29.31
  it "6 months" do
    formatter.format_age("2025-01-15", "2025-07-15").should eq "6 bulan"
  end

  # 29.32
  it "3½ years — half marker" do
    formatter.format_age("2022-06-15", "2025-12-15").should eq "3 tahun setengah"
  end

  # 29.33
  it "7+ years" do
    formatter.format_age("2018-06-15", "2025-06-15").should eq "7 tahun"
  end
end

describe "Locale — Amharic" do
  formatter = SayableAge::Formatter.new(SayableAge::Locales::AM)

  # 29.34
  it "justBorn" do
    formatter.format_age("2025-06-15", "2025-06-15").should eq "አዲስ የተወለደ"
  end

  # 29.35
  it "1 day — one form" do
    formatter.format_age("2025-06-14", "2025-06-15").should eq "1 ቀን"
  end

  # 29.36
  it "3 days — other form" do
    formatter.format_age("2025-06-12", "2025-06-15").should eq "3 ቀናት"
  end

  # 29.37
  it "1w1d with Ethiopic delimiter" do
    formatter.format_age("2025-06-07", "2025-06-15").should eq "1 ሳምንት፣ 1 ቀን"
  end

  # 29.38
  it "6 months — other form" do
    formatter.format_age("2025-01-15", "2025-07-15").should eq "6 ወራት"
  end

  # 29.39
  it "3½ years — half marker" do
    formatter.format_age("2022-06-15", "2025-12-15").should eq "3 ዓመታት ተኩል"
  end
end

# ================================================================
# Section 30: Locale lookup by code string
# ================================================================
describe "Locale lookup by code string" do
  # 30.1
  it "finds en locale" do
    locale = SayableAge::Locales.get("en")
    locale.should_not be_nil
    locale.not_nil!.code.should eq "en"
  end

  # 30.2
  it "finds fr locale" do
    locale = SayableAge::Locales.get("fr")
    locale.should_not be_nil
    locale.not_nil!.code.should eq "fr"
  end

  # 30.3
  it "returns nil for unknown code" do
    SayableAge::Locales.get("xx").should be_nil
  end

  # 30.4
  it "returns nil for empty string" do
    SayableAge::Locales.get("").should be_nil
  end

  # 30.5
  it "is case-sensitive" do
    SayableAge::Locales.get("EN").should be_nil
  end
end

# ================================================================
# Section 31: Weeks and days across month ends
# ================================================================
describe "Weeks and days across month ends" do
  # 31.1
  it "88 days across a 28-day February" do
    SayableAge::Formatter.new(SayableAge::Locales.get("en").not_nil!, :normal).format_age("2016-12-31", "2017-03-29").should eq "12 weeks, 4 days"
  end

  # 31.2
  it "90 days across a year end into a leap year" do
    SayableAge::Formatter.new(SayableAge::Locales.get("en").not_nil!, :normal).format_age("1991-11-27", "1992-02-25").should eq "12 weeks, 6 days"
  end

  # 31.3
  it "33 days across a year end" do
    SayableAge::Formatter.new(SayableAge::Locales.get("en").not_nil!, :normal).format_age("2020-11-30", "2021-01-02").should eq "4 weeks, 5 days"
  end

  # 31.4
  it "Compact form of 31.1" do
    SayableAge::Formatter.new(SayableAge::Locales.get("en").not_nil!, :compact).format_age("2016-12-31", "2017-03-29").should eq "12w4d"
  end
end

# ================================================================
# Section 32: Half years take their plural form from whole years
# ================================================================
describe "Half years take their plural form from whole years" do
  # 32.1
  it "Polish 3 is 'few'" do
    SayableAge::Formatter.new(SayableAge::Locales.get("pl").not_nil!, :normal).format_age("2021-06-15", "2025-01-15").should eq "3 i pół lata"
  end

  # 32.2
  it "Polish 5 is 'many'" do
    SayableAge::Formatter.new(SayableAge::Locales.get("pl").not_nil!, :short).format_age("2020-06-15", "2025-12-15").should eq "5 i pół lat"
  end

  # 32.3
  it "Tachelhit 6 is 'few'" do
    SayableAge::Formatter.new(SayableAge::Locales.get("shi").not_nil!, :normal).format_age("2005-06-08", "2012-06-07").should eq "6 iseggasen d uzgen"
  end
end

# ================================================================
# Section 33: Input validation
# ================================================================
describe "Input validation" do
  # 33.1
  it "February 30 doesn't exist" do
    SayableAge::Formatter.new(SayableAge::Locales.get("en").not_nil!, :normal).format_age("2025-02-30", "2032-06-25").should be_nil
  end

  # 33.2
  it "Month 13" do
    SayableAge::Formatter.new(SayableAge::Locales.get("en").not_nil!, :normal).format_age("2025-13-01", "2027-01-31").should be_nil
  end

  # 33.3
  it "February 29 in a non-leap year" do
    SayableAge::Formatter.new(SayableAge::Locales.get("en").not_nil!, :normal).format_age("2023-02-29", "2025-03-01").should be_nil
  end

  # 33.4
  it "Day 00" do
    SayableAge::Formatter.new(SayableAge::Locales.get("en").not_nil!, :normal).format_age("2025-06-00", "2027-02-25").should be_nil
  end

  # 33.5
  it "Unpadded month and day" do
    SayableAge::Formatter.new(SayableAge::Locales.get("en").not_nil!, :normal).format_age("2025-6-1", "2027-02-25").should be_nil
  end

  # 33.6
  it "Surrounding whitespace" do
    SayableAge::Formatter.new(SayableAge::Locales.get("en").not_nil!, :normal).format_age(" 2025-06-01", "2027-02-25").should be_nil
  end

  # 33.7
  it "A datetime is not a date" do
    SayableAge::Formatter.new(SayableAge::Locales.get("en").not_nil!, :normal).format_age("2025-06-15T10:00:00", "2027-02-25").should be_nil
  end

  # 33.8
  it "Invalid asOf" do
    SayableAge::Formatter.new(SayableAge::Locales.get("en").not_nil!, :normal).format_age("2020-01-01", "2025-04-31").should be_nil
  end

  # 33.9
  it "formatStage validates too" do
    SayableAge::Formatter.new(SayableAge::Locales.get("en").not_nil!, :normal).format_stage("2025-02-30", "2027-09-05").should be_nil
  end

  # 33.10
  it "February 29 in a leap year is valid" do
    SayableAge::Formatter.new(SayableAge::Locales.get("en").not_nil!, :normal).format_age("2024-02-29", "2026-03-01").should eq "2 years"
  end
end
