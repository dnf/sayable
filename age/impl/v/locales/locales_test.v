module locales

// All tests use explicit (dob, asOf) pairs for determinism.

// ================================================================
// Section 1: Null / edge cases
// ================================================================

// 1.1
fn test_1_1() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('', '')
	assert result == none
}

// 1.2
fn test_1_2() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('', '')
	assert result == none
}

// 1.3
fn test_1_3() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('', '')
	assert result == none
}

// 1.4
fn test_1_4() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-07-01', '2025-06-15')
	assert result == none
}

// 1.5
fn test_1_5() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('1525-06-15', '2025-06-15') or { panic('expected result for 1.5') }
	assert result == '500 years'
}

// 1.6
fn test_1_6() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('1524-06-15', '2025-06-15')
	assert result == none
}

// 1.7
fn test_1_7() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('1025-06-15', '2025-06-15')
	assert result == none
}

// ================================================================
// Section 2: Days tier (0–6 days)
// ================================================================

// 2.1
fn test_2_1() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-06-15', '2025-06-15') or { panic('expected result for 2.1') }
	assert result == 'Newborn'
}

// 2.2
fn test_2_2() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-06-14', '2025-06-15') or { panic('expected result for 2.2') }
	assert result == '1 day'
}

// 2.3
fn test_2_3() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-06-12', '2025-06-15') or { panic('expected result for 2.3') }
	assert result == '3 days'
}

// 2.4
fn test_2_4() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-06-09', '2025-06-15') or { panic('expected result for 2.4') }
	assert result == '6 days'
}

// 2.5
fn test_2_5() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-06-08', '2025-06-15') or { panic('expected result for 2.5') }
	assert result == '1 week'
}

// ================================================================
// Section 3: Weeks+days tier (7 days to <3 calendar months)
// ================================================================

// 3.1
fn test_3_1() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-06-08', '2025-06-15') or { panic('expected result for 3.1') }
	assert result == '1 week'
}

// 3.2
fn test_3_2() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-06-07', '2025-06-15') or { panic('expected result for 3.2') }
	assert result == '1 week, 1 day'
}

// 3.3
fn test_3_3() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-06-06', '2025-06-15') or { panic('expected result for 3.3') }
	assert result == '1 week, 2 days'
}

// 3.4
fn test_3_4() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-06-02', '2025-06-15') or { panic('expected result for 3.4') }
	assert result == '1 week, 6 days'
}

// 3.5
fn test_3_5() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-06-01', '2025-06-15') or { panic('expected result for 3.5') }
	assert result == '2 weeks'
}

// 3.6
fn test_3_6() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-05-31', '2025-06-15') or { panic('expected result for 3.6') }
	assert result == '2 weeks, 1 day'
}

// 3.7
fn test_3_7() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-05-26', '2025-06-15') or { panic('expected result for 3.7') }
	assert result == '2 weeks, 6 days'
}

// 3.8
fn test_3_8() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-05-25', '2025-06-15') or { panic('expected result for 3.8') }
	assert result == '3 weeks'
}

// 3.9
fn test_3_9() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-05-15', '2025-06-15') or { panic('expected result for 3.9') }
	assert result == '4 weeks, 3 days'
}

// 3.10
fn test_3_10() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-04-15', '2025-06-15') or { panic('expected result for 3.10') }
	assert result == '8 weeks, 5 days'
}

// 3.11
fn test_3_11() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-03-15', '2025-06-14') or { panic('expected result for 3.11') }
	assert result == '13 weeks'
}

// 3.12
fn test_3_12() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-03-15', '2025-06-15') or { panic('expected result for 3.12') }
	assert result == '3 months'
}

// ================================================================
// Section 4: Month boundaries — standard months
// ================================================================

// 4.1
fn test_4_1() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-01-01', '2025-04-01') or { panic('expected result for 4.1') }
	assert result == '3 months'
}

// 4.2
fn test_4_2() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-01-01', '2025-03-31') or { panic('expected result for 4.2') }
	assert result.contains('week')
}

// 4.3
fn test_4_3() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-06-15', '2025-09-15') or { panic('expected result for 4.3') }
	assert result == '3 months'
}

// 4.4
fn test_4_4() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-06-15', '2025-09-14') or { panic('expected result for 4.4') }
	assert result.contains('week')
}

// 4.5
fn test_4_5() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-06-15', '2025-12-15') or { panic('expected result for 4.5') }
	assert result == '6 months'
}

// ================================================================
// Section 5: Month boundaries — February non-leap year
// ================================================================

// 5.1
fn test_5_1() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-01-31', '2025-02-28') or { panic('expected result for 5.1') }
	assert result == '4 weeks'
}

// 5.2
fn test_5_2() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-01-31', '2025-04-30') or { panic('expected result for 5.2') }
	assert result == '3 months'
}

// 5.3
fn test_5_3() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-01-31', '2025-04-29') or { panic('expected result for 5.3') }
	assert result.contains('week')
}

// 5.4
fn test_5_4() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-02-01', '2025-05-01') or { panic('expected result for 5.4') }
	assert result == '3 months'
}

