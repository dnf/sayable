program sayable_cli
  use iso_c_binding, only: c_int
  use iso_fortran_env, only: input_unit, output_unit, error_unit, int64
  use sayableage_types
  use sayableage
  use sayableage_locales
  use sayabledate_types
  use sayabledate
  use sayabledate_locales
  use sayabletime_types
  use sayabletime
  use sayabletime_locales
  use sayableduration_types
  use sayableduration
  use sayableduration_locales
  implicit none

  character(len=*), parameter :: CLI_VERSION = '0.5.0'
  integer, parameter :: MAX_ARG_LEN = 1024
  integer, parameter :: MAX_POSITIONALS = 8
  character(len=1), parameter :: TAB = achar(9)
  character(len=1), parameter :: NEWLINE = achar(10)
  character(len=1), parameter :: CARRIAGE_RETURN = achar(13)
  ! Stands in for a locale code with trailing blanks, which Fortran's
  ! blank-padded comparison would otherwise match to a real code.
  character(len=1), parameter :: UNKNOWN_LOCALE = '?'

  ! The current request's arguments: the command line, or one REPL line.
  ! Lengths are kept separately because Fortran strings are blank-padded,
  ! and a trailing blank must make a value invalid, not vanish.
  character(len=MAX_ARG_LEN), allocatable :: args(:)
  integer, allocatable :: arg_lens(:)
  integer :: argc

  character(len=MAX_ARG_LEN) :: command
  character(len=MAX_ARG_LEN) :: positionals(MAX_POSITIONALS)
  integer :: pos_lens(MAX_POSITIONALS)
  integer :: pos_count
  character(len=MAX_ARG_LEN) :: locale_code
  character(len=MAX_ARG_LEN) :: as_of_str
  integer :: as_of_len
  character(len=MAX_ARG_LEN) :: gender_str
  integer :: compactness
  logical :: with_year
  logical :: has_as_of
  logical :: has_gender

  ! Stdout of the current request, lines joined by NEWLINE, so the REPL
  ! can answer with it on one line.
  character(len=:), allocatable :: out_text
  logical :: has_output

  integer :: exit_code

  if (is_repl_invocation()) then
    call repl()
    call exit_program(0)
  end if

  call load_command_line()
  call run(exit_code)
  if (has_output) write(output_unit, '(A)') out_text
  call exit_program(exit_code)

