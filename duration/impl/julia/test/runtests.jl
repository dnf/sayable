using Test
using SayableDuration

# Section 1: Null / edge cases
@testset "Null / edge cases" begin
    @test format_duration(SayableDurationFormatter(get_locale("en")), -1) === nothing  # 1.2
    @test format_since(SayableDurationFormatter(get_locale("en")), "", "2025-01-15T10:00:00") === nothing  # 1.3
    @test format_until(SayableDurationFormatter(get_locale("en")), "", "2025-01-15T10:00:00") === nothing  # 1.4
    @test format_since(SayableDurationFormatter(get_locale("en")), "2025-01-15T10:00:00", "2025-01-15T09:00:00") === nothing  # 1.5
    @test format_until(SayableDurationFormatter(get_locale("en")), "2025-01-15T09:00:00", "2025-01-15T10:00:00") === nothing  # 1.6
end

# Section 2: Duration — seconds tier (0-59s)
@testset "Duration — seconds tier (0-59s)" begin
    en = SayableDurationFormatter(get_locale("en"))
    @test format_duration(en, 0) == "just now"  # 2.1
    @test format_duration(en, 1) == "1 second"  # 2.2
    @test format_duration(en, 45) == "45 seconds"  # 2.3
    @test format_duration(en, 59) == "59 seconds"  # 2.4
end

# Section 3: Duration — minutes + seconds tier (1-4 min)
@testset "Duration — minutes + seconds tier (1-4 min)" begin
    en = SayableDurationFormatter(get_locale("en"))
    @test format_duration(en, 60) == "1 minute"  # 3.1
    @test format_duration(en, 90) == "1 minute, 30 seconds"  # 3.2
    @test format_duration(en, 240) == "4 minutes"  # 3.3
    @test format_duration(en, 270) == "4 minutes, 30 seconds"  # 3.4
end

# Section 4: Duration — minutes tier (5-59 min)
@testset "Duration — minutes tier (5-59 min)" begin
    en = SayableDurationFormatter(get_locale("en"))
    @test format_duration(en, 300) == "5 minutes"  # 4.1
    @test format_duration(en, 1500) == "25 minutes"  # 4.2
    @test format_duration(en, 3540) == "59 minutes"  # 4.3
end

# Section 5: Duration — hours + minutes tier (1-5 hr)
@testset "Duration — hours + minutes tier (1-5 hr)" begin
    en = SayableDurationFormatter(get_locale("en"))
    @test format_duration(en, 3600) == "1 hour"  # 5.1
    @test format_duration(en, 5400) == "1½ hours"  # 5.2
    @test format_duration(en, 8100) == "2 hours, 15 minutes"  # 5.3
    @test format_duration(en, 18000) == "5 hours"  # 5.4
end

# Section 6: Duration — hours tier (6-23 hr)
@testset "Duration — hours tier (6-23 hr)" begin
    en = SayableDurationFormatter(get_locale("en"))
    @test format_duration(en, 28800) == "8 hours"  # 6.1
    @test format_duration(en, 82800) == "23 hours"  # 6.2
end

# Section 7: Duration — days tier
@testset "Duration — days tier" begin
    en = SayableDurationFormatter(get_locale("en"))
    @test format_duration(en, 86400) == "1 day"  # 7.1
    @test format_duration(en, 97200) == "1 day, 3 hours"  # 7.2
    @test format_duration(en, 129600) == "1½ days"  # 7.3
    @test format_duration(en, 432000) == "5 days"  # 7.4
    @test format_duration(en, 172800) == "2 days"  # 7.5
end

# Section 8: Duration — weeks tier
@testset "Duration — weeks tier" begin
    en = SayableDurationFormatter(get_locale("en"))
    @test format_duration(en, 604800) == "1 week"  # 8.1
    @test format_duration(en, 1296000) == "2 weeks, 1 day"  # 8.2
    @test format_duration(en, 2419200) == "4 weeks"  # 8.3
end

# Section 9: Duration — months and years tier
@testset "Duration — months and years tier" begin
    en = SayableDurationFormatter(get_locale("en"))
    @test format_duration(en, 2678400) == "1 month"  # 9.1
    @test format_duration(en, 7884000) == "3 months"  # 9.2
    @test format_duration(en, 31536000) == "1 year"  # 9.3
    @test format_duration(en, 39420000) == "1 year, 3 months"  # 9.4
end

# Section 10: Duration from ISO timestamps
@testset "Duration from ISO timestamps" begin
    en = SayableDurationFormatter(get_locale("en"))
    @test format_duration(en, "2025-01-15T10:00:00", "2025-01-15T11:30:00") == "1½ hours"  # 10.1
    @test format_duration(en, "2025-01-15T10:00:00", "2025-01-15T10:45:00") == "45 minutes"  # 10.2
end