// 5.5
fn test_5_5() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-02-01', '2025-04-30') or { panic('expected result for 5.5') }
	assert result.contains('week')
}

// ================================================================
// Section 6: Month boundaries — February leap year
// ================================================================

// 6.1
fn test_6_1() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2024-01-31', '2024-02-29') or { panic('expected result for 6.1') }
	assert result == '4 weeks, 1 day'
}

// 6.2
fn test_6_2() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2024-01-31', '2024-02-28') or { panic('expected result for 6.2') }
	assert result == '4 weeks'
}

// 6.3
fn test_6_3() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2024-01-31', '2024-04-30') or { panic('expected result for 6.3') }
	assert result == '3 months'
}

// 6.4
fn test_6_4() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2024-01-30', '2024-02-29') or { panic('expected result for 6.4') }
	assert result.contains('week')
}

// 6.5
fn test_6_5() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2024-01-30', '2024-02-28') or { panic('expected result for 6.5') }
	assert result.contains('week')
}

// ================================================================
// Section 7: Month boundaries — 30-day months
// ================================================================

// 7.1
fn test_7_1() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-03-31', '2025-06-30') or { panic('expected result for 7.1') }
	assert result == '3 months'
}

// 7.2
fn test_7_2() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-03-31', '2025-06-29') or { panic('expected result for 7.2') }
	assert result.contains('week')
}

// 7.3
fn test_7_3() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-08-31', '2025-11-30') or { panic('expected result for 7.3') }
	assert result == '3 months'
}

// 7.4
fn test_7_4() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-08-31', '2025-11-29') or { panic('expected result for 7.4') }
	assert result.contains('week')
}

// ================================================================
// Section 8: Month boundaries — leap year baby (born Feb 29)
// ================================================================

// 8.1
fn test_8_1() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2024-02-29', '2024-05-29') or { panic('expected result for 8.1') }
	assert result == '3 months'
}

// 8.2
fn test_8_2() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2024-02-29', '2024-05-28') or { panic('expected result for 8.2') }
	assert result.contains('week')
}

// 8.3
fn test_8_3() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2024-02-29', '2025-02-28') or { panic('expected result for 8.3') }
	assert result == '12 months'
}

// 8.4
fn test_8_4() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2024-02-29', '2025-03-01') or { panic('expected result for 8.4') }
	assert result == '12 months'
}

// ================================================================
// Section 9: Months tier (3–23 months)
// ================================================================

// 9.1
fn test_9_1() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-01-15', '2025-04-15') or { panic('expected result for 9.1') }
	assert result == '3 months'
}

// 9.2
fn test_9_2() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-01-15', '2025-07-15') or { panic('expected result for 9.2') }
	assert result == '6 months'
}

// 9.3
fn test_9_3() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2024-06-15', '2025-06-15') or { panic('expected result for 9.3') }
	assert result == '12 months'
}

// 9.4
fn test_9_4() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2024-01-15', '2025-12-15') or { panic('expected result for 9.4') }
	assert result == '23 months'
}

// 9.5
fn test_9_5() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-01-15', '2025-07-14') or { panic('expected result for 9.5') }
	assert result == '5 months'
}

// 9.6
fn test_9_6() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2024-11-10', '2025-04-10') or { panic('expected result for 9.6') }
	assert result == '5 months'
}

// ================================================================
// Section 10: Years+months tier (24–35 months)
// ================================================================

// 10.1
fn test_10_1() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2023-06-15', '2025-06-15') or { panic('expected result for 10.1') }
	assert result == '2 years'
}

// 10.2
fn test_10_2() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2023-06-15', '2025-07-15') or { panic('expected result for 10.2') }
	assert result == '2 years, 1 month'
}

// 10.3
fn test_10_3() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2023-06-15', '2025-12-15') or { panic('expected result for 10.3') }
	assert result == '2 years, 6 months'
}

// 10.4
fn test_10_4() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2023-06-15', '2026-05-15') or { panic('expected result for 10.4') }
	assert result == '2 years, 11 months'
}

// 10.5
fn test_10_5() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2023-06-15', '2025-06-14') or { panic('expected result for 10.5') }
	assert result == '23 months'
}

// ================================================================
// Section 11: Half-year tier (3–6 years)
// ================================================================

// 11.1
fn test_11_1() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2022-06-15', '2025-06-15') or { panic('expected result for 11.1') }
	assert result == '3 years'
}

// 11.2
fn test_11_2() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2022-06-15', '2025-11-15') or { panic('expected result for 11.2') }
	assert result == '3 years'
}

// 11.3
fn test_11_3() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2022-06-15', '2025-12-15') or { panic('expected result for 11.3') }
	assert result == '3½ years'
}

// 11.4
fn test_11_4() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2022-06-15', '2026-05-15') or { panic('expected result for 11.4') }
	assert result == '3½ years'
}

// 11.5
fn test_11_5() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2021-06-15', '2025-06-15') or { panic('expected result for 11.5') }
	assert result == '4 years'
}

// 11.6
fn test_11_6() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2021-06-15', '2025-12-15') or { panic('expected result for 11.6') }
	assert result == '4½ years'
}

