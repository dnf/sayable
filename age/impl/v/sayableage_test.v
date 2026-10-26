module sayableage

import locales
import time

fn test_1_1() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('', '')
	assert result == none, '1.1'
}

fn test_1_3() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('', '')
	assert result == none, '1.3'
}

fn test_1_4() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-07-01', '2025-06-15')
	assert result == none, '1.4'
}

fn test_1_5() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('1525-06-15', '2025-06-15') or { panic('1.5 should not be none') }
	assert result == '500 years'
}

fn test_1_6() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('1524-06-15', '2025-06-15')
	assert result == none, '1.6'
}

fn test_1_7() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('1025-06-15', '2025-06-15')
	assert result == none, '1.7'
}

fn test_2_1() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-15', '2025-06-15') or { panic('2.1 should not be none') }
	assert result == 'Newborn'
}

fn test_2_2() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-14', '2025-06-15') or { panic('2.2 should not be none') }
	assert result == '1 day'
}

fn test_2_3() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-12', '2025-06-15') or { panic('2.3 should not be none') }
	assert result == '3 days'
}

fn test_2_4() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-09', '2025-06-15') or { panic('2.4 should not be none') }
	assert result == '6 days'
}

fn test_2_5() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-08', '2025-06-15') or { panic('2.5 should not be none') }
	assert result == '1 week'
}

fn test_3_1() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-08', '2025-06-15') or { panic('3.1 should not be none') }
	assert result == '1 week'
}

fn test_3_2() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-07', '2025-06-15') or { panic('3.2 should not be none') }
	assert result == '1 week, 1 day'
}

fn test_3_3() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-06', '2025-06-15') or { panic('3.3 should not be none') }
	assert result == '1 week, 2 days'
}

fn test_3_4() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-02', '2025-06-15') or { panic('3.4 should not be none') }
	assert result == '1 week, 6 days'
}

fn test_3_5() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-01', '2025-06-15') or { panic('3.5 should not be none') }
	assert result == '2 weeks'
}

fn test_3_6() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-05-31', '2025-06-15') or { panic('3.6 should not be none') }
	assert result == '2 weeks, 1 day'
}

fn test_3_7() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-05-26', '2025-06-15') or { panic('3.7 should not be none') }
	assert result == '2 weeks, 6 days'
}

fn test_3_8() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-05-25', '2025-06-15') or { panic('3.8 should not be none') }
	assert result == '3 weeks'
}

fn test_3_9() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-05-15', '2025-06-15') or { panic('3.9 should not be none') }
	assert result == '4 weeks, 3 days'
}

fn test_3_10() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-04-15', '2025-06-15') or { panic('3.10 should not be none') }
	assert result == '8 weeks, 5 days'
}

fn test_3_11() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-03-15', '2025-06-14') or { panic('3.11 should not be none') }
	assert result == '13 weeks'
}

fn test_3_12() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-03-15', '2025-06-15') or { panic('3.12 should not be none') }
	assert result == '3 months'
}

fn test_4_1() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-01-01', '2025-04-01') or { panic('4.1 should not be none') }
	assert result == '3 months'
}

fn test_4_2() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-01-01', '2025-03-31') or { panic('4.2 should not be none') }
	assert result.contains('weeks'), '4.2'
}

fn test_4_3() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-15', '2025-09-15') or { panic('4.3 should not be none') }
	assert result == '3 months'
}

fn test_4_4() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-15', '2025-09-14') or { panic('4.4 should not be none') }
	assert result.contains('weeks'), '4.4'
}

fn test_4_5() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-15', '2025-12-15') or { panic('4.5 should not be none') }
	assert result == '6 months'
}

fn test_5_1() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-01-31', '2025-02-28') or { panic('5.1 should not be none') }
	assert result == '4 weeks'
}

fn test_5_2() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-01-31', '2025-04-30') or { panic('5.2 should not be none') }
	assert result == '3 months'
}

fn test_5_3() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-01-31', '2025-04-29') or { panic('5.3 should not be none') }
	assert result.contains('weeks'), '5.3'
}

fn test_5_4() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-02-01', '2025-05-01') or { panic('5.4 should not be none') }
	assert result == '3 months'
}

fn test_5_5() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-02-01', '2025-04-30') or { panic('5.5 should not be none') }
	assert result.contains('weeks'), '5.5'
}

fn test_6_1() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2024-01-31', '2024-02-29') or { panic('6.1 should not be none') }
	assert result == '4 weeks, 1 day'
}

fn test_6_2() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2024-01-31', '2024-02-28') or { panic('6.2 should not be none') }
	assert result == '4 weeks'
}

fn test_6_3() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2024-01-31', '2024-04-30') or { panic('6.3 should not be none') }
	assert result == '3 months'
}

fn test_6_4() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2024-01-30', '2024-02-29') or { panic('6.4 should not be none') }
	assert result.contains('weeks'), '6.4'
}

