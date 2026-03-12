program test_format_date
  use sayabledate_types
  use sayabledate
  use sayabledate_locales
  implicit none

  integer :: tests_passed, tests_failed
  tests_passed = 0
  tests_failed = 0

  call test_null_edge_cases()
  call test_format_date_normal()
  call test_format_date_short()
  call test_format_date_compact()
  call test_format_relative_proximity()
  call test_format_relative_compact()
  call test_locale_german()
  call test_locale_french()
  call test_locale_japanese()
  call test_locale_russian()
  call test_locale_arabic()
  call test_locale_spanish()

  write(*, '(A)') ''
  write(*, '(A)') '=== Results ==='
  write(*, '(A,I0)') 'Passed: ', tests_passed
  write(*, '(A,I0)') 'Failed: ', tests_failed
  write(*, '(A,I0)') 'Total:  ', tests_passed + tests_failed

  if (tests_failed > 0) stop 1

contains

  subroutine assert_eq(name, got, expected)
    character(len=*), intent(in) :: name, got, expected
    if (trim(got) == trim(expected)) then
      tests_passed = tests_passed + 1
    else
      write(*, '(A,A,A,A,A,A,A)') 'FAIL [', name, ']: got "', trim(got), '", expected "', trim(expected), '"'
      tests_failed = tests_failed + 1
    end if
  end subroutine assert_eq

  subroutine assert_null(name, got)
    character(len=*), intent(in) :: name, got
    if (len_trim(got) == 0) then
      tests_passed = tests_passed + 1
    else
      write(*, '(A,A,A,A,A)') 'FAIL [', name, ']: expected empty, got "', trim(got), '"'
      tests_failed = tests_failed + 1
    end if
  end subroutine assert_null

  ! ================================================================
  ! Null / edge cases
  ! ================================================================
  subroutine test_null_edge_cases()
    type(sd_locale), pointer :: en
    character(len=SD_MAX_STR_LEN) :: res

    en => sd_get_locale('en')

    ! 1.1 — null date
    res = sd_format_date(en, SD_NORMAL, '')
    call assert_null('1.1 null date', res)

    ! 1.2 — empty string
    res = sd_format_date(en, SD_NORMAL, '')
    call assert_null('1.2 empty string', res)

    ! 1.3 — invalid date
    res = sd_format_date(en, SD_NORMAL, 'invalid')
    call assert_null('1.3 invalid date', res)

    ! 1.4 — relative with null asOf
    res = sd_format_relative(en, SD_NORMAL, '2025-03-15', '')
    call assert_null('1.4 null asOf', res)

    ! 1.5 — relative with null date
    res = sd_format_relative(en, SD_NORMAL, '', '2025-03-15')
    call assert_null('1.5 null date', res)
  end subroutine test_null_edge_cases

  ! ================================================================
  ! format_date — normal compactness (English)
  ! ================================================================
  subroutine test_format_date_normal()
    type(sd_locale), pointer :: en
    character(len=SD_MAX_STR_LEN) :: res

    en => sd_get_locale('en')

    ! 2.1
    res = sd_format_date(en, SD_NORMAL, '2025-03-15')
    call assert_eq('2.1 March 15th', res, 'March 15th')

    ! 2.2
    res = sd_format_date(en, SD_NORMAL, '2025-01-01')
    call assert_eq('2.2 January 1st', res, 'January 1st')

    ! 2.3
    res = sd_format_date(en, SD_NORMAL, '2025-05-22')
    call assert_eq('2.3 May 22nd', res, 'May 22nd')

    ! 2.4
    res = sd_format_date(en, SD_NORMAL, '2025-07-03')
    call assert_eq('2.4 July 3rd', res, 'July 3rd')

    ! 2.5
    res = sd_format_date(en, SD_NORMAL, '2025-12-31')
    call assert_eq('2.5 December 31st', res, 'December 31st')

    ! 2.6
    res = sd_format_date(en, SD_NORMAL, '2025-06-11')
    call assert_eq('2.6 June 11th', res, 'June 11th')

    ! 2.7 — ISO datetime input
    res = sd_format_date(en, SD_NORMAL, '2025-03-15T14:30:00')
    call assert_eq('2.7 ISO datetime', res, 'March 15th')
  end subroutine test_format_date_normal

  ! ================================================================
  ! format_date — short compactness (English)
  ! ================================================================
  subroutine test_format_date_short()
    type(sd_locale), pointer :: en
    character(len=SD_MAX_STR_LEN) :: res

    en => sd_get_locale('en')

    ! 3.1
    res = sd_format_date(en, SD_SHORT, '2025-03-15')
    call assert_eq('3.1 Mar 15', res, 'Mar 15')

    ! 3.2
    res = sd_format_date(en, SD_SHORT, '2025-01-01')
    call assert_eq('3.2 Jan 1', res, 'Jan 1')

    ! 3.3
    res = sd_format_date(en, SD_SHORT, '2025-12-25')
    call assert_eq('3.3 Dec 25', res, 'Dec 25')
  end subroutine test_format_date_short

  ! ================================================================
  ! format_date — compact (English)
  ! ================================================================
  subroutine test_format_date_compact()
    type(sd_locale), pointer :: en
    character(len=SD_MAX_STR_LEN) :: res

    en => sd_get_locale('en')

    ! 4.1
    res = sd_format_date(en, SD_COMPACT, '2025-03-15')
    call assert_eq('4.1 3/15', res, '3/15')

    ! 4.2
    res = sd_format_date(en, SD_COMPACT, '2025-01-01')
    call assert_eq('4.2 1/1', res, '1/1')
  end subroutine test_format_date_compact

  ! ================================================================
  ! format_relative — proximity tiers (English)
  ! ================================================================
  subroutine test_format_relative_proximity()
    type(sd_locale), pointer :: en
    character(len=SD_MAX_STR_LEN) :: res

    en => sd_get_locale('en')

    ! 5.1 — today
    res = sd_format_relative(en, SD_NORMAL, '2025-03-15', '2025-03-15')
    call assert_eq('5.1 today', res, 'today')

    ! 5.2 — tomorrow
    res = sd_format_relative(en, SD_NORMAL, '2025-03-16', '2025-03-15')
    call assert_eq('5.2 tomorrow', res, 'tomorrow')

    ! 5.3 — yesterday
    res = sd_format_relative(en, SD_NORMAL, '2025-03-14', '2025-03-15')
    call assert_eq('5.3 yesterday', res, 'yesterday')

    ! 5.4 — day after tomorrow
    res = sd_format_relative(en, SD_NORMAL, '2025-03-17', '2025-03-15')
    call assert_eq('5.4 day after tomorrow', res, 'the day after tomorrow')

    ! 5.5 — day before yesterday
    res = sd_format_relative(en, SD_NORMAL, '2025-03-13', '2025-03-15')
    call assert_eq('5.5 day before yesterday', res, 'the day before yesterday')

    ! 5.6 — this Wednesday (+4)
    res = sd_format_relative(en, SD_NORMAL, '2025-03-19', '2025-03-15')
    call assert_eq('5.6 this Wednesday', res, 'this Wednesday')

    ! 5.7 — this Thursday (+5)
    res = sd_format_relative(en, SD_NORMAL, '2025-03-20', '2025-03-15')
    call assert_eq('5.7 this Thursday', res, 'this Thursday')

    ! 5.8 — last Tuesday (-4)
    res = sd_format_relative(en, SD_NORMAL, '2025-03-11', '2025-03-15')
    call assert_eq('5.8 last Tuesday', res, 'last Tuesday')

    ! 5.9 — next Saturday (+7)
    res = sd_format_relative(en, SD_NORMAL, '2025-03-22', '2025-03-15')
    call assert_eq('5.9 next Saturday', res, 'next Saturday')

    ! 5.10 — next Thursday (+12)
    res = sd_format_relative(en, SD_NORMAL, '2025-03-27', '2025-03-15')
    call assert_eq('5.10 next Thursday', res, 'next Thursday')

    ! 5.11 — calendar fallback same year (-14)
    res = sd_format_relative(en, SD_NORMAL, '2025-03-01', '2025-03-15')
    call assert_eq('5.11 March 1st', res, 'March 1st')

    ! 5.12 — calendar fallback same year (+26)
    res = sd_format_relative(en, SD_NORMAL, '2025-04-10', '2025-03-15')
    call assert_eq('5.12 April 10th', res, 'April 10th')

    ! 5.13 — different year includes year
    res = sd_format_relative(en, SD_NORMAL, '2026-01-05', '2025-03-15')
    call assert_eq('5.13 Jan 5 2026', res, 'January 5th, 2026')

    ! 5.14 — past year includes year
    res = sd_format_relative(en, SD_NORMAL, '2024-12-25', '2025-03-15')
    call assert_eq('5.14 Dec 25 2024', res, 'December 25th, 2024')
  end subroutine test_format_relative_proximity

  ! ================================================================
  ! format_relative — compact skips weekday tiers
  ! ================================================================
  subroutine test_format_relative_compact()
    type(sd_locale), pointer :: en
    character(len=SD_MAX_STR_LEN) :: res

    en => sd_get_locale('en')

    ! 6.1 — compact today
    res = sd_format_relative(en, SD_COMPACT, '2025-03-15', '2025-03-15')
    call assert_eq('6.1 compact today', res, 'today')

    ! 6.2 — compact tomorrow
    res = sd_format_relative(en, SD_COMPACT, '2025-03-16', '2025-03-15')
    call assert_eq('6.2 compact tomorrow', res, 'tomorrow')

    ! 6.3 — compact goes straight to numeric
    res = sd_format_relative(en, SD_COMPACT, '2025-03-19', '2025-03-15')
    call assert_eq('6.3 compact numeric', res, '3/19')

    ! 6.4 — compact different year
    res = sd_format_relative(en, SD_COMPACT, '2026-01-05', '2025-03-15')
    call assert_eq('6.4 compact year', res, '1/5/26')
  end subroutine test_format_relative_compact

  ! ================================================================
  ! Locale — German
  ! ================================================================
  subroutine test_locale_german()
    type(sd_locale), pointer :: de
    character(len=SD_MAX_STR_LEN) :: res

    de => sd_get_locale('de')

    ! 7.1
    res = sd_format_date(de, SD_NORMAL, '2025-03-15')
    call assert_eq('7.1 de date', res, '15. M' // char(195) // char(164) // 'rz')

    ! 7.2
    res = sd_format_relative(de, SD_NORMAL, '2025-03-16', '2025-03-15')
    call assert_eq('7.2 de morgen', res, 'morgen')

    ! 7.3
    res = sd_format_relative(de, SD_NORMAL, '2025-03-17', '2025-03-15')
    call assert_eq('7.3 de uebermorgen', res, char(195) // char(188) // 'bermorgen')

    ! 7.4
    res = sd_format_relative(de, SD_NORMAL, '2025-03-19', '2025-03-15')
    call assert_eq('7.4 de this Mittwoch', res, 'diesen Mittwoch')
  end subroutine test_locale_german

  ! ================================================================
  ! Locale — French
  ! ================================================================
  subroutine test_locale_french()
    type(sd_locale), pointer :: fr
    character(len=SD_MAX_STR_LEN) :: res

    fr => sd_get_locale('fr')

    ! 8.1
    res = sd_format_date(fr, SD_NORMAL, '2025-03-01')
    call assert_eq('8.1 fr 1er mars', res, '1er mars')

    ! 8.2
    res = sd_format_date(fr, SD_NORMAL, '2025-03-15')
    call assert_eq('8.2 fr 15 mars', res, '15 mars')

    ! 8.3
    res = sd_format_relative(fr, SD_NORMAL, '2025-03-16', '2025-03-15')
    call assert_eq('8.3 fr demain', res, 'demain')
  end subroutine test_locale_french

  ! ================================================================
  ! Locale — Japanese
  ! ================================================================
  subroutine test_locale_japanese()
    type(sd_locale), pointer :: ja
    character(len=SD_MAX_STR_LEN) :: res

    ja => sd_get_locale('ja')

    ! 9.1
    res = sd_format_date(ja, SD_NORMAL, '2025-03-15')
    call assert_eq('9.1 ja date', res, '3' // char(230) // char(156) // char(136) // '15' // &
      char(230) // char(151) // char(165))

    ! 9.2
    res = sd_format_relative(ja, SD_NORMAL, '2025-03-16', '2025-03-15')
    call assert_eq('9.2 ja tomorrow', res, char(230) // char(152) // char(142) // char(230) // &
      char(151) // char(165))

    ! 9.3
    res = sd_format_relative(ja, SD_NORMAL, '2025-03-19', '2025-03-15')
    call assert_eq('9.3 ja this weekday', res, char(228) // char(187) // char(138) // &
      char(229) // char(186) // char(166) // char(227) // char(129) // char(174) // &
      char(230) // char(176) // char(180) // char(230) // char(155) // char(156) // &
      char(230) // char(151) // char(165))
  end subroutine test_locale_japanese

  ! ================================================================
  ! Locale — Russian (genitive months)
  ! ================================================================
  subroutine test_locale_russian()
    type(sd_locale), pointer :: ru
    character(len=SD_MAX_STR_LEN) :: res

    ru => sd_get_locale('ru')

    ! 10.1 — uses genitive form
    res = sd_format_date(ru, SD_NORMAL, '2025-03-15')
    call assert_eq('10.1 ru genitive', res, '15 ' // char(208) // char(188) // &
      char(208) // char(176) // char(209) // char(128) // char(209) // char(130) // &
      char(208) // char(176))

    ! 10.2
    res = sd_format_relative(ru, SD_NORMAL, '2025-03-16', '2025-03-15')
    call assert_eq('10.2 ru zavtra', res, char(208) // char(183) // char(208) // char(176) // &
      char(208) // char(178) // char(209) // char(130) // char(209) // char(128) // &
      char(208) // char(176))
  end subroutine test_locale_russian

  ! ================================================================
  ! Locale — Arabic
  ! ================================================================
  subroutine test_locale_arabic()
    type(sd_locale), pointer :: ar
    character(len=SD_MAX_STR_LEN) :: res

    ar => sd_get_locale('ar')

    ! 11.1
    res = sd_format_date(ar, SD_NORMAL, '2025-03-15')
    call assert_eq('11.1 ar date', res, '15 ' // char(217) // char(133) // &
      char(216) // char(167) // char(216) // char(177) // char(216) // char(179))

    ! 11.2
    res = sd_format_relative(ar, SD_NORMAL, '2025-03-16', '2025-03-15')
    call assert_eq('11.2 ar tomorrow', res, char(216) // char(186) // char(216) // char(175) // &
      char(216) // char(167) // char(217) // char(139))
  end subroutine test_locale_arabic

  ! ================================================================
  ! Locale — Spanish
  ! ================================================================
  subroutine test_locale_spanish()
    type(sd_locale), pointer :: es
    character(len=SD_MAX_STR_LEN) :: res

    es => sd_get_locale('es')

    ! 12.1
    res = sd_format_date(es, SD_NORMAL, '2025-03-15')
    call assert_eq('12.1 es date', res, '15 de marzo')

    ! 12.2
    res = sd_format_relative(es, SD_NORMAL, '2025-03-17', '2025-03-15')
    call assert_eq('12.2 es pasado manana', res, 'pasado ma' // char(195) // char(177) // 'ana')
  end subroutine test_locale_spanish

end program test_format_date
