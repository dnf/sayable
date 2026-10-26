using Test
using Dates
using SayableAge

# No as-of date means today, so the default-date tests derive their date of
# birth from the real current date (Dates clamps Feb 29 to Feb 28).
iso_days_ago(n) = string(Dates.today() - Day(n))
iso_years_ago(n) = string(Dates.today() - Year(n))

# Section 1: Null / edge cases
@testset "Null / edge cases" begin
    @test format_age(SayableAgeFormatter(get_locale("en")), "", "") === nothing  # 1.1
    # 1.2: skipped (undefined not applicable in Julia)
    @test format_age(SayableAgeFormatter(get_locale("en")), "", "") === nothing  # 1.3
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-07-01", "2025-06-15") === nothing  # 1.4
    @test format_age(SayableAgeFormatter(get_locale("en")), "1525-06-15", "2025-06-15") == "500 years"  # 1.5
    @test format_age(SayableAgeFormatter(get_locale("en")), "1524-06-15", "2025-06-15") === nothing  # 1.6
    @test format_age(SayableAgeFormatter(get_locale("en")), "1025-06-15", "2025-06-15") === nothing  # 1.7
end

# Section 2: Days tier (0–6 days)
@testset "Days tier (0–6 days)" begin
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-06-15", "2025-06-15") == "Newborn"  # 2.1
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-06-14", "2025-06-15") == "1 day"  # 2.2
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-06-12", "2025-06-15") == "3 days"  # 2.3
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-06-09", "2025-06-15") == "6 days"  # 2.4
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-06-08", "2025-06-15") == "1 week"  # 2.5
end

# Section 3: Weeks+days tier (7 days to <3 calendar months)
@testset "Weeks+days tier (7 days to <3 calendar months)" begin
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-06-08", "2025-06-15") == "1 week"  # 3.1
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-06-07", "2025-06-15") == "1 week, 1 day"  # 3.2
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-06-06", "2025-06-15") == "1 week, 2 days"  # 3.3
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-06-02", "2025-06-15") == "1 week, 6 days"  # 3.4
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-06-01", "2025-06-15") == "2 weeks"  # 3.5
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-05-31", "2025-06-15") == "2 weeks, 1 day"  # 3.6
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-05-26", "2025-06-15") == "2 weeks, 6 days"  # 3.7
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-05-25", "2025-06-15") == "3 weeks"  # 3.8
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-05-15", "2025-06-15") == "4 weeks, 3 days"  # 3.9
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-04-15", "2025-06-15") == "8 weeks, 5 days"  # 3.10
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-03-15", "2025-06-14") == "13 weeks"  # 3.11
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-03-15", "2025-06-15") == "3 months"  # 3.12
end

# Section 4: Month boundaries — standard months
@testset "Month boundaries — standard months" begin
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-01-01", "2025-04-01") == "3 months"  # 4.1
    @test occursin("weeks", format_age(SayableAgeFormatter(get_locale("en")), "2025-01-01", "2025-03-31"))  # 4.2
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-06-15", "2025-09-15") == "3 months"  # 4.3
    @test occursin("weeks", format_age(SayableAgeFormatter(get_locale("en")), "2025-06-15", "2025-09-14"))  # 4.4
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-06-15", "2025-12-15") == "6 months"  # 4.5
end

# Section 5: Month boundaries — February non-leap year
@testset "Month boundaries — February non-leap year" begin
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-01-31", "2025-02-28") == "4 weeks"  # 5.1
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-01-31", "2025-04-30") == "3 months"  # 5.2
    @test occursin("weeks", format_age(SayableAgeFormatter(get_locale("en")), "2025-01-31", "2025-04-29"))  # 5.3
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-02-01", "2025-05-01") == "3 months"  # 5.4
    @test occursin("weeks", format_age(SayableAgeFormatter(get_locale("en")), "2025-02-01", "2025-04-30"))  # 5.5
end

