module sayableage_types
  implicit none
  private

  public :: PT_ZERO, PT_ONE, PT_TWO, PT_FEW, PT_MANY, PT_OTHER
  public :: PT_NORMAL, PT_SHORT, PT_COMPACT
  public :: PT_MAX_STR_LEN, PT_MAX_AGE_MONTHS
  public :: pt_unit_forms, pt_unit_set, pt_stage_label, pt_stages
  public :: pt_compactness_override, pt_locale
  public :: pt_plural_fn

  integer, parameter :: PT_ZERO  = 1
  integer, parameter :: PT_ONE   = 2
  integer, parameter :: PT_TWO   = 3
  integer, parameter :: PT_FEW   = 4
  integer, parameter :: PT_MANY  = 5
  integer, parameter :: PT_OTHER = 6

  integer, parameter :: PT_NORMAL  = 0
  integer, parameter :: PT_SHORT   = 1
  integer, parameter :: PT_COMPACT = 2

  integer, parameter :: PT_MAX_STR_LEN = 256
  integer, parameter :: PT_MAX_AGE_MONTHS = 6000

  abstract interface
    function pt_plural_fn(n) result(cat)
      integer, intent(in) :: n
      integer :: cat
    end function pt_plural_fn
  end interface

  type :: pt_unit_forms
    logical :: has_simple = .false.
    character(len=PT_MAX_STR_LEN) :: simple = ''
    logical :: has_form(6) = .false.
    character(len=PT_MAX_STR_LEN) :: forms(6) = ''
  end type pt_unit_forms

  type :: pt_unit_set
    type(pt_unit_forms) :: day
    type(pt_unit_forms) :: week
    type(pt_unit_forms) :: month
    type(pt_unit_forms) :: year
  end type pt_unit_set

  type :: pt_stage_label
    character(len=PT_MAX_STR_LEN) :: label = ''
    character(len=PT_MAX_STR_LEN) :: f_label = ''
  end type pt_stage_label

  type :: pt_stages
    type(pt_stage_label) :: newborn
    type(pt_stage_label) :: infant
    type(pt_stage_label) :: toddler
    type(pt_stage_label) :: child
    type(pt_stage_label) :: teenager
    type(pt_stage_label) :: adult
  end type pt_stages

  type :: pt_compactness_override
    logical :: has_day = .false.
    type(pt_unit_forms) :: day
    logical :: has_week = .false.
    type(pt_unit_forms) :: week
    logical :: has_month = .false.
    type(pt_unit_forms) :: month
    logical :: has_year = .false.
    type(pt_unit_forms) :: year
    logical :: has_half = .false.
    character(len=PT_MAX_STR_LEN) :: half = ''
    logical :: has_delimiter = .false.
    character(len=PT_MAX_STR_LEN) :: delimiter = ''
    integer :: delimiter_len = 0
    logical :: has_just_born = .false.
    character(len=PT_MAX_STR_LEN) :: just_born = ''
  end type pt_compactness_override

  type :: pt_locale
    character(len=8) :: code = ''
    procedure(pt_plural_fn), pointer, nopass :: plural => null()
    type(pt_unit_set) :: units
    character(len=PT_MAX_STR_LEN) :: half = ''
    character(len=PT_MAX_STR_LEN) :: delimiter = ''
    integer :: delimiter_len = 0
    character(len=PT_MAX_STR_LEN) :: just_born = ''
    type(pt_stages) :: stages
    logical :: has_short = .false.
    type(pt_compactness_override) :: short_override
    logical :: has_compact = .false.
    type(pt_compactness_override) :: compact_override
  end type pt_locale

end module sayableage_types