# Section 11: Relative time — since
@testset "Relative time — since" begin
    en = SayableDurationFormatter(get_locale("en"))
    @test format_since(en, "2025-01-15T10:00:00", "2025-01-15T10:00:00") == "just now"  # 11.1
    @test format_since(en, "2025-01-15T10:00:00", "2025-01-15T10:00:30") == "30 seconds ago"  # 11.2
    @test format_since(en, "2025-01-15T10:00:00", "2025-01-15T10:45:00") == "45 minutes ago"  # 11.3
    @test format_since(en, "2025-01-15T10:00:00", "2025-01-15T13:00:00") == "3 hours ago"  # 11.4
end

# Section 12: Relative time — until
@testset "Relative time — until" begin
    en = SayableDurationFormatter(get_locale("en"))
    @test format_until(en, "2025-01-15T10:00:00", "2025-01-15T10:00:00") == "just now"  # 12.1
    @test format_until(en, "2025-01-15T10:20:00", "2025-01-15T10:00:00") == "in 20 minutes"  # 12.2
    @test format_until(en, "2025-01-15T13:00:00", "2025-01-15T10:00:00") == "in 3 hours"  # 12.3
end

# Section 13: Locale — German
@testset "Locale — German" begin
    de = SayableDurationFormatter(get_locale("de"))
    @test format_duration(de, 3600) == "1 Stunde"  # 13.1
    @test format_since(de, "2025-01-15T10:00:00", "2025-01-15T10:05:00") == "vor 5 Minuten"  # 13.2
end

# Section 14: Locale — French
@testset "Locale — French" begin
    fr = SayableDurationFormatter(get_locale("fr"))
    @test format_duration(fr, 7200) == "2 heures"  # 14.1
end

# Section 15: Locale — Japanese
@testset "Locale — Japanese" begin
    ja = SayableDurationFormatter(get_locale("ja"))
    @test format_duration(ja, 120) == "2分"  # 15.1
    @test format_since(ja, "2025-01-15T10:00:00", "2025-01-15T11:00:00") == "1時間前"  # 15.2
end

# Section 16: Short compactness — duration
@testset "Short compactness — duration" begin
    en_short = SayableDurationFormatter(get_locale("en"), Short)
    @test format_duration(en_short, 3600) == "1h"  # 16.1
    @test format_duration(en_short, 90) == "1m, 30s"  # 16.2
end

# Section 17: Compact compactness — duration
@testset "Compact compactness — duration" begin
    en_compact = SayableDurationFormatter(get_locale("en"), Compact)
    @test format_duration(en_compact, 3600) == "1h"  # 17.1
    @test format_duration(en_compact, 90) == "1m30s"  # 17.2
end

# Section 18: Short compactness — relative time
@testset "Short compactness — relative time" begin
    @test format_since(SayableDurationFormatter(get_locale("men"), Short), "2025-01-20T01:32:11", "2025-01-22T15:39:16") == "lɔhɔnga 2, awa 14 taa gbɔyɔ"  # 18.1
end

# Section 19: Range (500-year ceiling)
@testset "Range (500-year ceiling)" begin
    @test format_duration(SayableDurationFormatter(get_locale("en")), 15778800000) == "500 years"  # 19.1
    @test format_duration(SayableDurationFormatter(get_locale("en")), 15800000000) === nothing  # 19.2
    @test format_duration(SayableDurationFormatter(get_locale("en")), 99999999999) === nothing  # 19.3
    @test format_since(SayableDurationFormatter(get_locale("en")), "1500-01-01T00:00:00", "2025-01-01T00:00:00") === nothing  # 19.4
    @test format_until(SayableDurationFormatter(get_locale("en")), "2600-01-01T00:00:00", "2025-01-01T00:00:00") === nothing  # 19.5
end

# Section 20: Timestamp validation
@testset "Timestamp validation" begin
    @test format_duration(SayableDurationFormatter(get_locale("en")), "2025-01-15T10:00", "2025-01-15T11:30:00") == "1½ hours"  # 20.1
    @test format_duration(SayableDurationFormatter(get_locale("en")), "2025-01-15T10", "2025-01-15T11:30:00") === nothing  # 20.2
    @test format_duration(SayableDurationFormatter(get_locale("en")), "2025-1-5T10:00:00", "2025-01-15T11:30:00") === nothing  # 20.3
    @test format_duration(SayableDurationFormatter(get_locale("en")), "2025-02-30T10:00:00", "2025-03-15T11:30:00") === nothing  # 20.4
    @test format_since(SayableDurationFormatter(get_locale("en")), "2025-01-15T10:00:00", "2025-01-15T25:00:00") === nothing  # 20.5
end

# Locale lookup
@testset "Locale lookup" begin
    @test get_locale("en") !== nothing
    @test get_locale("en").code == "en"
    @test get_locale("xx") === nothing
    @test get_locale("") === nothing
end
