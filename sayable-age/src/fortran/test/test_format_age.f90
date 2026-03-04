program test_format_age
  use sayableage_types
  use sayableage
  use sayableage_locales
  implicit none

  integer :: tests_passed, tests_failed
  tests_passed = 0
  tests_failed = 0

  call test_null_edge_cases()
  call test_days_tier()
  call test_weeks_days_tier()
  call test_month_boundary_standard()
  call test_month_boundary_feb_non_leap()
  call test_month_boundary_feb_leap()
  call test_month_boundary_30day()
  call test_leap_year_baby()
  call test_months_tier()
  call test_years_months_tier()
  call test_half_year_tier()
  call test_integer_tier()
  call test_cross_year_feb()
  call test_born_on_31st()
  call test_stage_null_edge_cases()
  call test_stage_newborn()
  call test_stage_infant()
  call test_stage_toddler()
  call test_stage_child()
  call test_stage_teenager()
  call test_stage_adult()
  call test_stage_gender_spanish()
  call test_stage_gender_neutral()
  call test_sayableage_english()
  call test_sayableage_spanish()
  call test_compact_short()
  call test_compact_compact()
  call test_locale_hebrew()
  call test_locale_macedonian()
  call test_locale_swahili()
  call test_locale_indonesian()
  call test_locale_amharic()
  call test_locale_lookup()

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

  subroutine assert_contains(name, got, substr)
    character(len=*), intent(in) :: name, got, substr
    if (index(trim(got), trim(substr)) > 0) then
      tests_passed = tests_passed + 1
    else
      write(*, '(A,A,A,A,A,A,A)') 'FAIL [', name, ']: "', trim(got), '" does not contain "', trim(substr), '"'
      tests_failed = tests_failed + 1
    end if
  end subroutine assert_contains

  subroutine assert_true(name, cond)
    character(len=*), intent(in) :: name
    logical, intent(in) :: cond
    if (cond) then
      tests_passed = tests_passed + 1
    else
      write(*, '(A,A,A)') 'FAIL [', name, ']: condition was false'
      tests_failed = tests_failed + 1
    end if
  end subroutine assert_true

  ! ================================================================
  ! formatAge -- null/edge cases
  ! ================================================================
  subroutine test_null_edge_cases()
    type(pt_locale), pointer :: en
    character(len=PT_MAX_STR_LEN) :: res

    en => pt_get_locale('en')

    res = pt_format_age(en, PT_NORMAL, '', '2025-06-15')
    call assert_null('empty string', res) ! 1.1, 1.3

    res = pt_format_age(en, PT_NORMAL, '2025-07-01', '2025-06-15')
    call assert_null('future dob', res) ! 1.4

    res = pt_format_age(en, PT_NORMAL, '1525-06-15', '2025-06-15')
    call assert_eq('exactly 500 years', res, '500 years') ! 1.5

    res = pt_format_age(en, PT_NORMAL, '1524-06-15', '2025-06-15')
    call assert_null('501 years exceeds max', res) ! 1.6

    res = pt_format_age(en, PT_NORMAL, '1025-06-15', '2025-06-15')
    call assert_null('1000 years exceeds max', res) ! 1.7
  end subroutine test_null_edge_cases

  ! ================================================================
  ! formatAge -- days tier (0-6)
  ! ================================================================
  subroutine test_days_tier()
    type(pt_locale), pointer :: en
    character(len=PT_MAX_STR_LEN) :: res

    en => pt_get_locale('en')

    res = pt_format_age(en, PT_NORMAL, '2025-06-15', '2025-06-15')
    call assert_eq('born today', res, 'Newborn') ! 2.1

    res = pt_format_age(en, PT_NORMAL, '2025-06-14', '2025-06-15')
    call assert_eq('1 day', res, '1 day') ! 2.2

    res = pt_format_age(en, PT_NORMAL, '2025-06-12', '2025-06-15')
    call assert_eq('3 days', res, '3 days') ! 2.3

    res = pt_format_age(en, PT_NORMAL, '2025-06-09', '2025-06-15')
    call assert_eq('6 days', res, '6 days') ! 2.4

    res = pt_format_age(en, PT_NORMAL, '2025-06-08', '2025-06-15')
    call assert_eq('7 days -> 1 week', res, '1 week') ! 2.5
  end subroutine test_days_tier

  ! ================================================================
  ! formatAge -- weeks+days tier
  ! ================================================================
  subroutine test_weeks_days_tier()
    type(pt_locale), pointer :: en
    character(len=PT_MAX_STR_LEN) :: res

    en => pt_get_locale('en')

    res = pt_format_age(en, PT_NORMAL, '2025-06-08', '2025-06-15')
    call assert_eq('7 days', res, '1 week') ! 3.1

    res = pt_format_age(en, PT_NORMAL, '2025-06-07', '2025-06-15')
    call assert_eq('8 days', res, '1 week, 1 day') ! 3.2

    res = pt_format_age(en, PT_NORMAL, '2025-06-06', '2025-06-15')
    call assert_eq('9 days', res, '1 week, 2 days') ! 3.3

    res = pt_format_age(en, PT_NORMAL, '2025-06-02', '2025-06-15')
    call assert_eq('13 days', res, '1 week, 6 days') ! 3.4

    res = pt_format_age(en, PT_NORMAL, '2025-06-01', '2025-06-15')
    call assert_eq('14 days', res, '2 weeks') ! 3.5

    res = pt_format_age(en, PT_NORMAL, '2025-05-31', '2025-06-15')
    call assert_eq('15 days', res, '2 weeks, 1 day') ! 3.6

    res = pt_format_age(en, PT_NORMAL, '2025-05-26', '2025-06-15')
    call assert_eq('20 days', res, '2 weeks, 6 days') ! 3.7

    res = pt_format_age(en, PT_NORMAL, '2025-05-25', '2025-06-15')
    call assert_eq('21 days', res, '3 weeks') ! 3.8

    res = pt_format_age(en, PT_NORMAL, '2025-05-15', '2025-06-15')
    call assert_eq('1 cal month still weeks', res, '4 weeks, 3 days') ! 3.9

    res = pt_format_age(en, PT_NORMAL, '2025-04-15', '2025-06-15')
    call assert_eq('2 cal months still weeks', res, '8 weeks, 5 days') ! 3.10

    res = pt_format_age(en, PT_NORMAL, '2025-03-15', '2025-06-14')
    call assert_eq('day before 3mo still weeks', res, '13 weeks') ! 3.11

    res = pt_format_age(en, PT_NORMAL, '2025-03-15', '2025-06-15')
    call assert_eq('on 3mo birthday', res, '3 months') ! 3.12
  end subroutine test_weeks_days_tier

  ! ================================================================
  ! formatAge -- month boundaries: standard months
  ! ================================================================
  subroutine test_month_boundary_standard()
    type(pt_locale), pointer :: en
    character(len=PT_MAX_STR_LEN) :: res

    en => pt_get_locale('en')

    res = pt_format_age(en, PT_NORMAL, '2025-01-01', '2025-04-01')
    call assert_eq('Jan1->Apr1=3mo', res, '3 months') ! 4.1

    res = pt_format_age(en, PT_NORMAL, '2025-01-01', '2025-03-31')
    call assert_contains('Jan1->Mar31 still weeks', res, 'weeks') ! 4.2

    res = pt_format_age(en, PT_NORMAL, '2025-06-15', '2025-09-15')
    call assert_eq('Jun15->Sep15=3mo', res, '3 months') ! 4.3

    res = pt_format_age(en, PT_NORMAL, '2025-06-15', '2025-09-14')
    call assert_contains('Jun15->Sep14 still weeks', res, 'weeks') ! 4.4

    res = pt_format_age(en, PT_NORMAL, '2025-06-15', '2025-12-15')
    call assert_eq('Jun15->Dec15=6mo', res, '6 months') ! 4.5
  end subroutine test_month_boundary_standard

  ! ================================================================
  ! formatAge -- month boundaries: February non-leap
  ! ================================================================
  subroutine test_month_boundary_feb_non_leap()
    type(pt_locale), pointer :: en
    character(len=PT_MAX_STR_LEN) :: res

    en => pt_get_locale('en')

    res = pt_format_age(en, PT_NORMAL, '2025-01-31', '2025-02-28')
    call assert_eq('Jan31->Feb28 non-leap', res, '4 weeks') ! 5.1

    res = pt_format_age(en, PT_NORMAL, '2025-01-31', '2025-04-30')
    call assert_eq('Jan31->Apr30=3mo', res, '3 months') ! 5.2

    res = pt_format_age(en, PT_NORMAL, '2025-01-31', '2025-04-29')
    call assert_contains('Jan31->Apr29 still weeks', res, 'weeks') ! 5.3

    res = pt_format_age(en, PT_NORMAL, '2025-02-01', '2025-05-01')
    call assert_eq('Feb1->May1=3mo', res, '3 months') ! 5.4

    res = pt_format_age(en, PT_NORMAL, '2025-02-01', '2025-04-30')
    call assert_contains('Feb1->Apr30 still weeks', res, 'weeks') ! 5.5
  end subroutine test_month_boundary_feb_non_leap

  ! ================================================================
  ! formatAge -- month boundaries: February leap year
  ! ================================================================
  subroutine test_month_boundary_feb_leap()
    type(pt_locale), pointer :: en
    character(len=PT_MAX_STR_LEN) :: res

    en => pt_get_locale('en')

    res = pt_format_age(en, PT_NORMAL, '2024-01-31', '2024-02-29')
    call assert_eq('Jan31->Feb29 leap', res, '4 weeks, 1 day') ! 6.1

    res = pt_format_age(en, PT_NORMAL, '2024-01-31', '2024-02-28')
    call assert_eq('Jan31->Feb28 leap', res, '4 weeks') ! 6.2

    res = pt_format_age(en, PT_NORMAL, '2024-01-31', '2024-04-30')
    call assert_eq('Jan31->Apr30 leap=3mo', res, '3 months') ! 6.3

    res = pt_format_age(en, PT_NORMAL, '2024-01-30', '2024-02-29')
    call assert_contains('Jan30->Feb29 leap still weeks', res, 'weeks') ! 6.4

    res = pt_format_age(en, PT_NORMAL, '2024-01-30', '2024-02-28')
    call assert_contains('Jan30->Feb28 leap still weeks', res, 'weeks') ! 6.5
  end subroutine test_month_boundary_feb_leap

  ! ================================================================
  ! formatAge -- month boundaries: 30-day months
  ! ================================================================
  subroutine test_month_boundary_30day()
    type(pt_locale), pointer :: en
    character(len=PT_MAX_STR_LEN) :: res

    en => pt_get_locale('en')

    res = pt_format_age(en, PT_NORMAL, '2025-03-31', '2025-06-30')
    call assert_eq('Mar31->Jun30=3mo', res, '3 months') ! 7.1

    res = pt_format_age(en, PT_NORMAL, '2025-03-31', '2025-06-29')
    call assert_contains('Mar31->Jun29 still weeks', res, 'weeks') ! 7.2

    res = pt_format_age(en, PT_NORMAL, '2025-08-31', '2025-11-30')
    call assert_eq('Aug31->Nov30=3mo', res, '3 months') ! 7.3

    res = pt_format_age(en, PT_NORMAL, '2025-08-31', '2025-11-29')
    call assert_contains('Aug31->Nov29 still weeks', res, 'weeks') ! 7.4
  end subroutine test_month_boundary_30day

  ! ================================================================
  ! formatAge -- leap year baby (born Feb 29)
  ! ================================================================
  subroutine test_leap_year_baby()
    type(pt_locale), pointer :: en
    character(len=PT_MAX_STR_LEN) :: res

    en => pt_get_locale('en')

    res = pt_format_age(en, PT_NORMAL, '2024-02-29', '2024-05-29')
    call assert_eq('Feb29->May29=3mo', res, '3 months') ! 8.1

    res = pt_format_age(en, PT_NORMAL, '2024-02-29', '2024-05-28')
    call assert_contains('Feb29->May28 still weeks', res, 'weeks') ! 8.2

    res = pt_format_age(en, PT_NORMAL, '2024-02-29', '2025-02-28')
    call assert_eq('Feb29->Feb28 next yr=12mo', res, '12 months') ! 8.3

    res = pt_format_age(en, PT_NORMAL, '2024-02-29', '2025-03-01')
    call assert_eq('Feb29->Mar1 next yr=12mo', res, '12 months') ! 8.4
  end subroutine test_leap_year_baby

  ! ================================================================
  ! formatAge -- months tier (3-23)
  ! ================================================================
  subroutine test_months_tier()
    type(pt_locale), pointer :: en
    character(len=PT_MAX_STR_LEN) :: res

    en => pt_get_locale('en')

    res = pt_format_age(en, PT_NORMAL, '2025-01-15', '2025-04-15')
    call assert_eq('3 months at transition', res, '3 months') ! 9.1

    res = pt_format_age(en, PT_NORMAL, '2025-01-15', '2025-07-15')
    call assert_eq('6 months', res, '6 months') ! 9.2

    res = pt_format_age(en, PT_NORMAL, '2024-06-15', '2025-06-15')
    call assert_eq('12 months (not 1 year)', res, '12 months') ! 9.3

    res = pt_format_age(en, PT_NORMAL, '2024-01-15', '2025-12-15')
    call assert_eq('23 months upper', res, '23 months') ! 9.4

    res = pt_format_age(en, PT_NORMAL, '2025-01-15', '2025-07-14')
    call assert_eq('day before boundary', res, '5 months') ! 9.5

    res = pt_format_age(en, PT_NORMAL, '2024-11-10', '2025-04-10')
    call assert_eq('cross year boundary', res, '5 months') ! 9.6
  end subroutine test_months_tier

  ! ================================================================
  ! formatAge -- years+months tier (24-35 months)
  ! ================================================================
  subroutine test_years_months_tier()
    type(pt_locale), pointer :: en
    character(len=PT_MAX_STR_LEN) :: res

    en => pt_get_locale('en')

    res = pt_format_age(en, PT_NORMAL, '2023-06-15', '2025-06-15')
    call assert_eq('2 years at 24mo', res, '2 years') ! 10.1

    res = pt_format_age(en, PT_NORMAL, '2023-06-15', '2025-07-15')
    call assert_eq('2 years 1 month', res, '2 years, 1 month') ! 10.2

    res = pt_format_age(en, PT_NORMAL, '2023-06-15', '2025-12-15')
    call assert_eq('2 years 6 months', res, '2 years, 6 months') ! 10.3

    res = pt_format_age(en, PT_NORMAL, '2023-06-15', '2026-05-15')
    call assert_eq('2 years 11 months', res, '2 years, 11 months') ! 10.4

    res = pt_format_age(en, PT_NORMAL, '2023-06-15', '2025-06-14')
    call assert_eq('day before 24mo', res, '23 months') ! 10.5
  end subroutine test_years_months_tier

  ! ================================================================
  ! formatAge -- half-year tier (3-6 years)
  ! ================================================================
  subroutine test_half_year_tier()
    type(pt_locale), pointer :: en
    character(len=PT_MAX_STR_LEN) :: res
    ! UTF-8 for "½" is bytes C2 BD
    character(len=2), parameter :: half_char = char(194) // char(189)

    en => pt_get_locale('en')

    res = pt_format_age(en, PT_NORMAL, '2022-06-15', '2025-06-15')
    call assert_eq('3 years exactly', res, '3 years') ! 11.1

    res = pt_format_age(en, PT_NORMAL, '2022-06-15', '2025-11-15')
    call assert_eq('3 years 5 months', res, '3 years') ! 11.2

    res = pt_format_age(en, PT_NORMAL, '2022-06-15', '2025-12-15')
    call assert_eq('3.5 years at 3y6m', res, '3' // half_char // ' years') ! 11.3

    res = pt_format_age(en, PT_NORMAL, '2022-06-15', '2026-05-15')
    call assert_eq('3.5 years at 3y11m', res, '3' // half_char // ' years') ! 11.4

    res = pt_format_age(en, PT_NORMAL, '2021-06-15', '2025-06-15')
    call assert_eq('4 years exactly', res, '4 years') ! 11.5

    res = pt_format_age(en, PT_NORMAL, '2021-06-15', '2025-12-15')
    call assert_eq('4.5 years', res, '4' // half_char // ' years') ! 11.6

    res = pt_format_age(en, PT_NORMAL, '2020-06-15', '2025-06-15')
    call assert_eq('5 years', res, '5 years') ! 11.7

    res = pt_format_age(en, PT_NORMAL, '2020-06-15', '2026-02-15')
    call assert_eq('5.5 years at 5y8m', res, '5' // half_char // ' years') ! 11.8

    res = pt_format_age(en, PT_NORMAL, '2019-06-15', '2025-06-15')
    call assert_eq('6 years', res, '6 years') ! 11.9

    res = pt_format_age(en, PT_NORMAL, '2019-06-15', '2025-12-15')
    call assert_eq('6.5 years', res, '6' // half_char // ' years') ! 11.10

    res = pt_format_age(en, PT_NORMAL, '2019-06-15', '2026-05-15')
    call assert_eq('6.5 years at 6y11m', res, '6' // half_char // ' years') ! 11.11

    res = pt_format_age(en, PT_NORMAL, '2022-06-15', '2025-06-14')
    call assert_eq('day before 3rd bday', res, '2 years, 11 months') ! 11.12
  end subroutine test_half_year_tier

  ! ================================================================
  ! formatAge -- integer tier (7+ years)
  ! ================================================================
  subroutine test_integer_tier()
    type(pt_locale), pointer :: en
    character(len=PT_MAX_STR_LEN) :: res

    en => pt_get_locale('en')

    res = pt_format_age(en, PT_NORMAL, '2018-06-15', '2025-06-15')
    call assert_eq('7 years exactly', res, '7 years') ! 12.1

    res = pt_format_age(en, PT_NORMAL, '2018-03-20', '2025-06-15')
    call assert_eq('7y3m no half', res, '7 years') ! 12.2

    res = pt_format_age(en, PT_NORMAL, '1980-01-01', '2025-06-15')
    call assert_eq('45 years', res, '45 years') ! 12.3
  end subroutine test_integer_tier

  ! ================================================================
  ! formatAge -- cross-year with Feb
  ! ================================================================
  subroutine test_cross_year_feb()
    type(pt_locale), pointer :: en
    character(len=PT_MAX_STR_LEN) :: res

    en => pt_get_locale('en')

    res = pt_format_age(en, PT_NORMAL, '2024-12-31', '2025-03-31')
    call assert_eq('Dec31->Mar31=3mo', res, '3 months') ! 13.1

    res = pt_format_age(en, PT_NORMAL, '2024-12-31', '2025-03-30')
    call assert_contains('Dec31->Mar30 still weeks', res, 'weeks') ! 13.2

    res = pt_format_age(en, PT_NORMAL, '2024-11-30', '2025-02-28')
    call assert_eq('Nov30->Feb28=3mo', res, '3 months') ! 13.3

    res = pt_format_age(en, PT_NORMAL, '2024-11-30', '2025-02-27')
    call assert_contains('Nov30->Feb27 still weeks', res, 'weeks') ! 13.4
  end subroutine test_cross_year_feb

  ! ================================================================
  ! formatAge -- born-on-31st progression
  ! ================================================================
  subroutine test_born_on_31st()
    type(pt_locale), pointer :: en
    character(len=PT_MAX_STR_LEN) :: res

    en => pt_get_locale('en')

    res = pt_format_age(en, PT_NORMAL, '2025-01-31', '2025-04-30')
    call assert_eq('Jan31->Apr30=3mo', res, '3 months') ! 14.1

    res = pt_format_age(en, PT_NORMAL, '2025-01-31', '2025-05-31')
    call assert_eq('Jan31->May31=4mo', res, '4 months') ! 14.2

    res = pt_format_age(en, PT_NORMAL, '2025-01-31', '2025-06-30')
    call assert_eq('Jan31->Jun30=5mo', res, '5 months') ! 14.3

    res = pt_format_age(en, PT_NORMAL, '2025-01-31', '2025-07-01')
    call assert_eq('Jan31->Jul1=5mo', res, '5 months') ! 14.4

    res = pt_format_age(en, PT_NORMAL, '2025-01-31', '2025-07-31')
    call assert_eq('Jan31->Jul31=6mo', res, '6 months') ! 14.5
  end subroutine test_born_on_31st

  ! ================================================================
  ! formatStage -- null/edge cases
  ! ================================================================
  subroutine test_stage_null_edge_cases()
    type(pt_locale), pointer :: en
    character(len=PT_MAX_STR_LEN) :: res

    en => pt_get_locale('en')

    res = pt_format_stage(en, '', '2025-06-15')
    call assert_null('stage empty', res) ! 16.1, 16.3

    res = pt_format_stage(en, '2025-07-01', '2025-06-15')
    call assert_null('stage future', res) ! 16.4

    res = pt_format_stage(en, '1525-06-15', '2025-06-15')
    call assert_eq('stage 500 years', res, 'Adult') ! 16.5

    res = pt_format_stage(en, '1524-06-15', '2025-06-15')
    call assert_null('stage 501 years', res) ! 16.6
  end subroutine test_stage_null_edge_cases

  ! ================================================================
  ! formatStage -- Newborn (0-1 months)
  ! ================================================================
  subroutine test_stage_newborn()
    type(pt_locale), pointer :: en
    character(len=PT_MAX_STR_LEN) :: res

    en => pt_get_locale('en')

    res = pt_format_stage(en, '2025-06-15', '2025-06-15')
    call assert_eq('stage born today', res, 'Newborn') ! 17.1

    res = pt_format_stage(en, '2025-06-14', '2025-06-15')
    call assert_eq('stage 1 day', res, 'Newborn') ! 17.2

    res = pt_format_stage(en, '2025-05-25', '2025-06-15')
    call assert_eq('stage 3 weeks', res, 'Newborn') ! 17.3

    res = pt_format_stage(en, '2025-05-15', '2025-06-15')
    call assert_eq('stage 1 month', res, 'Newborn') ! 17.4

    res = pt_format_stage(en, '2025-04-16', '2025-06-15')
    call assert_eq('stage 1mo 29d', res, 'Newborn') ! 17.5

    res = pt_format_stage(en, '2025-04-15', '2025-06-15')
    call assert_eq('stage 2mo -> Infant', res, 'Infant') ! 17.6
  end subroutine test_stage_newborn

  ! ================================================================
  ! formatStage -- Infant (2-11 months)
  ! ================================================================
  subroutine test_stage_infant()
    type(pt_locale), pointer :: en
    character(len=PT_MAX_STR_LEN) :: res

    en => pt_get_locale('en')

    res = pt_format_stage(en, '2025-04-15', '2025-06-15')
    call assert_eq('stage 2 months', res, 'Infant') ! 18.1

    res = pt_format_stage(en, '2024-12-15', '2025-06-15')
    call assert_eq('stage 6 months', res, 'Infant') ! 18.2

    res = pt_format_stage(en, '2024-07-15', '2025-06-15')
    call assert_eq('stage 11 months', res, 'Infant') ! 18.3

    res = pt_format_stage(en, '2024-06-15', '2025-06-15')
    call assert_eq('stage 12mo -> Toddler', res, 'Toddler') ! 18.4
  end subroutine test_stage_infant

  ! ================================================================
  ! formatStage -- Toddler (12-35 months)
  ! ================================================================
  subroutine test_stage_toddler()
    type(pt_locale), pointer :: en
    character(len=PT_MAX_STR_LEN) :: res

    en => pt_get_locale('en')

    res = pt_format_stage(en, '2024-06-15', '2025-06-15')
    call assert_eq('stage 12 months', res, 'Toddler') ! 19.1

    res = pt_format_stage(en, '2024-01-15', '2025-07-15')
    call assert_eq('stage 18 months', res, 'Toddler') ! 19.2

    res = pt_format_stage(en, '2023-06-15', '2025-06-15')
    call assert_eq('stage 24 months', res, 'Toddler') ! 19.3

    res = pt_format_stage(en, '2023-06-15', '2026-05-15')
    call assert_eq('stage 35 months', res, 'Toddler') ! 19.4

    res = pt_format_stage(en, '2022-06-15', '2025-06-15')
    call assert_eq('stage 36mo -> Child', res, 'Child') ! 19.5
  end subroutine test_stage_toddler

  ! ================================================================
  ! formatStage -- Child (36-155 months)
  ! ================================================================
  subroutine test_stage_child()
    type(pt_locale), pointer :: en
    character(len=PT_MAX_STR_LEN) :: res

    en => pt_get_locale('en')

    res = pt_format_stage(en, '2022-06-15', '2025-06-15')
    call assert_eq('stage 3 years', res, 'Child') ! 20.1

    res = pt_format_stage(en, '2021-06-15', '2025-06-15')
    call assert_eq('stage 4 years', res, 'Child') ! 20.2

    res = pt_format_stage(en, '2019-06-15', '2025-06-15')
    call assert_eq('stage 6 years', res, 'Child') ! 20.3

    res = pt_format_stage(en, '2016-06-15', '2025-06-15')
    call assert_eq('stage 9 years', res, 'Child') ! 20.4

    res = pt_format_stage(en, '2013-06-15', '2026-05-15')
    call assert_eq('stage 12y11m', res, 'Child') ! 20.5

    res = pt_format_stage(en, '2012-06-15', '2025-06-15')
    call assert_eq('stage 13y -> Teenager', res, 'Teenager') ! 20.6
  end subroutine test_stage_child

  ! ================================================================
  ! formatStage -- Teenager (156-215 months)
  ! ================================================================
  subroutine test_stage_teenager()
    type(pt_locale), pointer :: en
    character(len=PT_MAX_STR_LEN) :: res

    en => pt_get_locale('en')

    res = pt_format_stage(en, '2012-06-15', '2025-06-15')
    call assert_eq('stage 13 years', res, 'Teenager') ! 21.1

    res = pt_format_stage(en, '2010-06-15', '2025-06-15')
    call assert_eq('stage 15 years', res, 'Teenager') ! 21.2

    res = pt_format_stage(en, '2008-06-15', '2026-05-15')
    call assert_eq('stage 17y11m', res, 'Teenager') ! 21.3

    res = pt_format_stage(en, '2007-06-15', '2025-06-15')
    call assert_eq('stage 18y -> Adult', res, 'Adult') ! 21.4
  end subroutine test_stage_teenager

  ! ================================================================
  ! formatStage -- Adult (216+ months)
  ! ================================================================
  subroutine test_stage_adult()
    type(pt_locale), pointer :: en
    character(len=PT_MAX_STR_LEN) :: res

    en => pt_get_locale('en')

    res = pt_format_stage(en, '2007-06-15', '2025-06-15')
    call assert_eq('stage 18 years', res, 'Adult') ! 22.1

    res = pt_format_stage(en, '2000-06-15', '2025-06-15')
    call assert_eq('stage 25 years', res, 'Adult') ! 22.2

    res = pt_format_stage(en, '1980-01-01', '2025-06-15')
    call assert_eq('stage 45 years', res, 'Adult') ! 22.3
  end subroutine test_stage_adult

  ! ================================================================
  ! formatStage -- gender support (Spanish)
  ! ================================================================
  subroutine test_stage_gender_spanish()
    type(pt_locale), pointer :: es
    character(len=PT_MAX_STR_LEN) :: res

    es => pt_get_locale('es')

    ! 25.13
    res = pt_format_stage(es, '2025-06-15', '2025-06-15')
    call assert_eq('ES stage newborn m', res, 'Reci' // char(195) // char(169) // 'n nacido')

    ! 25.15
    res = pt_format_stage(es, '2024-06-15', '2025-06-15')
    call assert_eq('ES stage toddler m', res, 'Ni' // char(195) // char(177) // 'o peque' // char(195) // char(177) // 'o')

    ! 25.16
    res = pt_format_stage(es, '2022-06-15', '2025-06-15')
    call assert_eq('ES stage child m', res, 'Ni' // char(195) // char(177) // 'o')

    ! 25.18
    res = pt_format_stage(es, '2007-06-15', '2025-06-15')
    call assert_eq('ES stage adult m', res, 'Adulto')

    ! Feminine forms
    res = pt_format_stage(es, '2025-06-15', '2025-06-15', 'f')
    call assert_eq('ES stage newborn f', res, 'Reci' // char(195) // char(169) // 'n nacida')

    ! 25.14
    res = pt_format_stage(es, '2025-01-15', '2025-06-15', 'f')
    call assert_eq('ES stage infant f', res, 'Beb' // char(195) // char(169))

    ! 25.17
    res = pt_format_stage(es, '2012-06-15', '2025-06-15', 'f')
    call assert_eq('ES stage teenager f', res, 'Adolescente')

    res = pt_format_stage(es, '2007-06-15', '2025-06-15', 'f')
    call assert_eq('ES stage adult f', res, 'Adulta')
  end subroutine test_stage_gender_spanish

  ! ================================================================
  ! formatStage -- gender-neutral locale
  ! ================================================================
  subroutine test_stage_gender_neutral()
    type(pt_locale), pointer :: en
    character(len=PT_MAX_STR_LEN) :: res

    en => pt_get_locale('en')

    res = pt_format_stage(en, '2025-06-15', '2025-06-15', 'f')
    call assert_eq('EN stage newborn f', res, 'Newborn')

    res = pt_format_stage(en, '2007-06-15', '2025-06-15', 'f')
    call assert_eq('EN stage adult f', res, 'Adult')
  end subroutine test_stage_gender_neutral

  ! ================================================================
  ! SayableAge with English locale
  ! ================================================================
  subroutine test_sayableage_english()
    type(pt_locale), pointer :: en
    character(len=PT_MAX_STR_LEN) :: res
    character(len=2), parameter :: half_char = char(194) // char(189)

    en => pt_get_locale('en')

    res = pt_format_age(en, PT_NORMAL, '2025-06-15', '2025-06-15')
    call assert_eq('PT Newborn', res, 'Newborn') ! 24.1

    res = pt_format_age(en, PT_NORMAL, '2025-06-12', '2025-06-15')
    call assert_eq('PT 3 days', res, '3 days') ! 24.2

    res = pt_format_age(en, PT_NORMAL, '2025-06-07', '2025-06-15')
    call assert_eq('PT 1w1d', res, '1 week, 1 day') ! 24.3

    res = pt_format_age(en, PT_NORMAL, '2025-01-15', '2025-07-15')
    call assert_eq('PT 6 months', res, '6 months') ! 24.4

    res = pt_format_age(en, PT_NORMAL, '2023-06-15', '2025-07-15')
    call assert_eq('PT 2y1mo', res, '2 years, 1 month') ! 24.5

    res = pt_format_age(en, PT_NORMAL, '2022-06-15', '2025-12-15')
    call assert_eq('PT 3.5y', res, '3' // half_char // ' years') ! 24.6

    res = pt_format_age(en, PT_NORMAL, '2018-06-15', '2025-06-15')
    call assert_eq('PT 7 years', res, '7 years') ! 24.7

    res = pt_format_stage(en, '2025-06-15', '2025-06-15')
    call assert_eq('PT stage Newborn', res, 'Newborn') ! 24.8

    res = pt_format_stage(en, '2025-01-15', '2025-06-15')
    call assert_eq('PT stage Infant', res, 'Infant') ! 24.9

    res = pt_format_stage(en, '2024-06-15', '2025-06-15')
    call assert_eq('PT stage Toddler', res, 'Toddler') ! 24.10

    res = pt_format_stage(en, '2022-06-15', '2025-06-15')
    call assert_eq('PT stage Child', res, 'Child') ! 24.11

    res = pt_format_stage(en, '2012-06-15', '2025-06-15')
    call assert_eq('PT stage Teenager', res, 'Teenager') ! 24.12

    res = pt_format_stage(en, '2007-06-15', '2025-06-15')
    call assert_eq('PT stage Adult', res, 'Adult') ! 24.13

    res = pt_format_age(en, PT_NORMAL, '', '2025-06-15')
    call assert_null('PT null age', res) ! 24.14

    res = pt_format_stage(en, '', '2025-06-15')
    call assert_null('PT null stage', res) ! 24.15
  end subroutine test_sayableage_english

  ! ================================================================
  ! SayableAge with Spanish locale
  ! ================================================================
  subroutine test_sayableage_spanish()
    type(pt_locale), pointer :: es
    character(len=PT_MAX_STR_LEN) :: res

    es => pt_get_locale('es')

    res = pt_format_age(es, PT_NORMAL, '2025-06-15', '2025-06-15')
    call assert_eq('ES justBorn', res, 'Reci' // char(195) // char(169) // 'n nacido') ! 25.1

    res = pt_format_age(es, PT_NORMAL, '2025-06-14', '2025-06-15')
    call assert_eq('ES singular day', res, '1 d' // char(195) // char(173) // 'a') ! 25.2

    res = pt_format_age(es, PT_NORMAL, '2025-06-12', '2025-06-15')
    call assert_eq('ES plural days', res, '3 d' // char(195) // char(173) // 'as') ! 25.3

    res = pt_format_age(es, PT_NORMAL, '2025-06-08', '2025-06-15')
    call assert_eq('ES singular week', res, '1 semana') ! 25.4

    res = pt_format_age(es, PT_NORMAL, '2025-06-07', '2025-06-15')
    call assert_eq('ES weeks+days', res, '1 semana, 1 d' // char(195) // char(173) // 'a') ! 25.5

    res = pt_format_age(es, PT_NORMAL, '2025-05-26', '2025-06-15')
    call assert_eq('ES plural weeks+days', res, '2 semanas, 6 d' // char(195) // char(173) // 'as') ! 25.6

    res = pt_format_age(es, PT_NORMAL, '2025-01-15', '2025-07-15')
    call assert_eq('ES months', res, '6 meses') ! 25.7

    res = pt_format_age(es, PT_NORMAL, '2023-06-15', '2025-07-15')
    call assert_eq('ES singular month compound', res, '2 a' // char(195) // char(177) // 'os, 1 mes') ! 25.8

    res = pt_format_age(es, PT_NORMAL, '2023-06-15', '2025-12-15')
    call assert_eq('ES years+months', res, '2 a' // char(195) // char(177) // 'os, 6 meses') ! 25.9

    res = pt_format_age(es, PT_NORMAL, '2022-06-15', '2025-12-15')
    call assert_eq('ES half marker', res, '3 y medio a' // char(195) // char(177) // 'os') ! 25.10

    res = pt_format_age(es, PT_NORMAL, '2022-06-15', '2025-06-15')
    call assert_eq('ES integer years', res, '3 a' // char(195) // char(177) // 'os') ! 25.11

    res = pt_format_age(es, PT_NORMAL, '2018-06-15', '2025-06-15')
    call assert_eq('ES 7+ years', res, '7 a' // char(195) // char(177) // 'os') ! 25.12

    res = pt_format_age(es, PT_NORMAL, '', '2025-06-15')
    call assert_null('ES null', res) ! 25.19

    res = pt_format_stage(es, '', '2025-06-15')
    call assert_null('ES null stage', res) ! 25.20
  end subroutine test_sayableage_spanish

  ! ================================================================
  ! Compactness: short
  ! ================================================================
  subroutine test_compact_short()
    type(pt_locale), pointer :: en
    character(len=PT_MAX_STR_LEN) :: res
    character(len=2), parameter :: half_char = char(194) // char(189)

    en => pt_get_locale('en')

    res = pt_format_age(en, PT_SHORT, '2025-06-12', '2025-06-15')
    call assert_eq('short days', res, '3 d') ! 26.1

    res = pt_format_age(en, PT_SHORT, '2025-06-08', '2025-06-15')
    call assert_eq('short weeks', res, '1 wk') ! 26.2

    res = pt_format_age(en, PT_SHORT, '2025-06-07', '2025-06-15')
    call assert_eq('short weeks+days', res, '1 wk, 1 d') ! 26.3

    res = pt_format_age(en, PT_SHORT, '2025-01-15', '2025-07-15')
    call assert_eq('short months', res, '6 mo') ! 26.4

    res = pt_format_age(en, PT_SHORT, '2023-06-15', '2025-07-15')
    call assert_eq('short years+months', res, '2 yr, 1 mo') ! 26.5

    res = pt_format_age(en, PT_SHORT, '2022-06-15', '2025-12-15')
    call assert_eq('short half years', res, '3' // half_char // ' yr') ! 26.6

    res = pt_format_age(en, PT_SHORT, '2018-06-15', '2025-06-15')
    call assert_eq('short integer years', res, '7 yr') ! 26.7

    res = pt_format_age(en, PT_SHORT, '2025-06-15', '2025-06-15')
    call assert_eq('short justBorn', res, 'Newborn') ! 26.8

    res = pt_format_stage(en, '2025-01-15', '2025-06-15')
    call assert_eq('short stages unchanged', res, 'Infant') ! 26.9
  end subroutine test_compact_short

  ! ================================================================
  ! Compactness: compact
  ! ================================================================
  subroutine test_compact_compact()
    type(pt_locale), pointer :: en
    character(len=PT_MAX_STR_LEN) :: res
    character(len=2), parameter :: half_char = char(194) // char(189)

    en => pt_get_locale('en')

    res = pt_format_age(en, PT_COMPACT, '2025-06-12', '2025-06-15')
    call assert_eq('compact days', res, '3d') ! 27.1

    res = pt_format_age(en, PT_COMPACT, '2025-06-08', '2025-06-15')
    call assert_eq('compact weeks', res, '1w') ! 27.2

    res = pt_format_age(en, PT_COMPACT, '2025-06-07', '2025-06-15')
    call assert_eq('compact weeks+days', res, '1w1d') ! 27.3

    res = pt_format_age(en, PT_COMPACT, '2025-01-15', '2025-07-15')
    call assert_eq('compact months', res, '6m') ! 27.4

    res = pt_format_age(en, PT_COMPACT, '2023-06-15', '2025-07-15')
    call assert_eq('compact years+months', res, '2y1m') ! 27.5

    res = pt_format_age(en, PT_COMPACT, '2022-06-15', '2025-12-15')
    call assert_eq('compact half years', res, '3' // half_char // 'y') ! 27.6

    res = pt_format_age(en, PT_COMPACT, '2018-06-15', '2025-06-15')
    call assert_eq('compact integer years', res, '7y') ! 27.7

    res = pt_format_age(en, PT_COMPACT, '2025-06-15', '2025-06-15')
    call assert_eq('compact justBorn', res, 'Newborn') ! 27.8
  end subroutine test_compact_compact

  ! ================================================================
  ! Locale-specific: Hebrew
  ! ================================================================
  subroutine test_locale_hebrew()
    type(pt_locale), pointer :: he
    character(len=PT_MAX_STR_LEN) :: res

    he => pt_get_locale('he')

    ! 29.1 justBorn
    res = pt_format_age(he, PT_NORMAL, '2025-06-15', '2025-06-15')
    call assert_contains('he justBorn', res, char(215))

    ! 29.2 1 day one
    res = pt_format_age(he, PT_NORMAL, '2025-06-14', '2025-06-15')
    call assert_contains('he 1 day one', res, '1')

    ! 29.3 3 days other
    res = pt_format_age(he, PT_NORMAL, '2025-06-12', '2025-06-15')
    call assert_contains('he 3 days other', res, '3')

    ! 29.4 2 weeks dual
    res = pt_format_age(he, PT_NORMAL, '2025-06-01', '2025-06-15')
    call assert_true('he 2 weeks dual not empty', len_trim(res) > 0)

    ! 29.5 3 weeks other
    res = pt_format_age(he, PT_NORMAL, '2025-05-25', '2025-06-15')
    call assert_contains('he 3 weeks other', res, '3')

    ! 29.6 6 months
    res = pt_format_age(he, PT_NORMAL, '2025-01-15', '2025-07-15')
    call assert_contains('he 6 months', res, '6')

    ! 29.7 3 months
    res = pt_format_age(he, PT_NORMAL, '2025-03-15', '2025-06-15')
    call assert_contains('he 3 months', res, '3')

    ! 29.8 2y dual + 1m one
    res = pt_format_age(he, PT_NORMAL, '2023-06-15', '2025-07-15')
    call assert_true('he 2y1m not empty', len_trim(res) > 0)

    ! 29.9 3.5 years half
    res = pt_format_age(he, PT_NORMAL, '2022-06-15', '2025-12-15')
    call assert_contains('he 3.5y half', res, '3')

    ! 29.10 7+ years
    res = pt_format_age(he, PT_NORMAL, '2018-06-15', '2025-06-15')
    call assert_contains('he 7y other', res, '7')

    ! 29.11 stage m newborn
    res = pt_format_stage(he, '2025-06-15', '2025-06-15', 'm')
    call assert_true('he stage m newborn', len_trim(res) > 0)

    ! 29.12 stage f newborn
    res = pt_format_stage(he, '2025-06-15', '2025-06-15', 'f')
    call assert_true('he stage f newborn', len_trim(res) > 0)

    ! 29.13 stage m adult
    res = pt_format_stage(he, '2007-06-15', '2025-06-15', 'm')
    call assert_true('he stage m adult', len_trim(res) > 0)

    ! 29.14 stage f adult
    res = pt_format_stage(he, '2007-06-15', '2025-06-15', 'f')
    call assert_true('he stage f adult', len_trim(res) > 0)
  end subroutine test_locale_hebrew

  ! ================================================================
  ! Locale-specific: Macedonian
  ! ================================================================
  subroutine test_locale_macedonian()
    type(pt_locale), pointer :: mk
    character(len=PT_MAX_STR_LEN) :: res

    mk => pt_get_locale('mk')

    ! 29.15 justBorn
    res = pt_format_age(mk, PT_NORMAL, '2025-06-15', '2025-06-15')
    call assert_true('mk justBorn not empty', len_trim(res) > 0)

    ! 29.16 1 day one
    res = pt_format_age(mk, PT_NORMAL, '2025-06-14', '2025-06-15')
    call assert_contains('mk 1 day one', res, '1')

    ! 29.17 3 days other
    res = pt_format_age(mk, PT_NORMAL, '2025-06-12', '2025-06-15')
    call assert_contains('mk 3 days other', res, '3')

    ! 29.18 6 months other
    res = pt_format_age(mk, PT_NORMAL, '2025-01-15', '2025-07-15')
    call assert_contains('mk 6 months', res, '6')

    ! 29.19 2y1m
    res = pt_format_age(mk, PT_NORMAL, '2023-06-15', '2025-07-15')
    call assert_contains('mk 2y1m', res, '2')

    ! 29.20 3.5y half
    res = pt_format_age(mk, PT_NORMAL, '2022-06-15', '2025-12-15')
    call assert_contains('mk 3.5y half', res, '3')

    ! 29.21 7+ years
    res = pt_format_age(mk, PT_NORMAL, '2018-06-15', '2025-06-15')
    call assert_contains('mk 7y', res, '7')
  end subroutine test_locale_macedonian

  ! ================================================================
  ! Locale-specific: Swahili
  ! ================================================================
  subroutine test_locale_swahili()
    type(pt_locale), pointer :: sw
    character(len=PT_MAX_STR_LEN) :: res

    sw => pt_get_locale('sw')

    ! 29.22 justBorn
    res = pt_format_age(sw, PT_NORMAL, '2025-06-15', '2025-06-15')
    call assert_eq('sw justBorn', res, 'Mzaliwa mpya')

    ! 29.23 1 day
    res = pt_format_age(sw, PT_NORMAL, '2025-06-14', '2025-06-15')
    call assert_eq('sw 1 day', res, 'siku 1')

    ! 29.24 3 days
    res = pt_format_age(sw, PT_NORMAL, '2025-06-12', '2025-06-15')
    call assert_eq('sw 3 days', res, 'siku 3')

    ! 29.25 6 months
    res = pt_format_age(sw, PT_NORMAL, '2025-01-15', '2025-07-15')
    call assert_eq('sw 6 months', res, 'miezi 6')

    ! 29.26 2y 1m
    res = pt_format_age(sw, PT_NORMAL, '2023-06-15', '2025-07-15')
    call assert_eq('sw 2y 1m', res, 'miaka 2, mwezi 1')

    ! 29.27 3.5y half
    res = pt_format_age(sw, PT_NORMAL, '2022-06-15', '2025-12-15')
    call assert_eq('sw 3.5y half', res, 'miaka 3 na nusu')
  end subroutine test_locale_swahili

  ! ================================================================
  ! Locale-specific: Indonesian
  ! ================================================================
  subroutine test_locale_indonesian()
    type(pt_locale), pointer :: id_locale
    character(len=PT_MAX_STR_LEN) :: res

    id_locale => pt_get_locale('id')

    ! 29.28 justBorn
    res = pt_format_age(id_locale, PT_NORMAL, '2025-06-15', '2025-06-15')
    call assert_eq('id justBorn', res, 'Baru lahir')

    ! 29.29 1 day
    res = pt_format_age(id_locale, PT_NORMAL, '2025-06-14', '2025-06-15')
    call assert_eq('id 1 day', res, '1 hari')

    ! 29.30 3 days
    res = pt_format_age(id_locale, PT_NORMAL, '2025-06-12', '2025-06-15')
    call assert_eq('id 3 days', res, '3 hari')

    ! 29.31 6 months
    res = pt_format_age(id_locale, PT_NORMAL, '2025-01-15', '2025-07-15')
    call assert_eq('id 6 months', res, '6 bulan')

    ! 29.32 3.5y half
    res = pt_format_age(id_locale, PT_NORMAL, '2022-06-15', '2025-12-15')
    call assert_eq('id 3.5y half', res, '3 tahun setengah')

    ! 29.33 7y
    res = pt_format_age(id_locale, PT_NORMAL, '2018-06-15', '2025-06-15')
    call assert_eq('id 7y', res, '7 tahun')
  end subroutine test_locale_indonesian

  ! ================================================================
  ! Locale-specific: Amharic
  ! ================================================================
  subroutine test_locale_amharic()
    type(pt_locale), pointer :: am
    character(len=PT_MAX_STR_LEN) :: res

    am => pt_get_locale('am')

    ! 29.34 justBorn
    res = pt_format_age(am, PT_NORMAL, '2025-06-15', '2025-06-15')
    call assert_true('am justBorn not empty', len_trim(res) > 0)

    ! 29.35 1 day
    res = pt_format_age(am, PT_NORMAL, '2025-06-14', '2025-06-15')
    call assert_contains('am 1 day', res, '1')

    ! 29.36 3 days
    res = pt_format_age(am, PT_NORMAL, '2025-06-12', '2025-06-15')
    call assert_contains('am 3 days', res, '3')

    ! 29.37 1w1d ethiopic delimiter
    res = pt_format_age(am, PT_NORMAL, '2025-06-07', '2025-06-15')
    call assert_contains('am 1w1d', res, '1')

    ! 29.38 6 months
    res = pt_format_age(am, PT_NORMAL, '2025-01-15', '2025-07-15')
    call assert_contains('am 6 months', res, '6')

    ! 29.39 3.5y half
    res = pt_format_age(am, PT_NORMAL, '2022-06-15', '2025-12-15')
    call assert_contains('am 3.5y half', res, '3')
  end subroutine test_locale_amharic

  ! ================================================================
  ! Locale lookup by code string
  ! ================================================================
  subroutine test_locale_lookup()
    type(pt_locale), pointer :: loc

    ! 30.1
    loc => pt_get_locale('en')
    call assert_true('get(en) not null', associated(loc))
    call assert_eq('get(en) code', loc%code, 'en')

    ! 30.2
    loc => pt_get_locale('fr')
    call assert_true('get(fr) not null', associated(loc))
    call assert_eq('get(fr) code', loc%code, 'fr')

    ! 30.3
    loc => pt_get_locale('xx')
    call assert_true('get(xx) null', .not. associated(loc))

    ! 30.4
    loc => pt_get_locale('')
    call assert_true('get empty null', .not. associated(loc))

    ! 30.5
    loc => pt_get_locale('EN')
    call assert_true('get(EN) null', .not. associated(loc))
  end subroutine test_locale_lookup

end program test_format_age
