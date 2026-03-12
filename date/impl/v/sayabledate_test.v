module sayabledate

import locales

// Section 1: Null / edge cases

// 1.1
fn test_1_1() {
	sd := locales.new_sayable_date(locales.get_date_locale('en') or { assert false; return }, .normal)
	result := sd.format_date('')
	assert result == none, '1.1'
}

// 1.2
fn test_1_2() {
	sd := locales.new_sayable_date(locales.get_date_locale('en') or { assert false; return }, .normal)
	result := sd.format_date('')
	assert result == none, '1.2'
}

// 1.3
fn test_1_3() {
	sd := locales.new_sayable_date(locales.get_date_locale('en') or { assert false; return }, .normal)
	result := sd.format_date('invalid')
	assert result == none, '1.3'
}

// 1.4
fn test_1_4() {
	sd := locales.new_sayable_date(locales.get_date_locale('en') or { assert false; return }, .normal)
	result := sd.format_relative('2025-03-15', '')
	assert result == none, '1.4'
}

// 1.5
fn test_1_5() {
	sd := locales.new_sayable_date(locales.get_date_locale('en') or { assert false; return }, .normal)
	result := sd.format_relative('', '2025-03-15')
	assert result == none, '1.5'
}

// Section 2: format_date -- normal compactness (English)

// 2.1
fn test_2_1() {
	sd := locales.new_sayable_date(locales.get_date_locale('en') or { assert false; return }, .normal)
	result := sd.format_date('2025-03-15') or { assert false, '2.1 should not be none'; return }
	assert result == 'March 15th', '2.1: got ${result}'
}

// 2.2
fn test_2_2() {
	sd := locales.new_sayable_date(locales.get_date_locale('en') or { assert false; return }, .normal)
	result := sd.format_date('2025-01-01') or { assert false, '2.2 should not be none'; return }
	assert result == 'January 1st', '2.2: got ${result}'
}

// 2.3
fn test_2_3() {
	sd := locales.new_sayable_date(locales.get_date_locale('en') or { assert false; return }, .normal)
	result := sd.format_date('2025-05-22') or { assert false, '2.3 should not be none'; return }
	assert result == 'May 22nd', '2.3: got ${result}'
}

// 2.4
fn test_2_4() {
	sd := locales.new_sayable_date(locales.get_date_locale('en') or { assert false; return }, .normal)
	result := sd.format_date('2025-07-03') or { assert false, '2.4 should not be none'; return }
	assert result == 'July 3rd', '2.4: got ${result}'
}

// 2.5
fn test_2_5() {
	sd := locales.new_sayable_date(locales.get_date_locale('en') or { assert false; return }, .normal)
	result := sd.format_date('2025-12-31') or { assert false, '2.5 should not be none'; return }
	assert result == 'December 31st', '2.5: got ${result}'
}

// 2.6
fn test_2_6() {
	sd := locales.new_sayable_date(locales.get_date_locale('en') or { assert false; return }, .normal)
	result := sd.format_date('2025-06-11') or { assert false, '2.6 should not be none'; return }
	assert result == 'June 11th', '2.6: got ${result}'
}

// 2.7
fn test_2_7() {
	sd := locales.new_sayable_date(locales.get_date_locale('en') or { assert false; return }, .normal)
	result := sd.format_date('2025-03-15T14:30:00') or { assert false, '2.7 should not be none'; return }
	assert result == 'March 15th', '2.7: got ${result}'
}

// Section 3: format_date -- short compactness (English)

// 3.1
fn test_3_1() {
	sd := locales.new_sayable_date(locales.get_date_locale('en') or { assert false; return }, .short)
	result := sd.format_date('2025-03-15') or { assert false, '3.1 should not be none'; return }
	assert result == 'Mar 15', '3.1: got ${result}'
}

// 3.2
fn test_3_2() {
	sd := locales.new_sayable_date(locales.get_date_locale('en') or { assert false; return }, .short)
	result := sd.format_date('2025-01-01') or { assert false, '3.2 should not be none'; return }
	assert result == 'Jan 1', '3.2: got ${result}'
}