contains

  subroutine exit_program(code)
    integer, intent(in) :: code
    interface
      subroutine c_exit(status) bind(C, name="exit")
        import :: c_int
        integer(c_int), value :: status
      end subroutine c_exit
    end interface
    call c_exit(int(code, c_int))
  end subroutine exit_program

  function is_repl_invocation() result(res)
    logical :: res
    character(len=8) :: first
    integer :: first_len
    res = .false.
    if (command_argument_count() /= 1) return
    call get_command_argument(1, first, first_len)
    res = (first_len == len('--repl') .and. first == '--repl')
  end function is_repl_invocation

  ! Stores one argument with its exact length. An argument too long for the
  ! buffer becomes a NUL, which no parser accepts, instead of being
  ! truncated into something that might look valid.
  subroutine store_arg(i, value)
    integer, intent(in) :: i
    character(len=*), intent(in) :: value
    if (len(value) > MAX_ARG_LEN) then
      args(i) = achar(0)
      arg_lens(i) = 1
    else
      args(i) = value
      arg_lens(i) = len(value)
    end if
  end subroutine store_arg

  subroutine allocate_args(count)
    integer, intent(in) :: count
    if (allocated(args)) deallocate(args)
    if (allocated(arg_lens)) deallocate(arg_lens)
    allocate(args(max(count, 1)), arg_lens(max(count, 1)))
    arg_lens = 0
  end subroutine allocate_args

  subroutine load_command_line()
    integer :: i, arg_len
    character(len=:), allocatable :: value
    argc = command_argument_count()
    call allocate_args(argc)
    do i = 1, argc
      call get_command_argument(i, length=arg_len)
      allocate(character(len=arg_len) :: value)
      call get_command_argument(i, value)
      call store_arg(i, value)
      deallocate(value)
    end do
  end subroutine load_command_line

  ! Splits a REPL request on tabs, keeping empty fields.
  subroutine load_request(line)
    character(len=*), intent(in) :: line
    integer :: i, start, field
    argc = 1
    do i = 1, len(line)
      if (line(i:i) == TAB) argc = argc + 1
    end do
    call allocate_args(argc)
    field = 1
    start = 1
    do i = 1, len(line)
      if (line(i:i) == TAB) then
        call store_arg(field, line(start:i - 1))
        field = field + 1
        start = i + 1
      end if
    end do
    call store_arg(field, line(start:))
  end subroutine load_request

  ! Reads one stdin line of any length; returns .false. at end of input.
  function read_request_line(line) result(got_line)
    character(len=:), allocatable, intent(out) :: line
    logical :: got_line
    character(len=512) :: chunk
    integer :: ios, chunk_len

    line = ''
    got_line = .false.
    do
      read(input_unit, '(A)', advance='no', iostat=ios, size=chunk_len) chunk
      line = line // chunk(1:chunk_len)
      if (ios == 0) cycle
      if (is_iostat_eor(ios)) then
        got_line = .true.
      else
        got_line = len(line) > 0
      end if
      exit
    end do
    if (len(line) > 0) then
      if (line(len(line):len(line)) == CARRIAGE_RETURN) line = line(1:len(line) - 1)
    end if
  end function read_request_line

  subroutine repl()
    character(len=:), allocatable :: line
    integer :: rc, i

    do while (read_request_line(line))
      call load_request(line)
      call run(rc)
      do i = 1, len(out_text)
        if (out_text(i:i) == NEWLINE) out_text(i:i) = TAB
      end do
      write(output_unit, '(I0,A,A)') rc, TAB, out_text
      flush(output_unit)
    end do
  end subroutine repl

  subroutine emit(line)
    character(len=*), intent(in) :: line
    if (has_output) then
      out_text = out_text // NEWLINE // line
    else
      out_text = line
      has_output = .true.
    end if
  end subroutine emit

  subroutine usage_error(msg, rc)
    character(len=*), intent(in) :: msg
    integer, intent(out) :: rc
    write(error_unit, '(A,A)') 'error: ', msg
    write(error_unit, '(A)') "Run 'sayable help' for usage."
    rc = 2
  end subroutine usage_error

  ! Runs the request in args(1:argc); output goes to out_text.
  subroutine run(rc)
    integer, intent(out) :: rc

    out_text = ''
    has_output = .false.

    call parse_args(rc)
    if (rc /= 0) return

    select case (trim(command))
    case ('')
      call print_help()
      rc = 2
    case ('help')
      call print_help()
    case ('version')
      call emit('sayable ' // CLI_VERSION)
    case ('locales')
      call cmd_locales()
    case ('age')
      call cmd_age(rc)
    case ('stage')
      call cmd_stage(rc)
    case ('date')
      call cmd_date(rc)
    case ('relative')
      call cmd_relative(rc)
    case ('time')
      call cmd_time(rc)
    case ('duration')
      call cmd_duration(rc)
    case ('since')
      call cmd_since(rc)
    case ('until')
      call cmd_until(rc)
    case default
      call usage_error("unknown command '" // trim(command) // "'", rc)
    end select
  end subroutine run

  subroutine print_help()
    call emit('Usage: sayable <command> [arguments] [options]')
    call emit('')
    call emit('Commands:')
    call emit('  age <dob>              Format an age')
    call emit('  stage <dob>            Get developmental stage')
    call emit('  date <date>            Format a calendar date')
    call emit('  relative <date>        Format a relative date')
    call emit('  time <time>            Format a clock time')
    call emit('  duration <value> [end] Format a duration')
    call emit('  since <start>          Format elapsed time')
    call emit('  until <target>         Format remaining time')
    call emit('  locales                List available locale codes')
    call emit('  version                Show version')
    call emit('  help                   Show this help')
    call emit('')
    call emit('Options:')
    call emit('  -l, --locale <code>    Locale code (default: en)')
    call emit('  -d, --as-of <value>    Reference date/timestamp')
    call emit('      --short            Short compactness')
    call emit('      --compact          Compact compactness')
    call emit('  -g, --gender <m|f>     Gender for stage labels')
    call emit('      --with-year        Include year (date only)')
    call emit('  -h, --help             Show this help')
    call emit('  -v, --version          Show version')
  end subroutine print_help

  function today() result(buf)
    character(len=10) :: buf
    integer :: values(8)
    call date_and_time(values=values)
    write(buf, '(I4.4,A,I2.2,A,I2.2)') values(1), '-', values(2), '-', values(3)
  end function today

  ! Positional n exactly as given (trailing blanks included).
  function positional(n) result(value)
    integer, intent(in) :: n
    character(len=:), allocatable :: value
    value = positionals(n)(1:pos_lens(n))
  end function positional

  ! The --as-of value exactly as given (trailing blanks included).
  function as_of_value() result(value)
    character(len=:), allocatable :: value
    value = as_of_str(1:as_of_len)
  end function as_of_value

  function is_null_str(s) result(res)
    character(len=*), intent(in) :: s
    logical :: res
    res = (len(s) == 4 .and. s == 'null')
  end function is_null_str

  function is_all_digits(s) result(res)
    character(len=*), intent(in) :: s
    logical :: res
    integer :: i, slen
    slen = len(s)
    res = .false.
    if (slen == 0) return
    do i = 1, slen
      if (s(i:i) < '0' .or. s(i:i) > '9') return
    end do
    res = .true.
  end function is_all_digits

  function is_negative_integer(s) result(res)
    character(len=*), intent(in) :: s
    logical :: res
    integer :: slen
    slen = len(s)
    res = .false.
    if (slen < 2) return
    if (s(1:1) /= '-') return
    res = is_all_digits(s(2:slen))
  end function is_negative_integer

  ! A (possibly negative) digit string as seconds. Values with more digits
  ! than int64 holds are far beyond the 500-year ceiling, so they
  ! saturate instead of overflowing.
  function str_to_seconds(s) result(val)
    character(len=*), intent(in) :: s
    integer(int64) :: val
    integer, parameter :: MAX_EXACT_DIGITS = 18
    integer :: i, first
    logical :: neg
    neg = (s(1:1) == '-')
    first = merge(2, 1, neg)
    do while (first < len(s) .and. s(first:first) == '0')
      first = first + 1
    end do
    val = 0
    if (len(s) - first + 1 > MAX_EXACT_DIGITS) then
      val = huge(val)
    else
      do i = first, len(s)
        val = val * 10_int64 + int(ichar(s(i:i)) - ichar('0'), int64)
      end do
    end if
    if (neg) val = -val
  end function str_to_seconds

  subroutine parse_args(rc)
    integer, intent(out) :: rc
    integer :: i
    character(len=MAX_ARG_LEN) :: arg
    logical :: stop_opts

    rc = 0
    command = ''
    positionals = ''
    pos_lens = 0
    pos_count = 0
    locale_code = 'en'
    as_of_str = ''
    as_of_len = 0
    gender_str = ''
    compactness = 0
    with_year = .false.
    has_as_of = .false.
    has_gender = .false.
    stop_opts = .false.

    if (argc == 0) return

    arg = args(1)

    if (arg == '-h' .or. arg == '--help' .or. arg == 'help') then
      command = 'help'
      return
    end if
    if (arg == '-v' .or. arg == '--version' .or. arg == 'version') then
      command = 'version'
      return
    end if

    command = arg

    i = 2
    do while (i <= argc)
      arg = args(i)

      if (arg == '--' .and. .not. stop_opts) then
        stop_opts = .true.
        i = i + 1
        cycle
      end if

      if (.not. stop_opts .and. len_trim(arg) > 0 .and. arg(1:1) == '-') then
        if (arg == '-l' .or. arg == '--locale') then
          if (i + 1 > argc) then
            call usage_error("'--locale' requires a value", rc)
            return
          end if
          i = i + 1
          locale_code = args(i)
          if (arg_lens(i) /= len_trim(args(i)(1:arg_lens(i)))) locale_code = UNKNOWN_LOCALE
        else if (arg == '-d' .or. arg == '--as-of') then
          if (i + 1 > argc) then
            call usage_error("'--as-of' requires a value", rc)
            return
          end if
          i = i + 1
          as_of_str = args(i)
          as_of_len = arg_lens(i)
          has_as_of = .true.
        else if (arg == '-g' .or. arg == '--gender') then
          if (i + 1 > argc) then
            call usage_error("'--gender' requires a value", rc)
            return
          end if
          i = i + 1
          gender_str = args(i)
          has_gender = .true.
        else if (arg == '--short') then
          compactness = 1
        else if (arg == '--compact') then
          compactness = 2
        else if (arg == '--with-year') then
          with_year = .true.
        else if (arg == '-h' .or. arg == '--help') then
          command = 'help'
          return
        else if (arg == '-v' .or. arg == '--version') then
          command = 'version'
          return
        else
          call usage_error("unknown option '" // trim(arg) // "'", rc)
          return
        end if
      else
        pos_count = pos_count + 1
        if (pos_count <= MAX_POSITIONALS) then
          positionals(pos_count) = arg
          pos_lens(pos_count) = arg_lens(i)
        end if
      end if

      i = i + 1
    end do
  end subroutine parse_args

  subroutine cmd_age(rc)
    integer, intent(out) :: rc
    type(pt_locale), pointer :: loc
    character(len=:), allocatable :: dob, ref_date
    character(len=PT_MAX_STR_LEN) :: result

    rc = 0
    if (pos_count < 1) then
      call usage_error('age requires a date-of-birth argument', rc)
      return
    end if

    if (is_null_str(positional(1)) .or. pos_lens(1) == 0) then
      rc = 1
      return
    end if
    dob = positional(1)

    loc => pt_get_locale(trim(locale_code))
    if (.not. associated(loc)) then
      call usage_error("unknown locale '" // trim(locale_code) // "'", rc)
      return
    end if

    ! A null or empty as-of means today, as in the reference.
    ref_date = today()
    if (has_as_of .and. as_of_len > 0) then
      if (.not. is_null_str(as_of_value())) ref_date = as_of_value()
    end if

    result = pt_format_age(loc, compactness, dob, ref_date)

    if (len_trim(result) == 0) then
      rc = 1
      return
    end if

    call emit(trim(result))
  end subroutine cmd_age

  subroutine cmd_stage(rc)
    integer, intent(out) :: rc
    type(pt_locale), pointer :: loc
    character(len=:), allocatable :: dob, ref_date
    character(len=PT_MAX_STR_LEN) :: result

    rc = 0
    if (pos_count < 1) then
      call usage_error('stage requires a date-of-birth argument', rc)
      return
    end if

    if (is_null_str(positional(1)) .or. pos_lens(1) == 0) then
      rc = 1
      return
    end if
    dob = positional(1)

    loc => pt_get_locale(trim(locale_code))
    if (.not. associated(loc)) then
      call usage_error("unknown locale '" // trim(locale_code) // "'", rc)
      return
    end if

    ! A null or empty as-of means today, as in the reference.
    ref_date = today()
    if (has_as_of .and. as_of_len > 0) then
      if (.not. is_null_str(as_of_value())) ref_date = as_of_value()
    end if

    if (has_gender) then
      result = pt_format_stage(loc, dob, ref_date, trim(gender_str))
    else
      result = pt_format_stage(loc, dob, ref_date)
    end if

    if (len_trim(result) == 0) then
      rc = 1
      return
    end if

    call emit(trim(result))
  end subroutine cmd_stage

  subroutine cmd_date(rc)
    integer, intent(out) :: rc
    type(sd_locale), pointer :: loc
    character(len=:), allocatable :: date_str
    character(len=SD_MAX_STR_LEN) :: result

    rc = 0
    if (pos_count < 1) then
      call usage_error('date requires a date argument', rc)
      return
    end if

    if (is_null_str(positional(1)) .or. pos_lens(1) == 0) then
      rc = 1
      return
    end if
    date_str = positional(1)

    loc => sd_get_locale(trim(locale_code))
    if (.not. associated(loc)) then
      call usage_error("unknown locale '" // trim(locale_code) // "'", rc)
      return
    end if

    if (with_year) then
      result = sd_format_date_with_year(loc, compactness, date_str)
    else
      result = sd_format_date(loc, compactness, date_str)
    end if

    if (len_trim(result) == 0) then
      rc = 1
      return
    end if

    call emit(trim(result))
  end subroutine cmd_date

  subroutine cmd_relative(rc)
    integer, intent(out) :: rc
    type(sd_locale), pointer :: loc
    character(len=:), allocatable :: date_str, ref_date
    character(len=SD_MAX_STR_LEN) :: result

    rc = 0
    if (pos_count < 1) then
      call usage_error('relative requires a date argument', rc)
      return
    end if

    if (is_null_str(positional(1)) .or. pos_lens(1) == 0) then
      rc = 1
      return
    end if
    date_str = positional(1)

    if (.not. has_as_of) then
      call usage_error('relative requires --as-of / -d option', rc)
      return
    end if

    if (is_null_str(as_of_value())) then
      rc = 1
      return
    end if
    ref_date = as_of_value()

    loc => sd_get_locale(trim(locale_code))
    if (.not. associated(loc)) then
      call usage_error("unknown locale '" // trim(locale_code) // "'", rc)
      return
    end if

    result = sd_format_relative(loc, compactness, date_str, ref_date)

    if (len_trim(result) == 0) then
      rc = 1
      return
    end if

    call emit(trim(result))
  end subroutine cmd_relative

  subroutine cmd_time(rc)
    integer, intent(out) :: rc
    type(st_locale), pointer :: loc
    character(len=:), allocatable :: time_str
    character(len=ST_MAX_STR_LEN) :: result

    rc = 0
    if (pos_count < 1) then
      call usage_error('time requires a time argument', rc)
      return
    end if

    if (is_null_str(positional(1)) .or. pos_lens(1) == 0) then
      rc = 1
      return
    end if
    time_str = positional(1)

    loc => st_get_locale(trim(locale_code))
    if (.not. associated(loc)) then
      call usage_error("unknown locale '" // trim(locale_code) // "'", rc)
      return
    end if

    result = st_format_time(loc, compactness, time_str)

    if (len_trim(result) == 0) then
      rc = 1
      return
    end if

    call emit(trim(result))
  end subroutine cmd_time

  subroutine cmd_duration(rc)
    integer, intent(out) :: rc
    type(dur_locale), pointer :: loc
    character(len=:), allocatable :: value_str, end_str
    character(len=DUR_MAX_STR_LEN) :: result
    integer(int64) :: seconds

    rc = 0
    if (pos_count < 1) then
      call usage_error('duration requires a value argument', rc)
      return
    end if

    if (is_null_str(positional(1))) then
      rc = 1
      return
    end if
    value_str = positional(1)

    loc => dur_get_locale(trim(locale_code))
    if (.not. associated(loc)) then
      call usage_error("unknown locale '" // trim(locale_code) // "'", rc)
      return
    end if

    if (is_all_digits(value_str)) then
      seconds = str_to_seconds(value_str)
      result = dur_format_duration(loc, compactness, seconds)
    else if (is_negative_integer(value_str)) then
      seconds = str_to_seconds(value_str)
      result = dur_format_duration(loc, compactness, seconds)
    else
      if (pos_count < 2) then
        call usage_error('duration with timestamps requires start and end arguments', rc)
        return
      end if
      end_str = positional(2)
      if (is_null_str(end_str)) then
        rc = 1
        return
      end if
      result = dur_format_duration_iso(loc, compactness, value_str, end_str)
    end if

    if (len_trim(result) == 0) then
      rc = 1
      return
    end if

    call emit(trim(result))
  end subroutine cmd_duration

  subroutine cmd_since(rc)
    integer, intent(out) :: rc
    type(dur_locale), pointer :: loc
    character(len=:), allocatable :: start_str, ref_str
    character(len=DUR_MAX_STR_LEN) :: result

    rc = 0
    if (pos_count < 1) then
      call usage_error('since requires a start timestamp argument', rc)
      return
    end if

    if (is_null_str(positional(1))) then
      rc = 1
      return
    end if
    start_str = positional(1)

    if (.not. has_as_of) then
      call usage_error('since requires --as-of / -d option', rc)
      return
    end if

    if (is_null_str(as_of_value())) then
      rc = 1
      return
    end if
    ref_str = as_of_value()

    loc => dur_get_locale(trim(locale_code))
    if (.not. associated(loc)) then
      call usage_error("unknown locale '" // trim(locale_code) // "'", rc)
      return
    end if

    result = dur_format_since(loc, compactness, start_str, ref_str)

    if (len_trim(result) == 0) then
      rc = 1
      return
    end if

    call emit(trim(result))
  end subroutine cmd_since

  subroutine cmd_until(rc)
    integer, intent(out) :: rc
    type(dur_locale), pointer :: loc
    character(len=:), allocatable :: target_str, ref_str
    character(len=DUR_MAX_STR_LEN) :: result

    rc = 0
    if (pos_count < 1) then
      call usage_error('until requires a target timestamp argument', rc)
      return
    end if

    if (is_null_str(positional(1))) then
      rc = 1
      return
    end if
    target_str = positional(1)

    if (.not. has_as_of) then
      call usage_error('until requires --as-of / -d option', rc)
      return
    end if

    if (is_null_str(as_of_value())) then
      rc = 1
      return
    end if
    ref_str = as_of_value()

    loc => dur_get_locale(trim(locale_code))
    if (.not. associated(loc)) then
      call usage_error("unknown locale '" // trim(locale_code) // "'", rc)
      return
    end if

    result = dur_format_until(loc, compactness, target_str, ref_str)

    if (len_trim(result) == 0) then
      rc = 1
      return
    end if

    call emit(trim(result))
  end subroutine cmd_until

  subroutine cmd_locales()
    ! Sorted list of all locale codes
    integer, parameter :: LOCALE_COUNT = 168
    character(len=8) :: codes(LOCALE_COUNT)
    integer :: i

    codes(1) = 'af'
    codes(2) = 'ak'
    codes(3) = 'am'
    codes(4) = 'ar'
    codes(5) = 'ay'
    codes(6) = 'az'
    codes(7) = 'bci'
    codes(8) = 'be'
    codes(9) = 'bem'
    codes(10) = 'bg'
    codes(11) = 'bi'
    codes(12) = 'bm'
    codes(13) = 'bn'
    codes(14) = 'br'
    codes(15) = 'bs'
    codes(16) = 'ca'
    codes(17) = 'cak'
    codes(18) = 'ceb'
    codes(19) = 'cs'
    codes(20) = 'cy'
    codes(21) = 'da'
    codes(22) = 'de'
    codes(23) = 'din'
    codes(24) = 'dje'
    codes(25) = 'dv'
    codes(26) = 'dyu'
    codes(27) = 'dz'
    codes(28) = 'ee'
    codes(29) = 'el'
    codes(30) = 'en'
    codes(31) = 'es'
    codes(32) = 'et'
    codes(33) = 'eu'
    codes(34) = 'fa'
    codes(35) = 'fan'
    codes(36) = 'ff'
    codes(37) = 'fi'
    codes(38) = 'fil'
    codes(39) = 'fj'
    codes(40) = 'fon'
    codes(41) = 'fr'
    codes(42) = 'ga'
    codes(43) = 'gd'
    codes(44) = 'gl'
    codes(45) = 'gn'
    codes(46) = 'gu'
    codes(47) = 'gv'
    codes(48) = 'ha'
    codes(49) = 'he'
    codes(50) = 'hi'
    codes(51) = 'hmn'
    codes(52) = 'hr'
    codes(53) = 'ht'
    codes(54) = 'hu'
    codes(55) = 'hy'
    codes(56) = 'id'
    codes(57) = 'ig'
    codes(58) = 'is'
    codes(59) = 'it'
    codes(60) = 'ja'
    codes(61) = 'jv'
    codes(62) = 'ka'
    codes(63) = 'kbp'
    codes(64) = 'kek'
    codes(65) = 'ki'
    codes(66) = 'kk'
    codes(67) = 'kl'
    codes(68) = 'km'
    codes(69) = 'kn'
    codes(70) = 'ko'
    codes(71) = 'kpe'
    codes(72) = 'kri'
    codes(73) = 'ktu'
    codes(74) = 'ku'
    codes(75) = 'kw'
    codes(76) = 'ky'
    codes(77) = 'lb'
    codes(78) = 'lg'
    codes(79) = 'ln'
    codes(80) = 'lo'
    codes(81) = 'lt'
    codes(82) = 'luo'
    codes(83) = 'lv'
    codes(84) = 'mam'
    codes(85) = 'men'
    codes(86) = 'mfe'
    codes(87) = 'mg'
    codes(88) = 'mi'
    codes(89) = 'mk'
    codes(90) = 'ml'
    codes(91) = 'mn'
    codes(92) = 'mnk'
    codes(93) = 'mos'
    codes(94) = 'mr'
    codes(95) = 'ms'
    codes(96) = 'mt'
    codes(97) = 'my'
    codes(98) = 'nb'
    codes(99) = 'nd'
    codes(100) = 'ne'
    codes(101) = 'ng'
    codes(102) = 'nl'
    codes(103) = 'nr'
    codes(104) = 'nso'
    codes(105) = 'nus'
    codes(106) = 'ny'
    codes(107) = 'om'
    codes(108) = 'or'
    codes(109) = 'pa'
    codes(110) = 'pis'
    codes(111) = 'pl'
    codes(112) = 'pov'
    codes(113) = 'ps'
    codes(114) = 'pt'
    codes(115) = 'qu'
    codes(116) = 'quc'
    codes(117) = 'ro'
    codes(118) = 'ru'
    codes(119) = 'rw'
    codes(120) = 'sar'
    codes(121) = 'sd'
    codes(122) = 'sg'
    codes(123) = 'shi'
    codes(124) = 'shn'
    codes(125) = 'si'
    codes(126) = 'sk'
    codes(127) = 'sl'
    codes(128) = 'sn'
    codes(129) = 'snk'
    codes(130) = 'so'
    codes(131) = 'sq'
    codes(132) = 'sr'
    codes(133) = 'ss'
    codes(134) = 'st'
    codes(135) = 'su'
    codes(136) = 'suk'
    codes(137) = 'sv'
    codes(138) = 'sw'
    codes(139) = 'ta'
    codes(140) = 'te'
    codes(141) = 'tem'
    codes(142) = 'tet'
    codes(143) = 'tg'
    codes(144) = 'th'
    codes(145) = 'ti'
    codes(146) = 'tig'
    codes(147) = 'tk'
    codes(148) = 'tn'
    codes(149) = 'tpi'
    codes(150) = 'tr'
    codes(151) = 'ts'
    codes(152) = 'tum'
    codes(153) = 'tzm'
    codes(154) = 'uk'
    codes(155) = 'umb'
    codes(156) = 'ur'
    codes(157) = 'uz'
    codes(158) = 've'
    codes(159) = 'vi'
    codes(160) = 'vmw'
    codes(161) = 'wo'
    codes(162) = 'xh'
    codes(163) = 'yao'
    codes(164) = 'yo'
    codes(165) = 'yue'
    codes(166) = 'zdj'
    codes(167) = 'zh'
    codes(168) = 'zu'

    do i = 1, LOCALE_COUNT
      call emit(trim(codes(i)))
    end do
  end subroutine cmd_locales

end program sayable_cli
