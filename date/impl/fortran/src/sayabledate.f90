module sayabledate
  use sayabledate_types
  implicit none
  private

  character(len=*), parameter, public :: SD_VERSION = "0.5.0"

  public :: sd_format_date, sd_format_date_with_year, sd_format_relative

contains

  subroutine parse_date(s, year, month, day, ok)
    character(len=*), intent(in) :: s
    integer, intent(out) :: year, month, day
    logical, intent(out) :: ok
    integer :: i

    ok = .false.
    year = 0
    month = 0
    day = 0

    ! YYYY-MM-DD, optionally followed by T and a time (only the date part
    ! is read).
    if (len(s) < 10) return
    if (len(s) > 10) then
      if (s(11:11) /= 'T') return
    end if

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

    if (month < 1 .or. month > 12) return
    ok = (day >= 1 .and. day <= days_in_month(year, month))
  end subroutine parse_date

  pure function days_in_month(year, month) result(days)
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
  end function days_in_month

  pure function to_jdn(year, month, day) result(jd)
    integer, intent(in) :: year, month, day
    integer :: jd, a, y, m
    a = (14 - month) / 12
    y = year + 4800 - a
    m = month + 12 * a - 3
    jd = day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045
  end function to_jdn

  pure function weekday(year, month, day) result(dow)
    integer, intent(in) :: year, month, day
    integer :: dow
    dow = mod(to_jdn(year, month, day) + 1, 7)
  end function weekday

  function int_to_str(n) result(s)
    integer, intent(in) :: n
    character(len=12) :: s
    write(s, '(I0)') n
  end function int_to_str

  function replace_first(tmpl, marker, replacement) result(res)
    character(len=*), intent(in) :: tmpl, marker, replacement
    character(len=SD_MAX_STR_LEN) :: res
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

  function format_absolute(locale, compactness, year, month, day, include_year) result(res)
    type(sd_locale), intent(in) :: locale
    integer, intent(in) :: compactness
    integer, intent(in) :: year, month, day
    logical, intent(in) :: include_year
    character(len=SD_MAX_STR_LEN) :: res
    character(len=SD_MAX_STR_LEN) :: day_fmt, exc_fmt, formatted_day
    character(len=SD_MAX_STR_LEN) :: month_name, pattern
    character(len=SD_MAX_STR_LEN) :: months_arr(12), months_in_date_arr(12)
    character(len=12) :: day_str, d_str, m_str, year_str, yy_str
    logical :: use_months_in_date
    type(sd_compactness_override) :: ovr
    logical :: has_ovr, ovr_cleared_exceptions
    integer :: num_exc
    character(len=8) :: exc_keys(SD_MAX_EXCEPTIONS)
    character(len=SD_MAX_STR_LEN) :: exc_vals(SD_MAX_EXCEPTIONS)

    ! Resolve compactness
    has_ovr = .false.
    ovr_cleared_exceptions = .false.
    if (compactness == SD_SHORT .and. locale%has_short) then
      has_ovr = .true.
      ovr = locale%short_override
    else if (compactness == SD_COMPACT .and. locale%has_compact) then
      has_ovr = .true.
      ovr = locale%compact_override
    end if

    ! Months
    months_arr = locale%months
    if (has_ovr .and. ovr%has_months) months_arr = ovr%months

    ! Months in date
    use_months_in_date = locale%has_months_in_date
    months_in_date_arr = locale%months_in_date
    if (has_ovr .and. ovr%has_months_in_date) then
      use_months_in_date = .true.
      months_in_date_arr = ovr%months_in_date
    end if

    ! Day format
    day_fmt = locale%day_format
    if (has_ovr .and. ovr%has_day_format) then
      day_fmt = ovr%day_format
      ! If override sets day_format but not day_format_exceptions, clear exceptions
      if (.not. ovr%has_day_format_exceptions) ovr_cleared_exceptions = .true.
    end if

    ! Day format exceptions
    num_exc = locale%num_exceptions
    exc_keys = locale%exception_keys
    exc_vals = locale%exception_vals
    if (has_ovr .and. ovr%has_day_format_exceptions) then
      num_exc = ovr%num_exceptions
      exc_keys = ovr%exception_keys
      exc_vals = ovr%exception_vals
    end if
    if (ovr_cleared_exceptions) num_exc = 0

    ! Date pattern
    pattern = locale%date_pattern
    if (include_year) pattern = locale%date_pattern_with_year
    if (has_ovr) then
      if (include_year .and. ovr%has_date_pattern_with_year) then
        pattern = ovr%date_pattern_with_year
      else if (.not. include_year .and. ovr%has_date_pattern) then
        pattern = ovr%date_pattern
      end if
    end if

    ! Format the day with ordinal
    day_str = int_to_str(day)
    exc_fmt = ''
    if (num_exc > 0) then
      block
        integer :: ei
        do ei = 1, num_exc
          if (trim(exc_keys(ei)) == trim(day_str)) then
            exc_fmt = exc_vals(ei)
            exit
          end if
        end do
      end block
    end if
    if (len_trim(exc_fmt) > 0) then
      formatted_day = replace_first(exc_fmt, '{n}', trim(day_str))
    else
      formatted_day = replace_first(day_fmt, '{n}', trim(day_str))
    end if

    ! Pick month name
    if (use_months_in_date) then
      month_name = months_in_date_arr(month)
    else
      month_name = months_arr(month)
    end if

    ! Build result
    res = replace_first(pattern, '{month}', trim(month_name))
    res = replace_first(res, '{day}', trim(formatted_day))

    d_str = int_to_str(day)
    res = replace_first(res, '{d}', trim(d_str))

    m_str = int_to_str(month)
    res = replace_first(res, '{m}', trim(m_str))

    if (include_year) then
      year_str = int_to_str(year)
      res = replace_first(res, '{year}', trim(year_str))
      write(yy_str, '(I2.2)') mod(year, 100)
      res = replace_first(res, '{yy}', trim(yy_str))
    end if
  end function format_absolute

  function sd_format_date(locale, compactness, date) result(res)
    type(sd_locale), intent(in) :: locale
    integer, intent(in) :: compactness
    character(len=*), intent(in) :: date
    character(len=SD_MAX_STR_LEN) :: res
    integer :: year, month, day
    logical :: ok

    res = ''
    if (len_trim(date) == 0) return

    call parse_date(date, year, month, day, ok)
    if (.not. ok) return

    res = format_absolute(locale, compactness, year, month, day, .false.)
  end function sd_format_date

  function sd_format_date_with_year(locale, compactness, date) result(res)
    type(sd_locale), intent(in) :: locale
    integer, intent(in) :: compactness
    character(len=*), intent(in) :: date
    character(len=SD_MAX_STR_LEN) :: res
    integer :: year, month, day
    logical :: ok

    res = ''
    if (len_trim(date) == 0) return

    call parse_date(date, year, month, day, ok)
    if (.not. ok) return

    res = format_absolute(locale, compactness, year, month, day, .true.)
  end function sd_format_date_with_year

  function sd_format_relative(locale, compactness, date, as_of) result(res)
    type(sd_locale), intent(in) :: locale
    integer, intent(in) :: compactness
    character(len=*), intent(in) :: date, as_of
    character(len=SD_MAX_STR_LEN) :: res
    integer :: dy, dm, dd, ay, am, ad
    integer :: date_jdn, asof_jdn, diff, dow
    logical :: ok, is_compact
    character(len=SD_MAX_STR_LEN) :: today_str, tomorrow_str, yesterday_str
    character(len=SD_MAX_STR_LEN) :: weekday_name
    type(sd_compactness_override) :: ovr
    character(len=SD_MAX_STR_LEN) :: weekdays_arr(7)

    res = ''
    if (len_trim(date) == 0) return
    if (len_trim(as_of) == 0) return

    call parse_date(date, dy, dm, dd, ok)
    if (.not. ok) return
    call parse_date(as_of, ay, am, ad, ok)
    if (.not. ok) return

    date_jdn = to_jdn(dy, dm, dd)
    asof_jdn = to_jdn(ay, am, ad)
    diff = date_jdn - asof_jdn

    is_compact = (compactness == SD_COMPACT)

    ! Resolve proximity terms with compactness
    today_str = locale%today
    tomorrow_str = locale%tomorrow
    yesterday_str = locale%yesterday
    weekdays_arr = locale%weekdays
    if (compactness == SD_SHORT .and. locale%has_short) then
      ovr = locale%short_override
      if (ovr%has_today) today_str = ovr%today
      if (ovr%has_tomorrow) tomorrow_str = ovr%tomorrow
      if (ovr%has_yesterday) yesterday_str = ovr%yesterday
      if (ovr%has_weekdays) weekdays_arr = ovr%weekdays
    else if (compactness == SD_COMPACT .and. locale%has_compact) then
      ovr = locale%compact_override
      if (ovr%has_today) today_str = ovr%today
      if (ovr%has_tomorrow) tomorrow_str = ovr%tomorrow
      if (ovr%has_yesterday) yesterday_str = ovr%yesterday
      if (ovr%has_weekdays) weekdays_arr = ovr%weekdays
    end if

    ! Today
    if (diff == 0) then
      res = today_str
      return
    end if

    ! Tomorrow
    if (diff == 1) then
      res = tomorrow_str
      return
    end if

    ! Yesterday
    if (diff == -1) then
      res = yesterday_str
      return
    end if

    ! Day after tomorrow (optional, not in compact)
    if (diff == 2 .and. len_trim(locale%day_after_tomorrow) > 0 .and. .not. is_compact) then
      res = locale%day_after_tomorrow
      return
    end if

    ! Day before yesterday (optional, not in compact)
    if (diff == -2 .and. len_trim(locale%day_before_yesterday) > 0 .and. .not. is_compact) then
      res = locale%day_before_yesterday
      return
    end if

    ! Compact: skip weekday references, go straight to calendar date
    if (is_compact) then
      res = format_absolute(locale, compactness, dy, dm, dd, (dy /= ay))
      return
    end if

    ! This weekday (+2 to +6)
    if (diff >= 2 .and. diff <= 6 .and. len_trim(locale%this_weekday) > 0) then
      dow = weekday(dy, dm, dd)
      weekday_name = weekdays_arr(dow + 1)
      res = replace_first(locale%this_weekday, '{weekday}', trim(weekday_name))
      return
    end if

    ! Last weekday (-2 to -6)
    if (diff >= -6 .and. diff <= -2 .and. len_trim(locale%last_weekday) > 0) then
      dow = weekday(dy, dm, dd)
      weekday_name = weekdays_arr(dow + 1)
      res = replace_first(locale%last_weekday, '{weekday}', trim(weekday_name))
      return
    end if

    ! Next weekday (+7 to +13)
    if (diff >= 7 .and. diff <= 13 .and. len_trim(locale%next_weekday) > 0) then
      dow = weekday(dy, dm, dd)
      weekday_name = weekdays_arr(dow + 1)
      res = replace_first(locale%next_weekday, '{weekday}', trim(weekday_name))
      return
    end if

    ! Calendar fallback
    res = format_absolute(locale, compactness, dy, dm, dd, (dy /= ay))
  end function sd_format_relative

end module sayabledate