# Section 6: Month boundaries — February leap year
@testset "Month boundaries — February leap year" begin
    @test format_age(SayableAgeFormatter(get_locale("en")), "2024-01-31", "2024-02-29") == "4 weeks, 1 day"  # 6.1
    @test format_age(SayableAgeFormatter(get_locale("en")), "2024-01-31", "2024-02-28") == "4 weeks"  # 6.2
    @test format_age(SayableAgeFormatter(get_locale("en")), "2024-01-31", "2024-04-30") == "3 months"  # 6.3
    @test occursin("weeks", format_age(SayableAgeFormatter(get_locale("en")), "2024-01-30", "2024-02-29"))  # 6.4
    @test occursin("weeks", format_age(SayableAgeFormatter(get_locale("en")), "2024-01-30", "2024-02-28"))  # 6.5
end

# Section 7: Month boundaries — 30-day months
@testset "Month boundaries — 30-day months" begin
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-03-31", "2025-06-30") == "3 months"  # 7.1
    @test occursin("weeks", format_age(SayableAgeFormatter(get_locale("en")), "2025-03-31", "2025-06-29"))  # 7.2
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-08-31", "2025-11-30") == "3 months"  # 7.3
    @test occursin("weeks", format_age(SayableAgeFormatter(get_locale("en")), "2025-08-31", "2025-11-29"))  # 7.4
end

# Section 8: Month boundaries — leap year baby (born Feb 29)
@testset "Month boundaries — leap year baby (born Feb 29)" begin
    @test format_age(SayableAgeFormatter(get_locale("en")), "2024-02-29", "2024-05-29") == "3 months"  # 8.1
    @test occursin("weeks", format_age(SayableAgeFormatter(get_locale("en")), "2024-02-29", "2024-05-28"))  # 8.2
    @test format_age(SayableAgeFormatter(get_locale("en")), "2024-02-29", "2025-02-28") == "12 months"  # 8.3
    @test format_age(SayableAgeFormatter(get_locale("en")), "2024-02-29", "2025-03-01") == "12 months"  # 8.4
end

# Section 9: Months tier (3–23 months)
@testset "Months tier (3–23 months)" begin
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-01-15", "2025-04-15") == "3 months"  # 9.1
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-01-15", "2025-07-15") == "6 months"  # 9.2
    @test format_age(SayableAgeFormatter(get_locale("en")), "2024-06-15", "2025-06-15") == "12 months"  # 9.3
    @test format_age(SayableAgeFormatter(get_locale("en")), "2024-01-15", "2025-12-15") == "23 months"  # 9.4
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-01-15", "2025-07-14") == "5 months"  # 9.5
    @test format_age(SayableAgeFormatter(get_locale("en")), "2024-11-10", "2025-04-10") == "5 months"  # 9.6
end

# Section 10: Years+months tier (24–35 months)
@testset "Years+months tier (24–35 months)" begin
    @test format_age(SayableAgeFormatter(get_locale("en")), "2023-06-15", "2025-06-15") == "2 years"  # 10.1
    @test format_age(SayableAgeFormatter(get_locale("en")), "2023-06-15", "2025-07-15") == "2 years, 1 month"  # 10.2
    @test format_age(SayableAgeFormatter(get_locale("en")), "2023-06-15", "2025-12-15") == "2 years, 6 months"  # 10.3
    @test format_age(SayableAgeFormatter(get_locale("en")), "2023-06-15", "2026-05-15") == "2 years, 11 months"  # 10.4
    @test format_age(SayableAgeFormatter(get_locale("en")), "2023-06-15", "2025-06-14") == "23 months"  # 10.5
end

# Section 11: Half-year tier (3–6 years)
@testset "Half-year tier (3–6 years)" begin
    @test format_age(SayableAgeFormatter(get_locale("en")), "2022-06-15", "2025-06-15") == "3 years"  # 11.1
    @test format_age(SayableAgeFormatter(get_locale("en")), "2022-06-15", "2025-11-15") == "3 years"  # 11.2
    @test format_age(SayableAgeFormatter(get_locale("en")), "2022-06-15", "2025-12-15") == "3½ years"  # 11.3
    @test format_age(SayableAgeFormatter(get_locale("en")), "2022-06-15", "2026-05-15") == "3½ years"  # 11.4
    @test format_age(SayableAgeFormatter(get_locale("en")), "2021-06-15", "2025-06-15") == "4 years"  # 11.5
    @test format_age(SayableAgeFormatter(get_locale("en")), "2021-06-15", "2025-12-15") == "4½ years"  # 11.6
    @test format_age(SayableAgeFormatter(get_locale("en")), "2020-06-15", "2025-06-15") == "5 years"  # 11.7
    @test format_age(SayableAgeFormatter(get_locale("en")), "2020-06-15", "2026-02-15") == "5½ years"  # 11.8
    @test format_age(SayableAgeFormatter(get_locale("en")), "2019-06-15", "2025-06-15") == "6 years"  # 11.9
    @test format_age(SayableAgeFormatter(get_locale("en")), "2019-06-15", "2025-12-15") == "6½ years"  # 11.10
    @test format_age(SayableAgeFormatter(get_locale("en")), "2019-06-15", "2026-05-15") == "6½ years"  # 11.11
    @test format_age(SayableAgeFormatter(get_locale("en")), "2022-06-15", "2025-06-14") == "2 years, 11 months"  # 11.12
