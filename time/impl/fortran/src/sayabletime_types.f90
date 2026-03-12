module sayabletime_types
  implicit none
  private

  public :: ST_NORMAL, ST_SHORT, ST_COMPACT
  public :: ST_MAX_STR_LEN, ST_NUM_PATTERNS
  public :: st_clock_config, st_short_clock_config, st_locale

  integer, parameter :: ST_NORMAL  = 0
  integer, parameter :: ST_SHORT   = 1
  integer, parameter :: ST_COMPACT = 2

  integer, parameter :: ST_MAX_STR_LEN = 256
  integer, parameter :: ST_NUM_PATTERNS = 12

  type :: st_clock_config
    character(len=ST_MAX_STR_LEN) :: hours(12) = ''
    character(len=ST_MAX_STR_LEN) :: midnight = ''
    character(len=ST_MAX_STR_LEN) :: noon = ''
    logical :: has_pattern(ST_NUM_PATTERNS) = .false.
    character(len=ST_MAX_STR_LEN) :: patterns(ST_NUM_PATTERNS) = ''
  end type st_clock_config

  type :: st_short_clock_config
    logical :: use24h = .false.
    character(len=ST_MAX_STR_LEN) :: format = ''
    logical :: has_am_pm = .false.
    character(len=ST_MAX_STR_LEN) :: am = ''
    character(len=ST_MAX_STR_LEN) :: pm = ''
  end type st_short_clock_config

  type :: st_locale
    character(len=8) :: code = ''
    type(st_clock_config) :: clock
    logical :: has_short = .false.
    type(st_short_clock_config) :: short_clock
    logical :: has_compact = .false.
    type(st_short_clock_config) :: compact_clock
  end type st_locale

end module sayabletime_types