// 11.7
fn test_11_7() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2020-06-15', '2025-06-15') or { panic('expected result for 11.7') }
	assert result == '5 years'
}

// 11.8
fn test_11_8() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2020-06-15', '2026-02-15') or { panic('expected result for 11.8') }
	assert result == '5½ years'
}

// 11.9
fn test_11_9() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2019-06-15', '2025-06-15') or { panic('expected result for 11.9') }
	assert result == '6 years'
}

// 11.10
fn test_11_10() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2019-06-15', '2025-12-15') or { panic('expected result for 11.10') }
	assert result == '6½ years'
}

// 11.11
fn test_11_11() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2019-06-15', '2026-05-15') or { panic('expected result for 11.11') }
	assert result == '6½ years'
}

// 11.12
fn test_11_12() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2022-06-15', '2025-06-14') or { panic('expected result for 11.12') }
	assert result == '2 years, 11 months'
}

// ================================================================
// Section 12: Integer tier (7+ years)
// ================================================================

// 12.1
fn test_12_1() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2018-06-15', '2025-06-15') or { panic('expected result for 12.1') }
	assert result == '7 years'
}

// 12.2
fn test_12_2() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2018-03-20', '2025-06-15') or { panic('expected result for 12.2') }
	assert result == '7 years'
}

// 12.3
fn test_12_3() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('1980-01-01', '2025-06-15') or { panic('expected result for 12.3') }
	assert result == '45 years'
}

// ================================================================
// Section 13: Cross-year transitions with February
// ================================================================

// 13.1
fn test_13_1() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2024-12-31', '2025-03-31') or { panic('expected result for 13.1') }
	assert result == '3 months'
}

// 13.2
fn test_13_2() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2024-12-31', '2025-03-30') or { panic('expected result for 13.2') }
	assert result.contains('week')
}

// 13.3
fn test_13_3() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2024-11-30', '2025-02-28') or { panic('expected result for 13.3') }
	assert result == '3 months'
}

// 13.4
fn test_13_4() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2024-11-30', '2025-02-27') or { panic('expected result for 13.4') }
	assert result.contains('week')
}

// ================================================================
// Section 14: Born-on-31st progression
// ================================================================

// 14.1
fn test_14_1() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-01-31', '2025-04-30') or { panic('expected result for 14.1') }
	assert result == '3 months'
}

// 14.2
fn test_14_2() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-01-31', '2025-05-31') or { panic('expected result for 14.2') }
	assert result == '4 months'
}

// 14.3
fn test_14_3() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-01-31', '2025-06-30') or { panic('expected result for 14.3') }
	assert result == '5 months'
}

// 14.4
fn test_14_4() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-01-31', '2025-07-01') or { panic('expected result for 14.4') }
	assert result == '5 months'
}

// 14.5
fn test_14_5() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-01-31', '2025-07-31') or { panic('expected result for 14.5') }
	assert result == '6 months'
}

// ================================================================
// Section 15: Default asOf (current date)
// ================================================================

// 15.1: Skipped (requires system date mocking)

// 15.2: Skipped (requires system date mocking)

// ================================================================
// Section 16: formatStage — null / edge cases
// ================================================================

// 16.1
fn test_16_1() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('', '', '')
	assert result == none
}

// 16.2
fn test_16_2() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('undefined', '', '')
	assert result == none
}

// 16.3
fn test_16_3() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('', '', '')
	assert result == none
}

// 16.4
fn test_16_4() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('2025-07-01', '2025-06-15', '')
	assert result == none
}

// 16.5
fn test_16_5() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('1525-06-15', '2025-06-15', '') or { panic('expected result for 16.5') }
	assert result == 'Adult'
}

// 16.6
fn test_16_6() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('1524-06-15', '2025-06-15', '')
	assert result == none
}

// ================================================================
// Section 17: formatStage — Newborn (0–1 months, <2 calendar months)
// ================================================================

// 17.1
fn test_17_1() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('2025-06-15', '2025-06-15', '') or { panic('expected result for 17.1') }
	assert result == 'Newborn'
}

// 17.2
fn test_17_2() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('2025-06-14', '2025-06-15', '') or { panic('expected result for 17.2') }
	assert result == 'Newborn'
}

// 17.3
fn test_17_3() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('2025-05-25', '2025-06-15', '') or { panic('expected result for 17.3') }
	assert result == 'Newborn'
}

// 17.4
fn test_17_4() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('2025-05-15', '2025-06-15', '') or { panic('expected result for 17.4') }
	assert result == 'Newborn'
}

// 17.5
fn test_17_5() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('2025-04-16', '2025-06-15', '') or { panic('expected result for 17.5') }
	assert result == 'Newborn'
}

// 17.6
fn test_17_6() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('2025-04-15', '2025-06-15', '') or { panic('expected result for 17.6') }
	assert result == 'Infant'
}

// ================================================================
// Section 18: formatStage — Infant (2–11 months)
// ================================================================

// 18.1
fn test_18_1() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('2025-04-15', '2025-06-15', '') or { panic('expected result for 18.1') }
	assert result == 'Infant'
}

