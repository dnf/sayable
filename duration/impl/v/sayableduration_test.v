module sayableduration

import locales

// Section 1: Null / edge cases

// 1.1
fn test_1_1() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_duration(-1)
	assert result == none, '1.1'
}

// 1.2
fn test_1_2() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_duration(-1)
	assert result == none, '1.2'
}

// 1.3
fn test_1_3() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_since('', '2025-01-15T10:00:00')
	assert result == none, '1.3'
}

// 1.4
fn test_1_4() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_until('', '2025-01-15T10:00:00')
	assert result == none, '1.4'
}

// 1.5
fn test_1_5() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_since('2025-01-15T10:00:00', '2025-01-15T09:00:00')
	assert result == none, '1.5'
}

// 1.6
fn test_1_6() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_until('2025-01-15T09:00:00', '2025-01-15T10:00:00')
	assert result == none, '1.6'
}

// Section 2: Duration -- seconds tier (0-59s)

// 2.1
fn test_2_1() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_duration(0) or { assert false, '2.1 should not be none'; return }
	assert result == 'just now', '2.1: got ${result}'
}

// 2.2
fn test_2_2() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_duration(1) or { assert false, '2.2 should not be none'; return }
	assert result == '1 second', '2.2: got ${result}'
}

// 2.3
fn test_2_3() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_duration(45) or { assert false, '2.3 should not be none'; return }
	assert result == '45 seconds', '2.3: got ${result}'
}

// 2.4
fn test_2_4() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_duration(59) or { assert false, '2.4 should not be none'; return }
	assert result == '59 seconds', '2.4: got ${result}'
}

// Section 3: Duration -- minutes + seconds tier (1-4 min)

// 3.1
fn test_3_1() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_duration(60) or { assert false, '3.1 should not be none'; return }
	assert result == '1 minute', '3.1: got ${result}'
}

// 3.2
fn test_3_2() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_duration(90) or { assert false, '3.2 should not be none'; return }
	assert result == '1 minute, 30 seconds', '3.2: got ${result}'
}

// 3.3
fn test_3_3() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_duration(240) or { assert false, '3.3 should not be none'; return }
	assert result == '4 minutes', '3.3: got ${result}'
}

// 3.4
fn test_3_4() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_duration(270) or { assert false, '3.4 should not be none'; return }
	assert result == '4 minutes, 30 seconds', '3.4: got ${result}'
}

// Section 4: Duration -- minutes tier (5-59 min)

// 4.1
fn test_4_1() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_duration(300) or { assert false, '4.1 should not be none'; return }
	assert result == '5 minutes', '4.1: got ${result}'
}

// 4.2
fn test_4_2() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_duration(1500) or { assert false, '4.2 should not be none'; return }
	assert result == '25 minutes', '4.2: got ${result}'
}

// 4.3
fn test_4_3() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_duration(3540) or { assert false, '4.3 should not be none'; return }
	assert result == '59 minutes', '4.3: got ${result}'
}

// Section 5: Duration -- hours + minutes tier (1-5 hr)

// 5.1
fn test_5_1() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_duration(3600) or { assert false, '5.1 should not be none'; return }
	assert result == '1 hour', '5.1: got ${result}'
}

// 5.2
fn test_5_2() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_duration(5400) or { assert false, '5.2 should not be none'; return }
	assert result == '1½ hours', '5.2: got ${result}'
}

// 5.3
fn test_5_3() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_duration(8100) or { assert false, '5.3 should not be none'; return }
	assert result == '2 hours, 15 minutes', '5.3: got ${result}'
}

// 5.4
fn test_5_4() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_duration(18000) or { assert false, '5.4 should not be none'; return }
	assert result == '5 hours', '5.4: got ${result}'
}

// Section 6: Duration -- hours tier (6-23 hr)

// 6.1
fn test_6_1() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_duration(28800) or { assert false, '6.1 should not be none'; return }
	assert result == '8 hours', '6.1: got ${result}'
}

// 6.2
fn test_6_2() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_duration(82800) or { assert false, '6.2 should not be none'; return }
	assert result == '23 hours', '6.2: got ${result}'
}

// Section 7: Duration -- days tier

// 7.1
fn test_7_1() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_duration(86400) or { assert false, '7.1 should not be none'; return }
	assert result == '1 day', '7.1: got ${result}'
}

// 7.2
fn test_7_2() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_duration(97200) or { assert false, '7.2 should not be none'; return }
	assert result == '1 day, 3 hours', '7.2: got ${result}'
}

// 7.3
fn test_7_3() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_duration(129600) or { assert false, '7.3 should not be none'; return }
	assert result == '1½ days', '7.3: got ${result}'
}

// 7.4
fn test_7_4() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_duration(432000) or { assert false, '7.4 should not be none'; return }
	assert result == '5 days', '7.4: got ${result}'
}

// 7.5
fn test_7_5() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_duration(172800) or { assert false, '7.5 should not be none'; return }
	assert result == '2 days', '7.5: got ${result}'
}

// Section 8: Duration -- weeks tier

// 8.1
fn test_8_1() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_duration(604800) or { assert false, '8.1 should not be none'; return }
	assert result == '1 week', '8.1: got ${result}'
}

// 8.2
fn test_8_2() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_duration(1296000) or { assert false, '8.2 should not be none'; return }
	assert result == '2 weeks, 1 day', '8.2: got ${result}'
}

