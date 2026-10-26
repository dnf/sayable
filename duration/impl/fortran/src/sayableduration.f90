module sayableduration
  use, intrinsic :: iso_fortran_env, only: int64
  use sayableduration_types
  implicit none
  private

  character(len=*), parameter, public :: DUR_VERSION = "0.5.0"

  ! 500 years, the same ceiling as sayable-age
  integer, parameter, public :: DUR_MAX_DURATION_MONTHS = 6000

  public :: dur_format_duration, dur_format_duration_iso, dur_format_since, dur_format_until

  ! Seconds as a default or a 64-bit integer (500 years exceed 32 bits).
  interface dur_format_duration
    module procedure dur_format_duration_default, dur_format_duration_int64
  end interface dur_format_duration

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

  pure function days_since_epoch(year, month, day) result(total)
    integer, intent(in) :: year, month, day
    integer :: total, y, m
    total = 0
    if (year >= 2000) then
      do y = 2000, year - 1
        if (is_leap_year(y)) then
          total = total + 366
        else
          total = total + 365
        end if
      end do
    else
      do y = year, 1999
        if (is_leap_year(y)) then
          total = total - 366
        else
          total = total - 365
        end if
      end do
    end if
    do m = 1, month - 1
      total = total + days_in_month(year, m)
    end do
    total = total + day - 1
  end function days_since_epoch

  ! The character at position i, or NUL past either end, so callers can
  ! look ahead without bounds checks (Fortran doesn't short-circuit).
  pure function char_at(s, i) result(c)
    character(len=*), intent(in) :: s
    integer, intent(in) :: i
    character(len=1) :: c
    if (i < 1 .or. i > len(s)) then
      c = achar(0)
    else
      c = s(i:i)
    end if
  end function char_at

  pure function is_digit_at(s, i) result(res)
    character(len=*), intent(in) :: s
    integer, intent(in) :: i
    logical :: res
    character(len=1) :: c
    c = char_at(s, i)
    res = (c >= '0' .and. c <= '9')
  end function is_digit_at

  pure function all_digits_at(s, first, count) result(res)
    character(len=*), intent(in) :: s
    integer, intent(in) :: first, count
    logical :: res
    integer :: i
    res = .false.
    do i = first, first + count - 1
      if (.not. is_digit_at(s, i)) return
    end do
    res = .true.
  end function all_digits_at

  ! The value of count digits starting at first (checked by all_digits_at).
  pure function digits_value(s, first, count) result(val)
    character(len=*), intent(in) :: s
    integer, intent(in) :: first, count
    integer :: val, i
    val = 0
    do i = first, first + count - 1
      val = val * 10 + ichar(s(i:i)) - ichar('0')
    end do
  end function digits_value

  pure function days_in_month_of(year, month) result(days)
    integer, intent(in) :: year, month
    integer :: days
    select case (month)
    case (4, 6, 9, 11)
      days = 30
    case (2)
      if ((mod(year, 4) == 0 .and. mod(year, 100) /= 0) .or. mod(year, 400) == 0) then
        days = 29
      else
        days = 28
      end if
    case default
      days = 31
    end select
  end function days_in_month_of

  ! YYYY-MM-DD naming a real calendar day.
  pure subroutine parse_calendar_date(s, year, month, day, ok)
    character(len=*), intent(in) :: s
    integer, intent(out) :: year, month, day
    logical, intent(out) :: ok
    ok = .false.
    year = 0
    month = 0
    day = 0
    if (len(s) /= 10) return
    if (char_at(s, 5) /= '-' .or. char_at(s, 8) /= '-') return
    if (.not. (all_digits_at(s, 1, 4) .and. all_digits_at(s, 6, 2) .and. all_digits_at(s, 9, 2))) return
    year = digits_value(s, 1, 4)
    month = digits_value(s, 6, 2)
    day = digits_value(s, 9, 2)
    if (month < 1 .or. month > 12) return
    ok = (day >= 1 .and. day <= days_in_month_of(year, month))
  end subroutine parse_calendar_date

  ! Z or +HH:MM / -HH:MM (validated, never applied).
  pure function is_zone_suffix(s) result(res)
    character(len=*), intent(in) :: s
    logical :: res
    if (len(s) == 1) then
      res = (s == 'Z')
    else if (len(s) == 6) then
      res = (char_at(s, 1) == '+' .or. char_at(s, 1) == '-') .and. all_digits_at(s, 2, 2) &
        .and. char_at(s, 4) == ':' .and. all_digits_at(s, 5, 2)
    else
      res = .false.
    end if
  end function is_zone_suffix

  ! H:MM or HH:MM, then optional :SS with optional .fraction, then an
  ! optional zone suffix.
  pure subroutine parse_clock(s, hour, minute, second, ok)
    character(len=*), intent(in) :: s
    integer, intent(out) :: hour, minute, second
    logical, intent(out) :: ok
    integer :: hour_digits, p

    ok = .false.
    hour = 0
    minute = 0
    second = 0
    hour_digits = 0
    do while (hour_digits < 2 .and. is_digit_at(s, hour_digits + 1))
      hour_digits = hour_digits + 1
    end do
    if (hour_digits == 0) return
    p = hour_digits + 1
    if (char_at(s, p) /= ':' .or. .not. all_digits_at(s, p + 1, 2)) return
    hour = digits_value(s, 1, hour_digits)
    minute = digits_value(s, p + 1, 2)
    p = p + 3

    if (char_at(s, p) == ':' .and. all_digits_at(s, p + 1, 2)) then
      second = digits_value(s, p + 1, 2)
      p = p + 3
      if (char_at(s, p) == '.' .and. is_digit_at(s, p + 1)) then
        p = p + 1
        do while (is_digit_at(s, p))
          p = p + 1
        end do
      end if
    end if

    if (p <= len(s)) then
      if (.not. is_zone_suffix(s(p:))) return
    end if
    ok = (hour <= 23 .and. minute <= 59 .and. second <= 59)
  end subroutine parse_clock

  ! YYYY-MM-DDTHH:MM (one- or two-digit hour), then optional :SS with
  ! optional .fraction, then an optional zone suffix that is ignored.
  subroutine parse_iso_datetime(s, seconds, ok)
    character(len=*), intent(in) :: s
    integer(int64), intent(out) :: seconds
    logical, intent(out) :: ok
    integer :: year, month, day, hour, minute, second

    ok = .false.
    seconds = 0
    if (len(s) < 11) return
    if (s(11:11) /= 'T') return
    call parse_calendar_date(s(1:10), year, month, day, ok)
    if (.not. ok) return
    call parse_clock(s(12:), hour, minute, second, ok)
    if (.not. ok) return
    seconds = int(days_since_epoch(year, month, day), int64) * 86400_int64 &
      + int(hour * 3600 + minute * 60 + second, int64)
  end subroutine parse_iso_datetime

  ! Months of 30.44 days (the average month), rounded.
  pure function approximate_months(days) result(months)
    integer(int64), intent(in) :: days
    integer(int64) :: months
    months = (days * 100_int64 + 1522_int64) / 3044_int64
  end function approximate_months

  function int_to_str(n) result(s)
    integer, intent(in) :: n
    character(len=12) :: s
    write(s, '(I0)') n
  end function int_to_str

  function replace_first(tmpl, marker, replacement) result(res)
    character(len=*), intent(in) :: tmpl, marker, replacement
    character(len=DUR_MAX_STR_LEN) :: res
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
    type(dur_unit_forms), intent(in) :: uf
    type(dur_locale), intent(in) :: loc
    character(len=*), intent(in) :: half
    character(len=DUR_MAX_STR_LEN) :: res
    character(len=12) :: base_n
    character(len=DUR_MAX_STR_LEN) :: n_str, tmpl, result_buf
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
      ! Half-marked values use "other" plural (e.g. "1.5 hours" not "1.5 hour")
      if (len_trim(half) > 0) then
        cat = PT_OTHER
      else
        cat = loc%plural(count)
      end if
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

  function format_duration_seconds(total_secs, locale, compactness) result(res)
    integer(int64), intent(in) :: total_secs
    integer, intent(in) :: compactness
    type(dur_locale), intent(in), target :: locale
    character(len=DUR_MAX_STR_LEN) :: res
    integer :: total_minutes, remainder_seconds, total_hours, remainder_minutes
    integer :: total_days, remainder_hours, total_weeks, remainder_days
    integer :: total_months, total_years, remainder_months
    integer :: delim_len
    type(dur_unit_forms) :: second_uf, minute_uf, hour_uf, day_uf, week_uf, month_uf, year_uf
    character(len=DUR_MAX_STR_LEN) :: half_str, delim_str
    character(len=DUR_MAX_STR_LEN) :: part1, part2
    type(dur_compactness_override) :: ovr

    ! Resolve compactness overrides
    second_uf = locale%units%second
    minute_uf = locale%units%minute
    hour_uf = locale%units%hour
    day_uf = locale%units%day
    week_uf = locale%units%week
    month_uf = locale%units%month
    year_uf = locale%units%year
    half_str = locale%half
    delim_str = locale%delimiter
    delim_len = locale%delimiter_len

    if (compactness == DUR_SHORT .and. locale%has_short) then
      ovr = locale%short_override
      if (ovr%has_second) second_uf = ovr%second
      if (ovr%has_minute) minute_uf = ovr%minute
      if (ovr%has_hour) hour_uf = ovr%hour
      if (ovr%has_day) day_uf = ovr%day
      if (ovr%has_week) week_uf = ovr%week
      if (ovr%has_month) month_uf = ovr%month
      if (ovr%has_year) year_uf = ovr%year
      if (ovr%has_half) half_str = ovr%half
      if (ovr%has_delimiter) then
        delim_str = ovr%delimiter
        delim_len = ovr%delimiter_len
      end if
    else if (compactness == DUR_COMPACT .and. locale%has_compact) then
      ovr = locale%compact_override
      if (ovr%has_second) second_uf = ovr%second
      if (ovr%has_minute) minute_uf = ovr%minute
      if (ovr%has_hour) hour_uf = ovr%hour
      if (ovr%has_day) day_uf = ovr%day
      if (ovr%has_week) week_uf = ovr%week
      if (ovr%has_month) month_uf = ovr%month
      if (ovr%has_year) year_uf = ovr%year
      if (ovr%has_half) half_str = ovr%half
      if (ovr%has_delimiter) then
        delim_str = ovr%delimiter
        delim_len = ovr%delimiter_len
      end if
    end if

    res = ''
    if (approximate_months(total_secs / 86400_int64) > DUR_MAX_DURATION_MONTHS) return

    ! 0 seconds
    if (total_secs == 0) then
      res = locale%just_now
      return
    end if

    ! 1-59 seconds
    if (total_secs < 60) then
      res = resolve_unit(int(total_secs), second_uf, locale, '')
      return
    end if

    total_minutes = int(total_secs / 60_int64)
    remainder_seconds = int(mod(total_secs, 60_int64))

    ! 1-4 minutes: minutes + seconds
    if (total_minutes < 5) then
      part1 = resolve_unit(total_minutes, minute_uf, locale, '')
      if (remainder_seconds > 0) then
        part2 = resolve_unit(remainder_seconds, second_uf, locale, '')
        res = trim(part1) // delim_str(1:delim_len) // trim(part2)
      else
        res = part1
      end if
      return
    end if

    ! 5-59 minutes
    if (total_minutes < 60) then
      res = resolve_unit(total_minutes, minute_uf, locale, '')
      return
    end if

    total_hours = int(total_secs / 3600_int64)
    remainder_minutes = int(mod(total_secs, 3600_int64)) / 60

    ! 1-5 hours: hours + minutes (with half marker)
    if (total_hours <= 5) then
      if (remainder_minutes == 30) then
        res = resolve_unit(total_hours, hour_uf, locale, trim(half_str))
        return
      end if
      part1 = resolve_unit(total_hours, hour_uf, locale, '')
      if (remainder_minutes > 0) then
        part2 = resolve_unit(remainder_minutes, minute_uf, locale, '')
        res = trim(part1) // delim_str(1:delim_len) // trim(part2)
      else
        res = part1
      end if
      return
    end if

    ! 6-23 hours
    if (total_hours < 24) then
      res = resolve_unit(total_hours, hour_uf, locale, '')
      return
    end if

    total_days = int(total_secs / 86400_int64)
    remainder_hours = int(mod(total_secs, 86400_int64)) / 3600

    ! 1-2 days: days + hours (with half marker)
    if (total_days <= 2) then
      if (remainder_hours == 12) then
        res = resolve_unit(total_days, day_uf, locale, trim(half_str))
        return
      end if
      part1 = resolve_unit(total_days, day_uf, locale, '')
      if (remainder_hours > 0) then
        part2 = resolve_unit(remainder_hours, hour_uf, locale, '')
        res = trim(part1) // delim_str(1:delim_len) // trim(part2)
      else
        res = part1
      end if
      return
    end if

    ! 3-6 days
    if (total_days < 7) then
      res = resolve_unit(total_days, day_uf, locale, '')
      return
    end if

    total_weeks = total_days / 7
    remainder_days = mod(total_days, 7)

    ! 1-4 weeks (< 30 days)
    if (total_days < 30) then
      part1 = resolve_unit(total_weeks, week_uf, locale, '')
      if (remainder_days > 0) then
        part2 = resolve_unit(remainder_days, day_uf, locale, '')
        res = trim(part1) // delim_str(1:delim_len) // trim(part2)
      else
        res = part1
      end if
      return
    end if

    total_months = int(approximate_months(int(total_days, int64)))

    ! 1-11 months
    if (total_months < 12) then
      if (total_months == 0) total_months = 1
      res = resolve_unit(total_months, month_uf, locale, '')
      return
    end if

    ! 12+ months: years + months
    total_years = total_months / 12
    remainder_months = mod(total_months, 12)
    part1 = resolve_unit(total_years, year_uf, locale, '')
    if (remainder_months > 0) then
      part2 = resolve_unit(remainder_months, month_uf, locale, '')
      res = trim(part1) // delim_str(1:delim_len) // trim(part2)
    else
      res = part1
    end if
  end function format_duration_seconds

  function dur_format_duration_default(locale, compactness, seconds) result(res)
    type(dur_locale), intent(in), target :: locale
    integer, intent(in) :: compactness, seconds
    character(len=DUR_MAX_STR_LEN) :: res

    res = dur_format_duration_int64(locale, compactness, int(seconds, int64))
  end function dur_format_duration_default

  function dur_format_duration_int64(locale, compactness, seconds) result(res)
    type(dur_locale), intent(in), target :: locale
    integer, intent(in) :: compactness
    integer(int64), intent(in) :: seconds
    character(len=DUR_MAX_STR_LEN) :: res

    res = ''
    if (seconds < 0) return
    res = format_duration_seconds(seconds, locale, compactness)
  end function dur_format_duration_int64

  function dur_format_duration_iso(locale, compactness, start_str, end_str) result(res)
    type(dur_locale), intent(in), target :: locale
    integer, intent(in) :: compactness
    character(len=*), intent(in) :: start_str, end_str
    character(len=DUR_MAX_STR_LEN) :: res
    integer(int64) :: s_secs, e_secs, diff
    logical :: ok

    res = ''
    if (len_trim(start_str) == 0) return
    if (len_trim(end_str) == 0) return

    call parse_iso_datetime(start_str, s_secs, ok)
    if (.not. ok) return
    call parse_iso_datetime(end_str, e_secs, ok)
    if (.not. ok) return

    diff = abs(e_secs - s_secs)
    res = format_duration_seconds(diff, locale, compactness)
  end function dur_format_duration_iso

  function dur_format_since(locale, compactness, start_str, as_of_str) result(res)
    type(dur_locale), intent(in), target :: locale
    integer, intent(in) :: compactness
    character(len=*), intent(in) :: start_str, as_of_str
    character(len=DUR_MAX_STR_LEN) :: res
    integer(int64) :: s_secs, a_secs, diff
    logical :: ok
    character(len=DUR_MAX_STR_LEN) :: dur, ago_tmpl
    type(dur_compactness_override) :: ovr

    res = ''
    if (len_trim(start_str) == 0) return
    if (len_trim(as_of_str) == 0) return

    call parse_iso_datetime(start_str, s_secs, ok)
    if (.not. ok) return
    call parse_iso_datetime(as_of_str, a_secs, ok)
    if (.not. ok) return

    diff = a_secs - s_secs
    if (diff < 0) return

    if (diff == 0) then
      res = locale%just_now
      return
    end if

    dur = format_duration_seconds(diff, locale, compactness)
    if (len_trim(dur) == 0) return

    ago_tmpl = locale%ago
    if (compactness == DUR_SHORT .and. locale%has_short) then
      ovr = locale%short_override
      if (ovr%has_ago) ago_tmpl = ovr%ago
    else if (compactness == DUR_COMPACT .and. locale%has_compact) then
      ovr = locale%compact_override
      if (ovr%has_ago) ago_tmpl = ovr%ago
    end if

    res = replace_first(ago_tmpl, '{0}', trim(dur))
  end function dur_format_since

  function dur_format_until(locale, compactness, target_str, as_of_str) result(res)
    type(dur_locale), intent(in), target :: locale
    integer, intent(in) :: compactness
    character(len=*), intent(in) :: target_str, as_of_str
    character(len=DUR_MAX_STR_LEN) :: res
    integer(int64) :: t_secs, a_secs, diff
    logical :: ok
    character(len=DUR_MAX_STR_LEN) :: dur, future_tmpl
    type(dur_compactness_override) :: ovr

    res = ''
    if (len_trim(target_str) == 0) return
    if (len_trim(as_of_str) == 0) return

    call parse_iso_datetime(target_str, t_secs, ok)
    if (.not. ok) return
    call parse_iso_datetime(as_of_str, a_secs, ok)
    if (.not. ok) return

    diff = t_secs - a_secs
    if (diff < 0) return

    if (diff == 0) then
      res = locale%just_now
      return
    end if

    dur = format_duration_seconds(diff, locale, compactness)
    if (len_trim(dur) == 0) return

    future_tmpl = locale%in_future
    if (compactness == DUR_SHORT .and. locale%has_short) then
      ovr = locale%short_override
      if (ovr%has_in_future) future_tmpl = ovr%in_future
    else if (compactness == DUR_COMPACT .and. locale%has_compact) then
      ovr = locale%compact_override
      if (ovr%has_in_future) future_tmpl = ovr%in_future
    end if

    res = replace_first(future_tmpl, '{0}', trim(dur))
  end function dur_format_until

end module sayableduration
