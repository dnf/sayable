package sayableage

// Canonical age tests generated from age/config/tests.json (IDs missing from test_format_age.odin).

import "core:testing"

// 3.2
@(test)
test_canonical_3_2 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "1 week, 1 day", format_age(buf[:], &locale_en, .Normal, "2025-06-07", "2025-06-15"))
}

// 3.3
@(test)
test_canonical_3_3 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "1 week, 2 days", format_age(buf[:], &locale_en, .Normal, "2025-06-06", "2025-06-15"))
}

// 3.4
@(test)
test_canonical_3_4 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "1 week, 6 days", format_age(buf[:], &locale_en, .Normal, "2025-06-02", "2025-06-15"))
}

// 3.5
@(test)
test_canonical_3_5 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "2 weeks", format_age(buf[:], &locale_en, .Normal, "2025-06-01", "2025-06-15"))
}

// 3.6
@(test)
test_canonical_3_6 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "2 weeks, 1 day", format_age(buf[:], &locale_en, .Normal, "2025-05-31", "2025-06-15"))
}

// 3.7
@(test)
test_canonical_3_7 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "2 weeks, 6 days", format_age(buf[:], &locale_en, .Normal, "2025-05-26", "2025-06-15"))
}

// 3.8
@(test)
test_canonical_3_8 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "3 weeks", format_age(buf[:], &locale_en, .Normal, "2025-05-25", "2025-06-15"))
}

// 3.9
@(test)
test_canonical_3_9 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "4 weeks, 3 days", format_age(buf[:], &locale_en, .Normal, "2025-05-15", "2025-06-15"))
}

// 3.10
@(test)
test_canonical_3_10 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "8 weeks, 5 days", format_age(buf[:], &locale_en, .Normal, "2025-04-15", "2025-06-15"))
}

// 3.11
@(test)
test_canonical_3_11 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "13 weeks", format_age(buf[:], &locale_en, .Normal, "2025-03-15", "2025-06-14"))
}

// 4.2
@(test)
test_canonical_4_2 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "12 weeks, 5 days", format_age(buf[:], &locale_en, .Normal, "2025-01-01", "2025-03-31"))
}

// 4.3
@(test)
test_canonical_4_3 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "3 months", format_age(buf[:], &locale_en, .Normal, "2025-06-15", "2025-09-15"))
}

// 4.4
@(test)
test_canonical_4_4 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "13 weeks", format_age(buf[:], &locale_en, .Normal, "2025-06-15", "2025-09-14"))
}

// 5.2
@(test)
test_canonical_5_2 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "3 months", format_age(buf[:], &locale_en, .Normal, "2025-01-31", "2025-04-30"))
}

// 5.3
@(test)
test_canonical_5_3 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "12 weeks, 4 days", format_age(buf[:], &locale_en, .Normal, "2025-01-31", "2025-04-29"))
}

// 5.4
@(test)
test_canonical_5_4 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "3 months", format_age(buf[:], &locale_en, .Normal, "2025-02-01", "2025-05-01"))
}

// 6.2
@(test)
test_canonical_6_2 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "4 weeks", format_age(buf[:], &locale_en, .Normal, "2024-01-31", "2024-02-28"))
}

// 6.3
@(test)
test_canonical_6_3 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "3 months", format_age(buf[:], &locale_en, .Normal, "2024-01-31", "2024-04-30"))
}

// 6.4
@(test)
test_canonical_6_4 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "4 weeks, 2 days", format_age(buf[:], &locale_en, .Normal, "2024-01-30", "2024-02-29"))
}

// 7.2
@(test)
test_canonical_7_2 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "12 weeks, 6 days", format_age(buf[:], &locale_en, .Normal, "2025-03-31", "2025-06-29"))
}

// 7.3
@(test)
test_canonical_7_3 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "3 months", format_age(buf[:], &locale_en, .Normal, "2025-08-31", "2025-11-30"))
}

// 8.2
@(test)
test_canonical_8_2 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "12 weeks, 5 days", format_age(buf[:], &locale_en, .Normal, "2024-02-29", "2024-05-28"))
}

// 8.3
@(test)
test_canonical_8_3 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "12 months", format_age(buf[:], &locale_en, .Normal, "2024-02-29", "2025-02-28"))
}

