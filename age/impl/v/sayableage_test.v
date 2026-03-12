module sayableage

import locales

fn test_1_1() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('', '')
	assert result == none, '1.1'
}

fn test_1_3() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('', '')
	assert result == none, '1.3'
}

fn test_1_4() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-07-01', '2025-06-15')
	assert result == none, '1.4'
}

fn test_1_5() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('1525-06-15', '2025-06-15') or { assert false, '1.5 should not be none'; return }
	assert result == '500 years', '1.5: got ${result}'
}

fn test_1_6() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('1524-06-15', '2025-06-15')
	assert result == none, '1.6'
}

fn test_1_7() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('1025-06-15', '2025-06-15')
	assert result == none, '1.7'
}

fn test_2_1() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-15', '2025-06-15') or { assert false, '2.1 should not be none'; return }
	assert result == 'Newborn', '2.1: got ${result}'
}

fn test_2_2() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-14', '2025-06-15') or { assert false, '2.2 should not be none'; return }
	assert result == '1 day', '2.2: got ${result}'
}

fn test_2_3() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-12', '2025-06-15') or { assert false, '2.3 should not be none'; return }
	assert result == '3 days', '2.3: got ${result}'
}

fn test_2_4() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-09', '2025-06-15') or { assert false, '2.4 should not be none'; return }
	assert result == '6 days', '2.4: got ${result}'
}

fn test_2_5() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-08', '2025-06-15') or { assert false, '2.5 should not be none'; return }
	assert result == '1 week', '2.5: got ${result}'
}

fn test_3_1() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-08', '2025-06-15') or { assert false, '3.1 should not be none'; return }
	assert result == '1 week', '3.1: got ${result}'
}

fn test_3_2() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-07', '2025-06-15') or { assert false, '3.2 should not be none'; return }
	assert result == '1 week, 1 day', '3.2: got ${result}'
}

fn test_3_3() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-06', '2025-06-15') or { assert false, '3.3 should not be none'; return }
	assert result == '1 week, 2 days', '3.3: got ${result}'
}

fn test_3_4() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-02', '2025-06-15') or { assert false, '3.4 should not be none'; return }
	assert result == '1 week, 6 days', '3.4: got ${result}'
}

fn test_3_5() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-01', '2025-06-15') or { assert false, '3.5 should not be none'; return }
	assert result == '2 weeks', '3.5: got ${result}'
}

fn test_3_6() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-05-31', '2025-06-15') or { assert false, '3.6 should not be none'; return }
	assert result == '2 weeks, 1 day', '3.6: got ${result}'
}

fn test_3_7() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-05-26', '2025-06-15') or { assert false, '3.7 should not be none'; return }
	assert result == '2 weeks, 6 days', '3.7: got ${result}'
}

fn test_3_8() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-05-25', '2025-06-15') or { assert false, '3.8 should not be none'; return }
	assert result == '3 weeks', '3.8: got ${result}'
}

fn test_3_9() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-05-15', '2025-06-15') or { assert false, '3.9 should not be none'; return }
	assert result == '4 weeks, 3 days', '3.9: got ${result}'
}

fn test_3_10() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-04-15', '2025-06-15') or { assert false, '3.10 should not be none'; return }
	assert result == '8 weeks, 5 days', '3.10: got ${result}'
}

fn test_3_11() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-03-15', '2025-06-14') or { assert false, '3.11 should not be none'; return }
	assert result == '13 weeks', '3.11: got ${result}'
}

fn test_3_12() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-03-15', '2025-06-15') or { assert false, '3.12 should not be none'; return }
	assert result == '3 months', '3.12: got ${result}'
}

fn test_4_1() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-01-01', '2025-04-01') or { assert false, '4.1 should not be none'; return }
	assert result == '3 months', '4.1: got ${result}'
}

fn test_4_2() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-01-01', '2025-03-31') or { assert false, '4.2 should not be none'; return }
	assert result.contains('weeks'), '4.2'
}

fn test_4_3() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-15', '2025-09-15') or { assert false, '4.3 should not be none'; return }
	assert result == '3 months', '4.3: got ${result}'
}

fn test_4_4() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-15', '2025-09-14') or { assert false, '4.4 should not be none'; return }
	assert result.contains('weeks'), '4.4'
}

fn test_4_5() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-15', '2025-12-15') or { assert false, '4.5 should not be none'; return }
	assert result == '6 months', '4.5: got ${result}'
}

fn test_5_1() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-01-31', '2025-02-28') or { assert false, '5.1 should not be none'; return }
	assert result == '4 weeks', '5.1: got ${result}'
}

fn test_5_2() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-01-31', '2025-04-30') or { assert false, '5.2 should not be none'; return }
	assert result == '3 months', '5.2: got ${result}'
}

fn test_5_3() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-01-31', '2025-04-29') or { assert false, '5.3 should not be none'; return }
	assert result.contains('weeks'), '5.3'
}

fn test_5_4() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-02-01', '2025-05-01') or { assert false, '5.4 should not be none'; return }
	assert result == '3 months', '5.4: got ${result}'
}

fn test_5_5() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-02-01', '2025-04-30') or { assert false, '5.5 should not be none'; return }
	assert result.contains('weeks'), '5.5'
}