end

# Section 12: Integer tier (7+ years)
@testset "Integer tier (7+ years)" begin
    @test format_age(SayableAgeFormatter(get_locale("en")), "2018-06-15", "2025-06-15") == "7 years"  # 12.1
    @test format_age(SayableAgeFormatter(get_locale("en")), "2018-03-20", "2025-06-15") == "7 years"  # 12.2
    @test format_age(SayableAgeFormatter(get_locale("en")), "1980-01-01", "2025-06-15") == "45 years"  # 12.3
end

# Section 13: Cross-year transitions with February
@testset "Cross-year transitions with February" begin
    @test format_age(SayableAgeFormatter(get_locale("en")), "2024-12-31", "2025-03-31") == "3 months"  # 13.1
    @test occursin("weeks", format_age(SayableAgeFormatter(get_locale("en")), "2024-12-31", "2025-03-30"))  # 13.2
    @test format_age(SayableAgeFormatter(get_locale("en")), "2024-11-30", "2025-02-28") == "3 months"  # 13.3
    @test occursin("weeks", format_age(SayableAgeFormatter(get_locale("en")), "2024-11-30", "2025-02-27"))  # 13.4
end

# Section 14: Born-on-31st progression
@testset "Born-on-31st progression" begin
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-01-31", "2025-04-30") == "3 months"  # 14.1
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-01-31", "2025-05-31") == "4 months"  # 14.2
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-01-31", "2025-06-30") == "5 months"  # 14.3
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-01-31", "2025-07-01") == "5 months"  # 14.4
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-01-31", "2025-07-31") == "6 months"  # 14.5
end

# Section 15: Default asOf (current date)
@testset "Default asOf (current date)" begin
    @test format_age(SayableAgeFormatter(get_locale("en")), iso_years_ago(5)) == "5 years"  # 15.1
    @test format_age(SayableAgeFormatter(get_locale("en")), iso_days_ago(5)) == "5 days"  # 15.2
end

# Section 16: formatStage — null / edge cases
@testset "formatStage — null / edge cases" begin
    @test format_stage(SayableAgeFormatter(get_locale("en")), "", "", "") === nothing  # 16.1
    # 16.2: skipped (undefined not applicable in Julia)
    @test format_stage(SayableAgeFormatter(get_locale("en")), "", "", "") === nothing  # 16.3
    @test format_stage(SayableAgeFormatter(get_locale("en")), "2025-07-01", "2025-06-15", "") === nothing  # 16.4
    @test format_stage(SayableAgeFormatter(get_locale("en")), "1525-06-15", "2025-06-15", "") == "Adult"  # 16.5
    @test format_stage(SayableAgeFormatter(get_locale("en")), "1524-06-15", "2025-06-15", "") === nothing  # 16.6
end

# Section 17: formatStage — Newborn (0–1 months, <2 calendar months)
@testset "formatStage — Newborn (0–1 months, <2 calendar months)" begin
    @test format_stage(SayableAgeFormatter(get_locale("en")), "2025-06-15", "2025-06-15", "") == "Newborn"  # 17.1
    @test format_stage(SayableAgeFormatter(get_locale("en")), "2025-06-14", "2025-06-15", "") == "Newborn"  # 17.2
    @test format_stage(SayableAgeFormatter(get_locale("en")), "2025-05-25", "2025-06-15", "") == "Newborn"  # 17.3
    @test format_stage(SayableAgeFormatter(get_locale("en")), "2025-05-15", "2025-06-15", "") == "Newborn"  # 17.4
    @test format_stage(SayableAgeFormatter(get_locale("en")), "2025-04-16", "2025-06-15", "") == "Newborn"  # 17.5
    @test format_stage(SayableAgeFormatter(get_locale("en")), "2025-04-15", "2025-06-15", "") == "Infant"  # 17.6
