module sayabletime
  use sayabletime_types
  implicit none
  private

  character(len=*), parameter, public :: ST_VERSION = "0.5.0"

  public :: st_format_time

contains

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

  ! A clock time alone, or after the T of an ISO datetime whose date part
  ! is a real calendar day.
  subroutine parse_time(s, hour, minute, ok)
    character(len=*), intent(in) :: s
    integer, intent(out) :: hour, minute
    logical, intent(out) :: ok
    integer :: t_pos, second, year, month, day

    hour = 0
    minute = 0
    t_pos = index(s, 'T')
    if (t_pos == 0) then
      call parse_clock(s, hour, minute, second, ok)
      return
    end if
    call parse_calendar_date(s(1:t_pos - 1), year, month, day, ok)
    if (.not. ok) return
    call parse_clock(s(t_pos + 1:), hour, minute, second, ok)
  end subroutine parse_time

  pure function round_to_5(minute) result(rounded)
    integer, intent(in) :: minute
    integer :: rounded
    rounded = ((minute + 2) / 5) * 5
  end function round_to_5

  function int_to_str(n) result(s)
    integer, intent(in) :: n
    character(len=12) :: s
    write(s, '(I0)') n
  end function int_to_str

  function zfill2(n) result(s)
    integer, intent(in) :: n
    character(len=2) :: s
    write(s, '(I2.2)') n
  end function zfill2

  function replace_first(tmpl, marker, replacement) result(res)
    character(len=*), intent(in) :: tmpl, marker, replacement
    character(len=ST_MAX_STR_LEN) :: res
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

  function format_natural(locale, hour, minute) result(res)
    type(st_locale), intent(in) :: locale
    integer, intent(in) :: hour, minute
    character(len=ST_MAX_STR_LEN) :: res
    integer :: rounded, h, h12, next_h12, pat_idx
    character(len=ST_MAX_STR_LEN) :: h_name, next_h_name, pattern

    rounded = round_to_5(minute)
    h = hour

    if (rounded == 60) then
      rounded = 0
      h = mod(h + 1, 24)
    end if

    ! Midnight and noon
    if (rounded == 0) then
      if (h == 0) then
        res = locale%clock%midnight
        return
      end if
      if (h == 12) then
        res = locale%clock%noon
        return
      end if
    end if

    h12 = mod(h, 12)
    next_h12 = mod(h + 1, 12)

    h_name = locale%clock%hours(h12 + 1)
    next_h_name = locale%clock%hours(next_h12 + 1)

    ! Look up pattern by rounded minute (index = rounded/5 + 1)
    pat_idx = rounded / 5 + 1
    if (locale%clock%has_pattern(pat_idx)) then
      pattern = locale%clock%patterns(pat_idx)
    else
      ! Default to the 0-minute pattern
      pattern = locale%clock%patterns(1)
    end if

    res = replace_first(pattern, '{h}', trim(h_name))
    res = replace_first(res, '{next_h}', trim(next_h_name))
  end function format_natural

  function format_digital(sc, hour, minute) result(res)
    type(st_short_clock_config), intent(in) :: sc
    integer, intent(in) :: hour, minute
    character(len=ST_MAX_STR_LEN) :: res
    integer :: h12
    character(len=ST_MAX_STR_LEN) :: ampm_str

    if (sc%use24h) then
      res = replace_first(sc%format, '{h}', trim(int_to_str(hour)))
      res = replace_first(res, '{mm}', zfill2(minute))
      return
    end if

    h12 = mod(hour, 12)
    if (h12 == 0) h12 = 12

    if (sc%has_am_pm) then
      if (hour < 12) then
        ampm_str = sc%am
      else
        ampm_str = sc%pm
      end if
    else
      if (hour < 12) then
        ampm_str = 'AM'
      else
        ampm_str = 'PM'
      end if
    end if

    res = replace_first(sc%format, '{h}', trim(int_to_str(h12)))
    res = replace_first(res, '{mm}', zfill2(minute))
    res = replace_first(res, '{ampm}', trim(ampm_str))
  end function format_digital

  function st_format_time(locale, compactness, time_str) result(res)
    type(st_locale), intent(in) :: locale
    integer, intent(in) :: compactness
    character(len=*), intent(in) :: time_str
    character(len=ST_MAX_STR_LEN) :: res
    integer :: hour, minute
    logical :: ok

    res = ''
    if (len_trim(time_str) == 0) return

    call parse_time(time_str, hour, minute, ok)
    if (.not. ok) return

    ! Short or compact with digital clock
    if (compactness /= ST_NORMAL) then
      if (compactness == ST_SHORT .and. locale%has_short) then
        res = format_digital(locale%short_clock, hour, minute)
        return
      end if
      if (compactness == ST_COMPACT .and. locale%has_compact) then
        res = format_digital(locale%compact_clock, hour, minute)
        return
      end if
    end if

    res = format_natural(locale, hour, minute)
  end function st_format_time

end module sayabletime