fn test_6_1() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2024-01-31', '2024-02-29') or { assert false, '6.1 should not be none'; return }
	assert result == '4 weeks, 1 day', '6.1: got ${result}'
}

fn test_6_2() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2024-01-31', '2024-02-28') or { assert false, '6.2 should not be none'; return }
	assert result == '4 weeks', '6.2: got ${result}'
}

fn test_6_3() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2024-01-31', '2024-04-30') or { assert false, '6.3 should not be none'; return }
	assert result == '3 months', '6.3: got ${result}'
}

fn test_6_4() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2024-01-30', '2024-02-29') or { assert false, '6.4 should not be none'; return }
	assert result.contains('weeks'), '6.4'
}

fn test_6_5() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2024-01-30', '2024-02-28') or { assert false, '6.5 should not be none'; return }
	assert result.contains('weeks'), '6.5'
}

fn test_7_1() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-03-31', '2025-06-30') or { assert false, '7.1 should not be none'; return }
	assert result == '3 months', '7.1: got ${result}'
}

fn test_7_2() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-03-31', '2025-06-29') or { assert false, '7.2 should not be none'; return }
	assert result.contains('weeks'), '7.2'
}

fn test_7_3() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-08-31', '2025-11-30') or { assert false, '7.3 should not be none'; return }
	assert result == '3 months', '7.3: got ${result}'
}

fn test_7_4() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-08-31', '2025-11-29') or { assert false, '7.4 should not be none'; return }
	assert result.contains('weeks'), '7.4'
}

fn test_8_1() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2024-02-29', '2024-05-29') or { assert false, '8.1 should not be none'; return }
	assert result == '3 months', '8.1: got ${result}'
}

fn test_8_2() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2024-02-29', '2024-05-28') or { assert false, '8.2 should not be none'; return }
	assert result.contains('weeks'), '8.2'
}

fn test_8_3() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2024-02-29', '2025-02-28') or { assert false, '8.3 should not be none'; return }
	assert result == '12 months', '8.3: got ${result}'
}

fn test_8_4() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2024-02-29', '2025-03-01') or { assert false, '8.4 should not be none'; return }
	assert result == '12 months', '8.4: got ${result}'
}

fn test_9_1() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-01-15', '2025-04-15') or { assert false, '9.1 should not be none'; return }
	assert result == '3 months', '9.1: got ${result}'
}

fn test_9_2() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-01-15', '2025-07-15') or { assert false, '9.2 should not be none'; return }
	assert result == '6 months', '9.2: got ${result}'
}

fn test_9_3() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2024-06-15', '2025-06-15') or { assert false, '9.3 should not be none'; return }
	assert result == '12 months', '9.3: got ${result}'
}

fn test_9_4() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2024-01-15', '2025-12-15') or { assert false, '9.4 should not be none'; return }
	assert result == '23 months', '9.4: got ${result}'
}

fn test_9_5() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-01-15', '2025-07-14') or { assert false, '9.5 should not be none'; return }
	assert result == '5 months', '9.5: got ${result}'
}

fn test_9_6() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2024-11-10', '2025-04-10') or { assert false, '9.6 should not be none'; return }
	assert result == '5 months', '9.6: got ${result}'
}

fn test_10_1() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2023-06-15', '2025-06-15') or { assert false, '10.1 should not be none'; return }
	assert result == '2 years', '10.1: got ${result}'
}

fn test_10_2() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2023-06-15', '2025-07-15') or { assert false, '10.2 should not be none'; return }
	assert result == '2 years, 1 month', '10.2: got ${result}'
}

fn test_10_3() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2023-06-15', '2025-12-15') or { assert false, '10.3 should not be none'; return }
	assert result == '2 years, 6 months', '10.3: got ${result}'
}

fn test_10_4() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2023-06-15', '2026-05-15') or { assert false, '10.4 should not be none'; return }
	assert result == '2 years, 11 months', '10.4: got ${result}'
}

fn test_10_5() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2023-06-15', '2025-06-14') or { assert false, '10.5 should not be none'; return }
	assert result == '23 months', '10.5: got ${result}'
}

fn test_11_1() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2022-06-15', '2025-06-15') or { assert false, '11.1 should not be none'; return }
	assert result == '3 years', '11.1: got ${result}'
}

fn test_11_2() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2022-06-15', '2025-11-15') or { assert false, '11.2 should not be none'; return }
	assert result == '3 years', '11.2: got ${result}'
}

fn test_11_3() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2022-06-15', '2025-12-15') or { assert false, '11.3 should not be none'; return }
	assert result == '3½ years', '11.3: got ${result}'
}

fn test_11_4() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2022-06-15', '2026-05-15') or { assert false, '11.4 should not be none'; return }
	assert result == '3½ years', '11.4: got ${result}'
}

fn test_11_5() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2021-06-15', '2025-06-15') or { assert false, '11.5 should not be none'; return }
	assert result == '4 years', '11.5: got ${result}'
}

fn test_11_6() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2021-06-15', '2025-12-15') or { assert false, '11.6 should not be none'; return }
	assert result == '4½ years', '11.6: got ${result}'
}

fn test_11_7() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2020-06-15', '2025-06-15') or { assert false, '11.7 should not be none'; return }
	assert result == '5 years', '11.7: got ${result}'
}

