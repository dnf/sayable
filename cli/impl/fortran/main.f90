program sayable_cli
  use iso_c_binding, only: c_int
  use iso_fortran_env, only: input_unit, output_unit, error_unit
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

  ! The current request's arguments: the command line, or one REPL line.
  character(len=MAX_ARG_LEN), allocatable :: args(:)
  integer :: argc

  character(len=MAX_ARG_LEN) :: command
  character(len=MAX_ARG_LEN) :: positionals(MAX_POSITIONALS)
  integer :: pos_count
  character(len=MAX_ARG_LEN) :: locale_code
  character(len=MAX_ARG_LEN) :: as_of_str
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

  subroutine load_command_line()
    integer :: i
    argc = command_argument_count()
    if (allocated(args)) deallocate(args)
    allocate(args(max(argc, 1)))
    do i = 1, argc
      call get_command_argument(i, args(i))
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
    if (allocated(args)) deallocate(args)
    allocate(args(argc))
    field = 1
    start = 1
    do i = 1, len(line)
      if (line(i:i) == TAB) then
        args(field) = line(start:i - 1)
        field = field + 1
        start = i + 1
      end if
    end do
    args(field) = line(start:)
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

  subroutine get_today(buf)
    character(len=*), intent(out) :: buf
    integer :: values(8)
    call date_and_time(values=values)
    write(buf, '(I4.4,A,I2.2,A,I2.2)') values(1), '-', values(2), '-', values(3)
  end subroutine get_today

  function is_null_str(s) result(res)
    character(len=*), intent(in) :: s
    logical :: res
    res = (s == 'null')
  end function is_null_str

  function is_all_digits(s) result(res)
    character(len=*), intent(in) :: s
    logical :: res
    integer :: i, slen
    slen = len_trim(s)
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
    slen = len_trim(s)
    res = .false.
    if (slen < 2) return
    if (s(1:1) /= '-') return
    res = is_all_digits(s(2:slen))
  end function is_negative_integer

  function str_to_int(s) result(val)
    character(len=*), intent(in) :: s
    integer :: val
    integer :: i, slen
    logical :: neg
    val = 0
    slen = len_trim(s)
    neg = .false.
    i = 1
    if (s(1:1) == '-') then
      neg = .true.
      i = 2
    end if
    do while (i <= slen)
      val = val * 10 + ichar(s(i:i)) - ichar('0')
      i = i + 1
    end do
    if (neg) val = -val
  end function str_to_int

  subroutine parse_args(rc)
    integer, intent(out) :: rc
    integer :: i
    character(len=MAX_ARG_LEN) :: arg
    logical :: stop_opts

    rc = 0
    command = ''
    positionals = ''
    pos_count = 0
    locale_code = 'en'
    as_of_str = ''
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
        else if (arg == '-d' .or. arg == '--as-of') then
          if (i + 1 > argc) then
            call usage_error("'--as-of' requires a value", rc)
            return
          end if
          i = i + 1
          as_of_str = args(i)
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
        if (pos_count <= MAX_POSITIONALS) positionals(pos_count) = arg
      end if

      i = i + 1
    end do
  end subroutine parse_args

  subroutine cmd_age(rc)
    integer, intent(out) :: rc
    type(pt_locale), pointer :: loc
    character(len=MAX_ARG_LEN) :: dob, ref_date
    character(len=PT_MAX_STR_LEN) :: result

    rc = 0
    if (pos_count < 1) then
      call usage_error('age requires a date-of-birth argument', rc)
      return
    end if

    if (is_null_str(trim(positionals(1))) .or. len_trim(positionals(1)) == 0) then
      rc = 1
      return
    end if
    dob = positionals(1)

    loc => pt_get_locale(trim(locale_code))
    if (.not. associated(loc)) then
      call usage_error("unknown locale '" // trim(locale_code) // "'", rc)
      return
    end if

    if (has_as_of) then
      if (is_null_str(trim(as_of_str))) then
        rc = 1
        return
      end if
      ref_date = as_of_str
    else
      call get_today(ref_date)
    end if

    result = pt_format_age(loc, compactness, trim(dob), trim(ref_date))

    if (len_trim(result) == 0) then
      rc = 1
      return
    end if

    call emit(trim(result))
  end subroutine cmd_age

  subroutine cmd_stage(rc)
    integer, intent(out) :: rc
    type(pt_locale), pointer :: loc
    character(len=MAX_ARG_LEN) :: dob, ref_date
    character(len=PT_MAX_STR_LEN) :: result

    rc = 0
    if (pos_count < 1) then
      call usage_error('stage requires a date-of-birth argument', rc)
      return
    end if

    if (is_null_str(trim(positionals(1))) .or. len_trim(positionals(1)) == 0) then
      rc = 1
      return
    end if
    dob = positionals(1)

    loc => pt_get_locale(trim(locale_code))
    if (.not. associated(loc)) then
      call usage_error("unknown locale '" // trim(locale_code) // "'", rc)
      return
    end if

    if (has_as_of) then
      if (is_null_str(trim(as_of_str))) then
        rc = 1
        return
      end if
      ref_date = as_of_str
    else
      call get_today(ref_date)
    end if

    if (has_gender) then
      result = pt_format_stage(loc, trim(dob), trim(ref_date), trim(gender_str))
    else
      result = pt_format_stage(loc, trim(dob), trim(ref_date))
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
    character(len=MAX_ARG_LEN) :: date_str
    character(len=SD_MAX_STR_LEN) :: result

    rc = 0
    if (pos_count < 1) then
      call usage_error('date requires a date argument', rc)
      return
    end if

    if (is_null_str(trim(positionals(1))) .or. len_trim(positionals(1)) == 0) then
      rc = 1
      return
    end if
    date_str = positionals(1)

    loc => sd_get_locale(trim(locale_code))
    if (.not. associated(loc)) then
      call usage_error("unknown locale '" // trim(locale_code) // "'", rc)
      return
    end if

    if (with_year) then
      result = sd_format_date_with_year(loc, compactness, trim(date_str))
    else
      result = sd_format_date(loc, compactness, trim(date_str))
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
    character(len=MAX_ARG_LEN) :: date_str, ref_date
    character(len=SD_MAX_STR_LEN) :: result

    rc = 0
    if (pos_count < 1) then
      call usage_error('relative requires a date argument', rc)
      return
    end if

    if (is_null_str(trim(positionals(1))) .or. len_trim(positionals(1)) == 0) then
      rc = 1
      return
    end if
    date_str = positionals(1)

    if (.not. has_as_of) then
      call usage_error('relative requires --as-of / -d option', rc)
      return
    end if

    if (is_null_str(trim(as_of_str))) then
      rc = 1
      return
    end if
    ref_date = as_of_str

    loc => sd_get_locale(trim(locale_code))
    if (.not. associated(loc)) then
      call usage_error("unknown locale '" // trim(locale_code) // "'", rc)
      return
    end if

    result = sd_format_relative(loc, compactness, trim(date_str), trim(ref_date))

    if (len_trim(result) == 0) then
      rc = 1
      return
    end if

    call emit(trim(result))
  end subroutine cmd_relative

  subroutine cmd_time(rc)
    integer, intent(out) :: rc
    type(st_locale), pointer :: loc
    character(len=MAX_ARG_LEN) :: time_str
    character(len=ST_MAX_STR_LEN) :: result

    rc = 0
    if (pos_count < 1) then
      call usage_error('time requires a time argument', rc)
      return
    end if

    if (is_null_str(trim(positionals(1))) .or. len_trim(positionals(1)) == 0) then
      rc = 1
      return
    end if
    time_str = positionals(1)

    loc => st_get_locale(trim(locale_code))
    if (.not. associated(loc)) then
      call usage_error("unknown locale '" // trim(locale_code) // "'", rc)
      return
    end if

    result = st_format_time(loc, compactness, trim(time_str))

    if (len_trim(result) == 0) then
      rc = 1
      return
    end if

    call emit(trim(result))
  end subroutine cmd_time

  subroutine cmd_duration(rc)
    integer, intent(out) :: rc
    type(dur_locale), pointer :: loc
    character(len=MAX_ARG_LEN) :: value_str, end_str
    character(len=DUR_MAX_STR_LEN) :: result
    integer :: seconds

    rc = 0
    if (pos_count < 1) then
      call usage_error('duration requires a value argument', rc)
      return
    end if

    if (is_null_str(trim(positionals(1)))) then
      rc = 1
      return
    end if
    value_str = positionals(1)

    loc => dur_get_locale(trim(locale_code))
    if (.not. associated(loc)) then
      call usage_error("unknown locale '" // trim(locale_code) // "'", rc)
      return
    end if

    if (is_all_digits(trim(value_str))) then
      seconds = str_to_int(trim(value_str))
      result = dur_format_duration(loc, compactness, seconds)
    else if (is_negative_integer(trim(value_str))) then
      seconds = str_to_int(trim(value_str))
      result = dur_format_duration(loc, compactness, seconds)
    else
      if (pos_count < 2) then
        call usage_error('duration with timestamps requires start and end arguments', rc)
        return
      end if
      end_str = positionals(2)
      if (is_null_str(trim(end_str))) then
        rc = 1
        return
      end if
      result = dur_format_duration_iso(loc, compactness, trim(value_str), trim(end_str))
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
    character(len=MAX_ARG_LEN) :: start_str, ref_str
    character(len=DUR_MAX_STR_LEN) :: result

    rc = 0
    if (pos_count < 1) then
      call usage_error('since requires a start timestamp argument', rc)
      return
    end if

    if (is_null_str(trim(positionals(1)))) then
      rc = 1
      return
    end if
    start_str = positionals(1)

    if (.not. has_as_of) then
      call usage_error('since requires --as-of / -d option', rc)
      return
    end if

    if (is_null_str(trim(as_of_str))) then
      rc = 1
      return
    end if
    ref_str = as_of_str

    loc => dur_get_locale(trim(locale_code))
    if (.not. associated(loc)) then
      call usage_error("unknown locale '" // trim(locale_code) // "'", rc)
      return
    end if

    result = dur_format_since(loc, compactness, trim(start_str), trim(ref_str))

    if (len_trim(result) == 0) then
      rc = 1
      return
    end if

    call emit(trim(result))
  end subroutine cmd_since

  subroutine cmd_until(rc)
    integer, intent(out) :: rc
    type(dur_locale), pointer :: loc
    character(len=MAX_ARG_LEN) :: target_str, ref_str
    character(len=DUR_MAX_STR_LEN) :: result

    rc = 0
    if (pos_count < 1) then
      call usage_error('until requires a target timestamp argument', rc)
      return
    end if

    if (is_null_str(trim(positionals(1)))) then
      rc = 1
      return
    end if
    target_str = positionals(1)

    if (.not. has_as_of) then
      call usage_error('until requires --as-of / -d option', rc)
      return
    end if

    if (is_null_str(trim(as_of_str))) then
      rc = 1
      return
    end if
    ref_str = as_of_str

    loc => dur_get_locale(trim(locale_code))
    if (.not. associated(loc)) then
      call usage_error("unknown locale '" // trim(locale_code) // "'", rc)
      return
    end if

    result = dur_format_until(loc, compactness, trim(target_str), trim(ref_str))

    if (len_trim(result) == 0) then
      rc = 1
      return
    end if

    call emit(trim(result))
  end subroutine cmd_until

  subroutine cmd_locales()
    ! Sorted list of all locale codes
    character(len=8) :: codes(149)
    integer :: i

    codes(1) = 'af'
    codes(2) = 'ak'
    codes(3) = 'am'
    codes(4) = 'ar'
    codes(5) = 'az'
    codes(6) = 'bci'
    codes(7) = 'be'
    codes(8) = 'bem'
    codes(9) = 'bg'
    codes(10) = 'bi'
    codes(11) = 'bm'
    codes(12) = 'bn'
    codes(13) = 'br'
    codes(14) = 'bs'
    codes(15) = 'ca'
    codes(16) = 'ceb'
    codes(17) = 'cs'
    codes(18) = 'cy'
    codes(19) = 'da'
    codes(20) = 'de'
    codes(21) = 'din'
    codes(22) = 'dje'
    codes(23) = 'dyu'
    codes(24) = 'ee'
    codes(25) = 'el'
    codes(26) = 'en'
    codes(27) = 'es'
    codes(28) = 'et'
    codes(29) = 'eu'
    codes(30) = 'fa'
    codes(31) = 'fan'
    codes(32) = 'ff'
    codes(33) = 'fi'
    codes(34) = 'fil'
    codes(35) = 'fj'
    codes(36) = 'fon'
    codes(37) = 'fr'
    codes(38) = 'ga'
    codes(39) = 'gd'
    codes(40) = 'gl'
    codes(41) = 'gn'
    codes(42) = 'gu'
    codes(43) = 'gv'
    codes(44) = 'ha'
    codes(45) = 'he'
    codes(46) = 'hi'
    codes(47) = 'hr'
    codes(48) = 'ht'
    codes(49) = 'hu'
    codes(50) = 'hy'
    codes(51) = 'id'
    codes(52) = 'ig'
    codes(53) = 'is'
    codes(54) = 'it'
    codes(55) = 'ja'
    codes(56) = 'jv'
    codes(57) = 'ka'
    codes(58) = 'kbp'
    codes(59) = 'kk'
    codes(60) = 'km'
    codes(61) = 'kn'
    codes(62) = 'ko'
    codes(63) = 'kpe'
    codes(64) = 'ktu'
    codes(65) = 'ku'
    codes(66) = 'kw'
    codes(67) = 'ky'
    codes(68) = 'lg'
    codes(69) = 'ln'
    codes(70) = 'lo'
    codes(71) = 'lt'
    codes(72) = 'lv'
    codes(73) = 'men'
    codes(74) = 'mfe'
    codes(75) = 'mg'
    codes(76) = 'mi'
    codes(77) = 'mk'
    codes(78) = 'ml'
    codes(79) = 'mn'
    codes(80) = 'mnk'
    codes(81) = 'mos'
    codes(82) = 'mr'
    codes(83) = 'ms'
    codes(84) = 'mt'
    codes(85) = 'my'
    codes(86) = 'nb'
    codes(87) = 'nd'
    codes(88) = 'ne'
    codes(89) = 'ng'
    codes(90) = 'nl'
    codes(91) = 'nso'
    codes(92) = 'nus'
    codes(93) = 'ny'
    codes(94) = 'om'
    codes(95) = 'or'
    codes(96) = 'pa'
    codes(97) = 'pis'
    codes(98) = 'pl'
    codes(99) = 'pov'
    codes(100) = 'ps'
    codes(101) = 'pt'
    codes(102) = 'qu'
    codes(103) = 'ro'
    codes(104) = 'ru'
    codes(105) = 'rw'
    codes(106) = 'sar'
    codes(107) = 'sd'
    codes(108) = 'sg'
    codes(109) = 'shi'
    codes(110) = 'si'
    codes(111) = 'sk'
    codes(112) = 'sl'
    codes(113) = 'sn'
    codes(114) = 'snk'
    codes(115) = 'so'
    codes(116) = 'sq'
    codes(117) = 'sr'
    codes(118) = 'ss'
    codes(119) = 'st'
    codes(120) = 'su'
    codes(121) = 'suk'
    codes(122) = 'sv'
    codes(123) = 'sw'
    codes(124) = 'ta'
    codes(125) = 'te'
    codes(126) = 'tem'
    codes(127) = 'tg'
    codes(128) = 'th'
    codes(129) = 'ti'
    codes(130) = 'tig'
    codes(131) = 'tk'
    codes(132) = 'tn'
    codes(133) = 'tpi'
    codes(134) = 'tr'
    codes(135) = 'ts'
    codes(136) = 'tzm'
    codes(137) = 'uk'
    codes(138) = 'umb'
    codes(139) = 'ur'
    codes(140) = 'uz'
    codes(141) = 'vi'
    codes(142) = 'vmw'
    codes(143) = 'wo'
    codes(144) = 'xh'
    codes(145) = 'yo'
    codes(146) = 'yue'
    codes(147) = 'zdj'
    codes(148) = 'zh'
    codes(149) = 'zu'

    do i = 1, 149
      call emit(trim(codes(i)))
    end do
  end subroutine cmd_locales

end program sayable_cli
