using Test
using SayableDate

# Section 1: Null / edge cases
@testset "Null / edge cases" begin
    @test format_date(SayableDateFormatter(get_locale("en")), "") === nothing  # 1.1, 1.2
    @test format_date(SayableDateFormatter(get_locale("en")), "invalid") === nothing  # 1.3
    @test format_relative(SayableDateFormatter(get_locale("en")), "2025-03-15", "") === nothing  # 1.4
    @test format_relative(SayableDateFormatter(get_locale("en")), "", "2025-03-15") === nothing  # 1.5
end

# Section 2: format_date — normal compactness (English)
@testset "format_date — normal compactness (English)" begin
    en = SayableDateFormatter(get_locale("en"))
    @test format_date(en, "2025-03-15") == "March 15th"  # 2.1
    @test format_date(en, "2025-01-01") == "January 1st"  # 2.2
    @test format_date(en, "2025-05-22") == "May 22nd"  # 2.3
    @test format_date(en, "2025-07-03") == "July 3rd"  # 2.4
    @test format_date(en, "2025-12-31") == "December 31st"  # 2.5
    @test format_date(en, "2025-06-11") == "June 11th"  # 2.6
    @test format_date(en, "2025-03-15T14:30:00") == "March 15th"  # 2.7
end

# Section 3: format_date — short compactness (English)
@testset "format_date — short compactness (English)" begin
    en_short = SayableDateFormatter(get_locale("en"), Short)
    @test format_date(en_short, "2025-03-15") == "Mar 15"  # 3.1
    @test format_date(en_short, "2025-01-01") == "Jan 1"  # 3.2
    @test format_date(en_short, "2025-12-25") == "Dec 25"  # 3.3
end

# Section 4: format_date — compact (English)
@testset "format_date — compact (English)" begin
    en_compact = SayableDateFormatter(get_locale("en"), Compact)
    @test format_date(en_compact, "2025-03-15") == "3/15"  # 4.1
    @test format_date(en_compact, "2025-01-01") == "1/1"  # 4.2
end

# Section 5: format_relative — proximity tiers (English)
@testset "format_relative — proximity tiers (English)" begin
    en = SayableDateFormatter(get_locale("en"))
    @test format_relative(en, "2025-03-15", "2025-03-15") == "today"  # 5.1
    @test format_relative(en, "2025-03-16", "2025-03-15") == "tomorrow"  # 5.2
    @test format_relative(en, "2025-03-14", "2025-03-15") == "yesterday"  # 5.3
    @test format_relative(en, "2025-03-17", "2025-03-15") == "the day after tomorrow"  # 5.4
    @test format_relative(en, "2025-03-13", "2025-03-15") == "the day before yesterday"  # 5.5
    @test format_relative(en, "2025-03-19", "2025-03-15") == "this Wednesday"  # 5.6
    @test format_relative(en, "2025-03-20", "2025-03-15") == "this Thursday"  # 5.7
    @test format_relative(en, "2025-03-11", "2025-03-15") == "last Tuesday"  # 5.8
    @test format_relative(en, "2025-03-22", "2025-03-15") == "next Saturday"  # 5.9
    @test format_relative(en, "2025-03-27", "2025-03-15") == "next Thursday"  # 5.10
    @test format_relative(en, "2025-03-01", "2025-03-15") == "March 1st"  # 5.11
    @test format_relative(en, "2025-04-10", "2025-03-15") == "April 10th"  # 5.12
    @test format_relative(en, "2026-01-05", "2025-03-15") == "January 5th, 2026"  # 5.13
    @test format_relative(en, "2024-12-25", "2025-03-15") == "December 25th, 2024"  # 5.14
end

# Section 6: format_relative — compact skips weekday tiers
@testset "format_relative — compact skips weekday tiers" begin
    en_compact = SayableDateFormatter(get_locale("en"), Compact)
    @test format_relative(en_compact, "2025-03-15", "2025-03-15") == "today"  # 6.1
    @test format_relative(en_compact, "2025-03-16", "2025-03-15") == "tomorrow"  # 6.2
    @test format_relative(en_compact, "2025-03-19", "2025-03-15") == "3/19"  # 6.3
    @test format_relative(en_compact, "2026-01-05", "2025-03-15") == "1/5/26"  # 6.4
end

# Section 7: Locale — German
@testset "Locale — German" begin
    de = SayableDateFormatter(get_locale("de"))
    @test format_date(de, "2025-03-15") == "15. März"  # 7.1
    @test format_relative(de, "2025-03-16", "2025-03-15") == "morgen"  # 7.2
    @test format_relative(de, "2025-03-17", "2025-03-15") == "übermorgen"  # 7.3
    @test format_relative(de, "2025-03-19", "2025-03-15") == "diesen Mittwoch"  # 7.4
end