fn test_11_8() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2020-06-15', '2026-02-15') or { assert false, '11.8 should not be none'; return }
	assert result == '5½ years', '11.8: got ${result}'
}

fn test_11_9() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2019-06-15', '2025-06-15') or { assert false, '11.9 should not be none'; return }
	assert result == '6 years', '11.9: got ${result}'
}

fn test_11_10() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2019-06-15', '2025-12-15') or { assert false, '11.10 should not be none'; return }
	assert result == '6½ years', '11.10: got ${result}'
}

fn test_11_11() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2019-06-15', '2026-05-15') or { assert false, '11.11 should not be none'; return }
	assert result == '6½ years', '11.11: got ${result}'
}

fn test_11_12() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2022-06-15', '2025-06-14') or { assert false, '11.12 should not be none'; return }
	assert result == '2 years, 11 months', '11.12: got ${result}'
}

fn test_12_1() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2018-06-15', '2025-06-15') or { assert false, '12.1 should not be none'; return }
	assert result == '7 years', '12.1: got ${result}'
}

fn test_12_2() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2018-03-20', '2025-06-15') or { assert false, '12.2 should not be none'; return }
	assert result == '7 years', '12.2: got ${result}'
}

fn test_12_3() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('1980-01-01', '2025-06-15') or { assert false, '12.3 should not be none'; return }
	assert result == '45 years', '12.3: got ${result}'
}

fn test_13_1() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2024-12-31', '2025-03-31') or { assert false, '13.1 should not be none'; return }
	assert result == '3 months', '13.1: got ${result}'
}

fn test_13_2() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2024-12-31', '2025-03-30') or { assert false, '13.2 should not be none'; return }
	assert result.contains('weeks'), '13.2'
}

fn test_13_3() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2024-11-30', '2025-02-28') or { assert false, '13.3 should not be none'; return }
	assert result == '3 months', '13.3: got ${result}'
}

fn test_13_4() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2024-11-30', '2025-02-27') or { assert false, '13.4 should not be none'; return }
	assert result.contains('weeks'), '13.4'
}

fn test_14_1() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-01-31', '2025-04-30') or { assert false, '14.1 should not be none'; return }
	assert result == '3 months', '14.1: got ${result}'
}

fn test_14_2() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-01-31', '2025-05-31') or { assert false, '14.2 should not be none'; return }
	assert result == '4 months', '14.2: got ${result}'
}

fn test_14_3() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-01-31', '2025-06-30') or { assert false, '14.3 should not be none'; return }
	assert result == '5 months', '14.3: got ${result}'
}

fn test_14_4() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-01-31', '2025-07-01') or { assert false, '14.4 should not be none'; return }
	assert result == '5 months', '14.4: got ${result}'
}

fn test_14_5() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-01-31', '2025-07-31') or { assert false, '14.5 should not be none'; return }
	assert result == '6 months', '14.5: got ${result}'
}

fn test_16_1() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('', '', '')
	assert result == none, '16.1'
}

fn test_16_3() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('', '', '')
	assert result == none, '16.3'
}

fn test_16_4() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('2025-07-01', '2025-06-15', '')
	assert result == none, '16.4'
}

fn test_16_5() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('1525-06-15', '2025-06-15', '') or { assert false, '16.5 should not be none'; return }
	assert result == 'Adult', '16.5: got ${result}'
}

fn test_16_6() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('1524-06-15', '2025-06-15', '')
	assert result == none, '16.6'
}

fn test_17_1() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('2025-06-15', '2025-06-15', '') or { assert false, '17.1 should not be none'; return }
	assert result == 'Newborn', '17.1: got ${result}'
}

fn test_17_2() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('2025-06-14', '2025-06-15', '') or { assert false, '17.2 should not be none'; return }
	assert result == 'Newborn', '17.2: got ${result}'
}

fn test_17_3() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('2025-05-25', '2025-06-15', '') or { assert false, '17.3 should not be none'; return }
	assert result == 'Newborn', '17.3: got ${result}'
}

fn test_17_4() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('2025-05-15', '2025-06-15', '') or { assert false, '17.4 should not be none'; return }
	assert result == 'Newborn', '17.4: got ${result}'
}

fn test_17_5() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('2025-04-16', '2025-06-15', '') or { assert false, '17.5 should not be none'; return }
	assert result == 'Newborn', '17.5: got ${result}'
}

fn test_17_6() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('2025-04-15', '2025-06-15', '') or { assert false, '17.6 should not be none'; return }
	assert result == 'Infant', '17.6: got ${result}'
}

fn test_18_1() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('2025-04-15', '2025-06-15', '') or { assert false, '18.1 should not be none'; return }
	assert result == 'Infant', '18.1: got ${result}'
}

fn test_18_2() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('2024-12-15', '2025-06-15', '') or { assert false, '18.2 should not be none'; return }
	assert result == 'Infant', '18.2: got ${result}'
}

fn test_18_3() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('2024-07-15', '2025-06-15', '') or { assert false, '18.3 should not be none'; return }
	assert result == 'Infant', '18.3: got ${result}'
}

fn test_18_4() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('2024-06-15', '2025-06-15', '') or { assert false, '18.4 should not be none'; return }
	assert result == 'Toddler', '18.4: got ${result}'
}