end

# Section 18: formatStage — Infant (2–11 months)
@testset "formatStage — Infant (2–11 months)" begin
    @test format_stage(SayableAgeFormatter(get_locale("en")), "2025-04-15", "2025-06-15", "") == "Infant"  # 18.1
    @test format_stage(SayableAgeFormatter(get_locale("en")), "2024-12-15", "2025-06-15", "") == "Infant"  # 18.2
    @test format_stage(SayableAgeFormatter(get_locale("en")), "2024-07-15", "2025-06-15", "") == "Infant"  # 18.3
    @test format_stage(SayableAgeFormatter(get_locale("en")), "2024-06-15", "2025-06-15", "") == "Toddler"  # 18.4
end

# Section 19: formatStage — Toddler (12–35 months)
@testset "formatStage — Toddler (12–35 months)" begin
    @test format_stage(SayableAgeFormatter(get_locale("en")), "2024-06-15", "2025-06-15", "") == "Toddler"  # 19.1
    @test format_stage(SayableAgeFormatter(get_locale("en")), "2024-01-15", "2025-07-15", "") == "Toddler"  # 19.2
    @test format_stage(SayableAgeFormatter(get_locale("en")), "2023-06-15", "2025-06-15", "") == "Toddler"  # 19.3
    @test format_stage(SayableAgeFormatter(get_locale("en")), "2023-06-15", "2026-05-15", "") == "Toddler"  # 19.4
    @test format_stage(SayableAgeFormatter(get_locale("en")), "2022-06-15", "2025-06-15", "") == "Child"  # 19.5
end

# Section 20: formatStage — Child (36–155 months, 3–12 years)
@testset "formatStage — Child (36–155 months, 3–12 years)" begin
    @test format_stage(SayableAgeFormatter(get_locale("en")), "2022-06-15", "2025-06-15", "") == "Child"  # 20.1
    @test format_stage(SayableAgeFormatter(get_locale("en")), "2021-06-15", "2025-06-15", "") == "Child"  # 20.2
    @test format_stage(SayableAgeFormatter(get_locale("en")), "2019-06-15", "2025-06-15", "") == "Child"  # 20.3
    @test format_stage(SayableAgeFormatter(get_locale("en")), "2016-06-15", "2025-06-15", "") == "Child"  # 20.4
    @test format_stage(SayableAgeFormatter(get_locale("en")), "2013-06-15", "2026-05-15", "") == "Child"  # 20.5
    @test format_stage(SayableAgeFormatter(get_locale("en")), "2012-06-15", "2025-06-15", "") == "Teenager"  # 20.6
end

# Section 21: formatStage — Teenager (156–215 months, 13–17 years)
@testset "formatStage — Teenager (156–215 months, 13–17 years)" begin
    @test format_stage(SayableAgeFormatter(get_locale("en")), "2012-06-15", "2025-06-15", "") == "Teenager"  # 21.1
    @test format_stage(SayableAgeFormatter(get_locale("en")), "2010-06-15", "2025-06-15", "") == "Teenager"  # 21.2
    @test format_stage(SayableAgeFormatter(get_locale("en")), "2008-06-15", "2026-05-15", "") == "Teenager"  # 21.3
    @test format_stage(SayableAgeFormatter(get_locale("en")), "2007-06-15", "2025-06-15", "") == "Adult"  # 21.4
end

# Section 22: formatStage — Adult (216+ months, 18+ years)
@testset "formatStage — Adult (216+ months, 18+ years)" begin
    @test format_stage(SayableAgeFormatter(get_locale("en")), "2007-06-15", "2025-06-15", "") == "Adult"  # 22.1
    @test format_stage(SayableAgeFormatter(get_locale("en")), "2000-06-15", "2025-06-15", "") == "Adult"  # 22.2
    @test format_stage(SayableAgeFormatter(get_locale("en")), "1980-01-01", "2025-06-15", "") == "Adult"  # 22.3