// 8.3
fn test_8_3() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_duration(2419200) or { assert false, '8.3 should not be none'; return }
	assert result == '4 weeks', '8.3: got ${result}'
}

// Section 9: Duration -- months and years tier

// 9.1
fn test_9_1() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_duration(2678400) or { assert false, '9.1 should not be none'; return }
	assert result == '1 month', '9.1: got ${result}'
}

// 9.2
fn test_9_2() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_duration(7884000) or { assert false, '9.2 should not be none'; return }
	assert result == '3 months', '9.2: got ${result}'
}

// 9.3
fn test_9_3() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_duration(31536000) or { assert false, '9.3 should not be none'; return }
	assert result == '1 year', '9.3: got ${result}'
}

// 9.4
fn test_9_4() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_duration(39420000) or { assert false, '9.4 should not be none'; return }
	assert result == '1 year, 3 months', '9.4: got ${result}'
}

// Section 10: Duration from ISO timestamps

// 10.1
fn test_10_1() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_duration_iso('2025-01-15T10:00:00', '2025-01-15T11:30:00') or { assert false, '10.1 should not be none'; return }
	assert result == '1½ hours', '10.1: got ${result}'
}

// 10.2
fn test_10_2() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_duration_iso('2025-01-15T10:00:00', '2025-01-15T10:45:00') or { assert false, '10.2 should not be none'; return }
	assert result == '45 minutes', '10.2: got ${result}'
}

// Section 11: Relative time -- since

// 11.1
fn test_11_1() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_since('2025-01-15T10:00:00', '2025-01-15T10:00:00') or { assert false, '11.1 should not be none'; return }
	assert result == 'just now', '11.1: got ${result}'
}

// 11.2
fn test_11_2() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_since('2025-01-15T10:00:00', '2025-01-15T10:00:30') or { assert false, '11.2 should not be none'; return }
	assert result == '30 seconds ago', '11.2: got ${result}'
}

// 11.3
fn test_11_3() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_since('2025-01-15T10:00:00', '2025-01-15T10:45:00') or { assert false, '11.3 should not be none'; return }
	assert result == '45 minutes ago', '11.3: got ${result}'
}

// 11.4
fn test_11_4() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_since('2025-01-15T10:00:00', '2025-01-15T13:00:00') or { assert false, '11.4 should not be none'; return }
	assert result == '3 hours ago', '11.4: got ${result}'
}

// Section 12: Relative time -- until

// 12.1
fn test_12_1() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_until('2025-01-15T10:00:00', '2025-01-15T10:00:00') or { assert false, '12.1 should not be none'; return }
	assert result == 'just now', '12.1: got ${result}'
}

// 12.2
fn test_12_2() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_until('2025-01-15T10:20:00', '2025-01-15T10:00:00') or { assert false, '12.2 should not be none'; return }
	assert result == 'in 20 minutes', '12.2: got ${result}'
}

// 12.3
fn test_12_3() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .normal)
	result := sd.format_until('2025-01-15T13:00:00', '2025-01-15T10:00:00') or { assert false, '12.3 should not be none'; return }
	assert result == 'in 3 hours', '12.3: got ${result}'
}

// Section 13: Locale -- German

// 13.1
fn test_13_1() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('de') or { assert false; return }, .normal)
	result := sd.format_duration(3600) or { assert false, '13.1 should not be none'; return }
	assert result == '1 Stunde', '13.1: got ${result}'
}

// 13.2
fn test_13_2() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('de') or { assert false; return }, .normal)
	result := sd.format_since('2025-01-15T10:00:00', '2025-01-15T10:05:00') or { assert false, '13.2 should not be none'; return }
	assert result == 'vor 5 Minuten', '13.2: got ${result}'
}

// Section 14: Locale -- French

// 14.1
fn test_14_1() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('fr') or { assert false; return }, .normal)
	result := sd.format_duration(7200) or { assert false, '14.1 should not be none'; return }
	assert result == '2 heures', '14.1: got ${result}'
}

// Section 15: Locale -- Japanese

// 15.1
fn test_15_1() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('ja') or { assert false; return }, .normal)
	result := sd.format_duration(120) or { assert false, '15.1 should not be none'; return }
	assert result == '2分', '15.1: got ${result}'
}

// 15.2
fn test_15_2() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('ja') or { assert false; return }, .normal)
	result := sd.format_since('2025-01-15T10:00:00', '2025-01-15T11:00:00') or { assert false, '15.2 should not be none'; return }
	assert result == '1時間前', '15.2: got ${result}'
}

// Section 16: Short compactness -- duration

// 16.1
fn test_16_1() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .short)
	result := sd.format_duration(3600) or { assert false, '16.1 should not be none'; return }
	assert result == '1h', '16.1: got ${result}'
}

// 16.2
fn test_16_2() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .short)
	result := sd.format_duration(90) or { assert false, '16.2 should not be none'; return }
	assert result == '1m, 30s', '16.2: got ${result}'
}

// Section 17: Compact compactness -- duration

// 17.1
fn test_17_1() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .compact)
	result := sd.format_duration(3600) or { assert false, '17.1 should not be none'; return }
	assert result == '1h', '17.1: got ${result}'
}

// 17.2
fn test_17_2() {
	sd := locales.new_sayable_duration(locales.get_duration_locale('en') or { assert false; return }, .compact)
	result := sd.format_duration(90) or { assert false, '17.2 should not be none'; return }
	assert result == '1m30s', '17.2: got ${result}'
}