// 3.3
fn test_3_3() {
	sd := locales.new_sayable_date(locales.get_date_locale('en') or { assert false; return }, .short)
	result := sd.format_date('2025-12-25') or { assert false, '3.3 should not be none'; return }
	assert result == 'Dec 25', '3.3: got ${result}'
}

// Section 4: format_date -- compact (English)

// 4.1
fn test_4_1() {
	sd := locales.new_sayable_date(locales.get_date_locale('en') or { assert false; return }, .compact)
	result := sd.format_date('2025-03-15') or { assert false, '4.1 should not be none'; return }
	assert result == '3/15', '4.1: got ${result}'
}

// 4.2
fn test_4_2() {
	sd := locales.new_sayable_date(locales.get_date_locale('en') or { assert false; return }, .compact)
	result := sd.format_date('2025-01-01') or { assert false, '4.2 should not be none'; return }
	assert result == '1/1', '4.2: got ${result}'
}

// Section 5: format_relative -- proximity tiers (English)

// 5.1
fn test_5_1() {
	sd := locales.new_sayable_date(locales.get_date_locale('en') or { assert false; return }, .normal)
	result := sd.format_relative('2025-03-15', '2025-03-15') or { assert false, '5.1 should not be none'; return }
	assert result == 'today', '5.1: got ${result}'
}

// 5.2
fn test_5_2() {
	sd := locales.new_sayable_date(locales.get_date_locale('en') or { assert false; return }, .normal)
	result := sd.format_relative('2025-03-16', '2025-03-15') or { assert false, '5.2 should not be none'; return }
	assert result == 'tomorrow', '5.2: got ${result}'
}

// 5.3
fn test_5_3() {
	sd := locales.new_sayable_date(locales.get_date_locale('en') or { assert false; return }, .normal)
	result := sd.format_relative('2025-03-14', '2025-03-15') or { assert false, '5.3 should not be none'; return }
	assert result == 'yesterday', '5.3: got ${result}'
}

// 5.4
fn test_5_4() {
	sd := locales.new_sayable_date(locales.get_date_locale('en') or { assert false; return }, .normal)
	result := sd.format_relative('2025-03-17', '2025-03-15') or { assert false, '5.4 should not be none'; return }
	assert result == 'the day after tomorrow', '5.4: got ${result}'
}

// 5.5
fn test_5_5() {
	sd := locales.new_sayable_date(locales.get_date_locale('en') or { assert false; return }, .normal)
	result := sd.format_relative('2025-03-13', '2025-03-15') or { assert false, '5.5 should not be none'; return }
	assert result == 'the day before yesterday', '5.5: got ${result}'
}

// 5.6
fn test_5_6() {
	sd := locales.new_sayable_date(locales.get_date_locale('en') or { assert false; return }, .normal)
	result := sd.format_relative('2025-03-19', '2025-03-15') or { assert false, '5.6 should not be none'; return }
	assert result == 'this Wednesday', '5.6: got ${result}'
}

// 5.7
fn test_5_7() {
	sd := locales.new_sayable_date(locales.get_date_locale('en') or { assert false; return }, .normal)
	result := sd.format_relative('2025-03-20', '2025-03-15') or { assert false, '5.7 should not be none'; return }
	assert result == 'this Thursday', '5.7: got ${result}'
}

// 5.8
fn test_5_8() {
	sd := locales.new_sayable_date(locales.get_date_locale('en') or { assert false; return }, .normal)
	result := sd.format_relative('2025-03-11', '2025-03-15') or { assert false, '5.8 should not be none'; return }
	assert result == 'last Tuesday', '5.8: got ${result}'
}

// 5.9
fn test_5_9() {
	sd := locales.new_sayable_date(locales.get_date_locale('en') or { assert false; return }, .normal)
	result := sd.format_relative('2025-03-22', '2025-03-15') or { assert false, '5.9 should not be none'; return }
	assert result == 'next Saturday', '5.9: got ${result}'
}