// 18.2
fn test_18_2() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('2024-12-15', '2025-06-15', '') or { panic('expected result for 18.2') }
	assert result == 'Infant'
}

// 18.3
fn test_18_3() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('2024-07-15', '2025-06-15', '') or { panic('expected result for 18.3') }
	assert result == 'Infant'
}

// 18.4
fn test_18_4() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('2024-06-15', '2025-06-15', '') or { panic('expected result for 18.4') }
	assert result == 'Toddler'
}

// ================================================================
// Section 19: formatStage — Toddler (12–35 months)
// ================================================================

// 19.1
fn test_19_1() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('2024-06-15', '2025-06-15', '') or { panic('expected result for 19.1') }
	assert result == 'Toddler'
}

// 19.2
fn test_19_2() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('2024-01-15', '2025-07-15', '') or { panic('expected result for 19.2') }
	assert result == 'Toddler'
}

// 19.3
fn test_19_3() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('2023-06-15', '2025-06-15', '') or { panic('expected result for 19.3') }
	assert result == 'Toddler'
}

// 19.4
fn test_19_4() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('2023-06-15', '2026-05-15', '') or { panic('expected result for 19.4') }
	assert result == 'Toddler'
}

// 19.5
fn test_19_5() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('2022-06-15', '2025-06-15', '') or { panic('expected result for 19.5') }
	assert result == 'Child'
}

// ================================================================
// Section 20: formatStage — Child (36–155 months, 3–12 years)
// ================================================================

// 20.1
fn test_20_1() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('2022-06-15', '2025-06-15', '') or { panic('expected result for 20.1') }
	assert result == 'Child'
}

// 20.2
fn test_20_2() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('2021-06-15', '2025-06-15', '') or { panic('expected result for 20.2') }
	assert result == 'Child'
}

// 20.3
fn test_20_3() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('2019-06-15', '2025-06-15', '') or { panic('expected result for 20.3') }
	assert result == 'Child'
}

// 20.4
fn test_20_4() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('2016-06-15', '2025-06-15', '') or { panic('expected result for 20.4') }
	assert result == 'Child'
}

// 20.5
fn test_20_5() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('2013-06-15', '2026-05-15', '') or { panic('expected result for 20.5') }
	assert result == 'Child'
}

// 20.6
fn test_20_6() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('2012-06-15', '2025-06-15', '') or { panic('expected result for 20.6') }
	assert result == 'Teenager'
}

// ================================================================
// Section 21: formatStage — Teenager (156–215 months, 13–17 years)
// ================================================================

// 21.1
fn test_21_1() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('2012-06-15', '2025-06-15', '') or { panic('expected result for 21.1') }
	assert result == 'Teenager'
}

// 21.2
fn test_21_2() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('2010-06-15', '2025-06-15', '') or { panic('expected result for 21.2') }
	assert result == 'Teenager'
}

// 21.3
fn test_21_3() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('2008-06-15', '2026-05-15', '') or { panic('expected result for 21.3') }
	assert result == 'Teenager'
}

// 21.4
fn test_21_4() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('2007-06-15', '2025-06-15', '') or { panic('expected result for 21.4') }
	assert result == 'Adult'
}

// ================================================================
// Section 22: formatStage — Adult (216+ months, 18+ years)
// ================================================================

// 22.1
fn test_22_1() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('2007-06-15', '2025-06-15', '') or { panic('expected result for 22.1') }
	assert result == 'Adult'
}

// 22.2
fn test_22_2() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('2000-06-15', '2025-06-15', '') or { panic('expected result for 22.2') }
	assert result == 'Adult'
}

// 22.3
fn test_22_3() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('1980-01-01', '2025-06-15', '') or { panic('expected result for 22.3') }
	assert result == 'Adult'
}

// ================================================================
// Section 23: formatStage — default asOf
// ================================================================

// 23.1: Skipped (requires system date mocking)

// 23.2: Skipped (requires system date mocking)

// 23.3: Skipped (requires system date mocking)

// ================================================================
// Section 24: SayableAge class — English locale delegation
// ================================================================

// 24.1
fn test_24_1() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-06-15', '2025-06-15') or { panic('expected result for 24.1') }
	assert result == 'Newborn'
}

// 24.2
fn test_24_2() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-06-12', '2025-06-15') or { panic('expected result for 24.2') }
	assert result == '3 days'
}

// 24.3
fn test_24_3() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-06-07', '2025-06-15') or { panic('expected result for 24.3') }
	assert result == '1 week, 1 day'
}

// 24.4
fn test_24_4() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2025-01-15', '2025-07-15') or { panic('expected result for 24.4') }
	assert result == '6 months'
}

// 24.5
fn test_24_5() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2023-06-15', '2025-07-15') or { panic('expected result for 24.5') }
	assert result == '2 years, 1 month'
}

// 24.6
fn test_24_6() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2022-06-15', '2025-12-15') or { panic('expected result for 24.6') }
	assert result == '3½ years'
}

// 24.7
fn test_24_7() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('2018-06-15', '2025-06-15') or { panic('expected result for 24.7') }
	assert result == '7 years'
}