fn test_6_5() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2024-01-30', '2024-02-28') or { panic('6.5 should not be none') }
	assert result.contains('weeks'), '6.5'
}

fn test_7_1() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-03-31', '2025-06-30') or { panic('7.1 should not be none') }
	assert result == '3 months'
}

fn test_7_2() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-03-31', '2025-06-29') or { panic('7.2 should not be none') }
	assert result.contains('weeks'), '7.2'
}

fn test_7_3() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-08-31', '2025-11-30') or { panic('7.3 should not be none') }
	assert result == '3 months'
}

fn test_7_4() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-08-31', '2025-11-29') or { panic('7.4 should not be none') }
	assert result.contains('weeks'), '7.4'
}

fn test_8_1() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2024-02-29', '2024-05-29') or { panic('8.1 should not be none') }
	assert result == '3 months'
}

fn test_8_2() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2024-02-29', '2024-05-28') or { panic('8.2 should not be none') }
	assert result.contains('weeks'), '8.2'
}

fn test_8_3() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2024-02-29', '2025-02-28') or { panic('8.3 should not be none') }
	assert result == '12 months'
}

fn test_8_4() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2024-02-29', '2025-03-01') or { panic('8.4 should not be none') }
	assert result == '12 months'
}

fn test_9_1() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-01-15', '2025-04-15') or { panic('9.1 should not be none') }
	assert result == '3 months'
}

fn test_9_2() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-01-15', '2025-07-15') or { panic('9.2 should not be none') }
	assert result == '6 months'
}

fn test_9_3() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2024-06-15', '2025-06-15') or { panic('9.3 should not be none') }
	assert result == '12 months'
}

fn test_9_4() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2024-01-15', '2025-12-15') or { panic('9.4 should not be none') }
	assert result == '23 months'
}

fn test_9_5() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-01-15', '2025-07-14') or { panic('9.5 should not be none') }
	assert result == '5 months'
}

fn test_9_6() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2024-11-10', '2025-04-10') or { panic('9.6 should not be none') }
	assert result == '5 months'
}

fn test_10_1() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2023-06-15', '2025-06-15') or { panic('10.1 should not be none') }
	assert result == '2 years'
}

fn test_10_2() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2023-06-15', '2025-07-15') or { panic('10.2 should not be none') }
	assert result == '2 years, 1 month'
}

fn test_10_3() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2023-06-15', '2025-12-15') or { panic('10.3 should not be none') }
	assert result == '2 years, 6 months'
}

fn test_10_4() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2023-06-15', '2026-05-15') or { panic('10.4 should not be none') }
	assert result == '2 years, 11 months'
}

fn test_10_5() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2023-06-15', '2025-06-14') or { panic('10.5 should not be none') }
	assert result == '23 months'
}

fn test_11_1() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2022-06-15', '2025-06-15') or { panic('11.1 should not be none') }
	assert result == '3 years'
}

fn test_11_2() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2022-06-15', '2025-11-15') or { panic('11.2 should not be none') }
	assert result == '3 years'
}

fn test_11_3() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2022-06-15', '2025-12-15') or { panic('11.3 should not be none') }
	assert result == '3½ years'
}

fn test_11_4() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2022-06-15', '2026-05-15') or { panic('11.4 should not be none') }
	assert result == '3½ years'
}

fn test_11_5() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2021-06-15', '2025-06-15') or { panic('11.5 should not be none') }
	assert result == '4 years'
}

fn test_11_6() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2021-06-15', '2025-12-15') or { panic('11.6 should not be none') }
	assert result == '4½ years'
}

fn test_11_7() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2020-06-15', '2025-06-15') or { panic('11.7 should not be none') }
	assert result == '5 years'
}

fn test_11_8() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2020-06-15', '2026-02-15') or { panic('11.8 should not be none') }
	assert result == '5½ years'
}

fn test_11_9() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2019-06-15', '2025-06-15') or { panic('11.9 should not be none') }
	assert result == '6 years'
}

fn test_11_10() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2019-06-15', '2025-12-15') or { panic('11.10 should not be none') }
	assert result == '6½ years'
}

fn test_11_11() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2019-06-15', '2026-05-15') or { panic('11.11 should not be none') }
	assert result == '6½ years'
}

fn test_11_12() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2022-06-15', '2025-06-14') or { panic('11.12 should not be none') }
	assert result == '2 years, 11 months'
}

fn test_12_1() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2018-06-15', '2025-06-15') or { panic('12.1 should not be none') }
	assert result == '7 years'
}

fn test_12_2() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2018-03-20', '2025-06-15') or { panic('12.2 should not be none') }
	assert result == '7 years'
}

fn test_12_3() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('1980-01-01', '2025-06-15') or { panic('12.3 should not be none') }
	assert result == '45 years'
}