fn test_19_1() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('2024-06-15', '2025-06-15', '') or { assert false, '19.1 should not be none'; return }
	assert result == 'Toddler', '19.1: got ${result}'
}

fn test_19_2() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('2024-01-15', '2025-07-15', '') or { assert false, '19.2 should not be none'; return }
	assert result == 'Toddler', '19.2: got ${result}'
}

fn test_19_3() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('2023-06-15', '2025-06-15', '') or { assert false, '19.3 should not be none'; return }
	assert result == 'Toddler', '19.3: got ${result}'
}

fn test_19_4() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('2023-06-15', '2026-05-15', '') or { assert false, '19.4 should not be none'; return }
	assert result == 'Toddler', '19.4: got ${result}'
}

fn test_19_5() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('2022-06-15', '2025-06-15', '') or { assert false, '19.5 should not be none'; return }
	assert result == 'Child', '19.5: got ${result}'
}

fn test_20_1() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('2022-06-15', '2025-06-15', '') or { assert false, '20.1 should not be none'; return }
	assert result == 'Child', '20.1: got ${result}'
}

fn test_20_2() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('2021-06-15', '2025-06-15', '') or { assert false, '20.2 should not be none'; return }
	assert result == 'Child', '20.2: got ${result}'
}

fn test_20_3() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('2019-06-15', '2025-06-15', '') or { assert false, '20.3 should not be none'; return }
	assert result == 'Child', '20.3: got ${result}'
}

fn test_20_4() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('2016-06-15', '2025-06-15', '') or { assert false, '20.4 should not be none'; return }
	assert result == 'Child', '20.4: got ${result}'
}

fn test_20_5() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('2013-06-15', '2026-05-15', '') or { assert false, '20.5 should not be none'; return }
	assert result == 'Child', '20.5: got ${result}'
}

fn test_20_6() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('2012-06-15', '2025-06-15', '') or { assert false, '20.6 should not be none'; return }
	assert result == 'Teenager', '20.6: got ${result}'
}

fn test_21_1() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('2012-06-15', '2025-06-15', '') or { assert false, '21.1 should not be none'; return }
	assert result == 'Teenager', '21.1: got ${result}'
}

fn test_21_2() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('2010-06-15', '2025-06-15', '') or { assert false, '21.2 should not be none'; return }
	assert result == 'Teenager', '21.2: got ${result}'
}

fn test_21_3() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('2008-06-15', '2026-05-15', '') or { assert false, '21.3 should not be none'; return }
	assert result == 'Teenager', '21.3: got ${result}'
}

fn test_21_4() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('2007-06-15', '2025-06-15', '') or { assert false, '21.4 should not be none'; return }
	assert result == 'Adult', '21.4: got ${result}'
}

fn test_22_1() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('2007-06-15', '2025-06-15', '') or { assert false, '22.1 should not be none'; return }
	assert result == 'Adult', '22.1: got ${result}'
}

fn test_22_2() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('2000-06-15', '2025-06-15', '') or { assert false, '22.2 should not be none'; return }
	assert result == 'Adult', '22.2: got ${result}'
}

fn test_22_3() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('1980-01-01', '2025-06-15', '') or { assert false, '22.3 should not be none'; return }
	assert result == 'Adult', '22.3: got ${result}'
}

fn test_24_1() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-15', '2025-06-15') or { assert false, '24.1 should not be none'; return }
	assert result == 'Newborn', '24.1: got ${result}'
}

fn test_24_2() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-12', '2025-06-15') or { assert false, '24.2 should not be none'; return }
	assert result == '3 days', '24.2: got ${result}'
}

fn test_24_3() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-07', '2025-06-15') or { assert false, '24.3 should not be none'; return }
	assert result == '1 week, 1 day', '24.3: got ${result}'
}

fn test_24_4() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2025-01-15', '2025-07-15') or { assert false, '24.4 should not be none'; return }
	assert result == '6 months', '24.4: got ${result}'
}

fn test_24_5() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2023-06-15', '2025-07-15') or { assert false, '24.5 should not be none'; return }
	assert result == '2 years, 1 month', '24.5: got ${result}'
}

fn test_24_6() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2022-06-15', '2025-12-15') or { assert false, '24.6 should not be none'; return }
	assert result == '3½ years', '24.6: got ${result}'
}

fn test_24_7() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('2018-06-15', '2025-06-15') or { assert false, '24.7 should not be none'; return }
	assert result == '7 years', '24.7: got ${result}'
}

fn test_24_8() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('2025-06-15', '2025-06-15', '') or { assert false, '24.8 should not be none'; return }
	assert result == 'Newborn', '24.8: got ${result}'
}

fn test_24_9() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('2025-01-15', '2025-06-15', '') or { assert false, '24.9 should not be none'; return }
	assert result == 'Infant', '24.9: got ${result}'
}

fn test_24_10() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('2024-06-15', '2025-06-15', '') or { assert false, '24.10 should not be none'; return }
	assert result == 'Toddler', '24.10: got ${result}'
}

fn test_24_11() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('2022-06-15', '2025-06-15', '') or { assert false, '24.11 should not be none'; return }
	assert result == 'Child', '24.11: got ${result}'
}