// 9.2
@(test)
test_canonical_9_2 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "6 months", format_age(buf[:], &locale_en, .Normal, "2025-01-15", "2025-07-15"))
}

// 9.3
@(test)
test_canonical_9_3 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "12 months", format_age(buf[:], &locale_en, .Normal, "2024-06-15", "2025-06-15"))
}

// 9.4
@(test)
test_canonical_9_4 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "23 months", format_age(buf[:], &locale_en, .Normal, "2024-01-15", "2025-12-15"))
}

// 9.5
@(test)
test_canonical_9_5 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "5 months", format_age(buf[:], &locale_en, .Normal, "2025-01-15", "2025-07-14"))
}

// 10.2
@(test)
test_canonical_10_2 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "2 years, 1 month", format_age(buf[:], &locale_en, .Normal, "2023-06-15", "2025-07-15"))
}

// 10.3
@(test)
test_canonical_10_3 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "2 years, 6 months", format_age(buf[:], &locale_en, .Normal, "2023-06-15", "2025-12-15"))
}

// 10.4
@(test)
test_canonical_10_4 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "2 years, 11 months", format_age(buf[:], &locale_en, .Normal, "2023-06-15", "2026-05-15"))
}

// 11.2
@(test)
test_canonical_11_2 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "3 years", format_age(buf[:], &locale_en, .Normal, "2022-06-15", "2025-11-15"))
}

// 11.3
@(test)
test_canonical_11_3 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "3½ years", format_age(buf[:], &locale_en, .Normal, "2022-06-15", "2025-12-15"))
}

// 11.4
@(test)
test_canonical_11_4 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "3½ years", format_age(buf[:], &locale_en, .Normal, "2022-06-15", "2026-05-15"))
}

// 11.5
@(test)
test_canonical_11_5 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "4 years", format_age(buf[:], &locale_en, .Normal, "2021-06-15", "2025-06-15"))
}

// 11.6
@(test)
test_canonical_11_6 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "4½ years", format_age(buf[:], &locale_en, .Normal, "2021-06-15", "2025-12-15"))
}

// 11.7
@(test)
test_canonical_11_7 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "5 years", format_age(buf[:], &locale_en, .Normal, "2020-06-15", "2025-06-15"))
}

// 11.8
@(test)
test_canonical_11_8 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "5½ years", format_age(buf[:], &locale_en, .Normal, "2020-06-15", "2026-02-15"))
}

// 11.9
@(test)
test_canonical_11_9 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "6 years", format_age(buf[:], &locale_en, .Normal, "2019-06-15", "2025-06-15"))
}

// 11.11
@(test)
test_canonical_11_11 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "6½ years", format_age(buf[:], &locale_en, .Normal, "2019-06-15", "2026-05-15"))
}

// 12.2
@(test)
test_canonical_12_2 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "7 years", format_age(buf[:], &locale_en, .Normal, "2018-03-20", "2025-06-15"))
}

// 13.2
@(test)
test_canonical_13_2 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "12 weeks, 5 days", format_age(buf[:], &locale_en, .Normal, "2024-12-31", "2025-03-30"))
}

// 13.3
@(test)
test_canonical_13_3 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "3 months", format_age(buf[:], &locale_en, .Normal, "2024-11-30", "2025-02-28"))
}

// 14.2
@(test)
test_canonical_14_2 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "4 months", format_age(buf[:], &locale_en, .Normal, "2025-01-31", "2025-05-31"))
}

// 14.3
@(test)
test_canonical_14_3 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "5 months", format_age(buf[:], &locale_en, .Normal, "2025-01-31", "2025-06-30"))
}

// 14.4
@(test)
test_canonical_14_4 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "5 months", format_age(buf[:], &locale_en, .Normal, "2025-01-31", "2025-07-01"))
}

// 16.3
@(test)
test_canonical_16_3 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_nil(t, format_stage(&locale_en, "", "", ""))
}

// 16.4
@(test)
test_canonical_16_4 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_nil(t, format_stage(&locale_en, "2025-07-01", "2025-06-15", ""))
}

// 16.5
@(test)
test_canonical_16_5 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "Adult", format_stage(&locale_en, "1525-06-15", "2025-06-15", ""))
}

// 17.2
@(test)
test_canonical_17_2 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "Newborn", format_stage(&locale_en, "2025-06-14", "2025-06-15", ""))
}