fn test_13_1() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2024-12-31', '2025-03-31') or { panic('13.1 should not be none') }
	assert result == '3 months'
}

fn test_13_2() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2024-12-31', '2025-03-30') or { panic('13.2 should not be none') }
	assert result.contains('weeks'), '13.2'
}

fn test_13_3() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2024-11-30', '2025-02-28') or { panic('13.3 should not be none') }
	assert result == '3 months'
}

fn test_13_4() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2024-11-30', '2025-02-27') or { panic('13.4 should not be none') }
	assert result.contains('weeks'), '13.4'
}

fn test_14_1() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-01-31', '2025-04-30') or { panic('14.1 should not be none') }
	assert result == '3 months'
}

fn test_14_2() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-01-31', '2025-05-31') or { panic('14.2 should not be none') }
	assert result == '4 months'
}

fn test_14_3() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-01-31', '2025-06-30') or { panic('14.3 should not be none') }
	assert result == '5 months'
}

fn test_14_4() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-01-31', '2025-07-01') or { panic('14.4 should not be none') }
	assert result == '5 months'
}

fn test_14_5() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-01-31', '2025-07-31') or { panic('14.5 should not be none') }
	assert result == '6 months'
}

// Default as_of (empty string means today, local time): dateOfBirth is derived
// from the real current date to keep the canonical expected output. The day
// is capped at 28 so that a Feb 29 today still yields a real calendar date
// years earlier.
fn today_string() string {
	return time.now().ymmdd()
}

fn years_before_today(years int) string {
	today := time.now()
	day := if today.day > 28 { 28 } else { today.day }
	return '${today.year - years:04}-${today.month:02}-${day:02}'
}

fn days_before_today(days int) string {
	return time.now().add_days(-days).ymmdd()
}

// 15.1
fn test_15_1() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age(years_before_today(5), '') or { panic('15.1 should not be none') }
	assert result == '5 years'
}

// 15.2
fn test_15_2() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age(days_before_today(5), '') or { panic('15.2 should not be none') }
	assert result == '5 days'
}

fn test_16_1() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('', '', '')
	assert result == none, '16.1'
}

fn test_16_3() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('', '', '')
	assert result == none, '16.3'
}

fn test_16_4() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2025-07-01', '2025-06-15', '')
	assert result == none, '16.4'
}

fn test_16_5() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('1525-06-15', '2025-06-15', '') or { panic('16.5 should not be none') }
	assert result == 'Adult'
}

fn test_16_6() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('1524-06-15', '2025-06-15', '')
	assert result == none, '16.6'
}

fn test_17_1() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2025-06-15', '2025-06-15', '') or { panic('17.1 should not be none') }
	assert result == 'Newborn'
}

fn test_17_2() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2025-06-14', '2025-06-15', '') or { panic('17.2 should not be none') }
	assert result == 'Newborn'
}

fn test_17_3() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2025-05-25', '2025-06-15', '') or { panic('17.3 should not be none') }
	assert result == 'Newborn'
}

fn test_17_4() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2025-05-15', '2025-06-15', '') or { panic('17.4 should not be none') }
	assert result == 'Newborn'
}

fn test_17_5() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2025-04-16', '2025-06-15', '') or { panic('17.5 should not be none') }
	assert result == 'Newborn'
}

fn test_17_6() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2025-04-15', '2025-06-15', '') or { panic('17.6 should not be none') }
	assert result == 'Infant'
}

fn test_18_1() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2025-04-15', '2025-06-15', '') or { panic('18.1 should not be none') }
	assert result == 'Infant'
}

fn test_18_2() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2024-12-15', '2025-06-15', '') or { panic('18.2 should not be none') }
	assert result == 'Infant'
}

fn test_18_3() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2024-07-15', '2025-06-15', '') or { panic('18.3 should not be none') }
	assert result == 'Infant'
}

fn test_18_4() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2024-06-15', '2025-06-15', '') or { panic('18.4 should not be none') }
	assert result == 'Toddler'
}

fn test_19_1() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2024-06-15', '2025-06-15', '') or { panic('19.1 should not be none') }
	assert result == 'Toddler'
}

fn test_19_2() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2024-01-15', '2025-07-15', '') or { panic('19.2 should not be none') }
	assert result == 'Toddler'
}

fn test_19_3() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2023-06-15', '2025-06-15', '') or { panic('19.3 should not be none') }
	assert result == 'Toddler'
}

fn test_19_4() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2023-06-15', '2026-05-15', '') or { panic('19.4 should not be none') }
	assert result == 'Toddler'
}

fn test_19_5() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2022-06-15', '2025-06-15', '') or { panic('19.5 should not be none') }
	assert result == 'Child'
}

fn test_20_1() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2022-06-15', '2025-06-15', '') or { panic('20.1 should not be none') }
	assert result == 'Child'
}

fn test_20_2() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2021-06-15', '2025-06-15', '') or { panic('20.2 should not be none') }
	assert result == 'Child'
}