# Section 8: Locale — French
@testset "Locale — French" begin
    fr = SayableDateFormatter(get_locale("fr"))
    @test format_date(fr, "2025-03-01") == "1er mars"  # 8.1
    @test format_date(fr, "2025-03-15") == "15 mars"  # 8.2
    @test format_relative(fr, "2025-03-16", "2025-03-15") == "demain"  # 8.3
end

# Section 9: Locale — Japanese
@testset "Locale — Japanese" begin
    ja = SayableDateFormatter(get_locale("ja"))
    @test format_date(ja, "2025-03-15") == "3月15日"  # 9.1
    @test format_relative(ja, "2025-03-16", "2025-03-15") == "明日"  # 9.2
    @test format_relative(ja, "2025-03-19", "2025-03-15") == "今度の水曜日"  # 9.3
end

# Section 10: Locale — Russian (genitive months)
@testset "Locale — Russian (genitive months)" begin
    ru = SayableDateFormatter(get_locale("ru"))
    @test format_date(ru, "2025-03-15") == "15 марта"  # 10.1
    @test format_relative(ru, "2025-03-16", "2025-03-15") == "завтра"  # 10.2
end

# Section 11: Locale — Arabic
@testset "Locale — Arabic" begin
    ar = SayableDateFormatter(get_locale("ar"))
    @test format_date(ar, "2025-03-15") == "15 مارس"  # 11.1
    @test format_relative(ar, "2025-03-16", "2025-03-15") == "غداً"  # 11.2
end

# Section 12: Locale — Spanish
@testset "Locale — Spanish" begin
    es = SayableDateFormatter(get_locale("es"))
    @test format_date(es, "2025-03-15") == "15 de marzo"  # 12.1
    @test format_relative(es, "2025-03-17", "2025-03-15") == "pasado mañana"  # 12.2
end

# Section 13: format_date_with_year
@testset "format_date_with_year" begin
    @test format_date_with_year(SayableDateFormatter(get_locale("en")), "2018-02-04") == "February 4th, 2018"  # 13.1
    @test format_date_with_year(SayableDateFormatter(get_locale("en"), Short), "2025-03-15") == "Mar 15, 2025"  # 13.2
    @test format_date_with_year(SayableDateFormatter(get_locale("en"), Compact), "1997-01-21") == "1/21/97"  # 13.3
    @test format_date_with_year(SayableDateFormatter(get_locale("tg"), Compact), "2007-05-20") == "20/5/07"  # 13.4
    @test format_date_with_year(SayableDateFormatter(get_locale("fi"), Short), "1996-06-21") == "21. kesäkuuta 1996"  # 13.5
end

# Section 14: Short month names (locales that keep the full genitive)
@testset "Short month names (locales that keep the full genitive)" begin
    @test format_date(SayableDateFormatter(get_locale("sk"), Short), "2031-02-15") == "15. februára"  # 14.1
    @test format_date(SayableDateFormatter(get_locale("cs"), Short), "2025-12-10") == "10. prosince"  # 14.2
    @test format_date(SayableDateFormatter(get_locale("uk"), Short), "2025-11-05") == "5 листопада"  # 14.3
    @test format_relative(SayableDateFormatter(get_locale("fi"), Short), "1998-08-08", "1998-08-15") == "8. elokuuta"  # 14.4
end

# Section 15: format_relative — short phrases
@testset "format_relative — short phrases" begin
    @test format_relative(SayableDateFormatter(get_locale("kw"), Short), "2035-12-04", "2035-12-02") == "an Mth ma"  # 15.1
    @test format_relative(SayableDateFormatter(get_locale("mam"), Short), "2000-01-23", "2000-01-25") == "Dom nchi'j"  # 15.2
    @test format_relative(SayableDateFormatter(get_locale("kek"), Short), "2014-10-24", "2014-10-22") == "a'in Vie"  # 15.3
end

# Section 16: Input validation
@testset "Input validation" begin
    @test format_date(SayableDateFormatter(get_locale("en")), "2025-02-30") === nothing  # 16.1
    @test format_date(SayableDateFormatter(get_locale("en")), "2025-13-01") === nothing  # 16.2
    @test format_date(SayableDateFormatter(get_locale("en")), "2025-6-1") === nothing  # 16.3
    @test format_date(SayableDateFormatter(get_locale("en")), " 2025-06-01") === nothing  # 16.4
    @test format_date(SayableDateFormatter(get_locale("en")), "2025-06-01T10:00:00") == "June 1st"  # 16.5
    @test format_date_with_year(SayableDateFormatter(get_locale("en")), "2023-02-29") === nothing  # 16.6
    @test format_relative(SayableDateFormatter(get_locale("en")), "2025-03-16", "2025-04-31") === nothing  # 16.7
end

# Locale lookup
@testset "Locale lookup" begin
    @test get_locale("en") !== nothing
    @test get_locale("en").code == "en"
    @test get_locale("xx") === nothing
    @test get_locale("") === nothing
end