end

# Section 23: formatStage — default asOf
@testset "formatStage — default asOf" begin
    @test format_stage(SayableAgeFormatter(get_locale("en")), iso_days_ago(0)) == "Newborn"  # 23.1
    @test format_stage(SayableAgeFormatter(get_locale("en")), iso_years_ago(5)) == "Child"  # 23.2
    @test format_stage(SayableAgeFormatter(get_locale("en")), iso_years_ago(45)) == "Adult"  # 23.3
end

# Section 24: SayableAge class — English locale delegation
@testset "SayableAge class — English locale delegation" begin
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-06-15", "2025-06-15") == "Newborn"  # 24.1
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-06-12", "2025-06-15") == "3 days"  # 24.2
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-06-07", "2025-06-15") == "1 week, 1 day"  # 24.3
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-01-15", "2025-07-15") == "6 months"  # 24.4
    @test format_age(SayableAgeFormatter(get_locale("en")), "2023-06-15", "2025-07-15") == "2 years, 1 month"  # 24.5
    @test format_age(SayableAgeFormatter(get_locale("en")), "2022-06-15", "2025-12-15") == "3½ years"  # 24.6
    @test format_age(SayableAgeFormatter(get_locale("en")), "2018-06-15", "2025-06-15") == "7 years"  # 24.7
    @test format_stage(SayableAgeFormatter(get_locale("en")), "2025-06-15", "2025-06-15", "") == "Newborn"  # 24.8
    @test format_stage(SayableAgeFormatter(get_locale("en")), "2025-01-15", "2025-06-15", "") == "Infant"  # 24.9
    @test format_stage(SayableAgeFormatter(get_locale("en")), "2024-06-15", "2025-06-15", "") == "Toddler"  # 24.10
    @test format_stage(SayableAgeFormatter(get_locale("en")), "2022-06-15", "2025-06-15", "") == "Child"  # 24.11
    @test format_stage(SayableAgeFormatter(get_locale("en")), "2012-06-15", "2025-06-15", "") == "Teenager"  # 24.12
    @test format_stage(SayableAgeFormatter(get_locale("en")), "2007-06-15", "2025-06-15", "") == "Adult"  # 24.13
    @test format_age(SayableAgeFormatter(get_locale("en")), "", "") === nothing  # 24.14
    @test format_stage(SayableAgeFormatter(get_locale("en")), "", "", "") === nothing  # 24.15
end

# Section 25: i18n — locale with all plural features
@testset "i18n — locale with all plural features" begin
    @test format_age(SayableAgeFormatter(get_locale("es")), "2025-06-15", "2025-06-15") == "Recién nacido"  # 25.1
    @test format_age(SayableAgeFormatter(get_locale("es")), "2025-06-14", "2025-06-15") == "1 día"  # 25.2
    @test format_age(SayableAgeFormatter(get_locale("es")), "2025-06-12", "2025-06-15") == "3 días"  # 25.3
    @test format_age(SayableAgeFormatter(get_locale("es")), "2025-06-08", "2025-06-15") == "1 semana"  # 25.4
    @test format_age(SayableAgeFormatter(get_locale("es")), "2025-06-07", "2025-06-15") == "1 semana, 1 día"  # 25.5
    @test format_age(SayableAgeFormatter(get_locale("es")), "2025-05-26", "2025-06-15") == "2 semanas, 6 días"  # 25.6
    @test format_age(SayableAgeFormatter(get_locale("es")), "2025-01-15", "2025-07-15") == "6 meses"  # 25.7
    @test format_age(SayableAgeFormatter(get_locale("es")), "2023-06-15", "2025-07-15") == "2 años, 1 mes"  # 25.8
    @test format_age(SayableAgeFormatter(get_locale("es")), "2023-06-15", "2025-12-15") == "2 años, 6 meses"  # 25.9
    @test format_age(SayableAgeFormatter(get_locale("es")), "2022-06-15", "2025-12-15") == "3 años y medio"  # 25.10
    @test format_age(SayableAgeFormatter(get_locale("es")), "2022-06-15", "2025-06-15") == "3 años"  # 25.11
    @test format_age(SayableAgeFormatter(get_locale("es")), "2018-06-15", "2025-06-15") == "7 años"  # 25.12
    @test format_stage(SayableAgeFormatter(get_locale("es")), "2025-06-15", "2025-06-15", "") == "Recién nacido"  # 25.13
    @test format_stage(SayableAgeFormatter(get_locale("es")), "2025-01-15", "2025-06-15", "") == "Bebé"  # 25.14
    @test format_stage(SayableAgeFormatter(get_locale("es")), "2024-06-15", "2025-06-15", "") == "Niño pequeño"  # 25.15
    @test format_stage(SayableAgeFormatter(get_locale("es")), "2022-06-15", "2025-06-15", "") == "Niño"  # 25.16
    @test format_stage(SayableAgeFormatter(get_locale("es")), "2012-06-15", "2025-06-15", "") == "Adolescente"  # 25.17
    @test format_stage(SayableAgeFormatter(get_locale("es")), "2007-06-15", "2025-06-15", "") == "Adulto"  # 25.18
    @test format_age(SayableAgeFormatter(get_locale("es")), "", "") === nothing  # 25.19
    @test format_stage(SayableAgeFormatter(get_locale("es")), "", "", "") === nothing  # 25.20