fn test_20_3() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2019-06-15', '2025-06-15', '') or { panic('20.3 should not be none') }
	assert result == 'Child'
}

fn test_20_4() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2016-06-15', '2025-06-15', '') or { panic('20.4 should not be none') }
	assert result == 'Child'
}

fn test_20_5() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2013-06-15', '2026-05-15', '') or { panic('20.5 should not be none') }
	assert result == 'Child'
}

fn test_20_6() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2012-06-15', '2025-06-15', '') or { panic('20.6 should not be none') }
	assert result == 'Teenager'
}

fn test_21_1() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2012-06-15', '2025-06-15', '') or { panic('21.1 should not be none') }
	assert result == 'Teenager'
}

fn test_21_2() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2010-06-15', '2025-06-15', '') or { panic('21.2 should not be none') }
	assert result == 'Teenager'
}

fn test_21_3() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2008-06-15', '2026-05-15', '') or { panic('21.3 should not be none') }
	assert result == 'Teenager'
}

fn test_21_4() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2007-06-15', '2025-06-15', '') or { panic('21.4 should not be none') }
	assert result == 'Adult'
}

fn test_22_1() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2007-06-15', '2025-06-15', '') or { panic('22.1 should not be none') }
	assert result == 'Adult'
}

fn test_22_2() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2000-06-15', '2025-06-15', '') or { panic('22.2 should not be none') }
	assert result == 'Adult'
}

fn test_22_3() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('1980-01-01', '2025-06-15', '') or { panic('22.3 should not be none') }
	assert result == 'Adult'
}

// 23.1
fn test_23_1() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage(today_string(), '', '') or { panic('23.1 should not be none') }
	assert result == 'Newborn'
}

// 23.2
fn test_23_2() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage(years_before_today(5), '', '') or { panic('23.2 should not be none') }
	assert result == 'Child'
}

// 23.3
fn test_23_3() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage(years_before_today(45), '', '') or { panic('23.3 should not be none') }
	assert result == 'Adult'
}

fn test_24_1() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-15', '2025-06-15') or { panic('24.1 should not be none') }
	assert result == 'Newborn'
}

fn test_24_2() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-12', '2025-06-15') or { panic('24.2 should not be none') }
	assert result == '3 days'
}

fn test_24_3() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-07', '2025-06-15') or { panic('24.3 should not be none') }
	assert result == '1 week, 1 day'
}

fn test_24_4() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-01-15', '2025-07-15') or { panic('24.4 should not be none') }
	assert result == '6 months'
}

fn test_24_5() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2023-06-15', '2025-07-15') or { panic('24.5 should not be none') }
	assert result == '2 years, 1 month'
}

fn test_24_6() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2022-06-15', '2025-12-15') or { panic('24.6 should not be none') }
	assert result == '3½ years'
}

fn test_24_7() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('2018-06-15', '2025-06-15') or { panic('24.7 should not be none') }
	assert result == '7 years'
}

fn test_24_8() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2025-06-15', '2025-06-15', '') or { panic('24.8 should not be none') }
	assert result == 'Newborn'
}

fn test_24_9() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2025-01-15', '2025-06-15', '') or { panic('24.9 should not be none') }
	assert result == 'Infant'
}

fn test_24_10() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2024-06-15', '2025-06-15', '') or { panic('24.10 should not be none') }
	assert result == 'Toddler'
}

fn test_24_11() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2022-06-15', '2025-06-15', '') or { panic('24.11 should not be none') }
	assert result == 'Child'
}

fn test_24_12() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2012-06-15', '2025-06-15', '') or { panic('24.12 should not be none') }
	assert result == 'Teenager'
}

fn test_24_13() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2007-06-15', '2025-06-15', '') or { panic('24.13 should not be none') }
	assert result == 'Adult'
}

fn test_24_14() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_age('', '')
	assert result == none, '24.14'
}

fn test_24_15() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := sa.format_stage('', '', '')
	assert result == none, '24.15'
}

