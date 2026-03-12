module sayableduration
  use sayableduration_types
  implicit none
  private

  character(len=*), parameter, public :: DUR_VERSION = "0.5.0"

  public :: dur_format_duration, dur_format_duration_iso, dur_format_since, dur_format_until

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

  subroutine parse_iso_datetime(s, seconds, ok)
    character(len=*), intent(in) :: s
    integer, intent(out) :: seconds
    logical, intent(out) :: ok
    integer :: slen, t_pos, i
    integer :: year, month, day, hour, minute, second
    integer :: time_start, time_end, colon1, colon2, total_days
    character(len=64) :: time_str

    ok = .false.
    seconds = 0

    slen = len_trim(s)
    if (slen == 0) return

    ! Must have 'T' for ISO datetime
    t_pos = index(s(1:slen), 'T')
    if (t_pos == 0) return
    if (t_pos < 11) return

    ! Parse date part
    if (s(5:5) /= '-' .or. s(8:8) /= '-') return
    year = 0
    do i = 1, 4
      if (s(i:i) < '0' .or. s(i:i) > '9') return
      year = year * 10 + ichar(s(i:i)) - ichar('0')
    end do
    month = 0
    do i = 6, 7
      if (s(i:i) < '0' .or. s(i:i) > '9') return
      month = month * 10 + ichar(s(i:i)) - ichar('0')
    end do
    day = 0
    do i = 9, 10
      if (s(i:i) < '0' .or. s(i:i) > '9') return
      day = day * 10 + ichar(s(i:i)) - ichar('0')
    end do

    ! Extract time part, strip timezone
    time_start = t_pos + 1
    time_str = ''
    time_end = 0
    do i = time_start, slen
      if (s(i:i) == '+' .or. s(i:i) == 'Z') exit
      time_end = time_end + 1
      time_str(time_end:time_end) = s(i:i)
    end do

    ! Parse time: HH:MM or HH:MM:SS
    colon1 = index(time_str(1:time_end), ':')
    if (colon1 == 0) return

    hour = 0
    do i = 1, colon1 - 1
      if (time_str(i:i) < '0' .or. time_str(i:i) > '9') return
      hour = hour * 10 + ichar(time_str(i:i)) - ichar('0')
    end do

    ! Find second colon for seconds
    colon2 = 0
    if (colon1 + 1 <= time_end) then
      colon2 = index(time_str(colon1 + 1:time_end), ':')
      if (colon2 > 0) colon2 = colon2 + colon1
    end if

    minute = 0
    if (colon2 > 0) then
      do i = colon1 + 1, colon2 - 1
        if (time_str(i:i) < '0' .or. time_str(i:i) > '9') return
        minute = minute * 10 + ichar(time_str(i:i)) - ichar('0')
      end do
    else
      do i = colon1 + 1, time_end
        if (time_str(i:i) < '0' .or. time_str(i:i) > '9') then
          if (time_str(i:i) == '.') exit
          return
        end if
        minute = minute * 10 + ichar(time_str(i:i)) - ichar('0')
      end do
    end if

    second = 0
    if (colon2 > 0 .and. colon2 + 1 <= time_end) then
      do i = colon2 + 1, time_end
        if (time_str(i:i) < '0' .or. time_str(i:i) > '9') then
          if (time_str(i:i) == '.') exit
          return
        end if
        second = second * 10 + ichar(time_str(i:i)) - ichar('0')
      end do
    end if

    total_days = days_since_epoch(year, month, day)
    seconds = total_days * 86400 + hour * 3600 + minute * 60 + second
    ok = .true.
  end subroutine parse_iso_datetime

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

  function format_duration_seconds(total, locale, compactness) result(res)
    integer, intent(in) :: total, compactness
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

    ! 0 seconds
    if (total == 0) then
      res = locale%just_now
      return
    end if

    ! 1-59 seconds
    if (total < 60) then
      res = resolve_unit(total, second_uf, locale, '')
      return
    end if

    total_minutes = total / 60
    remainder_seconds = mod(total, 60)

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

    total_hours = total / 3600
    remainder_minutes = mod(total, 3600) / 60

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

    total_days = total / 86400
    remainder_hours = mod(total, 86400) / 3600

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

    ! Approximate months (30.44 days average)
    total_months = nint(real(total_days) / 30.44)

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

  function dur_format_duration(locale, compactness, seconds) result(res)
    type(dur_locale), intent(in), target :: locale
    integer, intent(in) :: compactness, seconds
    character(len=DUR_MAX_STR_LEN) :: res

    res = ''
    if (seconds < 0) return
    res = format_duration_seconds(seconds, locale, compactness)
  end function dur_format_duration

  function dur_format_duration_iso(locale, compactness, start_str, end_str) result(res)
    type(dur_locale), intent(in), target :: locale
    integer, intent(in) :: compactness
    character(len=*), intent(in) :: start_str, end_str
    character(len=DUR_MAX_STR_LEN) :: res
    integer :: s_secs, e_secs, diff
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
    integer :: s_secs, a_secs, diff
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
    integer :: t_secs, a_secs, diff
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