// 17.3
@(test)
test_canonical_17_3 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "Newborn", format_stage(&locale_en, "2025-05-25", "2025-06-15", ""))
}

// 17.4
@(test)
test_canonical_17_4 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "Newborn", format_stage(&locale_en, "2025-05-15", "2025-06-15", ""))
}

// 17.5
@(test)
test_canonical_17_5 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "Newborn", format_stage(&locale_en, "2025-04-16", "2025-06-15", ""))
}

// 18.2
@(test)
test_canonical_18_2 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "Infant", format_stage(&locale_en, "2024-12-15", "2025-06-15", ""))
}

// 18.3
@(test)
test_canonical_18_3 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "Infant", format_stage(&locale_en, "2024-07-15", "2025-06-15", ""))
}

// 19.2
@(test)
test_canonical_19_2 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "Toddler", format_stage(&locale_en, "2024-01-15", "2025-07-15", ""))
}

// 19.3
@(test)
test_canonical_19_3 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "Toddler", format_stage(&locale_en, "2023-06-15", "2025-06-15", ""))
}

// 19.4
@(test)
test_canonical_19_4 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "Toddler", format_stage(&locale_en, "2023-06-15", "2026-05-15", ""))
}

// 20.2
@(test)
test_canonical_20_2 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "Child", format_stage(&locale_en, "2021-06-15", "2025-06-15", ""))
}

// 20.3
@(test)
test_canonical_20_3 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "Child", format_stage(&locale_en, "2019-06-15", "2025-06-15", ""))
}

// 20.4
@(test)
test_canonical_20_4 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "Child", format_stage(&locale_en, "2016-06-15", "2025-06-15", ""))
}

// 20.5
@(test)
test_canonical_20_5 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "Child", format_stage(&locale_en, "2013-06-15", "2026-05-15", ""))
}

// 21.2
@(test)
test_canonical_21_2 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "Teenager", format_stage(&locale_en, "2010-06-15", "2025-06-15", ""))
}

// 21.3
@(test)
test_canonical_21_3 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "Teenager", format_stage(&locale_en, "2008-06-15", "2026-05-15", ""))
}

// 22.2
@(test)
test_canonical_22_2 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "Adult", format_stage(&locale_en, "2000-06-15", "2025-06-15", ""))
}

// 24.2
@(test)
test_canonical_24_2 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "3 days", format_age(buf[:], &locale_en, .Normal, "2025-06-12", "2025-06-15"))
}

// 24.3
@(test)
test_canonical_24_3 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "1 week, 1 day", format_age(buf[:], &locale_en, .Normal, "2025-06-07", "2025-06-15"))
}

// 24.4
@(test)
test_canonical_24_4 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "6 months", format_age(buf[:], &locale_en, .Normal, "2025-01-15", "2025-07-15"))
}

// 24.5
@(test)
test_canonical_24_5 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "2 years, 1 month", format_age(buf[:], &locale_en, .Normal, "2023-06-15", "2025-07-15"))
}

// 24.6
@(test)
test_canonical_24_6 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "3½ years", format_age(buf[:], &locale_en, .Normal, "2022-06-15", "2025-12-15"))
}

// 24.7
@(test)
test_canonical_24_7 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "7 years", format_age(buf[:], &locale_en, .Normal, "2018-06-15", "2025-06-15"))
}

// 24.8
@(test)
test_canonical_24_8 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "Newborn", format_stage(&locale_en, "2025-06-15", "2025-06-15", ""))
}

// 24.9
@(test)
test_canonical_24_9 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "Infant", format_stage(&locale_en, "2025-01-15", "2025-06-15", ""))
}

// 24.10
@(test)
test_canonical_24_10 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "Toddler", format_stage(&locale_en, "2024-06-15", "2025-06-15", ""))
}

// 24.11
@(test)
test_canonical_24_11 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "Child", format_stage(&locale_en, "2022-06-15", "2025-06-15", ""))
}

// 24.12
@(test)
test_canonical_24_12 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "Teenager", format_stage(&locale_en, "2012-06-15", "2025-06-15", ""))
}

// 24.13
@(test)
test_canonical_24_13 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "Adult", format_stage(&locale_en, "2007-06-15", "2025-06-15", ""))
}