fn test_24_12() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('2012-06-15', '2025-06-15', '') or { assert false, '24.12 should not be none'; return }
	assert result == 'Teenager', '24.12: got ${result}'
}

fn test_24_13() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('2007-06-15', '2025-06-15', '') or { assert false, '24.13 should not be none'; return }
	assert result == 'Adult', '24.13: got ${result}'
}

fn test_24_14() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_age('', '')
	assert result == none, '24.14'
}

fn test_24_15() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .normal)
	result := sa.format_stage('', '', '')
	assert result == none, '24.15'
}

fn test_25_1() {
	sa := new_sayable_age(locales.get_locale('es') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-15', '2025-06-15') or { assert false, '25.1 should not be none'; return }
	assert result == 'Recién nacido', '25.1: got ${result}'
}

fn test_25_2() {
	sa := new_sayable_age(locales.get_locale('es') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-14', '2025-06-15') or { assert false, '25.2 should not be none'; return }
	assert result == '1 día', '25.2: got ${result}'
}

fn test_25_3() {
	sa := new_sayable_age(locales.get_locale('es') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-12', '2025-06-15') or { assert false, '25.3 should not be none'; return }
	assert result == '3 días', '25.3: got ${result}'
}

fn test_25_4() {
	sa := new_sayable_age(locales.get_locale('es') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-08', '2025-06-15') or { assert false, '25.4 should not be none'; return }
	assert result == '1 semana', '25.4: got ${result}'
}

fn test_25_5() {
	sa := new_sayable_age(locales.get_locale('es') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-07', '2025-06-15') or { assert false, '25.5 should not be none'; return }
	assert result == '1 semana, 1 día', '25.5: got ${result}'
}

fn test_25_6() {
	sa := new_sayable_age(locales.get_locale('es') or { assert false; return }, .normal)
	result := sa.format_age('2025-05-26', '2025-06-15') or { assert false, '25.6 should not be none'; return }
	assert result == '2 semanas, 6 días', '25.6: got ${result}'
}

fn test_25_7() {
	sa := new_sayable_age(locales.get_locale('es') or { assert false; return }, .normal)
	result := sa.format_age('2025-01-15', '2025-07-15') or { assert false, '25.7 should not be none'; return }
	assert result == '6 meses', '25.7: got ${result}'
}

fn test_25_8() {
	sa := new_sayable_age(locales.get_locale('es') or { assert false; return }, .normal)
	result := sa.format_age('2023-06-15', '2025-07-15') or { assert false, '25.8 should not be none'; return }
	assert result == '2 años, 1 mes', '25.8: got ${result}'
}

fn test_25_9() {
	sa := new_sayable_age(locales.get_locale('es') or { assert false; return }, .normal)
	result := sa.format_age('2023-06-15', '2025-12-15') or { assert false, '25.9 should not be none'; return }
	assert result == '2 años, 6 meses', '25.9: got ${result}'
}

fn test_25_10() {
	sa := new_sayable_age(locales.get_locale('es') or { assert false; return }, .normal)
	result := sa.format_age('2022-06-15', '2025-12-15') or { assert false, '25.10 should not be none'; return }
	assert result == '3 y medio años', '25.10: got ${result}'
}

fn test_25_11() {
	sa := new_sayable_age(locales.get_locale('es') or { assert false; return }, .normal)
	result := sa.format_age('2022-06-15', '2025-06-15') or { assert false, '25.11 should not be none'; return }
	assert result == '3 años', '25.11: got ${result}'
}

fn test_25_12() {
	sa := new_sayable_age(locales.get_locale('es') or { assert false; return }, .normal)
	result := sa.format_age('2018-06-15', '2025-06-15') or { assert false, '25.12 should not be none'; return }
	assert result == '7 años', '25.12: got ${result}'
}

fn test_25_13() {
	sa := new_sayable_age(locales.get_locale('es') or { assert false; return }, .normal)
	result := sa.format_stage('2025-06-15', '2025-06-15', '') or { assert false, '25.13 should not be none'; return }
	assert result == 'Recién nacido', '25.13: got ${result}'
}

fn test_25_14() {
	sa := new_sayable_age(locales.get_locale('es') or { assert false; return }, .normal)
	result := sa.format_stage('2025-01-15', '2025-06-15', '') or { assert false, '25.14 should not be none'; return }
	assert result == 'Bebé', '25.14: got ${result}'
}

fn test_25_15() {
	sa := new_sayable_age(locales.get_locale('es') or { assert false; return }, .normal)
	result := sa.format_stage('2024-06-15', '2025-06-15', '') or { assert false, '25.15 should not be none'; return }
	assert result == 'Niño pequeño', '25.15: got ${result}'
}

fn test_25_16() {
	sa := new_sayable_age(locales.get_locale('es') or { assert false; return }, .normal)
	result := sa.format_stage('2022-06-15', '2025-06-15', '') or { assert false, '25.16 should not be none'; return }
	assert result == 'Niño', '25.16: got ${result}'
}

fn test_25_17() {
	sa := new_sayable_age(locales.get_locale('es') or { assert false; return }, .normal)
	result := sa.format_stage('2012-06-15', '2025-06-15', '') or { assert false, '25.17 should not be none'; return }
	assert result == 'Adolescente', '25.17: got ${result}'
}

fn test_25_18() {
	sa := new_sayable_age(locales.get_locale('es') or { assert false; return }, .normal)
	result := sa.format_stage('2007-06-15', '2025-06-15', '') or { assert false, '25.18 should not be none'; return }
	assert result == 'Adulto', '25.18: got ${result}'
}

fn test_25_19() {
	sa := new_sayable_age(locales.get_locale('es') or { assert false; return }, .normal)
	result := sa.format_age('', '')
	assert result == none, '25.19'
}

fn test_25_20() {
	sa := new_sayable_age(locales.get_locale('es') or { assert false; return }, .normal)
	result := sa.format_stage('', '', '')
	assert result == none, '25.20'
}

fn test_26_1() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .short)
	result := sa.format_age('2025-06-12', '2025-06-15') or { assert false, '26.1 should not be none'; return }
	assert result == '3 d', '26.1: got ${result}'
}

fn test_26_2() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .short)
	result := sa.format_age('2025-06-08', '2025-06-15') or { assert false, '26.2 should not be none'; return }
	assert result == '1 wk', '26.2: got ${result}'
}

fn test_26_3() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .short)
	result := sa.format_age('2025-06-07', '2025-06-15') or { assert false, '26.3 should not be none'; return }
	assert result == '1 wk, 1 d', '26.3: got ${result}'
}