// 5.10
fn test_5_10() {
	sd := locales.new_sayable_date(locales.get_date_locale('en') or { assert false; return }, .normal)
	result := sd.format_relative('2025-03-27', '2025-03-15') or { assert false, '5.10 should not be none'; return }
	assert result == 'next Thursday', '5.10: got ${result}'
}

// 5.11
fn test_5_11() {
	sd := locales.new_sayable_date(locales.get_date_locale('en') or { assert false; return }, .normal)
	result := sd.format_relative('2025-03-01', '2025-03-15') or { assert false, '5.11 should not be none'; return }
	assert result == 'March 1st', '5.11: got ${result}'
}

// 5.12
fn test_5_12() {
	sd := locales.new_sayable_date(locales.get_date_locale('en') or { assert false; return }, .normal)
	result := sd.format_relative('2025-04-10', '2025-03-15') or { assert false, '5.12 should not be none'; return }
	assert result == 'April 10th', '5.12: got ${result}'
}

// 5.13
fn test_5_13() {
	sd := locales.new_sayable_date(locales.get_date_locale('en') or { assert false; return }, .normal)
	result := sd.format_relative('2026-01-05', '2025-03-15') or { assert false, '5.13 should not be none'; return }
	assert result == 'January 5th, 2026', '5.13: got ${result}'
}

// 5.14
fn test_5_14() {
	sd := locales.new_sayable_date(locales.get_date_locale('en') or { assert false; return }, .normal)
	result := sd.format_relative('2024-12-25', '2025-03-15') or { assert false, '5.14 should not be none'; return }
	assert result == 'December 25th, 2024', '5.14: got ${result}'
}

// Section 6: format_relative -- compact skips weekday tiers

// 6.1
fn test_6_1() {
	sd := locales.new_sayable_date(locales.get_date_locale('en') or { assert false; return }, .compact)
	result := sd.format_relative('2025-03-15', '2025-03-15') or { assert false, '6.1 should not be none'; return }
	assert result == 'today', '6.1: got ${result}'
}

// 6.2
fn test_6_2() {
	sd := locales.new_sayable_date(locales.get_date_locale('en') or { assert false; return }, .compact)
	result := sd.format_relative('2025-03-16', '2025-03-15') or { assert false, '6.2 should not be none'; return }
	assert result == 'tomorrow', '6.2: got ${result}'
}

// 6.3
fn test_6_3() {
	sd := locales.new_sayable_date(locales.get_date_locale('en') or { assert false; return }, .compact)
	result := sd.format_relative('2025-03-19', '2025-03-15') or { assert false, '6.3 should not be none'; return }
	assert result == '3/19', '6.3: got ${result}'
}

// 6.4
fn test_6_4() {
	sd := locales.new_sayable_date(locales.get_date_locale('en') or { assert false; return }, .compact)
	result := sd.format_relative('2026-01-05', '2025-03-15') or { assert false, '6.4 should not be none'; return }
	assert result == '1/5/26', '6.4: got ${result}'
}

// Section 7: Locale -- German

// 7.1
fn test_7_1() {
	sd := locales.new_sayable_date(locales.get_date_locale('de') or { assert false; return }, .normal)
	result := sd.format_date('2025-03-15') or { assert false, '7.1 should not be none'; return }
	assert result == '15. März', '7.1: got ${result}'
}

// 7.2
fn test_7_2() {
	sd := locales.new_sayable_date(locales.get_date_locale('de') or { assert false; return }, .normal)
	result := sd.format_relative('2025-03-16', '2025-03-15') or { assert false, '7.2 should not be none'; return }
	assert result == 'morgen', '7.2: got ${result}'
}

// 7.3
fn test_7_3() {
	sd := locales.new_sayable_date(locales.get_date_locale('de') or { assert false; return }, .normal)
	result := sd.format_relative('2025-03-17', '2025-03-15') or { assert false, '7.3 should not be none'; return }
	assert result == 'übermorgen', '7.3: got ${result}'
}

// 7.4
fn test_7_4() {
	sd := locales.new_sayable_date(locales.get_date_locale('de') or { assert false; return }, .normal)
	result := sd.format_relative('2025-03-19', '2025-03-15') or { assert false, '7.4 should not be none'; return }
	assert result == 'diesen Mittwoch', '7.4: got ${result}'
}