// 24.8
fn test_24_8() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('2025-06-15', '2025-06-15', '') or { panic('expected result for 24.8') }
	assert result == 'Newborn'
}

// 24.9
fn test_24_9() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('2025-01-15', '2025-06-15', '') or { panic('expected result for 24.9') }
	assert result == 'Infant'
}

// 24.10
fn test_24_10() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('2024-06-15', '2025-06-15', '') or { panic('expected result for 24.10') }
	assert result == 'Toddler'
}

// 24.11
fn test_24_11() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('2022-06-15', '2025-06-15', '') or { panic('expected result for 24.11') }
	assert result == 'Child'
}

// 24.12
fn test_24_12() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('2012-06-15', '2025-06-15', '') or { panic('expected result for 24.12') }
	assert result == 'Teenager'
}

// 24.13
fn test_24_13() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('2007-06-15', '2025-06-15', '') or { panic('expected result for 24.13') }
	assert result == 'Adult'
}

// 24.14
fn test_24_14() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_age('', '2025-06-15')
	assert result == none
}

// 24.15
fn test_24_15() {
	sa := new_sayable_age(&locale_en, .normal)
	result := sa.format_stage('', '2025-06-15', '')
	assert result == none
}

// ================================================================
// Section 25: i18n — locale with all plural features
// ================================================================

// 25.1
fn test_25_1() {
	sa := new_sayable_age(&locale_es, .normal)
	result := sa.format_age('2025-06-15', '2025-06-15') or { panic('expected result for 25.1') }
	assert result == 'Recién nacido'
}

// 25.2
fn test_25_2() {
	sa := new_sayable_age(&locale_es, .normal)
	result := sa.format_age('2025-06-14', '2025-06-15') or { panic('expected result for 25.2') }
	assert result == '1 día'
}

// 25.3
fn test_25_3() {
	sa := new_sayable_age(&locale_es, .normal)
	result := sa.format_age('2025-06-12', '2025-06-15') or { panic('expected result for 25.3') }
	assert result == '3 días'
}

// 25.4
fn test_25_4() {
	sa := new_sayable_age(&locale_es, .normal)
	result := sa.format_age('2025-06-08', '2025-06-15') or { panic('expected result for 25.4') }
	assert result == '1 semana'
}

// 25.5
fn test_25_5() {
	sa := new_sayable_age(&locale_es, .normal)
	result := sa.format_age('2025-06-07', '2025-06-15') or { panic('expected result for 25.5') }
	assert result == '1 semana, 1 día'
}

// 25.6
fn test_25_6() {
	sa := new_sayable_age(&locale_es, .normal)
	result := sa.format_age('2025-05-26', '2025-06-15') or { panic('expected result for 25.6') }
	assert result == '2 semanas, 6 días'
}

// 25.7
fn test_25_7() {
	sa := new_sayable_age(&locale_es, .normal)
	result := sa.format_age('2025-01-15', '2025-07-15') or { panic('expected result for 25.7') }
	assert result == '6 meses'
}

// 25.8
fn test_25_8() {
	sa := new_sayable_age(&locale_es, .normal)
	result := sa.format_age('2023-06-15', '2025-07-15') or { panic('expected result for 25.8') }
	assert result == '2 años, 1 mes'
}

// 25.9
fn test_25_9() {
	sa := new_sayable_age(&locale_es, .normal)
	result := sa.format_age('2023-06-15', '2025-12-15') or { panic('expected result for 25.9') }
	assert result == '2 años, 6 meses'
}

// 25.10
fn test_25_10() {
	sa := new_sayable_age(&locale_es, .normal)
	result := sa.format_age('2022-06-15', '2025-12-15') or { panic('expected result for 25.10') }
	assert result == '3 años y medio'
}

// 25.11
fn test_25_11() {
	sa := new_sayable_age(&locale_es, .normal)
	result := sa.format_age('2022-06-15', '2025-06-15') or { panic('expected result for 25.11') }
	assert result == '3 años'
}

// 25.12
fn test_25_12() {
	sa := new_sayable_age(&locale_es, .normal)
	result := sa.format_age('2018-06-15', '2025-06-15') or { panic('expected result for 25.12') }
	assert result == '7 años'
}

// 25.13
fn test_25_13() {
	sa := new_sayable_age(&locale_es, .normal)
	result := sa.format_stage('2025-06-15', '2025-06-15', '') or { panic('expected result for 25.13') }
	assert result == 'Recién nacido'
}

// 25.14
fn test_25_14() {
	sa := new_sayable_age(&locale_es, .normal)
	result := sa.format_stage('2025-01-15', '2025-06-15', '') or { panic('expected result for 25.14') }
	assert result == 'Bebé'
}

// 25.15
fn test_25_15() {
	sa := new_sayable_age(&locale_es, .normal)
	result := sa.format_stage('2024-06-15', '2025-06-15', '') or { panic('expected result for 25.15') }
	assert result == 'Niño pequeño'
}

// 25.16
fn test_25_16() {
	sa := new_sayable_age(&locale_es, .normal)
	result := sa.format_stage('2022-06-15', '2025-06-15', '') or { panic('expected result for 25.16') }
	assert result == 'Niño'
}

