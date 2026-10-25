program test_format_time
  use sayabletime_types
  use sayabletime
  use sayabletime_locales
  implicit none

  integer :: tests_passed, tests_failed
  tests_passed = 0
  tests_failed = 0

  call test_null_edge_cases()
  call test_clock_time_normal()
  call test_clock_time_short()
  call test_clock_time_compact()
  call test_locale_german()
  call test_locale_french()
  call test_locale_japanese()
  call test_finnish_dot_separator()
  call test_section_9()
  call test_section_10()

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
    type(st_locale), pointer :: en
    character(len=ST_MAX_STR_LEN) :: res

    en => st_get_locale('en')

    ! 1.1 — null time
    res = st_format_time(en, ST_NORMAL, '')
    call assert_null('1.1 null time', res)

    ! 1.2 — empty string
    res = st_format_time(en, ST_NORMAL, '')
    call assert_null('1.2 empty string', res)

    ! 1.3 — invalid time
    res = st_format_time(en, ST_NORMAL, 'invalid')
    call assert_null('1.3 invalid time', res)

    ! 1.4 — out of range
    res = st_format_time(en, ST_NORMAL, '25:00')
    call assert_null('1.4 out of range', res)
  end subroutine test_null_edge_cases

  ! ================================================================
  ! Clock time (normal compactness)
  ! ================================================================
  subroutine test_clock_time_normal()
    type(st_locale), pointer :: en
    character(len=ST_MAX_STR_LEN) :: res

    en => st_get_locale('en')

    ! 2.1 — midnight
    res = st_format_time(en, ST_NORMAL, '00:00')
    call assert_eq('2.1 midnight', res, 'midnight')

    ! 2.2 — noon
    res = st_format_time(en, ST_NORMAL, '12:00')
    call assert_eq('2.2 noon', res, 'noon')

    ! 2.3 — three o'clock
    res = st_format_time(en, ST_NORMAL, '15:00')
    call assert_eq('2.3 three oclock', res, 'three o' // char(39) // 'clock')

    ! 2.4 — a quarter past two
    res = st_format_time(en, ST_NORMAL, '14:15')
    call assert_eq('2.4 quarter past two', res, 'a quarter past two')

    ! 2.5 — half past nine
    res = st_format_time(en, ST_NORMAL, '09:30')
    call assert_eq('2.5 half past nine', res, 'half past nine')

    ! 2.6 — a quarter to eleven
    res = st_format_time(en, ST_NORMAL, '10:45')
    call assert_eq('2.6 quarter to eleven', res, 'a quarter to eleven')

    ! 2.7 — five past eight
    res = st_format_time(en, ST_NORMAL, '08:05')
    call assert_eq('2.7 five past eight', res, 'five past eight')

    ! 2.8 — five to five
    res = st_format_time(en, ST_NORMAL, '16:55')
    call assert_eq('2.8 five to five', res, 'five to five')

    ! 2.9 — rounds to midnight
    res = st_format_time(en, ST_NORMAL, '23:58')
    call assert_eq('2.9 rounds to midnight', res, 'midnight')

    ! 2.10 — 22 rounds to 20
    res = st_format_time(en, ST_NORMAL, '07:22')
    call assert_eq('2.10 twenty past seven', res, 'twenty past seven')

    ! 2.11 — ISO datetime input
    res = st_format_time(en, ST_NORMAL, '2025-01-15T14:15:00')
    call assert_eq('2.11 ISO datetime', res, 'a quarter past two')
  end subroutine test_clock_time_normal

  ! ================================================================
  ! Clock time (short compactness)
  ! ================================================================
  subroutine test_clock_time_short()
    type(st_locale), pointer :: en
    character(len=ST_MAX_STR_LEN) :: res

    en => st_get_locale('en')

    ! 3.1
    res = st_format_time(en, ST_SHORT, '14:15')
    call assert_eq('3.1 short 2:15 PM', res, '2:15 PM')

    ! 3.2
    res = st_format_time(en, ST_SHORT, '09:30')
    call assert_eq('3.2 short 9:30 AM', res, '9:30 AM')

    ! 3.3
    res = st_format_time(en, ST_SHORT, '00:00')
    call assert_eq('3.3 short 12:00 AM', res, '12:00 AM')

    ! 3.4
    res = st_format_time(en, ST_SHORT, '12:00')
    call assert_eq('3.4 short 12:00 PM', res, '12:00 PM')
  end subroutine test_clock_time_short

  ! ================================================================
  ! Clock time (compact)
  ! ================================================================
  subroutine test_clock_time_compact()
    type(st_locale), pointer :: en
    character(len=ST_MAX_STR_LEN) :: res

    en => st_get_locale('en')

    ! 4.1
    res = st_format_time(en, ST_COMPACT, '14:15')
    call assert_eq('4.1 compact 2:15p', res, '2:15p')

    ! 4.2
    res = st_format_time(en, ST_COMPACT, '09:30')
    call assert_eq('4.2 compact 9:30a', res, '9:30a')
  end subroutine test_clock_time_compact

  ! ================================================================
  ! Locale — German
  ! ================================================================
  subroutine test_locale_german()
    type(st_locale), pointer :: de
    character(len=ST_MAX_STR_LEN) :: res

    de => st_get_locale('de')

    ! 5.1 — halb vier
    res = st_format_time(de, ST_NORMAL, '15:30')
    call assert_eq('5.1 de halb vier', res, 'halb vier')
  end subroutine test_locale_german

  ! ================================================================
  ! Locale — French
  ! ================================================================
  subroutine test_locale_french()
    type(st_locale), pointer :: fr
    character(len=ST_MAX_STR_LEN) :: res

    fr => st_get_locale('fr')

    ! 6.1 — trois heures et quart
    res = st_format_time(fr, ST_NORMAL, '15:15')
    call assert_eq('6.1 fr quarter past three', res, 'trois heures et quart')
  end subroutine test_locale_french

  ! ================================================================
  ! Locale — Japanese
  ! ================================================================
  subroutine test_locale_japanese()
    type(st_locale), pointer :: ja
    character(len=ST_MAX_STR_LEN) :: res

    ja => st_get_locale('ja')

    ! 7.1 — san ji han (three half)
    res = st_format_time(ja, ST_NORMAL, '15:30')
    call assert_eq('7.1 ja three half', res, char(228) // char(184) // char(137) // &
      char(230) // char(153) // char(130) // char(229) // char(141) // char(138))
  end subroutine test_locale_japanese

  ! ================================================================
  ! Locale — Finnish (dot separator, short)
  ! ================================================================
  subroutine test_finnish_dot_separator()
    type(st_locale), pointer :: fi
    character(len=ST_MAX_STR_LEN) :: res

    fi => st_get_locale('fi')

    ! 8.1 — dot separator
    res = st_format_time(fi, ST_SHORT, '14:15')
    call assert_eq('8.1 fi dot separator', res, '14.15')

    ! 8.2 — midnight dot
    res = st_format_time(fi, ST_SHORT, '00:00')
    call assert_eq('8.2 fi midnight dot', res, '0.00')
  end subroutine test_finnish_dot_separator

  ! ================================================================
  ! Minutes in short and compact modes
  ! ================================================================
  subroutine test_section_9()
    type(st_locale), pointer :: loc
    character(len=ST_MAX_STR_LEN) :: res

    ! 9.1
    loc => st_get_locale('en')
    res = st_format_time(loc, ST_SHORT, '18:01')
    call assert_eq('9.1 format_time en short', res, &
      '6:01 PM')

    ! 9.2
    loc => st_get_locale('en')
    res = st_format_time(loc, ST_COMPACT, '19:05')
    call assert_eq('9.2 format_time en compact', res, &
      '7:05p')

  end subroutine test_section_9

  ! ================================================================
  ! Input validation
  ! ================================================================
  subroutine test_section_10()
    type(st_locale), pointer :: loc
    character(len=ST_MAX_STR_LEN) :: res

    ! 10.1
    loc => st_get_locale('en')
    res = st_format_time(loc, ST_NORMAL, '9:30')
    call assert_eq('10.1 format_time en normal', res, &
      'half past nine')

    ! 10.2
    loc => st_get_locale('en')
    res = st_format_time(loc, ST_NORMAL, '09:30')
    call assert_eq('10.2 format_time en normal', res, &
      'half past nine')

    ! 10.3
    loc => st_get_locale('en')
    res = st_format_time(loc, ST_NORMAL, ' 9:30')
    call assert_null('10.3 format_time en normal', res)

    ! 10.4
    loc => st_get_locale('en')
    res = st_format_time(loc, ST_NORMAL, '9:30 ')
    call assert_null('10.4 format_time en normal', res)

    ! 10.5
    loc => st_get_locale('en')
    res = st_format_time(loc, ST_NORMAL, '9:5')
    call assert_null('10.5 format_time en normal', res)

    ! 10.6
    loc => st_get_locale('en')
    res = st_format_time(loc, ST_NORMAL, '24:00')
    call assert_null('10.6 format_time en normal', res)

    ! 10.7
    loc => st_get_locale('en')
    res = st_format_time(loc, ST_NORMAL, '14:15:30')
    call assert_eq('10.7 format_time en normal', res, &
      'a quarter past two')

    ! 10.8
    loc => st_get_locale('en')
    res = st_format_time(loc, ST_NORMAL, '2025-01-15T14:15:00Z')
    call assert_eq('10.8 format_time en normal', res, &
      'a quarter past two')

    ! 10.9
    loc => st_get_locale('en')
    res = st_format_time(loc, ST_NORMAL, '2025-02-30T14:15:00')
    call assert_null('10.9 format_time en normal', res)

  end subroutine test_section_10

end program test_format_time