end

# Section 26: Compactness — short
@testset "Compactness — short" begin
    @test format_age(SayableAgeFormatter(get_locale("en"), Short), "2025-06-12", "2025-06-15") == "3 d"  # 26.1
    @test format_age(SayableAgeFormatter(get_locale("en"), Short), "2025-06-08", "2025-06-15") == "1 wk"  # 26.2
    @test format_age(SayableAgeFormatter(get_locale("en"), Short), "2025-06-07", "2025-06-15") == "1 wk, 1 d"  # 26.3
    @test format_age(SayableAgeFormatter(get_locale("en"), Short), "2025-01-15", "2025-07-15") == "6 mo"  # 26.4
    @test format_age(SayableAgeFormatter(get_locale("en"), Short), "2023-06-15", "2025-07-15") == "2 yr, 1 mo"  # 26.5
    @test format_age(SayableAgeFormatter(get_locale("en"), Short), "2022-06-15", "2025-12-15") == "3½ yr"  # 26.6
    @test format_age(SayableAgeFormatter(get_locale("en"), Short), "2018-06-15", "2025-06-15") == "7 yr"  # 26.7
    @test format_age(SayableAgeFormatter(get_locale("en"), Short), "2025-06-15", "2025-06-15") == "Newborn"  # 26.8
    @test format_stage(SayableAgeFormatter(get_locale("en"), Short), "2025-01-15", "2025-06-15", "") == "Infant"  # 26.9
end

# Section 27: Compactness — compact
@testset "Compactness — compact" begin
    @test format_age(SayableAgeFormatter(get_locale("en"), Compact), "2025-06-12", "2025-06-15") == "3d"  # 27.1
    @test format_age(SayableAgeFormatter(get_locale("en"), Compact), "2025-06-08", "2025-06-15") == "1w"  # 27.2
    @test format_age(SayableAgeFormatter(get_locale("en"), Compact), "2025-06-07", "2025-06-15") == "1w1d"  # 27.3
    @test format_age(SayableAgeFormatter(get_locale("en"), Compact), "2025-01-15", "2025-07-15") == "6m"  # 27.4
    @test format_age(SayableAgeFormatter(get_locale("en"), Compact), "2023-06-15", "2025-07-15") == "2y1m"  # 27.5
    @test format_age(SayableAgeFormatter(get_locale("en"), Compact), "2022-06-15", "2025-12-15") == "3½y"  # 27.6
    @test format_age(SayableAgeFormatter(get_locale("en"), Compact), "2018-06-15", "2025-06-15") == "7y"  # 27.7
    @test format_age(SayableAgeFormatter(get_locale("en"), Compact), "2025-06-15", "2025-06-15") == "Newborn"  # 27.8
end