fn test_25_1() {
	sa := locales.new_sayable_age(locales.get_locale('es') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-15', '2025-06-15') or { panic('25.1 should not be none') }
	assert result == 'Recién nacido'
}

fn test_25_2() {
	sa := locales.new_sayable_age(locales.get_locale('es') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-14', '2025-06-15') or { panic('25.2 should not be none') }
	assert result == '1 día'
}

fn test_25_3() {
	sa := locales.new_sayable_age(locales.get_locale('es') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-12', '2025-06-15') or { panic('25.3 should not be none') }
	assert result == '3 días'
}

fn test_25_4() {
	sa := locales.new_sayable_age(locales.get_locale('es') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-08', '2025-06-15') or { panic('25.4 should not be none') }
	assert result == '1 semana'
}

fn test_25_5() {
	sa := locales.new_sayable_age(locales.get_locale('es') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-07', '2025-06-15') or { panic('25.5 should not be none') }
	assert result == '1 semana, 1 día'
}

fn test_25_6() {
	sa := locales.new_sayable_age(locales.get_locale('es') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-05-26', '2025-06-15') or { panic('25.6 should not be none') }
	assert result == '2 semanas, 6 días'
}

fn test_25_7() {
	sa := locales.new_sayable_age(locales.get_locale('es') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-01-15', '2025-07-15') or { panic('25.7 should not be none') }
	assert result == '6 meses'
}

fn test_25_8() {
	sa := locales.new_sayable_age(locales.get_locale('es') or { panic('locale not found') }, .normal)
	result := sa.format_age('2023-06-15', '2025-07-15') or { panic('25.8 should not be none') }
	assert result == '2 años, 1 mes'
}

fn test_25_9() {
	sa := locales.new_sayable_age(locales.get_locale('es') or { panic('locale not found') }, .normal)
	result := sa.format_age('2023-06-15', '2025-12-15') or { panic('25.9 should not be none') }
	assert result == '2 años, 6 meses'
}

fn test_25_10() {
	sa := locales.new_sayable_age(locales.get_locale('es') or { panic('locale not found') }, .normal)
	result := sa.format_age('2022-06-15', '2025-12-15') or { panic('25.10 should not be none') }
	assert result == '3 años y medio'
}

fn test_25_11() {
	sa := locales.new_sayable_age(locales.get_locale('es') or { panic('locale not found') }, .normal)
	result := sa.format_age('2022-06-15', '2025-06-15') or { panic('25.11 should not be none') }
	assert result == '3 años'
}

fn test_25_12() {
	sa := locales.new_sayable_age(locales.get_locale('es') or { panic('locale not found') }, .normal)
	result := sa.format_age('2018-06-15', '2025-06-15') or { panic('25.12 should not be none') }
	assert result == '7 años'
}

fn test_25_13() {
	sa := locales.new_sayable_age(locales.get_locale('es') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2025-06-15', '2025-06-15', '') or { panic('25.13 should not be none') }
	assert result == 'Recién nacido'
}

fn test_25_14() {
	sa := locales.new_sayable_age(locales.get_locale('es') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2025-01-15', '2025-06-15', '') or { panic('25.14 should not be none') }
	assert result == 'Bebé'
}

fn test_25_15() {
	sa := locales.new_sayable_age(locales.get_locale('es') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2024-06-15', '2025-06-15', '') or { panic('25.15 should not be none') }
	assert result == 'Niño pequeño'
}

fn test_25_16() {
	sa := locales.new_sayable_age(locales.get_locale('es') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2022-06-15', '2025-06-15', '') or { panic('25.16 should not be none') }
	assert result == 'Niño'
}

fn test_25_17() {
	sa := locales.new_sayable_age(locales.get_locale('es') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2012-06-15', '2025-06-15', '') or { panic('25.17 should not be none') }
	assert result == 'Adolescente'
}

fn test_25_18() {
	sa := locales.new_sayable_age(locales.get_locale('es') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2007-06-15', '2025-06-15', '') or { panic('25.18 should not be none') }
	assert result == 'Adulto'
}

fn test_25_19() {
	sa := locales.new_sayable_age(locales.get_locale('es') or { panic('locale not found') }, .normal)
	result := sa.format_age('', '')
	assert result == none, '25.19'
}

fn test_25_20() {
	sa := locales.new_sayable_age(locales.get_locale('es') or { panic('locale not found') }, .normal)
	result := sa.format_stage('', '', '')
	assert result == none, '25.20'
}

fn test_26_1() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .short)
	result := sa.format_age('2025-06-12', '2025-06-15') or { panic('26.1 should not be none') }
	assert result == '3 d'
}

fn test_26_2() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .short)
	result := sa.format_age('2025-06-08', '2025-06-15') or { panic('26.2 should not be none') }
	assert result == '1 wk'
}

fn test_26_3() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .short)
	result := sa.format_age('2025-06-07', '2025-06-15') or { panic('26.3 should not be none') }
	assert result == '1 wk, 1 d'
}

fn test_26_4() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .short)
	result := sa.format_age('2025-01-15', '2025-07-15') or { panic('26.4 should not be none') }
	assert result == '6 mo'
}

fn test_26_5() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .short)
	result := sa.format_age('2023-06-15', '2025-07-15') or { panic('26.5 should not be none') }
	assert result == '2 yr, 1 mo'
}

fn test_26_6() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .short)
	result := sa.format_age('2022-06-15', '2025-12-15') or { panic('26.6 should not be none') }
	assert result == '3½ yr'
}

fn test_26_7() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .short)
	result := sa.format_age('2018-06-15', '2025-06-15') or { panic('26.7 should not be none') }
	assert result == '7 yr'
}

