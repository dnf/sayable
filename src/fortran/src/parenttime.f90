module parenttime
  use parenttime_types
  implicit none
  private

  public :: pt_format_age, pt_format_stage

contains

  pure function is_leap_year(year) result(leap)
    integer, intent(in) :: year
    logical :: leap
    leap = (mod(year, 4) == 0 .and. (mod(year, 100) /= 0 .or. mod(year, 400) == 0))
  end function is_leap_year

  pure function days_in_month(year, month) result(days)
    integer, intent(in) :: year, month
    integer :: days
    integer, parameter :: month_days(12) = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    if (month == 2 .and. is_leap_year(year)) then
      days = 29
    else
      days = month_days(month)
    end if
  end function days_in_month

  pure function julian_day(year, month, day) result(jd)
    integer, intent(in) :: year, month, day
    integer :: jd, a, y, m
    a = (14 - month) / 12
    y = year + 4800 - a
    m = month + 12 * a - 3
    jd = day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045
  end function julian_day

  subroutine parse_date(s, year, month, day, ok)
    character(len=*), intent(in) :: s
    integer, intent(out) :: year, month, day
    logical, intent(out) :: ok
    integer :: i

    ok = .false.
    year = 0
    month = 0
    day = 0

    if (len_trim(s) < 10) return
    if (s(5:5) /= '-' .or. s(8:8) /= '-') return

    do i = 1, 4
      if (s(i:i) < '0' .or. s(i:i) > '9') return
      year = year * 10 + ichar(s(i:i)) - ichar('0')
    end do
    do i = 6, 7
      if (s(i:i) < '0' .or. s(i:i) > '9') return
      month = month * 10 + ichar(s(i:i)) - ichar('0')
    end do
    do i = 9, 10
      if (s(i:i) < '0' .or. s(i:i) > '9') return
      day = day * 10 + ichar(s(i:i)) - ichar('0')
    end do

    ok = (year /= 0 .or. month /= 0 .or. day /= 0)
  end subroutine parse_date

  function int_to_str(n) result(s)
    integer, intent(in) :: n
    character(len=12) :: s
    write(s, '(I0)') n
  end function int_to_str

  function replace_first(tmpl, marker, replacement) result(res)
    character(len=*), intent(in) :: tmpl, marker, replacement
    character(len=PT_MAX_STR_LEN) :: res
    integer :: pos, tmpl_len, marker_len

    tmpl_len = len_trim(tmpl)
    marker_len = len_trim(marker)
    pos = index(tmpl(1:tmpl_len), marker(1:marker_len))
    if (pos == 0) then
      res = tmpl
      return
    end if
    res = tmpl(1:pos-1) // trim(replacement) // tmpl(pos + marker_len:tmpl_len)
  end function replace_first

  function resolve_unit(count, uf, loc, half) result(res)
    integer, intent(in) :: count
    type(pt_unit_forms), intent(in) :: uf
    type(pt_locale), intent(in) :: loc
    character(len=*), intent(in) :: half
    character(len=PT_MAX_STR_LEN) :: res
    character(len=12) :: base_n
    character(len=PT_MAX_STR_LEN) :: n_str, tmpl, result_buf
    integer :: cat

    base_n = int_to_str(count)

    ! Apply {n}-style half marker to the number
    if (len_trim(half) > 0 .and. index(trim(half), '{n}') > 0) then
      n_str = replace_first(half, '{n}', trim(base_n))
    else
      n_str = base_n
    end if

    ! Select template
    tmpl = ''
    if (uf%has_simple) then
      tmpl = uf%simple
    else
      cat = loc%plural(count)
      if (uf%has_form(cat)) then
        tmpl = uf%forms(cat)
      else if (uf%has_form(PT_OTHER)) then
        tmpl = uf%forms(PT_OTHER)
      end if
    end if

    if (len_trim(tmpl) == 0) then
      res = ''
      return
    end if

    ! Replace {n} with the (possibly half-marked) number
    result_buf = replace_first(tmpl, '{n}', trim(n_str))

    ! Apply {0}-style half marker (wraps the whole expression)
    if (len_trim(half) > 0 .and. index(trim(half), '{0}') > 0) then
      res = replace_first(half, '{0}', trim(result_buf))
    else
      res = result_buf
    end if
  end function resolve_unit

  function pt_format_age(locale, compactness, dob, as_of) result(res)
    type(pt_locale), intent(in), target :: locale
    integer, intent(in) :: compactness
    character(len=*), intent(in) :: dob, as_of
    character(len=PT_MAX_STR_LEN) :: res
    integer :: dob_y, dob_m, dob_d, ref_y, ref_m, ref_d
    integer :: diff_days, months, last_day, clamped_birthday
    integer :: weeks, days_rem, years, rem_months
    integer :: delim_len
    type(pt_unit_forms) :: day_uf, week_uf, month_uf, year_uf
    character(len=PT_MAX_STR_LEN) :: half_str, delim_str, just_born_str
    character(len=PT_MAX_STR_LEN) :: part1, part2
    type(pt_compactness_override) :: ovr
    logical :: ok

    res = ''

    if (len_trim(dob) == 0) return
    call parse_date(dob, dob_y, dob_m, dob_d, ok)
    if (.not. ok) return
    if (len_trim(as_of) == 0) return
    call parse_date(as_of, ref_y, ref_m, ref_d, ok)
    if (.not. ok) return

    diff_days = julian_day(ref_y, ref_m, ref_d) - julian_day(dob_y, dob_m, dob_d)
    if (diff_days < 0) return

    last_day = days_in_month(ref_y, ref_m)
    clamped_birthday = min(dob_d, last_day)
    months = (ref_y - dob_y) * 12 + (ref_m - dob_m)
    if (ref_d < clamped_birthday) months = months - 1
    if (months > PT_MAX_AGE_MONTHS) return

    ! Resolve compactness overrides
    day_uf = locale%units%day
    week_uf = locale%units%week
    month_uf = locale%units%month
    year_uf = locale%units%year
    half_str = locale%half
    delim_str = locale%delimiter
    delim_len = locale%delimiter_len
    just_born_str = locale%just_born

    if (compactness == PT_SHORT .and. locale%has_short) then
      ovr = locale%short_override
      if (ovr%has_day) day_uf = ovr%day
      if (ovr%has_week) week_uf = ovr%week
      if (ovr%has_month) month_uf = ovr%month
      if (ovr%has_year) year_uf = ovr%year
      if (ovr%has_half) half_str = ovr%half
      if (ovr%has_delimiter) then
        delim_str = ovr%delimiter
        delim_len = ovr%delimiter_len
      end if
      if (ovr%has_just_born) just_born_str = ovr%just_born
    else if (compactness == PT_COMPACT .and. locale%has_compact) then
      ovr = locale%compact_override
      if (ovr%has_day) day_uf = ovr%day
      if (ovr%has_week) week_uf = ovr%week
      if (ovr%has_month) month_uf = ovr%month
      if (ovr%has_year) year_uf = ovr%year
      if (ovr%has_half) half_str = ovr%half
      if (ovr%has_delimiter) then
        delim_str = ovr%delimiter
        delim_len = ovr%delimiter_len
      end if
      if (ovr%has_just_born) just_born_str = ovr%just_born
    end if

    ! Tier 1: 0 days
    if (diff_days == 0) then
      res = just_born_str
      return
    end if

    ! Tier 1b: 1-6 days
    if (diff_days < 7) then
      res = resolve_unit(diff_days, day_uf, locale, '')
      return
    end if

    ! Tier 2: weeks + days until 3 calendar months
    if (months < 3) then
      weeks = diff_days / 7
      days_rem = mod(diff_days, 7)
      part1 = resolve_unit(weeks, week_uf, locale, '')
      if (days_rem > 0) then
        part2 = resolve_unit(days_rem, day_uf, locale, '')
        res = trim(part1) // delim_str(1:delim_len) // trim(part2)
      else
        res = part1
      end if
      return
    end if

    ! Tier 3: 3-23 months
    if (months < 24) then
      res = resolve_unit(months, month_uf, locale, '')
      return
    end if

    ! Tier 4: 24-35 months -> years + months
    if (months < 36) then
      years = months / 12
      rem_months = mod(months, 12)
      if (rem_months == 0) then
        res = resolve_unit(years, year_uf, locale, '')
      else
        part1 = resolve_unit(years, year_uf, locale, '')
        part2 = resolve_unit(rem_months, month_uf, locale, '')
        res = trim(part1) // delim_str(1:delim_len) // trim(part2)
      end if
      return
    end if

    ! Tier 5: 3-6 years -> years with half marker
    if (months < 84) then
      years = months / 12
      rem_months = mod(months, 12)
      if (rem_months >= 6) then
        res = resolve_unit(years, year_uf, locale, trim(half_str))
      else
        res = resolve_unit(years, year_uf, locale, '')
      end if
      return
    end if

    ! Tier 6: 7+ years
    years = months / 12
    res = resolve_unit(years, year_uf, locale, '')
  end function pt_format_age

  function pt_format_stage(locale, dob, as_of, gender) result(res)
    type(pt_locale), intent(in) :: locale
    character(len=*), intent(in) :: dob, as_of
    character(len=*), intent(in), optional :: gender
    character(len=PT_MAX_STR_LEN) :: res
    integer :: dob_y, dob_m, dob_d, ref_y, ref_m, ref_d
    integer :: diff_days, months, last_day, clamped_birthday
    type(pt_stage_label) :: stage
    character(len=1) :: g
    logical :: ok

    res = ''

    if (len_trim(dob) == 0) return
    call parse_date(dob, dob_y, dob_m, dob_d, ok)
    if (.not. ok) return
    if (len_trim(as_of) == 0) return
    call parse_date(as_of, ref_y, ref_m, ref_d, ok)
    if (.not. ok) return

    diff_days = julian_day(ref_y, ref_m, ref_d) - julian_day(dob_y, dob_m, dob_d)
    if (diff_days < 0) return

    last_day = days_in_month(ref_y, ref_m)
    clamped_birthday = min(dob_d, last_day)
    months = (ref_y - dob_y) * 12 + (ref_m - dob_m)
    if (ref_d < clamped_birthday) months = months - 1
    if (months > PT_MAX_AGE_MONTHS) return

    if (months < 2) then
      stage = locale%stages%newborn
    else if (months < 12) then
      stage = locale%stages%infant
    else if (months < 36) then
      stage = locale%stages%toddler
    else if (months < 156) then
      stage = locale%stages%child
    else if (months < 216) then
      stage = locale%stages%teenager
    else
      stage = locale%stages%adult
    end if

    g = ''
    if (present(gender)) then
      if (len_trim(gender) > 0) g = gender(1:1)
    end if

    if (g == 'f' .and. len_trim(stage%f_label) > 0) then
      res = stage%f_label
    else
      res = stage%label
    end if
  end function pt_format_stage

end module parenttime