# Section 29: Locale-specific edge cases — plural rules
@testset "Locale-specific edge cases — plural rules" begin
    @test format_age(SayableAgeFormatter(get_locale("he")), "2025-06-15", "2025-06-15") == "רק נולד"  # 29.1
    @test format_age(SayableAgeFormatter(get_locale("he")), "2025-06-14", "2025-06-15") == "יום"  # 29.2
    @test format_age(SayableAgeFormatter(get_locale("he")), "2025-06-12", "2025-06-15") == "3 ימים"  # 29.3
    @test format_age(SayableAgeFormatter(get_locale("he")), "2025-06-01", "2025-06-15") == "שבועיים"  # 29.4
    @test format_age(SayableAgeFormatter(get_locale("he")), "2025-05-25", "2025-06-15") == "3 שבועות"  # 29.5
    @test format_age(SayableAgeFormatter(get_locale("he")), "2025-01-15", "2025-07-15") == "6 חודשים"  # 29.6
    @test format_age(SayableAgeFormatter(get_locale("he")), "2025-03-15", "2025-06-15") == "3 חודשים"  # 29.7
    @test format_age(SayableAgeFormatter(get_locale("he")), "2023-06-15", "2025-07-15") == "שנתיים, חודש"  # 29.8
    @test format_age(SayableAgeFormatter(get_locale("he")), "2022-06-15", "2025-12-15") == "3 שנים וחצי"  # 29.9
    @test format_age(SayableAgeFormatter(get_locale("he")), "2018-06-15", "2025-06-15") == "7 שנים"  # 29.10
    @test format_stage(SayableAgeFormatter(get_locale("he")), "2025-06-15", "2025-06-15", "m") == "רק נולד"  # 29.11
    @test format_stage(SayableAgeFormatter(get_locale("he")), "2025-06-15", "2025-06-15", "f") == "רק נולדה"  # 29.12
    @test format_stage(SayableAgeFormatter(get_locale("he")), "2007-06-15", "2025-06-15", "m") == "מבוגר"  # 29.13
    @test format_stage(SayableAgeFormatter(get_locale("he")), "2007-06-15", "2025-06-15", "f") == "מבוגרת"  # 29.14
    @test format_age(SayableAgeFormatter(get_locale("mk")), "2025-06-15", "2025-06-15") == "Новороденче"  # 29.15
    @test format_age(SayableAgeFormatter(get_locale("mk")), "2025-06-14", "2025-06-15") == "1 ден"  # 29.16
    @test format_age(SayableAgeFormatter(get_locale("mk")), "2025-06-12", "2025-06-15") == "3 дена"  # 29.17
    @test format_age(SayableAgeFormatter(get_locale("mk")), "2025-01-15", "2025-07-15") == "6 месеци"  # 29.18
    @test format_age(SayableAgeFormatter(get_locale("mk")), "2023-06-15", "2025-07-15") == "2 години, 1 месец"  # 29.19
    @test format_age(SayableAgeFormatter(get_locale("mk")), "2022-06-15", "2025-12-15") == "3 години и пол"  # 29.20
    @test format_age(SayableAgeFormatter(get_locale("mk")), "2018-06-15", "2025-06-15") == "7 години"  # 29.21
    @test format_age(SayableAgeFormatter(get_locale("sw")), "2025-06-15", "2025-06-15") == "Mzaliwa mpya"  # 29.22
    @test format_age(SayableAgeFormatter(get_locale("sw")), "2025-06-14", "2025-06-15") == "siku 1"  # 29.23
    @test format_age(SayableAgeFormatter(get_locale("sw")), "2025-06-12", "2025-06-15") == "siku 3"  # 29.24
    @test format_age(SayableAgeFormatter(get_locale("sw")), "2025-01-15", "2025-07-15") == "miezi 6"  # 29.25
    @test format_age(SayableAgeFormatter(get_locale("sw")), "2023-06-15", "2025-07-15") == "miaka 2, mwezi 1"  # 29.26
    @test format_age(SayableAgeFormatter(get_locale("sw")), "2022-06-15", "2025-12-15") == "miaka 3 na nusu"  # 29.27
    @test format_age(SayableAgeFormatter(get_locale("id")), "2025-06-15", "2025-06-15") == "Baru lahir"  # 29.28
    @test format_age(SayableAgeFormatter(get_locale("id")), "2025-06-14", "2025-06-15") == "1 hari"  # 29.29
    @test format_age(SayableAgeFormatter(get_locale("id")), "2025-06-12", "2025-06-15") == "3 hari"  # 29.30
    @test format_age(SayableAgeFormatter(get_locale("id")), "2025-01-15", "2025-07-15") == "6 bulan"  # 29.31
    @test format_age(SayableAgeFormatter(get_locale("id")), "2022-06-15", "2025-12-15") == "3 setengah tahun"  # 29.32
    @test format_age(SayableAgeFormatter(get_locale("id")), "2018-06-15", "2025-06-15") == "7 tahun"  # 29.33
    @test format_age(SayableAgeFormatter(get_locale("am")), "2025-06-15", "2025-06-15") == "አዲስ የተወለደ"  # 29.34
    @test format_age(SayableAgeFormatter(get_locale("am")), "2025-06-14", "2025-06-15") == "1 ቀን"  # 29.35
    @test format_age(SayableAgeFormatter(get_locale("am")), "2025-06-12", "2025-06-15") == "3 ቀናት"  # 29.36
    @test format_age(SayableAgeFormatter(get_locale("am")), "2025-06-07", "2025-06-15") == "1 ሳምንት፣ 1 ቀን"  # 29.37
    @test format_age(SayableAgeFormatter(get_locale("am")), "2025-01-15", "2025-07-15") == "6 ወራት"  # 29.38
    @test format_age(SayableAgeFormatter(get_locale("am")), "2022-06-15", "2025-12-15") == "3 ዓመታት ተኩል"  # 29.39
