program test_format_duration
  use sayableduration_types
  use sayableduration
  use sayableduration_locales
  implicit none

  integer :: tests_passed, tests_failed
  tests_passed = 0
  tests_failed = 0

  call test_null_edge_cases()
  call test_seconds_tier()
  call test_minutes_seconds_tier()
  call test_minutes_tier()
  call test_hours_minutes_tier()
  call test_hours_tier()
  call test_days_tier()
  call test_weeks_tier()
  call test_months_years_tier()
  call test_iso_timestamps()
  call test_format_since()
  call test_format_until()
  call test_locale_german()
  call test_locale_french()
  call test_locale_japanese()
  call test_short_compactness()
  call test_compact_compactness()

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
    type(dur_locale), pointer :: en
    character(len=DUR_MAX_STR_LEN) :: res

    en => dur_get_locale('en')

    ! 1.1 — null seconds (Fortran has no null integer; negative represents null)
    res = dur_format_duration(en, DUR_NORMAL, -1)
    call assert_null('1.1 null seconds', res)

    ! 1.2 — negative seconds
    res = dur_format_duration(en, DUR_NORMAL, -1)
    call assert_null('1.2 negative seconds', res)

    ! 1.3 — null start for since
    res = dur_format_since(en, DUR_NORMAL, '', '2025-01-15T10:00:00')
    call assert_null('1.3 null start', res)

    ! 1.4 — null target for until
    res = dur_format_until(en, DUR_NORMAL, '', '2025-01-15T10:00:00')
    call assert_null('1.4 null target', res)

    ! 1.5 — asOf before start
    res = dur_format_since(en, DUR_NORMAL, '2025-01-15T10:00:00', '2025-01-15T09:00:00')
    call assert_null('1.5 asOf before start', res)

    ! 1.6 — target in the past
    res = dur_format_until(en, DUR_NORMAL, '2025-01-15T09:00:00', '2025-01-15T10:00:00')
    call assert_null('1.6 target in past', res)
  end subroutine test_null_edge_cases

  ! ================================================================
  ! Duration — seconds tier (0-59s)
  ! ================================================================
  subroutine test_seconds_tier()
    type(dur_locale), pointer :: en
    character(len=DUR_MAX_STR_LEN) :: res

    en => dur_get_locale('en')

    ! 2.1
    res = dur_format_duration(en, DUR_NORMAL, 0)
    call assert_eq('2.1 just now', res, 'just now')

    ! 2.2
    res = dur_format_duration(en, DUR_NORMAL, 1)
    call assert_eq('2.2 1 second', res, '1 second')

    ! 2.3
    res = dur_format_duration(en, DUR_NORMAL, 45)
    call assert_eq('2.3 45 seconds', res, '45 seconds')

    ! 2.4
    res = dur_format_duration(en, DUR_NORMAL, 59)
    call assert_eq('2.4 59 seconds', res, '59 seconds')
  end subroutine test_seconds_tier

  ! ================================================================
  ! Duration — minutes + seconds tier (1-4 min)
  ! ================================================================
  subroutine test_minutes_seconds_tier()
    type(dur_locale), pointer :: en
    character(len=DUR_MAX_STR_LEN) :: res

    en => dur_get_locale('en')

    ! 3.1
    res = dur_format_duration(en, DUR_NORMAL, 60)
    call assert_eq('3.1 1 minute', res, '1 minute')

    ! 3.2
    res = dur_format_duration(en, DUR_NORMAL, 90)
    call assert_eq('3.2 1min 30sec', res, '1 minute, 30 seconds')

    ! 3.3
    res = dur_format_duration(en, DUR_NORMAL, 240)
    call assert_eq('3.3 4 minutes', res, '4 minutes')

    ! 3.4
    res = dur_format_duration(en, DUR_NORMAL, 270)
    call assert_eq('3.4 4min 30sec', res, '4 minutes, 30 seconds')
  end subroutine test_minutes_seconds_tier

  ! ================================================================
  ! Duration — minutes tier (5-59 min)
  ! ================================================================
  subroutine test_minutes_tier()
    type(dur_locale), pointer :: en
    character(len=DUR_MAX_STR_LEN) :: res

    en => dur_get_locale('en')

    ! 4.1
    res = dur_format_duration(en, DUR_NORMAL, 300)
    call assert_eq('4.1 5 minutes', res, '5 minutes')

    ! 4.2
    res = dur_format_duration(en, DUR_NORMAL, 1500)
    call assert_eq('4.2 25 minutes', res, '25 minutes')

    ! 4.3
    res = dur_format_duration(en, DUR_NORMAL, 3540)
    call assert_eq('4.3 59 minutes', res, '59 minutes')
  end subroutine test_minutes_tier

  ! ================================================================
  ! Duration — hours + minutes tier (1-5 hr)
  ! ================================================================
  subroutine test_hours_minutes_tier()
    type(dur_locale), pointer :: en
    character(len=DUR_MAX_STR_LEN) :: res

    en => dur_get_locale('en')

    ! 5.1
    res = dur_format_duration(en, DUR_NORMAL, 3600)
    call assert_eq('5.1 1 hour', res, '1 hour')

    ! 5.2 — half marker
    res = dur_format_duration(en, DUR_NORMAL, 5400)
    call assert_eq('5.2 1.5 hours', res, '1' // char(194) // char(189) // ' hours')

    ! 5.3
    res = dur_format_duration(en, DUR_NORMAL, 8100)
    call assert_eq('5.3 2h 15m', res, '2 hours, 15 minutes')

    ! 5.4
    res = dur_format_duration(en, DUR_NORMAL, 18000)
    call assert_eq('5.4 5 hours', res, '5 hours')
  end subroutine test_hours_minutes_tier

  ! ================================================================
  ! Duration — hours tier (6-23 hr)
  ! ================================================================
  subroutine test_hours_tier()
    type(dur_locale), pointer :: en
    character(len=DUR_MAX_STR_LEN) :: res

    en => dur_get_locale('en')

    ! 6.1
    res = dur_format_duration(en, DUR_NORMAL, 28800)
    call assert_eq('6.1 8 hours', res, '8 hours')

    ! 6.2
    res = dur_format_duration(en, DUR_NORMAL, 82800)
    call assert_eq('6.2 23 hours', res, '23 hours')
  end subroutine test_hours_tier

  ! ================================================================
  ! Duration — days tier
  ! ================================================================
  subroutine test_days_tier()
    type(dur_locale), pointer :: en
    character(len=DUR_MAX_STR_LEN) :: res

    en => dur_get_locale('en')

    ! 7.1
    res = dur_format_duration(en, DUR_NORMAL, 86400)
    call assert_eq('7.1 1 day', res, '1 day')

    ! 7.2
    res = dur_format_duration(en, DUR_NORMAL, 97200)
    call assert_eq('7.2 1d 3h', res, '1 day, 3 hours')

    ! 7.3 — half marker
    res = dur_format_duration(en, DUR_NORMAL, 129600)
    call assert_eq('7.3 1.5 days', res, '1' // char(194) // char(189) // ' days')

    ! 7.4
    res = dur_format_duration(en, DUR_NORMAL, 432000)
    call assert_eq('7.4 5 days', res, '5 days')

    ! 7.5
    res = dur_format_duration(en, DUR_NORMAL, 172800)
    call assert_eq('7.5 2 days', res, '2 days')
  end subroutine test_days_tier

  ! ================================================================
  ! Duration — weeks tier
  ! ================================================================
  subroutine test_weeks_tier()
    type(dur_locale), pointer :: en
    character(len=DUR_MAX_STR_LEN) :: res

    en => dur_get_locale('en')

    ! 8.1
    res = dur_format_duration(en, DUR_NORMAL, 604800)
    call assert_eq('8.1 1 week', res, '1 week')

    ! 8.2
    res = dur_format_duration(en, DUR_NORMAL, 1296000)
    call assert_eq('8.2 2w 1d', res, '2 weeks, 1 day')

    ! 8.3
    res = dur_format_duration(en, DUR_NORMAL, 2419200)
    call assert_eq('8.3 4 weeks', res, '4 weeks')
  end subroutine test_weeks_tier

  ! ================================================================
  ! Duration — months and years tier
  ! ================================================================
  subroutine test_months_years_tier()
    type(dur_locale), pointer :: en
    character(len=DUR_MAX_STR_LEN) :: res

    en => dur_get_locale('en')

    ! 9.1 — ~31 days
    res = dur_format_duration(en, DUR_NORMAL, 2678400)
    call assert_eq('9.1 1 month', res, '1 month')

    ! 9.2 — ~91 days
    res = dur_format_duration(en, DUR_NORMAL, 7884000)
    call assert_eq('9.2 3 months', res, '3 months')

    ! 9.3 — 365 days
    res = dur_format_duration(en, DUR_NORMAL, 31536000)
    call assert_eq('9.3 1 year', res, '1 year')

    ! 9.4 — ~456 days
    res = dur_format_duration(en, DUR_NORMAL, 39420000)
    call assert_eq('9.4 1y 3m', res, '1 year, 3 months')
  end subroutine test_months_years_tier

  ! ================================================================
  ! Duration from ISO timestamps
  ! ================================================================
  subroutine test_iso_timestamps()
    type(dur_locale), pointer :: en
    character(len=DUR_MAX_STR_LEN) :: res

    en => dur_get_locale('en')

    ! 10.1
    res = dur_format_duration_iso(en, DUR_NORMAL, '2025-01-15T10:00:00', '2025-01-15T11:30:00')
    call assert_eq('10.1 1.5h iso', res, '1' // char(194) // char(189) // ' hours')

    ! 10.2
    res = dur_format_duration_iso(en, DUR_NORMAL, '2025-01-15T10:00:00', '2025-01-15T10:45:00')
    call assert_eq('10.2 45min iso', res, '45 minutes')
  end subroutine test_iso_timestamps

  ! ================================================================
  ! Relative time — since
  ! ================================================================
  subroutine test_format_since()
    type(dur_locale), pointer :: en
    character(len=DUR_MAX_STR_LEN) :: res

    en => dur_get_locale('en')

    ! 11.1
    res = dur_format_since(en, DUR_NORMAL, '2025-01-15T10:00:00', '2025-01-15T10:00:00')
    call assert_eq('11.1 just now', res, 'just now')

    ! 11.2
    res = dur_format_since(en, DUR_NORMAL, '2025-01-15T10:00:00', '2025-01-15T10:00:30')
    call assert_eq('11.2 30s ago', res, '30 seconds ago')

    ! 11.3
    res = dur_format_since(en, DUR_NORMAL, '2025-01-15T10:00:00', '2025-01-15T10:45:00')
    call assert_eq('11.3 45min ago', res, '45 minutes ago')

    ! 11.4
    res = dur_format_since(en, DUR_NORMAL, '2025-01-15T10:00:00', '2025-01-15T13:00:00')
    call assert_eq('11.4 3h ago', res, '3 hours ago')
  end subroutine test_format_since

  ! ================================================================
  ! Relative time — until
  ! ================================================================
  subroutine test_format_until()
    type(dur_locale), pointer :: en
    character(len=DUR_MAX_STR_LEN) :: res

    en => dur_get_locale('en')

    ! 12.1
    res = dur_format_until(en, DUR_NORMAL, '2025-01-15T10:00:00', '2025-01-15T10:00:00')
    call assert_eq('12.1 just now', res, 'just now')

    ! 12.2
    res = dur_format_until(en, DUR_NORMAL, '2025-01-15T10:20:00', '2025-01-15T10:00:00')
    call assert_eq('12.2 in 20min', res, 'in 20 minutes')

    ! 12.3
    res = dur_format_until(en, DUR_NORMAL, '2025-01-15T13:00:00', '2025-01-15T10:00:00')
    call assert_eq('12.3 in 3h', res, 'in 3 hours')
  end subroutine test_format_until

  ! ================================================================
  ! Locale — German
  ! ================================================================
  subroutine test_locale_german()
    type(dur_locale), pointer :: de
    character(len=DUR_MAX_STR_LEN) :: res

    de => dur_get_locale('de')

    ! 13.1
    res = dur_format_duration(de, DUR_NORMAL, 3600)
    call assert_eq('13.1 de 1 Stunde', res, '1 Stunde')

    ! 13.2
    res = dur_format_since(de, DUR_NORMAL, '2025-01-15T10:00:00', '2025-01-15T10:05:00')
    call assert_eq('13.2 de vor 5 Minuten', res, 'vor 5 Minuten')
  end subroutine test_locale_german

  ! ================================================================
  ! Locale — French
  ! ================================================================
  subroutine test_locale_french()
    type(dur_locale), pointer :: fr
    character(len=DUR_MAX_STR_LEN) :: res

    fr => dur_get_locale('fr')

    ! 14.1
    res = dur_format_duration(fr, DUR_NORMAL, 7200)
    call assert_eq('14.1 fr 2 heures', res, '2 heures')
  end subroutine test_locale_french

  ! ================================================================
  ! Locale — Japanese
  ! ================================================================
  subroutine test_locale_japanese()
    type(dur_locale), pointer :: ja
    character(len=DUR_MAX_STR_LEN) :: res

    ja => dur_get_locale('ja')

    ! 15.1
    res = dur_format_duration(ja, DUR_NORMAL, 120)
    call assert_eq('15.1 ja 2min', res, '2' // char(229) // char(136) // char(134))

    ! 15.2
    res = dur_format_since(ja, DUR_NORMAL, '2025-01-15T10:00:00', '2025-01-15T11:00:00')
    call assert_eq('15.2 ja 1h ago', res, '1' // char(230) // char(153) // char(130) // &
      char(233) // char(150) // char(147) // char(229) // char(137) // char(141))
  end subroutine test_locale_japanese

  ! ================================================================
  ! Short compactness — duration
  ! ================================================================
  subroutine test_short_compactness()
    type(dur_locale), pointer :: en
    character(len=DUR_MAX_STR_LEN) :: res

    en => dur_get_locale('en')

    ! 16.1
    res = dur_format_duration(en, DUR_SHORT, 3600)
    call assert_eq('16.1 short 1h', res, '1h')

    ! 16.2
    res = dur_format_duration(en, DUR_SHORT, 90)
    call assert_eq('16.2 short 1m 30s', res, '1m, 30s')
  end subroutine test_short_compactness

  ! ================================================================
  ! Compact compactness — duration
  ! ================================================================
  subroutine test_compact_compactness()
    type(dur_locale), pointer :: en
    character(len=DUR_MAX_STR_LEN) :: res

    en => dur_get_locale('en')

    ! 17.1
    res = dur_format_duration(en, DUR_COMPACT, 3600)
    call assert_eq('17.1 compact 1h', res, '1h')

    ! 17.2
    res = dur_format_duration(en, DUR_COMPACT, 90)
    call assert_eq('17.2 compact 1m30s', res, '1m30s')
  end subroutine test_compact_compactness

end program test_format_duration