// 24.14
@(test)
test_canonical_24_14 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_nil(t, format_age(buf[:], &locale_en, .Normal, "", "2025-06-15"))
}

// 25.2
@(test)
test_canonical_25_2 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("es")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "1 día", format_age(buf[:], l, .Normal, "2025-06-14", "2025-06-15"))
}

// 25.3
@(test)
test_canonical_25_3 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("es")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "3 días", format_age(buf[:], l, .Normal, "2025-06-12", "2025-06-15"))
}

// 25.4
@(test)
test_canonical_25_4 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("es")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "1 semana", format_age(buf[:], l, .Normal, "2025-06-08", "2025-06-15"))
}

// 25.5
@(test)
test_canonical_25_5 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("es")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "1 semana, 1 día", format_age(buf[:], l, .Normal, "2025-06-07", "2025-06-15"))
}

// 25.6
@(test)
test_canonical_25_6 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("es")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "2 semanas, 6 días", format_age(buf[:], l, .Normal, "2025-05-26", "2025-06-15"))
}

// 25.7
@(test)
test_canonical_25_7 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("es")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "6 meses", format_age(buf[:], l, .Normal, "2025-01-15", "2025-07-15"))
}

// 25.8
@(test)
test_canonical_25_8 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("es")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "2 años, 1 mes", format_age(buf[:], l, .Normal, "2023-06-15", "2025-07-15"))
}

// 25.9
@(test)
test_canonical_25_9 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("es")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "2 años, 6 meses", format_age(buf[:], l, .Normal, "2023-06-15", "2025-12-15"))
}

// 25.10
@(test)
test_canonical_25_10 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("es")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "3 años y medio", format_age(buf[:], l, .Normal, "2022-06-15", "2025-12-15"))
}

// 25.11
@(test)
test_canonical_25_11 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("es")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "3 años", format_age(buf[:], l, .Normal, "2022-06-15", "2025-06-15"))
}

// 25.12
@(test)
test_canonical_25_12 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("es")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "7 años", format_age(buf[:], l, .Normal, "2018-06-15", "2025-06-15"))
}

// 25.13
@(test)
test_canonical_25_13 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("es")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "Recién nacido", format_stage(l, "2025-06-15", "2025-06-15", ""))
}

// 25.14
@(test)
test_canonical_25_14 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("es")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "Bebé", format_stage(l, "2025-01-15", "2025-06-15", ""))
}

// 25.15
@(test)
test_canonical_25_15 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("es")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "Niño pequeño", format_stage(l, "2024-06-15", "2025-06-15", ""))
}

// 25.16
@(test)
test_canonical_25_16 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("es")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "Niño", format_stage(l, "2022-06-15", "2025-06-15", ""))
}

// 25.17
@(test)
test_canonical_25_17 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("es")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "Adolescente", format_stage(l, "2012-06-15", "2025-06-15", ""))
}

// 25.18
@(test)
test_canonical_25_18 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("es")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "Adulto", format_stage(l, "2007-06-15", "2025-06-15", ""))
}

// 25.19
@(test)
test_canonical_25_19 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("es")
    if l == nil { testing.expect(t, false); return }
    expect_nil(t, format_age(buf[:], l, .Normal, "", "2025-06-15"))
}

// 26.2
@(test)
test_canonical_26_2 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "1 wk", format_age(buf[:], &locale_en, .Short, "2025-06-08", "2025-06-15"))
}

// 26.3
@(test)
test_canonical_26_3 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "1 wk, 1 d", format_age(buf[:], &locale_en, .Short, "2025-06-07", "2025-06-15"))
}

// 26.4
@(test)
test_canonical_26_4 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "6 mo", format_age(buf[:], &locale_en, .Short, "2025-01-15", "2025-07-15"))
}

// 26.5
@(test)
test_canonical_26_5 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "2 yr, 1 mo", format_age(buf[:], &locale_en, .Short, "2023-06-15", "2025-07-15"))
}

// 26.6
@(test)
test_canonical_26_6 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "3½ yr", format_age(buf[:], &locale_en, .Short, "2022-06-15", "2025-12-15"))
}

// 26.7
@(test)
test_canonical_26_7 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "7 yr", format_age(buf[:], &locale_en, .Short, "2018-06-15", "2025-06-15"))
}