// 25.17
fn test_25_17() {
	sa := new_sayable_age(&locale_es, .normal)
	result := sa.format_stage('2012-06-15', '2025-06-15', '') or { panic('expected result for 25.17') }
	assert result == 'Adolescente'
}

// 25.18
fn test_25_18() {
	sa := new_sayable_age(&locale_es, .normal)
	result := sa.format_stage('2007-06-15', '2025-06-15', '') or { panic('expected result for 25.18') }
	assert result == 'Adulto'
}

// 25.19
fn test_25_19() {
	sa := new_sayable_age(&locale_es, .normal)
	result := sa.format_age('', '2025-06-15')
	assert result == none
}

// 25.20
fn test_25_20() {
	sa := new_sayable_age(&locale_es, .normal)
	result := sa.format_stage('', '2025-06-15', '')
	assert result == none
}

// ================================================================
// Section 26: Compactness — short
// ================================================================

// 26.1
fn test_26_1() {
	sa := new_sayable_age(&locale_en, .short)
	result := sa.format_age('2025-06-12', '2025-06-15') or { panic('expected result for 26.1') }
	assert result == '3 d'
}

// 26.2
fn test_26_2() {
	sa := new_sayable_age(&locale_en, .short)
	result := sa.format_age('2025-06-08', '2025-06-15') or { panic('expected result for 26.2') }
	assert result == '1 wk'
}

// 26.3
fn test_26_3() {
	sa := new_sayable_age(&locale_en, .short)
	result := sa.format_age('2025-06-07', '2025-06-15') or { panic('expected result for 26.3') }
	assert result == '1 wk, 1 d'
}

// 26.4
fn test_26_4() {
	sa := new_sayable_age(&locale_en, .short)
	result := sa.format_age('2025-01-15', '2025-07-15') or { panic('expected result for 26.4') }
	assert result == '6 mo'
}

// 26.5
fn test_26_5() {
	sa := new_sayable_age(&locale_en, .short)
	result := sa.format_age('2023-06-15', '2025-07-15') or { panic('expected result for 26.5') }
	assert result == '2 yr, 1 mo'
}

// 26.6
fn test_26_6() {
	sa := new_sayable_age(&locale_en, .short)
	result := sa.format_age('2022-06-15', '2025-12-15') or { panic('expected result for 26.6') }
	assert result == '3½ yr'
}

// 26.7
fn test_26_7() {
	sa := new_sayable_age(&locale_en, .short)
	result := sa.format_age('2018-06-15', '2025-06-15') or { panic('expected result for 26.7') }
	assert result == '7 yr'
}

// 26.8
fn test_26_8() {
	sa := new_sayable_age(&locale_en, .short)
	result := sa.format_age('2025-06-15', '2025-06-15') or { panic('expected result for 26.8') }
	assert result == 'Newborn'
}

// 26.9
fn test_26_9() {
	sa := new_sayable_age(&locale_en, .short)
	result := sa.format_stage('2025-01-15', '2025-06-15', '') or { panic('expected result for 26.9') }
	assert result == 'Infant'
}

// ================================================================
// Section 27: Compactness — compact
// ================================================================

// 27.1
fn test_27_1() {
	sa := new_sayable_age(&locale_en, .compact)
	result := sa.format_age('2025-06-12', '2025-06-15') or { panic('expected result for 27.1') }
	assert result == '3d'
}

// 27.2
fn test_27_2() {
	sa := new_sayable_age(&locale_en, .compact)
	result := sa.format_age('2025-06-08', '2025-06-15') or { panic('expected result for 27.2') }
	assert result == '1w'
}

// 27.3
fn test_27_3() {
	sa := new_sayable_age(&locale_en, .compact)
	result := sa.format_age('2025-06-07', '2025-06-15') or { panic('expected result for 27.3') }
	assert result == '1w1d'
}

// 27.4
fn test_27_4() {
	sa := new_sayable_age(&locale_en, .compact)
	result := sa.format_age('2025-01-15', '2025-07-15') or { panic('expected result for 27.4') }
	assert result == '6m'
}

// 27.5
fn test_27_5() {
	sa := new_sayable_age(&locale_en, .compact)
	result := sa.format_age('2023-06-15', '2025-07-15') or { panic('expected result for 27.5') }
	assert result == '2y1m'
}

// 27.6
fn test_27_6() {
	sa := new_sayable_age(&locale_en, .compact)
	result := sa.format_age('2022-06-15', '2025-12-15') or { panic('expected result for 27.6') }
	assert result == '3½y'
}

// 27.7
fn test_27_7() {
	sa := new_sayable_age(&locale_en, .compact)
	result := sa.format_age('2018-06-15', '2025-06-15') or { panic('expected result for 27.7') }
	assert result == '7y'
}

// 27.8
fn test_27_8() {
	sa := new_sayable_age(&locale_en, .compact)
	result := sa.format_age('2025-06-15', '2025-06-15') or { panic('expected result for 27.8') }
	assert result == 'Newborn'
}

// ================================================================
// Section 29: Locale-specific edge cases — plural rules
// ================================================================

