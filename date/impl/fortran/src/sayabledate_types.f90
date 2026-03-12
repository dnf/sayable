module sayabledate_types
  implicit none
  private

  public :: SD_NORMAL, SD_SHORT, SD_COMPACT
  public :: SD_MAX_STR_LEN, SD_MAX_EXCEPTIONS
  public :: sd_compactness_override, sd_locale

  integer, parameter :: SD_NORMAL  = 0
  integer, parameter :: SD_SHORT   = 1
  integer, parameter :: SD_COMPACT = 2

  integer, parameter :: SD_MAX_STR_LEN = 256
  integer, parameter :: SD_MAX_EXCEPTIONS = 32

  type :: sd_compactness_override
    logical :: has_months = .false.
    character(len=SD_MAX_STR_LEN) :: months(12) = ''
    logical :: has_months_in_date = .false.
    character(len=SD_MAX_STR_LEN) :: months_in_date(12) = ''
    logical :: has_weekdays = .false.
    character(len=SD_MAX_STR_LEN) :: weekdays(7) = ''
    logical :: has_day_format = .false.
    character(len=SD_MAX_STR_LEN) :: day_format = ''
    logical :: has_day_format_exceptions = .false.
    integer :: num_exceptions = 0
    character(len=8) :: exception_keys(SD_MAX_EXCEPTIONS) = ''
    character(len=SD_MAX_STR_LEN) :: exception_vals(SD_MAX_EXCEPTIONS) = ''
    logical :: has_date_pattern = .false.
    character(len=SD_MAX_STR_LEN) :: date_pattern = ''
    logical :: has_date_pattern_with_year = .false.
    character(len=SD_MAX_STR_LEN) :: date_pattern_with_year = ''
    logical :: has_today = .false.
    character(len=SD_MAX_STR_LEN) :: today = ''
    logical :: has_tomorrow = .false.
    character(len=SD_MAX_STR_LEN) :: tomorrow = ''
    logical :: has_yesterday = .false.
    character(len=SD_MAX_STR_LEN) :: yesterday = ''
  end type sd_compactness_override

  type :: sd_locale
    character(len=8) :: code = ''
    character(len=SD_MAX_STR_LEN) :: months(12) = ''
    character(len=SD_MAX_STR_LEN) :: weekdays(7) = ''
    character(len=SD_MAX_STR_LEN) :: day_format = ''
    integer :: num_exceptions = 0
    character(len=8) :: exception_keys(SD_MAX_EXCEPTIONS) = ''
    character(len=SD_MAX_STR_LEN) :: exception_vals(SD_MAX_EXCEPTIONS) = ''
    character(len=SD_MAX_STR_LEN) :: date_pattern = ''
    character(len=SD_MAX_STR_LEN) :: date_pattern_with_year = ''
    character(len=SD_MAX_STR_LEN) :: today = ''
    character(len=SD_MAX_STR_LEN) :: tomorrow = ''
    character(len=SD_MAX_STR_LEN) :: yesterday = ''
    character(len=SD_MAX_STR_LEN) :: day_after_tomorrow = ''
    character(len=SD_MAX_STR_LEN) :: day_before_yesterday = ''
    character(len=SD_MAX_STR_LEN) :: this_weekday = ''
    character(len=SD_MAX_STR_LEN) :: next_weekday = ''
    character(len=SD_MAX_STR_LEN) :: last_weekday = ''
    logical :: has_months_in_date = .false.
    character(len=SD_MAX_STR_LEN) :: months_in_date(12) = ''
    logical :: has_short = .false.
    type(sd_compactness_override) :: short_override
    logical :: has_compact = .false.
    type(sd_compactness_override) :: compact_override
  end type sd_locale

end module sayabledate_types
