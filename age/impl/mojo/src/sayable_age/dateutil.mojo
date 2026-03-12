"""Date parsing and arithmetic for sayable-age.

Mojo has no date/time standard library, so we implement date parsing
and difference calculations using integer arithmetic, following the
same approach as the C implementation.
"""


fn is_leap_year(year: Int) -> Bool:
    """Return True if year is a leap year."""
    return (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0)


fn days_in_month(year: Int, month: Int) -> Int:
    """Return the number of days in the given month of the given year."""
    if month == 2:
        if is_leap_year(year):
            return 29
        return 28
    if month == 4 or month == 6 or month == 9 or month == 11:
        return 30
    return 31


fn julian_day_number(year: Int, month: Int, day: Int) -> Int:
    """Compute Julian Day Number for day-difference arithmetic."""
    var a = (14 - month) // 12
    var y = year + 4800 - a
    var m = month + 12 * a - 3
    return day + (153 * m + 2) // 5 + 365 * y + y // 4 - y // 100 + y // 400 - 32045


@value
struct DateParts:
    """Parsed date components."""

    var year: Int
    var month: Int
    var day: Int
    var valid: Bool

    fn __init__(out self):
        self.year = 0
        self.month = 0
        self.day = 0
        self.valid = False


fn _char_to_digit(c: String) -> Int:
    """Convert a single character to its digit value, or -1 if not a digit."""
    if c == "0":
        return 0
    if c == "1":
        return 1
    if c == "2":
        return 2
    if c == "3":
        return 3
    if c == "4":
        return 4
    if c == "5":
        return 5
    if c == "6":
        return 6
    if c == "7":
        return 7
    if c == "8":
        return 8
    if c == "9":
        return 9
    return -1


fn parse_date(s: String) -> DateParts:
    """Parse a YYYY-MM-DD date string into components.

    Returns a DateParts with valid=False if the string is not a valid date.
    """
    var result = DateParts()

    if len(s) < 10:
        return result

    # Check separator positions
    if s[4] != "-" or s[7] != "-":
        return result

    # Parse year (positions 0-3)
    var year = 0
    for i in range(4):
        var d = _char_to_digit(s[i])
        if d < 0:
            return result
        year = year * 10 + d

    # Parse month (positions 5-6)
    var month = 0
    for i in range(5, 7):
        var d = _char_to_digit(s[i])
        if d < 0:
            return result
        month = month * 10 + d

    # Parse day (positions 8-9)
    var day = 0
    for i in range(8, 10):
        var d = _char_to_digit(s[i])
        if d < 0:
            return result
        day = day * 10 + d

    if year == 0 and month == 0 and day == 0:
        return result

    result.year = year
    result.month = month
    result.day = day
    result.valid = True
    return result


@value
struct ParsedAge:
    """Result of parsing age from two dates."""

    var months: Int
    var diff_days: Int
    var valid: Bool

    fn __init__(out self):
        self.months = 0
        self.diff_days = 0
        self.valid = False


alias MAX_AGE_MONTHS = 6000


fn parse_age(date_of_birth: String, as_of: String) -> ParsedAge:
    """Parse two YYYY-MM-DD strings into (calendar_months, elapsed_days).

    Returns a ParsedAge with valid=False if inputs are invalid or DOB is in the future.
    """
    var result = ParsedAge()

    if len(date_of_birth) == 0:
        return result

    var dob = parse_date(date_of_birth)
    if not dob.valid:
        return result

    if len(as_of) == 0:
        return result

    var ref = parse_date(as_of)
    if not ref.valid:
        return result

    var diff_days = julian_day_number(ref.year, ref.month, ref.day) - julian_day_number(
        dob.year, dob.month, dob.day
    )
    if diff_days < 0:
        return result

    var last_day = days_in_month(ref.year, ref.month)
    var clamped_birthday: Int
    if dob.day < last_day:
        clamped_birthday = dob.day
    else:
        clamped_birthday = last_day
    var months = (ref.year - dob.year) * 12 + (ref.month - dob.month)
    if ref.day < clamped_birthday:
        months -= 1
    if months > MAX_AGE_MONTHS:
        return result

    result.months = months
    result.diff_days = diff_days
    result.valid = True
    return result
