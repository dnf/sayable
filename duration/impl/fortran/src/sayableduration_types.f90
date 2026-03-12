module sayableduration_types
  implicit none
  private

  public :: PT_ZERO, PT_ONE, PT_TWO, PT_FEW, PT_MANY, PT_OTHER
  public :: DUR_NORMAL, DUR_SHORT, DUR_COMPACT
  public :: DUR_MAX_STR_LEN
  public :: dur_unit_forms, dur_unit_set, dur_compactness_override, dur_locale
  public :: dur_plural_fn

  integer, parameter :: PT_ZERO  = 1
  integer, parameter :: PT_ONE   = 2
  integer, parameter :: PT_TWO   = 3
  integer, parameter :: PT_FEW   = 4
  integer, parameter :: PT_MANY  = 5
  integer, parameter :: PT_OTHER = 6

  integer, parameter :: DUR_NORMAL  = 0
  integer, parameter :: DUR_SHORT   = 1
  integer, parameter :: DUR_COMPACT = 2

  integer, parameter :: DUR_MAX_STR_LEN = 256

  abstract interface
    function dur_plural_fn(n) result(cat)
      integer, intent(in) :: n
      integer :: cat
    end function dur_plural_fn
  end interface

  type :: dur_unit_forms
    logical :: has_simple = .false.
    character(len=DUR_MAX_STR_LEN) :: simple = ''
    logical :: has_form(6) = .false.
    character(len=DUR_MAX_STR_LEN) :: forms(6) = ''
  end type dur_unit_forms

  type :: dur_unit_set
    type(dur_unit_forms) :: second
    type(dur_unit_forms) :: minute
    type(dur_unit_forms) :: hour
    type(dur_unit_forms) :: day
    type(dur_unit_forms) :: week
    type(dur_unit_forms) :: month
    type(dur_unit_forms) :: year
  end type dur_unit_set

  type :: dur_compactness_override
    logical :: has_second = .false.
    type(dur_unit_forms) :: second
    logical :: has_minute = .false.
    type(dur_unit_forms) :: minute
    logical :: has_hour = .false.
    type(dur_unit_forms) :: hour
    logical :: has_day = .false.
    type(dur_unit_forms) :: day
    logical :: has_week = .false.
    type(dur_unit_forms) :: week
    logical :: has_month = .false.
    type(dur_unit_forms) :: month
    logical :: has_year = .false.
    type(dur_unit_forms) :: year
    logical :: has_half = .false.
    character(len=DUR_MAX_STR_LEN) :: half = ''
    logical :: has_delimiter = .false.
    character(len=DUR_MAX_STR_LEN) :: delimiter = ''
    integer :: delimiter_len = 0
    logical :: has_ago = .false.
    character(len=DUR_MAX_STR_LEN) :: ago = ''
    logical :: has_in_future = .false.
    character(len=DUR_MAX_STR_LEN) :: in_future = ''
  end type dur_compactness_override

  type :: dur_locale
    character(len=8) :: code = ''
    procedure(dur_plural_fn), pointer, nopass :: plural => null()
    type(dur_unit_set) :: units
    character(len=DUR_MAX_STR_LEN) :: half = ''
    character(len=DUR_MAX_STR_LEN) :: delimiter = ''
    integer :: delimiter_len = 0
    character(len=DUR_MAX_STR_LEN) :: just_now = ''
    character(len=DUR_MAX_STR_LEN) :: ago = ''
    character(len=DUR_MAX_STR_LEN) :: in_future = ''
    logical :: has_short = .false.
    type(dur_compactness_override) :: short_override
    logical :: has_compact = .false.
    type(dur_compactness_override) :: compact_override
  end type dur_locale

end module sayableduration_types