fn test_26_8() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .short)
	result := sa.format_age('2025-06-15', '2025-06-15') or { panic('26.8 should not be none') }
	assert result == 'Newborn'
}

fn test_26_9() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .short)
	result := sa.format_stage('2025-01-15', '2025-06-15', '') or { panic('26.9 should not be none') }
	assert result == 'Infant'
}

fn test_27_1() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .compact)
	result := sa.format_age('2025-06-12', '2025-06-15') or { panic('27.1 should not be none') }
	assert result == '3d'
}

fn test_27_2() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .compact)
	result := sa.format_age('2025-06-08', '2025-06-15') or { panic('27.2 should not be none') }
	assert result == '1w'
}

fn test_27_3() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .compact)
	result := sa.format_age('2025-06-07', '2025-06-15') or { panic('27.3 should not be none') }
	assert result == '1w1d'
}

fn test_27_4() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .compact)
	result := sa.format_age('2025-01-15', '2025-07-15') or { panic('27.4 should not be none') }
	assert result == '6m'
}

fn test_27_5() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .compact)
	result := sa.format_age('2023-06-15', '2025-07-15') or { panic('27.5 should not be none') }
	assert result == '2y1m'
}

fn test_27_6() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .compact)
	result := sa.format_age('2022-06-15', '2025-12-15') or { panic('27.6 should not be none') }
	assert result == '3½y'
}

fn test_27_7() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .compact)
	result := sa.format_age('2018-06-15', '2025-06-15') or { panic('27.7 should not be none') }
	assert result == '7y'
}

fn test_27_8() {
	sa := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .compact)
	result := sa.format_age('2025-06-15', '2025-06-15') or { panic('27.8 should not be none') }
	assert result == 'Newborn'
}