// 26.8
@(test)
test_canonical_26_8 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "Newborn", format_age(buf[:], &locale_en, .Short, "2025-06-15", "2025-06-15"))
}

// 27.2
@(test)
test_canonical_27_2 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "1w", format_age(buf[:], &locale_en, .Compact, "2025-06-08", "2025-06-15"))
}

// 27.3
@(test)
test_canonical_27_3 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "1w1d", format_age(buf[:], &locale_en, .Compact, "2025-06-07", "2025-06-15"))
}

// 27.4
@(test)
test_canonical_27_4 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "6m", format_age(buf[:], &locale_en, .Compact, "2025-01-15", "2025-07-15"))
}

// 27.5
@(test)
test_canonical_27_5 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "2y1m", format_age(buf[:], &locale_en, .Compact, "2023-06-15", "2025-07-15"))
}

// 27.6
@(test)
test_canonical_27_6 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "3½y", format_age(buf[:], &locale_en, .Compact, "2022-06-15", "2025-12-15"))
}

// 27.7
@(test)
test_canonical_27_7 :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "7y", format_age(buf[:], &locale_en, .Compact, "2018-06-15", "2025-06-15"))
}

// 29.1
@(test)
test_canonical_29_1 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("he")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "רק נולד", format_age(buf[:], l, .Normal, "2025-06-15", "2025-06-15"))
}

// 29.2
@(test)
test_canonical_29_2 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("he")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "יום", format_age(buf[:], l, .Normal, "2025-06-14", "2025-06-15"))
}

// 29.4
@(test)
test_canonical_29_4 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("he")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "שבועיים", format_age(buf[:], l, .Normal, "2025-06-01", "2025-06-15"))
}

// 29.5
@(test)
test_canonical_29_5 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("he")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "3 שבועות", format_age(buf[:], l, .Normal, "2025-05-25", "2025-06-15"))
}

// 29.6
@(test)
test_canonical_29_6 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("he")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "6 חודשים", format_age(buf[:], l, .Normal, "2025-01-15", "2025-07-15"))
}

// 29.7
@(test)
test_canonical_29_7 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("he")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "3 חודשים", format_age(buf[:], l, .Normal, "2025-03-15", "2025-06-15"))
}

// 29.8
@(test)
test_canonical_29_8 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("he")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "שנתיים, חודש", format_age(buf[:], l, .Normal, "2023-06-15", "2025-07-15"))
}

// 29.9
@(test)
test_canonical_29_9 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("he")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "3 שנים וחצי", format_age(buf[:], l, .Normal, "2022-06-15", "2025-12-15"))
}

// 29.10
@(test)
test_canonical_29_10 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("he")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "7 שנים", format_age(buf[:], l, .Normal, "2018-06-15", "2025-06-15"))
}

// 29.11
@(test)
test_canonical_29_11 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("he")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "רק נולד", format_stage(l, "2025-06-15", "2025-06-15", "m"))
}

// 29.12
@(test)
test_canonical_29_12 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("he")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "רק נולדה", format_stage(l, "2025-06-15", "2025-06-15", "f"))
}

// 29.13
@(test)
test_canonical_29_13 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("he")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "מבוגר", format_stage(l, "2007-06-15", "2025-06-15", "m"))
}

// 29.14
@(test)
test_canonical_29_14 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("he")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "מבוגרת", format_stage(l, "2007-06-15", "2025-06-15", "f"))
}

// 29.15
@(test)
test_canonical_29_15 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("mk")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "Новороденче", format_age(buf[:], l, .Normal, "2025-06-15", "2025-06-15"))
}

// 29.16
@(test)
test_canonical_29_16 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("mk")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "1 ден", format_age(buf[:], l, .Normal, "2025-06-14", "2025-06-15"))
}

// 29.17
@(test)
test_canonical_29_17 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("mk")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "3 дена", format_age(buf[:], l, .Normal, "2025-06-12", "2025-06-15"))
}

// 29.18
@(test)
test_canonical_29_18 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("mk")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "6 месеци", format_age(buf[:], l, .Normal, "2025-01-15", "2025-07-15"))
}

// 29.19
@(test)
test_canonical_29_19 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("mk")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "2 години, 1 месец", format_age(buf[:], l, .Normal, "2023-06-15", "2025-07-15"))
}