// 29.1
fn test_29_1() {
	sa := new_sayable_age(&locale_he, .normal)
	result := sa.format_age('2025-06-15', '2025-06-15') or { panic('expected result for 29.1') }
	assert result == 'רק נולד'
}

// 29.2
fn test_29_2() {
	sa := new_sayable_age(&locale_he, .normal)
	result := sa.format_age('2025-06-14', '2025-06-15') or { panic('expected result for 29.2') }
	assert result == 'יום'
}

// 29.3
fn test_29_3() {
	sa := new_sayable_age(&locale_he, .normal)
	result := sa.format_age('2025-06-12', '2025-06-15') or { panic('expected result for 29.3') }
	assert result == '3 ימים'
}

// 29.4
fn test_29_4() {
	sa := new_sayable_age(&locale_he, .normal)
	result := sa.format_age('2025-06-01', '2025-06-15') or { panic('expected result for 29.4') }
	assert result == 'שבועיים'
}

// 29.5
fn test_29_5() {
	sa := new_sayable_age(&locale_he, .normal)
	result := sa.format_age('2025-05-25', '2025-06-15') or { panic('expected result for 29.5') }
	assert result == '3 שבועות'
}

// 29.6
fn test_29_6() {
	sa := new_sayable_age(&locale_he, .normal)
	result := sa.format_age('2025-01-15', '2025-07-15') or { panic('expected result for 29.6') }
	assert result == '6 חודשים'
}

// 29.7
fn test_29_7() {
	sa := new_sayable_age(&locale_he, .normal)
	result := sa.format_age('2025-03-15', '2025-06-15') or { panic('expected result for 29.7') }
	assert result == '3 חודשים'
}

// 29.8
fn test_29_8() {
	sa := new_sayable_age(&locale_he, .normal)
	result := sa.format_age('2023-06-15', '2025-07-15') or { panic('expected result for 29.8') }
	assert result == 'שנתיים, חודש'
}

// 29.9
fn test_29_9() {
	sa := new_sayable_age(&locale_he, .normal)
	result := sa.format_age('2022-06-15', '2025-12-15') or { panic('expected result for 29.9') }
	assert result == '3 שנים וחצי'
}

// 29.10
fn test_29_10() {
	sa := new_sayable_age(&locale_he, .normal)
	result := sa.format_age('2018-06-15', '2025-06-15') or { panic('expected result for 29.10') }
	assert result == '7 שנים'
}

// 29.11
fn test_29_11() {
	sa := new_sayable_age(&locale_he, .normal)
	result := sa.format_stage('2025-06-15', '2025-06-15', 'm') or { panic('expected result for 29.11') }
	assert result == 'רק נולד'
}

// 29.12
fn test_29_12() {
	sa := new_sayable_age(&locale_he, .normal)
	result := sa.format_stage('2025-06-15', '2025-06-15', 'f') or { panic('expected result for 29.12') }
	assert result == 'רק נולדה'
}

// 29.13
fn test_29_13() {
	sa := new_sayable_age(&locale_he, .normal)
	result := sa.format_stage('2007-06-15', '2025-06-15', 'm') or { panic('expected result for 29.13') }
	assert result == 'מבוגר'
}

// 29.14
fn test_29_14() {
	sa := new_sayable_age(&locale_he, .normal)
	result := sa.format_stage('2007-06-15', '2025-06-15', 'f') or { panic('expected result for 29.14') }
	assert result == 'מבוגרת'
}

// 29.15
fn test_29_15() {
	sa := new_sayable_age(&locale_mk, .normal)
	result := sa.format_age('2025-06-15', '2025-06-15') or { panic('expected result for 29.15') }
	assert result == 'Новороденче'
}

// 29.16
fn test_29_16() {
	sa := new_sayable_age(&locale_mk, .normal)
	result := sa.format_age('2025-06-14', '2025-06-15') or { panic('expected result for 29.16') }
	assert result == '1 ден'
}

// 29.17
fn test_29_17() {
	sa := new_sayable_age(&locale_mk, .normal)
	result := sa.format_age('2025-06-12', '2025-06-15') or { panic('expected result for 29.17') }
	assert result == '3 дена'
}

// 29.18
fn test_29_18() {
	sa := new_sayable_age(&locale_mk, .normal)
	result := sa.format_age('2025-01-15', '2025-07-15') or { panic('expected result for 29.18') }
	assert result == '6 месеци'
}

// 29.19
fn test_29_19() {
	sa := new_sayable_age(&locale_mk, .normal)
	result := sa.format_age('2023-06-15', '2025-07-15') or { panic('expected result for 29.19') }
	assert result == '2 години, 1 месец'
}

// 29.20
fn test_29_20() {
	sa := new_sayable_age(&locale_mk, .normal)
	result := sa.format_age('2022-06-15', '2025-12-15') or { panic('expected result for 29.20') }
	assert result == '3 години и пол'
}

// 29.21
fn test_29_21() {
	sa := new_sayable_age(&locale_mk, .normal)
	result := sa.format_age('2018-06-15', '2025-06-15') or { panic('expected result for 29.21') }
	assert result == '7 години'
}