fn test_29_1() {
	sa := locales.new_sayable_age(locales.get_locale('he') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-15', '2025-06-15') or { panic('29.1 should not be none') }
	assert result == 'רק נולד'
}

fn test_29_2() {
	sa := locales.new_sayable_age(locales.get_locale('he') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-14', '2025-06-15') or { panic('29.2 should not be none') }
	assert result == 'יום'
}

fn test_29_3() {
	sa := locales.new_sayable_age(locales.get_locale('he') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-12', '2025-06-15') or { panic('29.3 should not be none') }
	assert result == '3 ימים'
}

fn test_29_4() {
	sa := locales.new_sayable_age(locales.get_locale('he') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-01', '2025-06-15') or { panic('29.4 should not be none') }
	assert result == 'שבועיים'
}

fn test_29_5() {
	sa := locales.new_sayable_age(locales.get_locale('he') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-05-25', '2025-06-15') or { panic('29.5 should not be none') }
	assert result == '3 שבועות'
}

fn test_29_6() {
	sa := locales.new_sayable_age(locales.get_locale('he') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-01-15', '2025-07-15') or { panic('29.6 should not be none') }
	assert result == '6 חודשים'
}

fn test_29_7() {
	sa := locales.new_sayable_age(locales.get_locale('he') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-03-15', '2025-06-15') or { panic('29.7 should not be none') }
	assert result == '3 חודשים'
}

fn test_29_8() {
	sa := locales.new_sayable_age(locales.get_locale('he') or { panic('locale not found') }, .normal)
	result := sa.format_age('2023-06-15', '2025-07-15') or { panic('29.8 should not be none') }
	assert result == 'שנתיים, חודש'
}

fn test_29_9() {
	sa := locales.new_sayable_age(locales.get_locale('he') or { panic('locale not found') }, .normal)
	result := sa.format_age('2022-06-15', '2025-12-15') or { panic('29.9 should not be none') }
	assert result == '3 שנים וחצי'
}

fn test_29_10() {
	sa := locales.new_sayable_age(locales.get_locale('he') or { panic('locale not found') }, .normal)
	result := sa.format_age('2018-06-15', '2025-06-15') or { panic('29.10 should not be none') }
	assert result == '7 שנים'
}

fn test_29_11() {
	sa := locales.new_sayable_age(locales.get_locale('he') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2025-06-15', '2025-06-15', 'm') or { panic('29.11 should not be none') }
	assert result == 'רק נולד'
}

fn test_29_12() {
	sa := locales.new_sayable_age(locales.get_locale('he') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2025-06-15', '2025-06-15', 'f') or { panic('29.12 should not be none') }
	assert result == 'רק נולדה'
}

fn test_29_13() {
	sa := locales.new_sayable_age(locales.get_locale('he') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2007-06-15', '2025-06-15', 'm') or { panic('29.13 should not be none') }
	assert result == 'מבוגר'
}

fn test_29_14() {
	sa := locales.new_sayable_age(locales.get_locale('he') or { panic('locale not found') }, .normal)
	result := sa.format_stage('2007-06-15', '2025-06-15', 'f') or { panic('29.14 should not be none') }
	assert result == 'מבוגרת'
}

fn test_29_15() {
	sa := locales.new_sayable_age(locales.get_locale('mk') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-15', '2025-06-15') or { panic('29.15 should not be none') }
	assert result == 'Новороденче'
}

fn test_29_16() {
	sa := locales.new_sayable_age(locales.get_locale('mk') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-14', '2025-06-15') or { panic('29.16 should not be none') }
	assert result == '1 ден'
}

fn test_29_17() {
	sa := locales.new_sayable_age(locales.get_locale('mk') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-12', '2025-06-15') or { panic('29.17 should not be none') }
	assert result == '3 дена'
}

fn test_29_18() {
	sa := locales.new_sayable_age(locales.get_locale('mk') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-01-15', '2025-07-15') or { panic('29.18 should not be none') }
	assert result == '6 месеци'
}

fn test_29_19() {
	sa := locales.new_sayable_age(locales.get_locale('mk') or { panic('locale not found') }, .normal)
	result := sa.format_age('2023-06-15', '2025-07-15') or { panic('29.19 should not be none') }
	assert result == '2 години, 1 месец'
}

fn test_29_20() {
	sa := locales.new_sayable_age(locales.get_locale('mk') or { panic('locale not found') }, .normal)
	result := sa.format_age('2022-06-15', '2025-12-15') or { panic('29.20 should not be none') }
	assert result == '3 години и пол'
}

fn test_29_21() {
	sa := locales.new_sayable_age(locales.get_locale('mk') or { panic('locale not found') }, .normal)
	result := sa.format_age('2018-06-15', '2025-06-15') or { panic('29.21 should not be none') }
	assert result == '7 години'
}

fn test_29_22() {
	sa := locales.new_sayable_age(locales.get_locale('sw') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-15', '2025-06-15') or { panic('29.22 should not be none') }
	assert result == 'Mzaliwa mpya'
}

fn test_29_23() {
	sa := locales.new_sayable_age(locales.get_locale('sw') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-14', '2025-06-15') or { panic('29.23 should not be none') }
	assert result == 'siku 1'
}

fn test_29_24() {
	sa := locales.new_sayable_age(locales.get_locale('sw') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-12', '2025-06-15') or { panic('29.24 should not be none') }
	assert result == 'siku 3'
}

fn test_29_25() {
	sa := locales.new_sayable_age(locales.get_locale('sw') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-01-15', '2025-07-15') or { panic('29.25 should not be none') }
	assert result == 'miezi 6'
}

fn test_29_26() {
	sa := locales.new_sayable_age(locales.get_locale('sw') or { panic('locale not found') }, .normal)
	result := sa.format_age('2023-06-15', '2025-07-15') or { panic('29.26 should not be none') }
	assert result == 'miaka 2, mwezi 1'
}

fn test_29_27() {
	sa := locales.new_sayable_age(locales.get_locale('sw') or { panic('locale not found') }, .normal)
	result := sa.format_age('2022-06-15', '2025-12-15') or { panic('29.27 should not be none') }
	assert result == 'miaka 3 na nusu'
}

fn test_29_28() {
	sa := locales.new_sayable_age(locales.get_locale('id') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-15', '2025-06-15') or { panic('29.28 should not be none') }
	assert result == 'Baru lahir'
}

fn test_29_29() {
	sa := locales.new_sayable_age(locales.get_locale('id') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-14', '2025-06-15') or { panic('29.29 should not be none') }
	assert result == '1 hari'
}

fn test_29_30() {
	sa := locales.new_sayable_age(locales.get_locale('id') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-12', '2025-06-15') or { panic('29.30 should not be none') }
	assert result == '3 hari'
}

fn test_29_31() {
	sa := locales.new_sayable_age(locales.get_locale('id') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-01-15', '2025-07-15') or { panic('29.31 should not be none') }
	assert result == '6 bulan'
}

fn test_29_32() {
	sa := locales.new_sayable_age(locales.get_locale('id') or { panic('locale not found') }, .normal)
	result := sa.format_age('2022-06-15', '2025-12-15') or { panic('29.32 should not be none') }
	assert result == '3 setengah tahun'
}

fn test_29_33() {
	sa := locales.new_sayable_age(locales.get_locale('id') or { panic('locale not found') }, .normal)
	result := sa.format_age('2018-06-15', '2025-06-15') or { panic('29.33 should not be none') }
	assert result == '7 tahun'
}

fn test_29_34() {
	sa := locales.new_sayable_age(locales.get_locale('am') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-15', '2025-06-15') or { panic('29.34 should not be none') }
	assert result == 'አዲስ የተወለደ'
}

fn test_29_35() {
	sa := locales.new_sayable_age(locales.get_locale('am') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-14', '2025-06-15') or { panic('29.35 should not be none') }
	assert result == '1 ቀን'
}

fn test_29_36() {
	sa := locales.new_sayable_age(locales.get_locale('am') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-12', '2025-06-15') or { panic('29.36 should not be none') }
	assert result == '3 ቀናት'
}

fn test_29_37() {
	sa := locales.new_sayable_age(locales.get_locale('am') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-06-07', '2025-06-15') or { panic('29.37 should not be none') }
	assert result == '1 ሳምንት፣ 1 ቀን'
}

fn test_29_38() {
	sa := locales.new_sayable_age(locales.get_locale('am') or { panic('locale not found') }, .normal)
	result := sa.format_age('2025-01-15', '2025-07-15') or { panic('29.38 should not be none') }
	assert result == '6 ወራት'
}

fn test_29_39() {
	sa := locales.new_sayable_age(locales.get_locale('am') or { panic('locale not found') }, .normal)
	result := sa.format_age('2022-06-15', '2025-12-15') or { panic('29.39 should not be none') }
	assert result == '3 ዓመታት ተኩል'
}

fn test_30_1() {
	result := locales.get_locale('en') or { panic('30.1 should exist') }
	assert result.code == 'en', '30.1'
}

fn test_30_2() {
	result := locales.get_locale('fr') or { panic('30.2 should exist') }
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


// Section 31: Weeks and days across month ends

// 31.1
fn test_31_1() {
	f := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := f.format_age('2016-12-31', '2017-03-29') or { panic('31.1 should not be none') }
	assert result == '12 weeks, 4 days', '31.1'
}

// 31.2
fn test_31_2() {
	f := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := f.format_age('1991-11-27', '1992-02-25') or { panic('31.2 should not be none') }
	assert result == '12 weeks, 6 days', '31.2'
}

// 31.3
fn test_31_3() {
	f := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := f.format_age('2020-11-30', '2021-01-02') or { panic('31.3 should not be none') }
	assert result == '4 weeks, 5 days', '31.3'
}

// 31.4
fn test_31_4() {
	f := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .compact)
	result := f.format_age('2016-12-31', '2017-03-29') or { panic('31.4 should not be none') }
	assert result == '12w4d', '31.4'
}

// Section 32: Half years take their plural form from whole years

// 32.1
fn test_32_1() {
	f := locales.new_sayable_age(locales.get_locale('pl') or { panic('locale not found') }, .normal)
	result := f.format_age('2021-06-15', '2025-01-15') or { panic('32.1 should not be none') }
	assert result == '3 i pół lata', '32.1'
}

// 32.2
fn test_32_2() {
	f := locales.new_sayable_age(locales.get_locale('pl') or { panic('locale not found') }, .short)
	result := f.format_age('2020-06-15', '2025-12-15') or { panic('32.2 should not be none') }
	assert result == '5 i pół lat', '32.2'
}

// 32.3
fn test_32_3() {
	f := locales.new_sayable_age(locales.get_locale('shi') or { panic('locale not found') }, .normal)
	result := f.format_age('2005-06-08', '2012-06-07') or { panic('32.3 should not be none') }
	assert result == '6 ⵉⵙⴳⴳⵯⴰⵙⵏ ⴷ ⵓⵣⴳⵏ', '32.3'
}

// Section 33: Input validation

// 33.1
fn test_33_1() {
	f := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := f.format_age('2025-02-30', '2032-06-25')
	assert result == none, '33.1'
}

// 33.2
fn test_33_2() {
	f := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := f.format_age('2025-13-01', '2027-01-31')
	assert result == none, '33.2'
}

// 33.3
fn test_33_3() {
	f := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := f.format_age('2023-02-29', '2025-03-01')
	assert result == none, '33.3'
}

// 33.4
fn test_33_4() {
	f := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := f.format_age('2025-06-00', '2027-02-25')
	assert result == none, '33.4'
}

// 33.5
fn test_33_5() {
	f := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := f.format_age('2025-6-1', '2027-02-25')
	assert result == none, '33.5'
}

// 33.6
fn test_33_6() {
	f := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := f.format_age(' 2025-06-01', '2027-02-25')
	assert result == none, '33.6'
}

// 33.7
fn test_33_7() {
	f := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := f.format_age('2025-06-15T10:00:00', '2027-02-25')
	assert result == none, '33.7'
}

// 33.8
fn test_33_8() {
	f := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := f.format_age('2020-01-01', '2025-04-31')
	assert result == none, '33.8'
}

// 33.9
fn test_33_9() {
	f := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := f.format_stage('2025-02-30', '2027-09-05', '')
	assert result == none, '33.9'
}

// 33.10
fn test_33_10() {
	f := locales.new_sayable_age(locales.get_locale('en') or { panic('locale not found') }, .normal)
	result := f.format_age('2024-02-29', '2026-03-01') or { panic('33.10 should not be none') }
	assert result == '2 years', '33.10'
}