// 29.20
@(test)
test_canonical_29_20 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("mk")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "3 години и пол", format_age(buf[:], l, .Normal, "2022-06-15", "2025-12-15"))
}

// 29.21
@(test)
test_canonical_29_21 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("mk")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "7 години", format_age(buf[:], l, .Normal, "2018-06-15", "2025-06-15"))
}

// 29.22
@(test)
test_canonical_29_22 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("sw")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "Mzaliwa mpya", format_age(buf[:], l, .Normal, "2025-06-15", "2025-06-15"))
}

// 29.23
@(test)
test_canonical_29_23 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("sw")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "siku 1", format_age(buf[:], l, .Normal, "2025-06-14", "2025-06-15"))
}

// 29.24
@(test)
test_canonical_29_24 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("sw")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "siku 3", format_age(buf[:], l, .Normal, "2025-06-12", "2025-06-15"))
}

// 29.25
@(test)
test_canonical_29_25 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("sw")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "miezi 6", format_age(buf[:], l, .Normal, "2025-01-15", "2025-07-15"))
}

// 29.26
@(test)
test_canonical_29_26 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("sw")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "miaka 2, mwezi 1", format_age(buf[:], l, .Normal, "2023-06-15", "2025-07-15"))
}

// 29.27
@(test)
test_canonical_29_27 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("sw")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "miaka 3 na nusu", format_age(buf[:], l, .Normal, "2022-06-15", "2025-12-15"))
}

// 29.28
@(test)
test_canonical_29_28 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("id")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "Baru lahir", format_age(buf[:], l, .Normal, "2025-06-15", "2025-06-15"))
}

// 29.29
@(test)
test_canonical_29_29 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("id")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "1 hari", format_age(buf[:], l, .Normal, "2025-06-14", "2025-06-15"))
}

// 29.30
@(test)
test_canonical_29_30 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("id")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "3 hari", format_age(buf[:], l, .Normal, "2025-06-12", "2025-06-15"))
}

// 29.31
@(test)
test_canonical_29_31 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("id")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "6 bulan", format_age(buf[:], l, .Normal, "2025-01-15", "2025-07-15"))
}

// 29.32
@(test)
test_canonical_29_32 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("id")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "3 setengah tahun", format_age(buf[:], l, .Normal, "2022-06-15", "2025-12-15"))
}

// 29.33
@(test)
test_canonical_29_33 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("id")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "7 tahun", format_age(buf[:], l, .Normal, "2018-06-15", "2025-06-15"))
}

// 29.34
@(test)
test_canonical_29_34 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("am")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "አዲስ የተወለደ", format_age(buf[:], l, .Normal, "2025-06-15", "2025-06-15"))
}

// 29.35
@(test)
test_canonical_29_35 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("am")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "1 ቀን", format_age(buf[:], l, .Normal, "2025-06-14", "2025-06-15"))
}

// 29.36
@(test)
test_canonical_29_36 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("am")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "3 ቀናት", format_age(buf[:], l, .Normal, "2025-06-12", "2025-06-15"))
}

// 29.37
@(test)
test_canonical_29_37 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("am")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "1 ሳምንት፣ 1 ቀን", format_age(buf[:], l, .Normal, "2025-06-07", "2025-06-15"))
}

// 29.38
@(test)
test_canonical_29_38 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("am")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "6 ወራት", format_age(buf[:], l, .Normal, "2025-01-15", "2025-07-15"))
}

// 29.39
@(test)
test_canonical_29_39 :: proc(t: ^testing.T) {
    buf: [256]u8
    l := get_locale("am")
    if l == nil { testing.expect(t, false); return }
    expect_str(t, "3 ዓመታት ተኩል", format_age(buf[:], l, .Normal, "2022-06-15", "2025-12-15"))
}

// 30.1
@(test)
test_canonical_30_1 :: proc(t: ^testing.T) {
    l := get_locale("en")
    testing.expect(t, l != nil)
    if l != nil do testing.expect_value(t, l.code, "en")
}

// 30.2
@(test)
test_canonical_30_2 :: proc(t: ^testing.T) {
    l := get_locale("fr")
    testing.expect(t, l != nil)
    if l != nil do testing.expect_value(t, l.code, "fr")
}

// 30.4
@(test)
test_canonical_30_4 :: proc(t: ^testing.T) {
    l := get_locale("")
    testing.expect(t, l == nil)
}