fn test_26_4() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .short)
	result := sa.format_age('2025-01-15', '2025-07-15') or { assert false, '26.4 should not be none'; return }
	assert result == '6 mo', '26.4: got ${result}'
}

fn test_26_5() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .short)
	result := sa.format_age('2023-06-15', '2025-07-15') or { assert false, '26.5 should not be none'; return }
	assert result == '2 yr, 1 mo', '26.5: got ${result}'
}

fn test_26_6() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .short)
	result := sa.format_age('2022-06-15', '2025-12-15') or { assert false, '26.6 should not be none'; return }
	assert result == '3½ yr', '26.6: got ${result}'
}

fn test_26_7() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .short)
	result := sa.format_age('2018-06-15', '2025-06-15') or { assert false, '26.7 should not be none'; return }
	assert result == '7 yr', '26.7: got ${result}'
}

fn test_26_8() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .short)
	result := sa.format_age('2025-06-15', '2025-06-15') or { assert false, '26.8 should not be none'; return }
	assert result == 'Newborn', '26.8: got ${result}'
}

fn test_26_9() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .short)
	result := sa.format_stage('2025-01-15', '2025-06-15', '') or { assert false, '26.9 should not be none'; return }
	assert result == 'Infant', '26.9: got ${result}'
}

fn test_27_1() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .compact)
	result := sa.format_age('2025-06-12', '2025-06-15') or { assert false, '27.1 should not be none'; return }
	assert result == '3d', '27.1: got ${result}'
}

fn test_27_2() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .compact)
	result := sa.format_age('2025-06-08', '2025-06-15') or { assert false, '27.2 should not be none'; return }
	assert result == '1w', '27.2: got ${result}'
}

fn test_27_3() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .compact)
	result := sa.format_age('2025-06-07', '2025-06-15') or { assert false, '27.3 should not be none'; return }
	assert result == '1w1d', '27.3: got ${result}'
}

fn test_27_4() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .compact)
	result := sa.format_age('2025-01-15', '2025-07-15') or { assert false, '27.4 should not be none'; return }
	assert result == '6m', '27.4: got ${result}'
}

fn test_27_5() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .compact)
	result := sa.format_age('2023-06-15', '2025-07-15') or { assert false, '27.5 should not be none'; return }
	assert result == '2y1m', '27.5: got ${result}'
}

fn test_27_6() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .compact)
	result := sa.format_age('2022-06-15', '2025-12-15') or { assert false, '27.6 should not be none'; return }
	assert result == '3½y', '27.6: got ${result}'
}

fn test_27_7() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .compact)
	result := sa.format_age('2018-06-15', '2025-06-15') or { assert false, '27.7 should not be none'; return }
	assert result == '7y', '27.7: got ${result}'
}

fn test_27_8() {
	sa := new_sayable_age(locales.get_locale('en') or { assert false; return }, .compact)
	result := sa.format_age('2025-06-15', '2025-06-15') or { assert false, '27.8 should not be none'; return }
	assert result == 'Newborn', '27.8: got ${result}'
}

