module sayabletime

import locales

// Section 1: Null / edge cases

// 1.1
fn test_1_1() {
	st := locales.new_sayable_time(locales.get_time_locale('en') or { assert false; return }, .normal)
	result := st.format_time('')
	assert result == none, '1.1'
}

// 1.2
fn test_1_2() {
	st := locales.new_sayable_time(locales.get_time_locale('en') or { assert false; return }, .normal)
	result := st.format_time('')
	assert result == none, '1.2'
}

// 1.3
fn test_1_3() {
	st := locales.new_sayable_time(locales.get_time_locale('en') or { assert false; return }, .normal)
	result := st.format_time('invalid')
	assert result == none, '1.3'
}

// 1.4
fn test_1_4() {
	st := locales.new_sayable_time(locales.get_time_locale('en') or { assert false; return }, .normal)
	result := st.format_time('25:00')
	assert result == none, '1.4'
}

// Section 2: Clock time (normal compactness)

// 2.1
fn test_2_1() {
	st := locales.new_sayable_time(locales.get_time_locale('en') or { assert false; return }, .normal)
	result := st.format_time('00:00') or { assert false, '2.1 should not be none'; return }
	assert result == 'midnight', '2.1: got ${result}'
}

// 2.2
fn test_2_2() {
	st := locales.new_sayable_time(locales.get_time_locale('en') or { assert false; return }, .normal)
	result := st.format_time('12:00') or { assert false, '2.2 should not be none'; return }
	assert result == 'noon', '2.2: got ${result}'
}

// 2.3
fn test_2_3() {
	st := locales.new_sayable_time(locales.get_time_locale('en') or { assert false; return }, .normal)
	result := st.format_time('15:00') or { assert false, '2.3 should not be none'; return }
	assert result == "three o'clock", '2.3: got ${result}'
}

// 2.4
fn test_2_4() {
	st := locales.new_sayable_time(locales.get_time_locale('en') or { assert false; return }, .normal)
	result := st.format_time('14:15') or { assert false, '2.4 should not be none'; return }
	assert result == 'a quarter past two', '2.4: got ${result}'
}

// 2.5
fn test_2_5() {
	st := locales.new_sayable_time(locales.get_time_locale('en') or { assert false; return }, .normal)
	result := st.format_time('09:30') or { assert false, '2.5 should not be none'; return }
	assert result == 'half past nine', '2.5: got ${result}'
}

// 2.6
fn test_2_6() {
	st := locales.new_sayable_time(locales.get_time_locale('en') or { assert false; return }, .normal)
	result := st.format_time('10:45') or { assert false, '2.6 should not be none'; return }
	assert result == 'a quarter to eleven', '2.6: got ${result}'
}

// 2.7
fn test_2_7() {
	st := locales.new_sayable_time(locales.get_time_locale('en') or { assert false; return }, .normal)
	result := st.format_time('08:05') or { assert false, '2.7 should not be none'; return }
	assert result == 'five past eight', '2.7: got ${result}'
}

// 2.8
fn test_2_8() {
	st := locales.new_sayable_time(locales.get_time_locale('en') or { assert false; return }, .normal)
	result := st.format_time('16:55') or { assert false, '2.8 should not be none'; return }
	assert result == 'five to five', '2.8: got ${result}'
}

// 2.9
fn test_2_9() {
	st := locales.new_sayable_time(locales.get_time_locale('en') or { assert false; return }, .normal)
	result := st.format_time('23:58') or { assert false, '2.9 should not be none'; return }
	assert result == 'midnight', '2.9: got ${result}'
}

// 2.10
fn test_2_10() {
	st := locales.new_sayable_time(locales.get_time_locale('en') or { assert false; return }, .normal)
	result := st.format_time('07:22') or { assert false, '2.10 should not be none'; return }
	assert result == 'twenty past seven', '2.10: got ${result}'
}

// 2.11
fn test_2_11() {
	st := locales.new_sayable_time(locales.get_time_locale('en') or { assert false; return }, .normal)
	result := st.format_time('2025-01-15T14:15:00') or { assert false, '2.11 should not be none'; return }
	assert result == 'a quarter past two', '2.11: got ${result}'
}

// Section 3: Clock time (short compactness)

// 3.1
fn test_3_1() {
	st := locales.new_sayable_time(locales.get_time_locale('en') or { assert false; return }, .short)
	result := st.format_time('14:15') or { assert false, '3.1 should not be none'; return }
	assert result == '2:15 PM', '3.1: got ${result}'
}

// 3.2
fn test_3_2() {
	st := locales.new_sayable_time(locales.get_time_locale('en') or { assert false; return }, .short)
	result := st.format_time('09:30') or { assert false, '3.2 should not be none'; return }
	assert result == '9:30 AM', '3.2: got ${result}'
}

// 3.3
fn test_3_3() {
	st := locales.new_sayable_time(locales.get_time_locale('en') or { assert false; return }, .short)
	result := st.format_time('00:00') or { assert false, '3.3 should not be none'; return }
	assert result == '12:00 AM', '3.3: got ${result}'
}

// 3.4
fn test_3_4() {
	st := locales.new_sayable_time(locales.get_time_locale('en') or { assert false; return }, .short)
	result := st.format_time('12:00') or { assert false, '3.4 should not be none'; return }
	assert result == '12:00 PM', '3.4: got ${result}'
}

// Section 4: Clock time (compact)

// 4.1
fn test_4_1() {
	st := locales.new_sayable_time(locales.get_time_locale('en') or { assert false; return }, .compact)
	result := st.format_time('14:15') or { assert false, '4.1 should not be none'; return }
	assert result == '2:15p', '4.1: got ${result}'
}

// 4.2
fn test_4_2() {
	st := locales.new_sayable_time(locales.get_time_locale('en') or { assert false; return }, .compact)
	result := st.format_time('09:30') or { assert false, '4.2 should not be none'; return }
	assert result == '9:30a', '4.2: got ${result}'
}

// Section 5: Locale -- German

// 5.1
fn test_5_1() {
	st := locales.new_sayable_time(locales.get_time_locale('de') or { assert false; return }, .normal)
	result := st.format_time('15:30') or { assert false, '5.1 should not be none'; return }
	assert result == 'halb vier', '5.1: got ${result}'
}

// Section 6: Locale -- French

// 6.1
fn test_6_1() {
	st := locales.new_sayable_time(locales.get_time_locale('fr') or { assert false; return }, .normal)
	result := st.format_time('15:15') or { assert false, '6.1 should not be none'; return }
	assert result == 'trois heures et quart', '6.1: got ${result}'
}

// Section 7: Locale -- Japanese

// 7.1
fn test_7_1() {
	st := locales.new_sayable_time(locales.get_time_locale('ja') or { assert false; return }, .normal)
	result := st.format_time('15:30') or { assert false, '7.1 should not be none'; return }
	assert result == '三時半', '7.1: got ${result}'
}

// Section 8: Locale -- Finnish (dot separator, short)

// 8.1
fn test_8_1() {
	st := locales.new_sayable_time(locales.get_time_locale('fi') or { assert false; return }, .short)
	result := st.format_time('14:15') or { assert false, '8.1 should not be none'; return }
	assert result == '14.15', '8.1: got ${result}'
}

// 8.2
fn test_8_2() {
	st := locales.new_sayable_time(locales.get_time_locale('fi') or { assert false; return }, .short)
	result := st.format_time('00:00') or { assert false, '8.2 should not be none'; return }
	assert result == '0.00', '8.2: got ${result}'
}