// 29.22
fn test_29_22() {
	sa := new_sayable_age(&locale_sw, .normal)
	result := sa.format_age('2025-06-15', '2025-06-15') or { panic('expected result for 29.22') }
	assert result == 'Mzaliwa mpya'
}

// 29.23
fn test_29_23() {
	sa := new_sayable_age(&locale_sw, .normal)
	result := sa.format_age('2025-06-14', '2025-06-15') or { panic('expected result for 29.23') }
	assert result == 'siku 1'
}

// 29.24
fn test_29_24() {
	sa := new_sayable_age(&locale_sw, .normal)
	result := sa.format_age('2025-06-12', '2025-06-15') or { panic('expected result for 29.24') }
	assert result == 'siku 3'
}

// 29.25
fn test_29_25() {
	sa := new_sayable_age(&locale_sw, .normal)
	result := sa.format_age('2025-01-15', '2025-07-15') or { panic('expected result for 29.25') }
	assert result == 'miezi 6'
}

// 29.26
fn test_29_26() {
	sa := new_sayable_age(&locale_sw, .normal)
	result := sa.format_age('2023-06-15', '2025-07-15') or { panic('expected result for 29.26') }
	assert result == 'miaka 2, mwezi 1'
}

// 29.27
fn test_29_27() {
	sa := new_sayable_age(&locale_sw, .normal)
	result := sa.format_age('2022-06-15', '2025-12-15') or { panic('expected result for 29.27') }
	assert result == 'miaka 3 na nusu'
}

// 29.28
fn test_29_28() {
	sa := new_sayable_age(&locale_id, .normal)
	result := sa.format_age('2025-06-15', '2025-06-15') or { panic('expected result for 29.28') }
	assert result == 'Baru lahir'
}

// 29.29
fn test_29_29() {
	sa := new_sayable_age(&locale_id, .normal)
	result := sa.format_age('2025-06-14', '2025-06-15') or { panic('expected result for 29.29') }
	assert result == '1 hari'
}

// 29.30
fn test_29_30() {
	sa := new_sayable_age(&locale_id, .normal)
	result := sa.format_age('2025-06-12', '2025-06-15') or { panic('expected result for 29.30') }
	assert result == '3 hari'
}

// 29.31
fn test_29_31() {
	sa := new_sayable_age(&locale_id, .normal)
	result := sa.format_age('2025-01-15', '2025-07-15') or { panic('expected result for 29.31') }
	assert result == '6 bulan'
}

// 29.32
fn test_29_32() {
	sa := new_sayable_age(&locale_id, .normal)
	result := sa.format_age('2022-06-15', '2025-12-15') or { panic('expected result for 29.32') }
	assert result == '3 setengah tahun'
}

// 29.33
fn test_29_33() {
	sa := new_sayable_age(&locale_id, .normal)
	result := sa.format_age('2018-06-15', '2025-06-15') or { panic('expected result for 29.33') }
	assert result == '7 tahun'
}

// 29.34
fn test_29_34() {
	sa := new_sayable_age(&locale_am, .normal)
	result := sa.format_age('2025-06-15', '2025-06-15') or { panic('expected result for 29.34') }
	assert result == 'አዲስ የተወለደ'
}

// 29.35
fn test_29_35() {
	sa := new_sayable_age(&locale_am, .normal)
	result := sa.format_age('2025-06-14', '2025-06-15') or { panic('expected result for 29.35') }
	assert result == '1 ቀን'
}

// 29.36
fn test_29_36() {
	sa := new_sayable_age(&locale_am, .normal)
	result := sa.format_age('2025-06-12', '2025-06-15') or { panic('expected result for 29.36') }
	assert result == '3 ቀናት'
}

// 29.37
fn test_29_37() {
	sa := new_sayable_age(&locale_am, .normal)
	result := sa.format_age('2025-06-07', '2025-06-15') or { panic('expected result for 29.37') }
	assert result == '1 ሳምንት፣ 1 ቀን'
}

// 29.38
fn test_29_38() {
	sa := new_sayable_age(&locale_am, .normal)
	result := sa.format_age('2025-01-15', '2025-07-15') or { panic('expected result for 29.38') }
	assert result == '6 ወራት'
}

// 29.39
fn test_29_39() {
	sa := new_sayable_age(&locale_am, .normal)
	result := sa.format_age('2022-06-15', '2025-12-15') or { panic('expected result for 29.39') }
	assert result == '3 ዓመታት ተኩል'
}

// ================================================================
// Section 30: Locale lookup by code string
// ================================================================

// 30.1
fn test_30_1() {
	result := get_locale('en') or { panic('expected locale') }
	assert result.code == 'en'
}

// 30.2
fn test_30_2() {
	result := get_locale('fr') or { panic('expected locale') }
	assert result.code == 'fr'
}

// 30.3
fn test_30_3() {
	result := get_locale('xx')
	assert result == none
}

// 30.4
fn test_30_4() {
	result := get_locale('')
	assert result == none
}

// 30.5
fn test_30_5() {
	result := get_locale('EN')
	assert result == none
}