end

# Section 30: Locale lookup by code string
@testset "Locale lookup by code string" begin
    @test get_locale("en") !== nothing  # 30.1
    @test get_locale("en").code == "en"  # 30.1
    @test get_locale("fr") !== nothing  # 30.2
    @test get_locale("fr").code == "fr"  # 30.2
    @test get_locale("xx") === nothing  # 30.3
    @test get_locale("") === nothing  # 30.4
    @test get_locale("EN") === nothing  # 30.5
end


# Section 31: Weeks and days across month ends
@testset "Weeks and days across month ends" begin
    @test format_age(SayableAgeFormatter(get_locale("en")), "2016-12-31", "2017-03-29") == "12 weeks, 4 days"  # 31.1
    @test format_age(SayableAgeFormatter(get_locale("en")), "1991-11-27", "1992-02-25") == "12 weeks, 6 days"  # 31.2
    @test format_age(SayableAgeFormatter(get_locale("en")), "2020-11-30", "2021-01-02") == "4 weeks, 5 days"  # 31.3
    @test format_age(SayableAgeFormatter(get_locale("en"), Compact), "2016-12-31", "2017-03-29") == "12w4d"  # 31.4
end

# Section 32: Half years take their plural form from whole years
@testset "Half years take their plural form from whole years" begin
    @test format_age(SayableAgeFormatter(get_locale("pl")), "2021-06-15", "2025-01-15") == "3 i pół lata"  # 32.1
    @test format_age(SayableAgeFormatter(get_locale("pl"), Short), "2020-06-15", "2025-12-15") == "5 i pół lat"  # 32.2
    @test format_age(SayableAgeFormatter(get_locale("shi")), "2005-06-08", "2012-06-07") == "6 ⵉⵙⴳⴳⵯⴰⵙⵏ ⴷ ⵓⵣⴳⵏ"  # 32.3
end

# Section 33: Input validation
@testset "Input validation" begin
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-02-30", "2032-06-25") === nothing  # 33.1
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-13-01", "2027-01-31") === nothing  # 33.2
    @test format_age(SayableAgeFormatter(get_locale("en")), "2023-02-29", "2025-03-01") === nothing  # 33.3
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-06-00", "2027-02-25") === nothing  # 33.4
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-6-1", "2027-02-25") === nothing  # 33.5
    @test format_age(SayableAgeFormatter(get_locale("en")), " 2025-06-01", "2027-02-25") === nothing  # 33.6
    @test format_age(SayableAgeFormatter(get_locale("en")), "2025-06-15T10:00:00", "2027-02-25") === nothing  # 33.7
    @test format_age(SayableAgeFormatter(get_locale("en")), "2020-01-01", "2025-04-31") === nothing  # 33.8
    @test format_stage(SayableAgeFormatter(get_locale("en")), "2025-02-30", "2027-09-05", "") === nothing  # 33.9
    @test format_age(SayableAgeFormatter(get_locale("en")), "2024-02-29", "2026-03-01") == "2 years"  # 33.10
end