fn test_29_1() {
	sa := new_sayable_age(locales.get_locale('he') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-15', '2025-06-15') or { assert false, '29.1 should not be none'; return }
	assert result == 'רק נולד', '29.1: got ${result}'
}

fn test_29_2() {
	sa := new_sayable_age(locales.get_locale('he') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-14', '2025-06-15') or { assert false, '29.2 should not be none'; return }
	assert result == 'יום 1', '29.2: got ${result}'
}

fn test_29_3() {
	sa := new_sayable_age(locales.get_locale('he') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-12', '2025-06-15') or { assert false, '29.3 should not be none'; return }
	assert result == '3 ימים', '29.3: got ${result}'
}

fn test_29_4() {
	sa := new_sayable_age(locales.get_locale('he') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-01', '2025-06-15') or { assert false, '29.4 should not be none'; return }
	assert result == 'שבועיים', '29.4: got ${result}'
}

fn test_29_5() {
	sa := new_sayable_age(locales.get_locale('he') or { assert false; return }, .normal)
	result := sa.format_age('2025-05-25', '2025-06-15') or { assert false, '29.5 should not be none'; return }
	assert result == '3 שבועות', '29.5: got ${result}'
}

fn test_29_6() {
	sa := new_sayable_age(locales.get_locale('he') or { assert false; return }, .normal)
	result := sa.format_age('2025-01-15', '2025-07-15') or { assert false, '29.6 should not be none'; return }
	assert result == '6 חודשים', '29.6: got ${result}'
}

fn test_29_7() {
	sa := new_sayable_age(locales.get_locale('he') or { assert false; return }, .normal)
	result := sa.format_age('2025-03-15', '2025-06-15') or { assert false, '29.7 should not be none'; return }
	assert result == '3 חודשים', '29.7: got ${result}'
}

fn test_29_8() {
	sa := new_sayable_age(locales.get_locale('he') or { assert false; return }, .normal)
	result := sa.format_age('2023-06-15', '2025-07-15') or { assert false, '29.8 should not be none'; return }
	assert result == 'שנתיים, חודש 1', '29.8: got ${result}'
}

fn test_29_9() {
	sa := new_sayable_age(locales.get_locale('he') or { assert false; return }, .normal)
	result := sa.format_age('2022-06-15', '2025-12-15') or { assert false, '29.9 should not be none'; return }
	assert result == '3 שנים וחצי', '29.9: got ${result}'
}

fn test_29_10() {
	sa := new_sayable_age(locales.get_locale('he') or { assert false; return }, .normal)
	result := sa.format_age('2018-06-15', '2025-06-15') or { assert false, '29.10 should not be none'; return }
	assert result == '7 שנים', '29.10: got ${result}'
}

fn test_29_11() {
	sa := new_sayable_age(locales.get_locale('he') or { assert false; return }, .normal)
	result := sa.format_stage('2025-06-15', '2025-06-15', 'm') or { assert false, '29.11 should not be none'; return }
	assert result == 'רק נולד', '29.11: got ${result}'
}

fn test_29_12() {
	sa := new_sayable_age(locales.get_locale('he') or { assert false; return }, .normal)
	result := sa.format_stage('2025-06-15', '2025-06-15', 'f') or { assert false, '29.12 should not be none'; return }
	assert result == 'רק נולדה', '29.12: got ${result}'
}

fn test_29_13() {
	sa := new_sayable_age(locales.get_locale('he') or { assert false; return }, .normal)
	result := sa.format_stage('2007-06-15', '2025-06-15', 'm') or { assert false, '29.13 should not be none'; return }
	assert result == 'מבוגר', '29.13: got ${result}'
}

fn test_29_14() {
	sa := new_sayable_age(locales.get_locale('he') or { assert false; return }, .normal)
	result := sa.format_stage('2007-06-15', '2025-06-15', 'f') or { assert false, '29.14 should not be none'; return }
	assert result == 'מבוגרת', '29.14: got ${result}'
}

fn test_29_15() {
	sa := new_sayable_age(locales.get_locale('mk') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-15', '2025-06-15') or { assert false, '29.15 should not be none'; return }
	assert result == 'Новороденче', '29.15: got ${result}'
}

fn test_29_16() {
	sa := new_sayable_age(locales.get_locale('mk') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-14', '2025-06-15') or { assert false, '29.16 should not be none'; return }
	assert result == '1 ден', '29.16: got ${result}'
}

fn test_29_17() {
	sa := new_sayable_age(locales.get_locale('mk') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-12', '2025-06-15') or { assert false, '29.17 should not be none'; return }
	assert result == '3 дена', '29.17: got ${result}'
}

fn test_29_18() {
	sa := new_sayable_age(locales.get_locale('mk') or { assert false; return }, .normal)
	result := sa.format_age('2025-01-15', '2025-07-15') or { assert false, '29.18 should not be none'; return }
	assert result == '6 месеци', '29.18: got ${result}'
}

fn test_29_19() {
	sa := new_sayable_age(locales.get_locale('mk') or { assert false; return }, .normal)
	result := sa.format_age('2023-06-15', '2025-07-15') or { assert false, '29.19 should not be none'; return }
	assert result == '2 години, 1 месец', '29.19: got ${result}'
}

fn test_29_20() {
	sa := new_sayable_age(locales.get_locale('mk') or { assert false; return }, .normal)
	result := sa.format_age('2022-06-15', '2025-12-15') or { assert false, '29.20 should not be none'; return }
	assert result == '3 години и пол', '29.20: got ${result}'
}

fn test_29_21() {
	sa := new_sayable_age(locales.get_locale('mk') or { assert false; return }, .normal)
	result := sa.format_age('2018-06-15', '2025-06-15') or { assert false, '29.21 should not be none'; return }
	assert result == '7 години', '29.21: got ${result}'
}

fn test_29_22() {
	sa := new_sayable_age(locales.get_locale('sw') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-15', '2025-06-15') or { assert false, '29.22 should not be none'; return }
	assert result == 'Mzaliwa mpya', '29.22: got ${result}'
}

fn test_29_23() {
	sa := new_sayable_age(locales.get_locale('sw') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-14', '2025-06-15') or { assert false, '29.23 should not be none'; return }
	assert result == 'siku 1', '29.23: got ${result}'
}

fn test_29_24() {
	sa := new_sayable_age(locales.get_locale('sw') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-12', '2025-06-15') or { assert false, '29.24 should not be none'; return }
	assert result == 'siku 3', '29.24: got ${result}'
}

fn test_29_25() {
	sa := new_sayable_age(locales.get_locale('sw') or { assert false; return }, .normal)
	result := sa.format_age('2025-01-15', '2025-07-15') or { assert false, '29.25 should not be none'; return }
	assert result == 'miezi 6', '29.25: got ${result}'
}

fn test_29_26() {
	sa := new_sayable_age(locales.get_locale('sw') or { assert false; return }, .normal)
	result := sa.format_age('2023-06-15', '2025-07-15') or { assert false, '29.26 should not be none'; return }
	assert result == 'miaka 2, mwezi 1', '29.26: got ${result}'
}

fn test_29_27() {
	sa := new_sayable_age(locales.get_locale('sw') or { assert false; return }, .normal)
	result := sa.format_age('2022-06-15', '2025-12-15') or { assert false, '29.27 should not be none'; return }
	assert result == 'miaka 3 na nusu', '29.27: got ${result}'
}

fn test_29_28() {
	sa := new_sayable_age(locales.get_locale('id') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-15', '2025-06-15') or { assert false, '29.28 should not be none'; return }
	assert result == 'Baru lahir', '29.28: got ${result}'
}

fn test_29_29() {
	sa := new_sayable_age(locales.get_locale('id') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-14', '2025-06-15') or { assert false, '29.29 should not be none'; return }
	assert result == '1 hari', '29.29: got ${result}'
}

fn test_29_30() {
	sa := new_sayable_age(locales.get_locale('id') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-12', '2025-06-15') or { assert false, '29.30 should not be none'; return }
	assert result == '3 hari', '29.30: got ${result}'
}

fn test_29_31() {
	sa := new_sayable_age(locales.get_locale('id') or { assert false; return }, .normal)
	result := sa.format_age('2025-01-15', '2025-07-15') or { assert false, '29.31 should not be none'; return }
	assert result == '6 bulan', '29.31: got ${result}'
}

fn test_29_32() {
	sa := new_sayable_age(locales.get_locale('id') or { assert false; return }, .normal)
	result := sa.format_age('2022-06-15', '2025-12-15') or { assert false, '29.32 should not be none'; return }
	assert result == '3 tahun setengah', '29.32: got ${result}'
}

fn test_29_33() {
	sa := new_sayable_age(locales.get_locale('id') or { assert false; return }, .normal)
	result := sa.format_age('2018-06-15', '2025-06-15') or { assert false, '29.33 should not be none'; return }
	assert result == '7 tahun', '29.33: got ${result}'
}

fn test_29_34() {
	sa := new_sayable_age(locales.get_locale('am') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-15', '2025-06-15') or { assert false, '29.34 should not be none'; return }
	assert result == 'አዲስ የተወለደ', '29.34: got ${result}'
}

fn test_29_35() {
	sa := new_sayable_age(locales.get_locale('am') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-14', '2025-06-15') or { assert false, '29.35 should not be none'; return }
	assert result == '1 ቀን', '29.35: got ${result}'
}

fn test_29_36() {
	sa := new_sayable_age(locales.get_locale('am') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-12', '2025-06-15') or { assert false, '29.36 should not be none'; return }
	assert result == '3 ቀናት', '29.36: got ${result}'
}

fn test_29_37() {
	sa := new_sayable_age(locales.get_locale('am') or { assert false; return }, .normal)
	result := sa.format_age('2025-06-07', '2025-06-15') or { assert false, '29.37 should not be none'; return }
	assert result == '1 ሳምንት፣ 1 ቀን', '29.37: got ${result}'
}

fn test_29_38() {
	sa := new_sayable_age(locales.get_locale('am') or { assert false; return }, .normal)
	result := sa.format_age('2025-01-15', '2025-07-15') or { assert false, '29.38 should not be none'; return }
	assert result == '6 ወራት', '29.38: got ${result}'
}

fn test_29_39() {
	sa := new_sayable_age(locales.get_locale('am') or { assert false; return }, .normal)
	result := sa.format_age('2022-06-15', '2025-12-15') or { assert false, '29.39 should not be none'; return }
	assert result == '3 ዓመታት ተኩል', '29.39: got ${result}'
}

fn test_30_1() {
	result := locales.get_locale('en') or { assert false, '30.1 should exist'; return }
	assert result.code == 'en', '30.1'
}

fn test_30_2() {
	result := locales.get_locale('fr') or { assert false, '30.2 should exist'; return }
	assert result.code == 'fr', '30.2'
}

fn test_30_3() {
	result := locales.get_locale('xx')
	assert result == none, '30.3'
}

fn test_30_4() {
	result := locales.get_locale('')
	assert result == none, '30.4'
}

fn test_30_5() {
	result := locales.get_locale('EN')
	assert result == none, '30.5'
}