// Section 8: Locale -- French

// 8.1
fn test_8_1() {
	sd := locales.new_sayable_date(locales.get_date_locale('fr') or { assert false; return }, .normal)
	result := sd.format_date('2025-03-01') or { assert false, '8.1 should not be none'; return }
	assert result == '1er mars', '8.1: got ${result}'
}

// 8.2
fn test_8_2() {
	sd := locales.new_sayable_date(locales.get_date_locale('fr') or { assert false; return }, .normal)
	result := sd.format_date('2025-03-15') or { assert false, '8.2 should not be none'; return }
	assert result == '15 mars', '8.2: got ${result}'
}

// 8.3
fn test_8_3() {
	sd := locales.new_sayable_date(locales.get_date_locale('fr') or { assert false; return }, .normal)
	result := sd.format_relative('2025-03-16', '2025-03-15') or { assert false, '8.3 should not be none'; return }
	assert result == 'demain', '8.3: got ${result}'
}

// Section 9: Locale -- Japanese

// 9.1
fn test_9_1() {
	sd := locales.new_sayable_date(locales.get_date_locale('ja') or { assert false; return }, .normal)
	result := sd.format_date('2025-03-15') or { assert false, '9.1 should not be none'; return }
	assert result == '3月15日', '9.1: got ${result}'
}

// 9.2
fn test_9_2() {
	sd := locales.new_sayable_date(locales.get_date_locale('ja') or { assert false; return }, .normal)
	result := sd.format_relative('2025-03-16', '2025-03-15') or { assert false, '9.2 should not be none'; return }
	assert result == '明日', '9.2: got ${result}'
}

// 9.3
fn test_9_3() {
	sd := locales.new_sayable_date(locales.get_date_locale('ja') or { assert false; return }, .normal)
	result := sd.format_relative('2025-03-19', '2025-03-15') or { assert false, '9.3 should not be none'; return }
	assert result == '今度の水曜日', '9.3: got ${result}'
}

// Section 10: Locale -- Russian (genitive months)

// 10.1
fn test_10_1() {
	sd := locales.new_sayable_date(locales.get_date_locale('ru') or { assert false; return }, .normal)
	result := sd.format_date('2025-03-15') or { assert false, '10.1 should not be none'; return }
	assert result == '15 марта', '10.1: got ${result}'
}

// 10.2
fn test_10_2() {
	sd := locales.new_sayable_date(locales.get_date_locale('ru') or { assert false; return }, .normal)
	result := sd.format_relative('2025-03-16', '2025-03-15') or { assert false, '10.2 should not be none'; return }
	assert result == 'завтра', '10.2: got ${result}'
}

// Section 11: Locale -- Arabic

// 11.1
fn test_11_1() {
	sd := locales.new_sayable_date(locales.get_date_locale('ar') or { assert false; return }, .normal)
	result := sd.format_date('2025-03-15') or { assert false, '11.1 should not be none'; return }
	assert result == '15 مارس', '11.1: got ${result}'
}

// 11.2
fn test_11_2() {
	sd := locales.new_sayable_date(locales.get_date_locale('ar') or { assert false; return }, .normal)
	result := sd.format_relative('2025-03-16', '2025-03-15') or { assert false, '11.2 should not be none'; return }
	assert result == 'غداً', '11.2: got ${result}'
}

// Section 12: Locale -- Spanish

// 12.1
fn test_12_1() {
	sd := locales.new_sayable_date(locales.get_date_locale('es') or { assert false; return }, .normal)
	result := sd.format_date('2025-03-15') or { assert false, '12.1 should not be none'; return }
	assert result == '15 de marzo', '12.1: got ${result}'
}

// 12.2
fn test_12_2() {
	sd := locales.new_sayable_date(locales.get_date_locale('es') or { assert false; return }, .normal)
	result := sd.format_relative('2025-03-17', '2025-03-15') or { assert false, '12.2 should not be none'; return }
	assert result == 'pasado mañana', '12.2: got ${result}'
}
