module sayabletime
  use sayabletime_types
  implicit none
  private

  character(len=*), parameter, public :: ST_VERSION = "0.5.0"

  public :: st_format_time

contains

  subroutine parse_time(s, hour, minute, ok)
    character(len=*), intent(in) :: s
    integer, intent(out) :: hour, minute
    logical, intent(out) :: ok
    integer :: slen, t_pos, start_pos, colon_pos, i
    character(len=64) :: time_str

    ok = .false.
    hour = 0
    minute = 0

    slen = len_trim(s)
    if (slen == 0) return

    ! Find time part (after 'T' if ISO datetime)
    t_pos = index(s(1:slen), 'T')
    if (t_pos > 0) then
      start_pos = t_pos + 1
    else
      start_pos = 1
    end if

    ! Extract time string, strip timezone
    time_str = ''
    do i = start_pos, slen
      if (s(i:i) == '+' .or. s(i:i) == 'Z') exit
      time_str(i - start_pos + 1:i - start_pos + 1) = s(i:i)
    end do

    ! Find colon
    colon_pos = index(trim(time_str), ':')
    if (colon_pos == 0) return
    if (colon_pos < 2) return

    ! Parse hour
    hour = 0
    do i = 1, colon_pos - 1
      if (time_str(i:i) < '0' .or. time_str(i:i) > '9') return
      hour = hour * 10 + ichar(time_str(i:i)) - ichar('0')
    end do

    ! Parse minute (first 2 digits after colon, ignore seconds)
    minute = 0
    do i = colon_pos + 1, min(colon_pos + 2, len_trim(time_str))
      if (time_str(i:i) < '0' .or. time_str(i:i) > '9') then
        ! Allow dot for fractional seconds
        if (time_str(i:i) == '.') exit
        return
      end if
      minute = minute * 10 + ichar(time_str(i:i)) - ichar('0')
    end do

    if (hour < 0 .or. hour > 23) return
    if (minute < 0 .or. minute > 59) return
    ok = .true.
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
