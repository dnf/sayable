using Test
using SayableTime

# Section 1: Null / edge cases
@testset "Null / edge cases" begin
    @test format_time(SayableTimeFormatter(get_locale("en")), "") === nothing  # 1.1, 1.2
    @test format_time(SayableTimeFormatter(get_locale("en")), "invalid") === nothing  # 1.3
    @test format_time(SayableTimeFormatter(get_locale("en")), "25:00") === nothing  # 1.4
end

# Section 2: Clock time (normal compactness)
@testset "Clock time (normal compactness)" begin
    en = SayableTimeFormatter(get_locale("en"))
    @test format_time(en, "00:00") == "midnight"  # 2.1
    @test format_time(en, "12:00") == "noon"  # 2.2
    @test format_time(en, "15:00") == "three o'clock"  # 2.3
    @test format_time(en, "14:15") == "a quarter past two"  # 2.4
    @test format_time(en, "09:30") == "half past nine"  # 2.5
    @test format_time(en, "10:45") == "a quarter to eleven"  # 2.6
    @test format_time(en, "08:05") == "five past eight"  # 2.7
    @test format_time(en, "16:55") == "five to five"  # 2.8
    @test format_time(en, "23:58") == "midnight"  # 2.9
    @test format_time(en, "07:22") == "twenty past seven"  # 2.10
    @test format_time(en, "2025-01-15T14:15:00") == "a quarter past two"  # 2.11
end

# Section 3: Clock time (short compactness)
@testset "Clock time (short compactness)" begin
    en_short = SayableTimeFormatter(get_locale("en"), Short)
    @test format_time(en_short, "14:15") == "2:15 PM"  # 3.1
    @test format_time(en_short, "09:30") == "9:30 AM"  # 3.2
    @test format_time(en_short, "00:00") == "12:00 AM"  # 3.3
    @test format_time(en_short, "12:00") == "12:00 PM"  # 3.4
end

# Section 4: Clock time (compact)
@testset "Clock time (compact)" begin
    en_compact = SayableTimeFormatter(get_locale("en"), Compact)
    @test format_time(en_compact, "14:15") == "2:15p"  # 4.1
    @test format_time(en_compact, "09:30") == "9:30a"  # 4.2
end

# Section 5: Locale — German
@testset "Locale — German" begin
    de = SayableTimeFormatter(get_locale("de"))
    @test format_time(de, "15:30") == "halb vier"  # 5.1
end

# Section 6: Locale — French
@testset "Locale — French" begin
    fr = SayableTimeFormatter(get_locale("fr"))
    @test format_time(fr, "15:15") == "trois heures et quart"  # 6.1
end

# Section 7: Locale — Japanese
@testset "Locale — Japanese" begin
    ja = SayableTimeFormatter(get_locale("ja"))
    @test format_time(ja, "15:30") == "三時半"  # 7.1
end

# Section 8: Locale — Finnish (dot separator, short)
@testset "Locale — Finnish (dot separator, short)" begin
    fi_short = SayableTimeFormatter(get_locale("fi"), Short)
    @test format_time(fi_short, "14:15") == "14.15"  # 8.1
    @test format_time(fi_short, "00:00") == "0.00"  # 8.2
end

# Section 9: Minutes in short and compact modes
@testset "Minutes in short and compact modes" begin
    @test format_time(SayableTimeFormatter(get_locale("en"), Short), "18:01") == "6:01 PM"  # 9.1
    @test format_time(SayableTimeFormatter(get_locale("en"), Compact), "19:05") == "7:05p"  # 9.2
end

# Section 10: Input validation
@testset "Input validation" begin
    @test format_time(SayableTimeFormatter(get_locale("en")), "9:30") == "half past nine"  # 10.1
    @test format_time(SayableTimeFormatter(get_locale("en")), "09:30") == "half past nine"  # 10.2
    @test format_time(SayableTimeFormatter(get_locale("en")), " 9:30") === nothing  # 10.3
    @test format_time(SayableTimeFormatter(get_locale("en")), "9:30 ") === nothing  # 10.4
    @test format_time(SayableTimeFormatter(get_locale("en")), "9:5") === nothing  # 10.5
    @test format_time(SayableTimeFormatter(get_locale("en")), "24:00") === nothing  # 10.6
    @test format_time(SayableTimeFormatter(get_locale("en")), "14:15:30") == "a quarter past two"  # 10.7
    @test format_time(SayableTimeFormatter(get_locale("en")), "2025-01-15T14:15:00Z") == "a quarter past two"  # 10.8
    @test format_time(SayableTimeFormatter(get_locale("en")), "2025-02-30T14:15:00") === nothing  # 10.9
end

# Locale lookup
@testset "Locale lookup" begin
    @test get_locale("en") !== nothing
    @test get_locale("en").code == "en"
    @test get_locale("xx") === nothing
    @test get_locale("") === nothing
end
