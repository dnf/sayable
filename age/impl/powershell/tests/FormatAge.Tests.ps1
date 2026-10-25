# All tests use explicit (dob, asOf) pairs for determinism.

BeforeAll {
    Import-Module "$PSScriptRoot/../SayableAge.psm1" -Force
}

# ================================================================
# Null / edge cases
# ================================================================
Describe 'Null / edge cases' {
    # 1.1
    It 'returns null for null input' {
        Get-SayableAge -DateOfBirth $null -AsOf '2025-06-15' | Should -BeNullOrEmpty
    }

    # 1.3
    It 'returns null for empty string' {
        Get-SayableAge -DateOfBirth '' -AsOf '2025-06-15' | Should -BeNullOrEmpty
    }

    # 1.4
    It 'returns null for future DOB' {
        Get-SayableAge -DateOfBirth '2025-07-01' -AsOf '2025-06-15' | Should -BeNullOrEmpty
    }

    # 1.5
    It 'exactly 500 years is allowed' {
        Get-SayableAge -DateOfBirth '1525-06-15' -AsOf '2025-06-15' | Should -Be '500 years'
    }

    # 1.6
    It '501 years exceeds max age' {
        Get-SayableAge -DateOfBirth '1524-06-15' -AsOf '2025-06-15' | Should -BeNullOrEmpty
    }

    # 1.7
    It '1000 years exceeds max age' {
        Get-SayableAge -DateOfBirth '1025-06-15' -AsOf '2025-06-15' | Should -BeNullOrEmpty
    }
}

# ================================================================
# Days tier: 0-6 days
# ================================================================
Describe 'Days tier (0-6 days)' {
    # 2.1
    It 'born today = Newborn' {
        Get-SayableAge -DateOfBirth '2025-06-15' -AsOf '2025-06-15' | Should -Be 'Newborn'
    }

    # 2.2
    It '1 day singular' {
        Get-SayableAge -DateOfBirth '2025-06-14' -AsOf '2025-06-15' | Should -Be '1 day'
    }

    # 2.3
    It '3 days' {
        Get-SayableAge -DateOfBirth '2025-06-12' -AsOf '2025-06-15' | Should -Be '3 days'
    }

    # 2.4
    It '6 days' {
        Get-SayableAge -DateOfBirth '2025-06-09' -AsOf '2025-06-15' | Should -Be '6 days'
    }

    # 2.5
    It '7 days becomes 1 week' {
        Get-SayableAge -DateOfBirth '2025-06-08' -AsOf '2025-06-15' | Should -Be '1 week'
    }
}

# ================================================================
# Weeks+days tier: 7 days to <3 months
# ================================================================
Describe 'Weeks+days tier (7 days to <3 months)' {
    # 3.1
    It '7 days = 1 week' {
        Get-SayableAge -DateOfBirth '2025-06-08' -AsOf '2025-06-15' | Should -Be '1 week'
    }

    # 3.2
    It '8 days = 1 week, 1 day' {
        Get-SayableAge -DateOfBirth '2025-06-07' -AsOf '2025-06-15' | Should -Be '1 week, 1 day'
    }

    # 3.3
    It '9 days = 1 week, 2 days' {
        Get-SayableAge -DateOfBirth '2025-06-06' -AsOf '2025-06-15' | Should -Be '1 week, 2 days'
    }

    # 3.4
    It '13 days = 1 week, 6 days' {
        Get-SayableAge -DateOfBirth '2025-06-02' -AsOf '2025-06-15' | Should -Be '1 week, 6 days'
    }

    # 3.5
    It '14 days = 2 weeks' {
        Get-SayableAge -DateOfBirth '2025-06-01' -AsOf '2025-06-15' | Should -Be '2 weeks'
    }

    # 3.6
    It '15 days = 2 weeks, 1 day' {
        Get-SayableAge -DateOfBirth '2025-05-31' -AsOf '2025-06-15' | Should -Be '2 weeks, 1 day'
    }

    # 3.7
    It '20 days = 2 weeks, 6 days' {
        Get-SayableAge -DateOfBirth '2025-05-26' -AsOf '2025-06-15' | Should -Be '2 weeks, 6 days'
    }

    # 3.8
    It '21 days = 3 weeks' {
        Get-SayableAge -DateOfBirth '2025-05-25' -AsOf '2025-06-15' | Should -Be '3 weeks'
    }

    # 3.9
    It '1 cal month still weeks+days' {
        Get-SayableAge -DateOfBirth '2025-05-15' -AsOf '2025-06-15' | Should -Be '4 weeks, 3 days'
    }

    # 3.10
    It '2 cal months still weeks+days' {
        Get-SayableAge -DateOfBirth '2025-04-15' -AsOf '2025-06-15' | Should -Be '8 weeks, 5 days'
    }

    # 3.11
    It 'one day before 3mo still weeks' {
        Get-SayableAge -DateOfBirth '2025-03-15' -AsOf '2025-06-14' | Should -Be '13 weeks'
    }

    # 3.12
    It 'on 3mo birthday switches to months' {
        Get-SayableAge -DateOfBirth '2025-03-15' -AsOf '2025-06-15' | Should -Be '3 months'
    }
}

# ================================================================
# Month boundaries: standard months
# ================================================================
Describe 'Month boundaries - standard months' {
    # 4.1
    It 'Jan1 to Apr1 = 3 months' {
        Get-SayableAge -DateOfBirth '2025-01-01' -AsOf '2025-04-01' | Should -Be '3 months'
    }

    # 4.2
    It 'Jan1 to Mar31 still weeks' {
        Get-SayableAge -DateOfBirth '2025-01-01' -AsOf '2025-03-31' | Should -Match 'weeks'
    }

    # 4.3
    It 'Jun15 to Sep15 = 3 months' {
        Get-SayableAge -DateOfBirth '2025-06-15' -AsOf '2025-09-15' | Should -Be '3 months'
    }

    # 4.4
    It 'Jun15 to Sep14 still weeks' {
        Get-SayableAge -DateOfBirth '2025-06-15' -AsOf '2025-09-14' | Should -Match 'weeks'
    }

    # 4.5
    It 'Jun15 to Dec15 = 6 months' {
        Get-SayableAge -DateOfBirth '2025-06-15' -AsOf '2025-12-15' | Should -Be '6 months'
    }
}

# ================================================================
# Month boundaries: February non-leap
# ================================================================
Describe 'Month boundaries - February non-leap' {
    # 5.1
    It 'Jan31 to Feb28 non-leap = 4 weeks' {
        Get-SayableAge -DateOfBirth '2025-01-31' -AsOf '2025-02-28' | Should -Be '4 weeks'
    }

    # 5.2
    It 'Jan31 to Apr30 = 3 months (clamped)' {
        Get-SayableAge -DateOfBirth '2025-01-31' -AsOf '2025-04-30' | Should -Be '3 months'
    }

    # 5.3
    It 'Jan31 to Apr29 still weeks' {
        Get-SayableAge -DateOfBirth '2025-01-31' -AsOf '2025-04-29' | Should -Match 'weeks'
    }

    # 5.4
    It 'Feb1 to May1 = 3 months' {
        Get-SayableAge -DateOfBirth '2025-02-01' -AsOf '2025-05-01' | Should -Be '3 months'
    }

    # 5.5
    It 'Feb1 to Apr30 still weeks' {
        Get-SayableAge -DateOfBirth '2025-02-01' -AsOf '2025-04-30' | Should -Match 'weeks'
    }
}

# ================================================================
# Month boundaries: February leap year
# ================================================================
Describe 'Month boundaries - February leap year' {
    # 6.1
    It 'Jan31 to Feb29 leap = 4 weeks, 1 day' {
        Get-SayableAge -DateOfBirth '2024-01-31' -AsOf '2024-02-29' | Should -Be '4 weeks, 1 day'
    }

    # 6.2
    It 'Jan31 to Feb28 leap = 4 weeks' {
        Get-SayableAge -DateOfBirth '2024-01-31' -AsOf '2024-02-28' | Should -Be '4 weeks'
    }

    # 6.3
    It 'Jan31 to Apr30 leap = 3 months' {
        Get-SayableAge -DateOfBirth '2024-01-31' -AsOf '2024-04-30' | Should -Be '3 months'
    }

    # 6.4
    It 'Jan30 to Feb29 leap still weeks' {
        Get-SayableAge -DateOfBirth '2024-01-30' -AsOf '2024-02-29' | Should -Match 'weeks'
    }

    # 6.5
    It 'Jan30 to Feb28 leap still weeks' {
        Get-SayableAge -DateOfBirth '2024-01-30' -AsOf '2024-02-28' | Should -Match 'weeks'
    }
}

# ================================================================
# Month boundaries: 30-day months
# ================================================================
Describe 'Month boundaries - 30-day months' {
    # 7.1
    It 'Mar31 to Jun30 = 3 months' {
        Get-SayableAge -DateOfBirth '2025-03-31' -AsOf '2025-06-30' | Should -Be '3 months'
    }

    # 7.2
    It 'Mar31 to Jun29 still weeks' {
        Get-SayableAge -DateOfBirth '2025-03-31' -AsOf '2025-06-29' | Should -Match 'weeks'
    }

    # 7.3
    It 'Aug31 to Nov30 = 3 months' {
        Get-SayableAge -DateOfBirth '2025-08-31' -AsOf '2025-11-30' | Should -Be '3 months'
    }

    # 7.4
    It 'Aug31 to Nov29 still weeks' {
        Get-SayableAge -DateOfBirth '2025-08-31' -AsOf '2025-11-29' | Should -Match 'weeks'
    }
}

# ================================================================
# Month boundaries: leap year baby (born Feb 29)
# ================================================================
Describe 'Month boundaries - leap year baby' {
    # 8.1
    It 'Feb29 to May29 = 3 months' {
        Get-SayableAge -DateOfBirth '2024-02-29' -AsOf '2024-05-29' | Should -Be '3 months'
    }

    # 8.2
    It 'Feb29 to May28 still weeks' {
        Get-SayableAge -DateOfBirth '2024-02-29' -AsOf '2024-05-28' | Should -Match 'weeks'
    }

    # 8.3
    It 'Feb29 2024 to Feb28 2025 = 12 months' {
        Get-SayableAge -DateOfBirth '2024-02-29' -AsOf '2025-02-28' | Should -Be '12 months'
    }

    # 8.4
    It 'Feb29 2024 to Mar1 2025 = 12 months' {
        Get-SayableAge -DateOfBirth '2024-02-29' -AsOf '2025-03-01' | Should -Be '12 months'
    }
}

# ================================================================
# Months tier: 3-23 months
# ================================================================
Describe 'Months tier (3-23 months)' {
    # 9.1
    It '3 months at transition' {
        Get-SayableAge -DateOfBirth '2025-01-15' -AsOf '2025-04-15' | Should -Be '3 months'
    }

    # 9.2
    It '6 months' {
        Get-SayableAge -DateOfBirth '2025-01-15' -AsOf '2025-07-15' | Should -Be '6 months'
    }

    # 9.3
    It '12 months not 1 year' {
        Get-SayableAge -DateOfBirth '2024-06-15' -AsOf '2025-06-15' | Should -Be '12 months'
    }

    # 9.4
    It '23 months upper boundary' {
        Get-SayableAge -DateOfBirth '2024-01-15' -AsOf '2025-12-15' | Should -Be '23 months'
    }

    # 9.5
    It 'one day before month boundary' {
        Get-SayableAge -DateOfBirth '2025-01-15' -AsOf '2025-07-14' | Should -Be '5 months'
    }

    # 9.6
    It 'crossing year boundary' {
        Get-SayableAge -DateOfBirth '2024-11-10' -AsOf '2025-04-10' | Should -Be '5 months'
    }
}

# ================================================================
# Years+months tier: 24-35 months
# ================================================================
Describe 'Years+months tier (24-35 months)' {
    # 10.1
    It '2 years at 24 months' {
        Get-SayableAge -DateOfBirth '2023-06-15' -AsOf '2025-06-15' | Should -Be '2 years'
    }

    # 10.2
    It '2 years, 1 month' {
        Get-SayableAge -DateOfBirth '2023-06-15' -AsOf '2025-07-15' | Should -Be '2 years, 1 month'
    }

    # 10.3
    It '2 years, 6 months' {
        Get-SayableAge -DateOfBirth '2023-06-15' -AsOf '2025-12-15' | Should -Be '2 years, 6 months'
    }

    # 10.4
    It '2 years, 11 months' {
        Get-SayableAge -DateOfBirth '2023-06-15' -AsOf '2026-05-15' | Should -Be '2 years, 11 months'
    }

    # 10.5
    It 'one day before 24mo stays months' {
        Get-SayableAge -DateOfBirth '2023-06-15' -AsOf '2025-06-14' | Should -Be '23 months'
    }
}

# ================================================================
# Half-year tier: 3-6 years
# ================================================================
Describe 'Half-year tier (3-6 years)' {
    # 11.1
    It '3 years exactly' {
        Get-SayableAge -DateOfBirth '2022-06-15' -AsOf '2025-06-15' | Should -Be '3 years'
    }

    # 11.2
    It '3 years 5 months = 3 years' {
        Get-SayableAge -DateOfBirth '2022-06-15' -AsOf '2025-11-15' | Should -Be '3 years'
    }

    # 11.3
    It '3 years 6 months = 3 and half years' {
        Get-SayableAge -DateOfBirth '2022-06-15' -AsOf '2025-12-15' | Should -Be "3`u{00BD} years"
    }

    # 11.4
    It '3 years 11 months = 3 and half years' {
        Get-SayableAge -DateOfBirth '2022-06-15' -AsOf '2026-05-15' | Should -Be "3`u{00BD} years"
    }

    # 11.5
    It '4 years exactly' {
        Get-SayableAge -DateOfBirth '2021-06-15' -AsOf '2025-06-15' | Should -Be '4 years'
    }

    # 11.6
    It '4 and half years' {
        Get-SayableAge -DateOfBirth '2021-06-15' -AsOf '2025-12-15' | Should -Be "4`u{00BD} years"
    }

    # 11.7
    It '5 years' {
        Get-SayableAge -DateOfBirth '2020-06-15' -AsOf '2025-06-15' | Should -Be '5 years'
    }

    # 11.8
    It '5 and half years at 5y8m' {
        Get-SayableAge -DateOfBirth '2020-06-15' -AsOf '2026-02-15' | Should -Be "5`u{00BD} years"
    }

    # 11.9
    It '6 years' {
        Get-SayableAge -DateOfBirth '2019-06-15' -AsOf '2025-06-15' | Should -Be '6 years'
    }

    # 11.10
    It '6 and half years' {
        Get-SayableAge -DateOfBirth '2019-06-15' -AsOf '2025-12-15' | Should -Be "6`u{00BD} years"
    }

    # 11.11
    It '6 and half years at 6y11m' {
        Get-SayableAge -DateOfBirth '2019-06-15' -AsOf '2026-05-15' | Should -Be "6`u{00BD} years"
    }

    # 11.12
    It 'one day before 3rd birthday = 2 years, 11 months' {
        Get-SayableAge -DateOfBirth '2022-06-15' -AsOf '2025-06-14' | Should -Be '2 years, 11 months'
    }
}

# ================================================================
# Integer tier: 7+ years
# ================================================================
Describe 'Integer tier (7+ years)' {
    # 12.1
    It '7 years exactly' {
        Get-SayableAge -DateOfBirth '2018-06-15' -AsOf '2025-06-15' | Should -Be '7 years'
    }

    # 12.2
    It '7 years 6 months no half' {
        Get-SayableAge -DateOfBirth '2018-03-20' -AsOf '2025-06-15' | Should -Be '7 years'
    }

    # 12.3
    It '45 years' {
        Get-SayableAge -DateOfBirth '1980-01-01' -AsOf '2025-06-15' | Should -Be '45 years'
    }
}

# ================================================================
# Cross-year transitions with Feb
# ================================================================
Describe 'Cross-year transitions with February' {
    # 13.1
    It 'Dec31 to Mar31 = 3 months' {
        Get-SayableAge -DateOfBirth '2024-12-31' -AsOf '2025-03-31' | Should -Be '3 months'
    }

    # 13.2
    It 'Dec31 to Mar30 still weeks' {
        Get-SayableAge -DateOfBirth '2024-12-31' -AsOf '2025-03-30' | Should -Match 'weeks'
    }

    # 13.3
    It 'Nov30 to Feb28 = 3 months' {
        Get-SayableAge -DateOfBirth '2024-11-30' -AsOf '2025-02-28' | Should -Be '3 months'
    }

    # 13.4
    It 'Nov30 to Feb27 still weeks' {
        Get-SayableAge -DateOfBirth '2024-11-30' -AsOf '2025-02-27' | Should -Match 'weeks'
    }
}

# ================================================================
# Born-on-31st progression
# ================================================================
Describe 'Born-on-31st progression' {
    # 14.1
    It 'Jan31 to Apr30 = 3 months' {
        Get-SayableAge -DateOfBirth '2025-01-31' -AsOf '2025-04-30' | Should -Be '3 months'
    }

    # 14.2
    It 'Jan31 to May31 = 4 months' {
        Get-SayableAge -DateOfBirth '2025-01-31' -AsOf '2025-05-31' | Should -Be '4 months'
    }

    # 14.3
    It 'Jan31 to Jun30 = 5 months (clamped)' {
        Get-SayableAge -DateOfBirth '2025-01-31' -AsOf '2025-06-30' | Should -Be '5 months'
    }

    # 14.4
    It 'Jan31 to Jul1 = 5 months' {
        Get-SayableAge -DateOfBirth '2025-01-31' -AsOf '2025-07-01' | Should -Be '5 months'
    }

    # 14.5
    It 'Jan31 to Jul31 = 6 months' {
        Get-SayableAge -DateOfBirth '2025-01-31' -AsOf '2025-07-31' | Should -Be '6 months'
    }
}

# ================================================================
# formatStage
# ================================================================
Describe 'formatStage - null / edge cases' {
    # 16.1
    It 'returns null for null' {
        Get-SayableAgeStage -DateOfBirth $null -AsOf '2025-06-15' | Should -BeNullOrEmpty
    }

    # 16.3
    It 'returns null for empty' {
        Get-SayableAgeStage -DateOfBirth '' -AsOf '2025-06-15' | Should -BeNullOrEmpty
    }

    # 16.4
    It 'returns null for future' {
        Get-SayableAgeStage -DateOfBirth '2025-07-01' -AsOf '2025-06-15' | Should -BeNullOrEmpty
    }

    # 16.5
    It 'exactly 500 years returns Adult' {
        Get-SayableAgeStage -DateOfBirth '1525-06-15' -AsOf '2025-06-15' | Should -Be 'Adult'
    }

    # 16.6
    It '501 years exceeds max age' {
        Get-SayableAgeStage -DateOfBirth '1524-06-15' -AsOf '2025-06-15' | Should -BeNullOrEmpty
    }
}

Describe 'formatStage - Newborn (0-1 months)' {
    # 17.1
    It 'born today = Newborn' {
        Get-SayableAgeStage -DateOfBirth '2025-06-15' -AsOf '2025-06-15' | Should -Be 'Newborn'
    }

    # 17.2
    It '1 day = Newborn' {
        Get-SayableAgeStage -DateOfBirth '2025-06-14' -AsOf '2025-06-15' | Should -Be 'Newborn'
    }

    # 17.3
    It '3 weeks = Newborn' {
        Get-SayableAgeStage -DateOfBirth '2025-05-25' -AsOf '2025-06-15' | Should -Be 'Newborn'
    }

    # 17.4
    It '1 month = Newborn' {
        Get-SayableAgeStage -DateOfBirth '2025-05-15' -AsOf '2025-06-15' | Should -Be 'Newborn'
    }

    # 17.5
    It '1 month 29 days = Newborn' {
        Get-SayableAgeStage -DateOfBirth '2025-04-16' -AsOf '2025-06-15' | Should -Be 'Newborn'
    }

    # 17.6
    It 'exactly 2 months = Infant' {
        Get-SayableAgeStage -DateOfBirth '2025-04-15' -AsOf '2025-06-15' | Should -Be 'Infant'
    }
}

Describe 'formatStage - Infant (2-11 months)' {
    # 18.1
    It '2 months = Infant' {
        Get-SayableAgeStage -DateOfBirth '2025-04-15' -AsOf '2025-06-15' | Should -Be 'Infant'
    }

    # 18.2
    It '6 months = Infant' {
        Get-SayableAgeStage -DateOfBirth '2024-12-15' -AsOf '2025-06-15' | Should -Be 'Infant'
    }

    # 18.3
    It '11 months = Infant' {
        Get-SayableAgeStage -DateOfBirth '2024-07-15' -AsOf '2025-06-15' | Should -Be 'Infant'
    }

    # 18.4
    It '12 months = Toddler' {
        Get-SayableAgeStage -DateOfBirth '2024-06-15' -AsOf '2025-06-15' | Should -Be 'Toddler'
    }
}

Describe 'formatStage - Toddler (12-35 months)' {
    # 19.1
    It '12 months = Toddler' {
        Get-SayableAgeStage -DateOfBirth '2024-06-15' -AsOf '2025-06-15' | Should -Be 'Toddler'
    }

    # 19.2
    It '18 months = Toddler' {
        Get-SayableAgeStage -DateOfBirth '2024-01-15' -AsOf '2025-07-15' | Should -Be 'Toddler'
    }

    # 19.3
    It '24 months = Toddler' {
        Get-SayableAgeStage -DateOfBirth '2023-06-15' -AsOf '2025-06-15' | Should -Be 'Toddler'
    }

    # 19.4
    It '35 months = Toddler' {
        Get-SayableAgeStage -DateOfBirth '2023-06-15' -AsOf '2026-05-15' | Should -Be 'Toddler'
    }

    # 19.5
    It '36 months = Child' {
        Get-SayableAgeStage -DateOfBirth '2022-06-15' -AsOf '2025-06-15' | Should -Be 'Child'
    }
}

Describe 'formatStage - Child (36-155 months)' {
    # 20.1
    It '3 years = Child' {
        Get-SayableAgeStage -DateOfBirth '2022-06-15' -AsOf '2025-06-15' | Should -Be 'Child'
    }

    # 20.2
    It '4 years = Child' {
        Get-SayableAgeStage -DateOfBirth '2021-06-15' -AsOf '2025-06-15' | Should -Be 'Child'
    }

    # 20.3
    It '6 years = Child' {
        Get-SayableAgeStage -DateOfBirth '2019-06-15' -AsOf '2025-06-15' | Should -Be 'Child'
    }

    # 20.4
    It '9 years = Child' {
        Get-SayableAgeStage -DateOfBirth '2016-06-15' -AsOf '2025-06-15' | Should -Be 'Child'
    }

    # 20.5
    It '12 years 11 months = Child' {
        Get-SayableAgeStage -DateOfBirth '2013-06-15' -AsOf '2026-05-15' | Should -Be 'Child'
    }

    # 20.6
    It '13 years = Teenager' {
        Get-SayableAgeStage -DateOfBirth '2012-06-15' -AsOf '2025-06-15' | Should -Be 'Teenager'
    }
}

Describe 'formatStage - Teenager (156-215 months)' {
    # 21.1
    It '13 years = Teenager' {
        Get-SayableAgeStage -DateOfBirth '2012-06-15' -AsOf '2025-06-15' | Should -Be 'Teenager'
    }

    # 21.2
    It '15 years = Teenager' {
        Get-SayableAgeStage -DateOfBirth '2010-06-15' -AsOf '2025-06-15' | Should -Be 'Teenager'
    }

    # 21.3
    It '17 years 11 months = Teenager' {
        Get-SayableAgeStage -DateOfBirth '2008-06-15' -AsOf '2026-05-15' | Should -Be 'Teenager'
    }

    # 21.4
    It '18 years = Adult' {
        Get-SayableAgeStage -DateOfBirth '2007-06-15' -AsOf '2025-06-15' | Should -Be 'Adult'
    }
}

Describe 'formatStage - Adult (216+ months)' {
    # 22.1
    It '18 years = Adult' {
        Get-SayableAgeStage -DateOfBirth '2007-06-15' -AsOf '2025-06-15' | Should -Be 'Adult'
    }

    # 22.2
    It '25 years = Adult' {
        Get-SayableAgeStage -DateOfBirth '2000-06-15' -AsOf '2025-06-15' | Should -Be 'Adult'
    }

    # 22.3
    It '45 years = Adult' {
        Get-SayableAgeStage -DateOfBirth '1980-01-01' -AsOf '2025-06-15' | Should -Be 'Adult'
    }
}

# ================================================================
# SayableAge class — English locale delegation
# ================================================================
Describe 'Formatter class - English locale' {
    BeforeAll {
        $enLocale = Get-SayableAgeLocale -Code 'en'
        $fmt = New-SayableAgeFormatter -Locale $enLocale
    }

    # 24.1, 24.2, 24.3, 24.4, 24.5, 24.6, 24.7
    It 'format_age: Newborn' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-06-15' -AsOf '2025-06-15' | Should -Be 'Newborn'
    }
    It 'format_age: 3 days' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-06-12' -AsOf '2025-06-15' | Should -Be '3 days'
    }
    It 'format_age: 1 week, 1 day' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-06-07' -AsOf '2025-06-15' | Should -Be '1 week, 1 day'
    }
    It 'format_age: 6 months' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-01-15' -AsOf '2025-07-15' | Should -Be '6 months'
    }
    It 'format_age: 2 years, 1 month' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '2023-06-15' -AsOf '2025-07-15' | Should -Be '2 years, 1 month'
    }
    It 'format_age: 3 and half years' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '2022-06-15' -AsOf '2025-12-15' | Should -Be "3`u{00BD} years"
    }
    It 'format_age: 7 years' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '2018-06-15' -AsOf '2025-06-15' | Should -Be '7 years'
    }

    # 24.8, 24.9, 24.10, 24.11, 24.12, 24.13
    It 'format_stage: Newborn' {
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2025-06-15' -AsOf '2025-06-15' | Should -Be 'Newborn'
    }
    It 'format_stage: Infant' {
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2025-01-15' -AsOf '2025-06-15' | Should -Be 'Infant'
    }
    It 'format_stage: Toddler' {
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2024-06-15' -AsOf '2025-06-15' | Should -Be 'Toddler'
    }
    It 'format_stage: Child' {
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2022-06-15' -AsOf '2025-06-15' | Should -Be 'Child'
    }
    It 'format_stage: Teenager' {
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2012-06-15' -AsOf '2025-06-15' | Should -Be 'Teenager'
    }
    It 'format_stage: Adult' {
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2007-06-15' -AsOf '2025-06-15' | Should -Be 'Adult'
    }

    # 24.14, 24.15
    It 'null handling: format_age null' {
        Format-SayableAge -Formatter $fmt -DateOfBirth $null -AsOf '2025-06-15' | Should -BeNullOrEmpty
    }
    It 'null handling: format_stage null' {
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth $null -AsOf '2025-06-15' | Should -BeNullOrEmpty
    }
    It 'null handling: format_age empty' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '' -AsOf '2025-06-15' | Should -BeNullOrEmpty
    }
}

# ================================================================
# i18n — Spanish-like locale
# ================================================================
Describe 'i18n - Spanish locale' {
    BeforeAll {
        $esLocale = Get-SayableAgeLocale -Code 'es'
        $fmt = New-SayableAgeFormatter -Locale $esLocale
    }

    # 25.1, 25.2, 25.3, 25.4, 25.5, 25.6, 25.7, 25.8, 25.9, 25.10, 25.11, 25.12
    It 'justBorn' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-06-15' -AsOf '2025-06-15' | Should -Be 'Recién nacido'
    }
    It '1 day singular' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-06-14' -AsOf '2025-06-15' | Should -Be "1 d`u{00ED}a"
    }
    It '3 days plural' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-06-12' -AsOf '2025-06-15' | Should -Be "3 d`u{00ED}as"
    }
    It '1 week singular' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-06-08' -AsOf '2025-06-15' | Should -Be '1 semana'
    }
    It '1 week, 1 day compound' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-06-07' -AsOf '2025-06-15' | Should -Be "1 semana, 1 d`u{00ED}a"
    }
    It '2 weeks, 6 days compound' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-05-26' -AsOf '2025-06-15' | Should -Be "2 semanas, 6 d`u{00ED}as"
    }
    It '6 months' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-01-15' -AsOf '2025-07-15' | Should -Be '6 meses'
    }
    It '2 years, 1 month' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '2023-06-15' -AsOf '2025-07-15' | Should -Be "2 a`u{00F1}os, 1 mes"
    }
    It '2 years, 6 months' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '2023-06-15' -AsOf '2025-12-15' | Should -Be "2 a`u{00F1}os, 6 meses"
    }
    It '3 and half years' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '2022-06-15' -AsOf '2025-12-15' | Should -Be "3 y medio a`u{00F1}os"
    }
    It '3 years no half' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '2022-06-15' -AsOf '2025-06-15' | Should -Be "3 a`u{00F1}os"
    }
    It '7 years' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '2018-06-15' -AsOf '2025-06-15' | Should -Be "7 a`u{00F1}os"
    }

    # 25.13, 25.14, 25.15, 25.16, 25.17, 25.18
    It 'stage: Newborn' {
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2025-06-15' -AsOf '2025-06-15' | Should -Be 'Recién nacido'
    }
    It 'stage: Infant' {
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2025-01-15' -AsOf '2025-06-15' | Should -Be "Beb`u{00E9}"
    }
    It 'stage: Toddler' {
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2024-06-15' -AsOf '2025-06-15' | Should -Be "Ni`u{00F1}o peque`u{00F1}o"
    }
    It 'stage: Child' {
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2022-06-15' -AsOf '2025-06-15' | Should -Be "Ni`u{00F1}o"
    }
    It 'stage: Teenager' {
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2012-06-15' -AsOf '2025-06-15' | Should -Be 'Adolescente'
    }
    It 'stage: Adult' {
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2007-06-15' -AsOf '2025-06-15' | Should -Be 'Adulto'
    }

    # 25.19, 25.20
    It 'null handling: format_age null' {
        Format-SayableAge -Formatter $fmt -DateOfBirth $null -AsOf '2025-06-15' | Should -BeNullOrEmpty
    }
    It 'null handling: format_stage null' {
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth $null -AsOf '2025-06-15' | Should -BeNullOrEmpty
    }
}

# ================================================================
# Compactness — short
# ================================================================
Describe 'Compactness - short' {
    BeforeAll {
        $enLocale = Get-SayableAgeLocale -Code 'en'
        $fmt = New-SayableAgeFormatter -Locale $enLocale -Compactness 'short'
    }

    # 26.1
    It '3 d' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-06-12' -AsOf '2025-06-15' | Should -Be '3 d'
    }

    # 26.2
    It '1 wk' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-06-08' -AsOf '2025-06-15' | Should -Be '1 wk'
    }

    # 26.3
    It '1 wk, 1 d' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-06-07' -AsOf '2025-06-15' | Should -Be '1 wk, 1 d'
    }

    # 26.4
    It '6 mo' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-01-15' -AsOf '2025-07-15' | Should -Be '6 mo'
    }

    # 26.5
    It '2 yr, 1 mo' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '2023-06-15' -AsOf '2025-07-15' | Should -Be '2 yr, 1 mo'
    }

    # 26.6
    It '3 and half yr' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '2022-06-15' -AsOf '2025-12-15' | Should -Be "3`u{00BD} yr"
    }

    # 26.7
    It '7 yr' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '2018-06-15' -AsOf '2025-06-15' | Should -Be '7 yr'
    }

    # 26.8
    It 'justBorn unchanged' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-06-15' -AsOf '2025-06-15' | Should -Be 'Newborn'
    }

    # 26.9
    It 'stages unchanged' {
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2025-01-15' -AsOf '2025-06-15' | Should -Be 'Infant'
    }
}

# ================================================================
# Compactness — compact
# ================================================================
Describe 'Compactness - compact' {
    BeforeAll {
        $enLocale = Get-SayableAgeLocale -Code 'en'
        $fmt = New-SayableAgeFormatter -Locale $enLocale -Compactness 'compact'
    }

    # 27.1
    It '3d' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-06-12' -AsOf '2025-06-15' | Should -Be '3d'
    }

    # 27.2
    It '1w' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-06-08' -AsOf '2025-06-15' | Should -Be '1w'
    }

    # 27.3
    It '1w1d no delimiter' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-06-07' -AsOf '2025-06-15' | Should -Be '1w1d'
    }

    # 27.4
    It '6m' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-01-15' -AsOf '2025-07-15' | Should -Be '6m'
    }

    # 27.5
    It '2y1m no delimiter' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '2023-06-15' -AsOf '2025-07-15' | Should -Be '2y1m'
    }

    # 27.6
    It '3 and half y' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '2022-06-15' -AsOf '2025-12-15' | Should -Be "3`u{00BD}y"
    }

    # 27.7
    It '7y' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '2018-06-15' -AsOf '2025-06-15' | Should -Be '7y'
    }

    # 27.8
    It 'justBorn unchanged' {
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-06-15' -AsOf '2025-06-15' | Should -Be 'Newborn'
    }
}

# ================================================================
# Gender support for format_stage
# ================================================================
Describe 'Gender support' {
    It 'English stages ignore gender' {
        $enLocale = Get-SayableAgeLocale -Code 'en'
        $fmt = New-SayableAgeFormatter -Locale $enLocale
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2025-06-15' -AsOf '2025-06-15' -Gender 'm' | Should -Be 'Newborn'
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2025-06-15' -AsOf '2025-06-15' -Gender 'f' | Should -Be 'Newborn'
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2025-06-15' -AsOf '2025-06-15' | Should -Be 'Newborn'
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2007-06-15' -AsOf '2025-06-15' -Gender 'f' | Should -Be 'Adult'
    }

    It 'Spanish gendered stages' {
        $esLocale = Get-SayableAgeLocale -Code 'es'
        $fmt = New-SayableAgeFormatter -Locale $esLocale
        # Gendered: defaults to masculine
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2025-06-15' -AsOf '2025-06-15' | Should -Be 'Recién nacido'
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2025-06-15' -AsOf '2025-06-15' -Gender 'm' | Should -Be 'Recién nacido'
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2025-06-15' -AsOf '2025-06-15' -Gender 'f' | Should -Be 'Recién nacida'
        # Neutral stays the same
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2025-01-15' -AsOf '2025-06-15' -Gender 'f' | Should -Be "Beb`u{00E9}"
        # Toddler gendered
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2024-06-15' -AsOf '2025-06-15' -Gender 'm' | Should -Be "Ni`u{00F1}o peque`u{00F1}o"
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2024-06-15' -AsOf '2025-06-15' -Gender 'f' | Should -Be "Ni`u{00F1}a peque`u{00F1}a"
        # Adult gendered
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2007-06-15' -AsOf '2025-06-15' -Gender 'm' | Should -Be 'Adulto'
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2007-06-15' -AsOf '2025-06-15' -Gender 'f' | Should -Be 'Adulta'
    }

    It 'German adult gendered' {
        $deLocale = Get-SayableAgeLocale -Code 'de'
        $fmt = New-SayableAgeFormatter -Locale $deLocale
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2007-06-15' -AsOf '2025-06-15' -Gender 'm' | Should -Be 'Erwachsener'
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2007-06-15' -AsOf '2025-06-15' -Gender 'f' | Should -Be 'Erwachsene'
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2007-06-15' -AsOf '2025-06-15' | Should -Be 'Erwachsener'
    }

    It 'French gendered stages' {
        $frLocale = Get-SayableAgeLocale -Code 'fr'
        $fmt = New-SayableAgeFormatter -Locale $frLocale
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2025-06-15' -AsOf '2025-06-15' -Gender 'm' | Should -Be "Nouveau-n`u{00E9}"
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2025-06-15' -AsOf '2025-06-15' -Gender 'f' | Should -Be "Nouveau-n`u{00E9}e"
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2024-06-15' -AsOf '2025-06-15' | Should -Be 'Tout-petit'
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2012-06-15' -AsOf '2025-06-15' -Gender 'm' | Should -Be 'Adolescent'
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2012-06-15' -AsOf '2025-06-15' -Gender 'f' | Should -Be 'Adolescente'
    }
}

# ================================================================
# Section 29: Locale-specific edge cases
# ================================================================
Describe 'Locale-specific edge cases' {
    # Hebrew
    It '29.1 he justBorn' {
        $loc = Get-SayableAgeLocale -Code 'he'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-06-15' -AsOf '2025-06-15' | Should -Be 'רק נולד'
    }
    It '29.2 he one day' {
        $loc = Get-SayableAgeLocale -Code 'he'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-06-14' -AsOf '2025-06-15' | Should -Be 'יום 1'
    }
    It '29.3 he three days' {
        $loc = Get-SayableAgeLocale -Code 'he'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-06-12' -AsOf '2025-06-15' | Should -Be '3 ימים'
    }
    It '29.4 he two weeks dual' {
        $loc = Get-SayableAgeLocale -Code 'he'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-06-01' -AsOf '2025-06-15' | Should -Be 'שבועיים'
    }
    It '29.5 he three weeks' {
        $loc = Get-SayableAgeLocale -Code 'he'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-05-25' -AsOf '2025-06-15' | Should -Be '3 שבועות'
    }
    It '29.6 he six months' {
        $loc = Get-SayableAgeLocale -Code 'he'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-01-15' -AsOf '2025-07-15' | Should -Be '6 חודשים'
    }
    It '29.7 he three months' {
        $loc = Get-SayableAgeLocale -Code 'he'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-03-15' -AsOf '2025-06-15' | Should -Be '3 חודשים'
    }
    It '29.8 he two years dual + one month' {
        $loc = Get-SayableAgeLocale -Code 'he'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAge -Formatter $fmt -DateOfBirth '2023-06-15' -AsOf '2025-07-15' | Should -Be 'שנתיים, חודש 1'
    }
    It '29.9 he half years' {
        $loc = Get-SayableAgeLocale -Code 'he'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAge -Formatter $fmt -DateOfBirth '2022-06-15' -AsOf '2025-12-15' | Should -Be '3 שנים וחצי'
    }
    It '29.10 he seven years' {
        $loc = Get-SayableAgeLocale -Code 'he'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAge -Formatter $fmt -DateOfBirth '2018-06-15' -AsOf '2025-06-15' | Should -Be '7 שנים'
    }
    It '29.11 he stage masculine newborn' {
        $loc = Get-SayableAgeLocale -Code 'he'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2025-06-15' -AsOf '2025-06-15' -Gender 'm' | Should -Be 'רק נולד'
    }
    It '29.12 he stage feminine newborn' {
        $loc = Get-SayableAgeLocale -Code 'he'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2025-06-15' -AsOf '2025-06-15' -Gender 'f' | Should -Be 'רק נולדה'
    }
    It '29.13 he stage masculine adult' {
        $loc = Get-SayableAgeLocale -Code 'he'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2007-06-15' -AsOf '2025-06-15' -Gender 'm' | Should -Be 'מבוגר'
    }
    It '29.14 he stage feminine adult' {
        $loc = Get-SayableAgeLocale -Code 'he'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2007-06-15' -AsOf '2025-06-15' -Gender 'f' | Should -Be 'מבוגרת'
    }

    # Macedonian
    # 29.15
    It '29.15 mk justBorn' {
        $loc = Get-SayableAgeLocale -Code 'mk'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-06-15' -AsOf '2025-06-15' | Should -Be 'Новороденче'
    }
    # 29.16
    It '29.16 mk one day' {
        $loc = Get-SayableAgeLocale -Code 'mk'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-06-14' -AsOf '2025-06-15' | Should -Be '1 ден'
    }
    # 29.17
    It '29.17 mk three days' {
        $loc = Get-SayableAgeLocale -Code 'mk'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-06-12' -AsOf '2025-06-15' | Should -Be '3 дена'
    }
    # 29.18
    It '29.18 mk six months' {
        $loc = Get-SayableAgeLocale -Code 'mk'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-01-15' -AsOf '2025-07-15' | Should -Be '6 месеци'
    }
    # 29.19
    It '29.19 mk two years one month' {
        $loc = Get-SayableAgeLocale -Code 'mk'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAge -Formatter $fmt -DateOfBirth '2023-06-15' -AsOf '2025-07-15' | Should -Be '2 години, 1 месец'
    }
    # 29.20
    It '29.20 mk half years' {
        $loc = Get-SayableAgeLocale -Code 'mk'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAge -Formatter $fmt -DateOfBirth '2022-06-15' -AsOf '2025-12-15' | Should -Be '3 години и пол'
    }
    # 29.21
    It '29.21 mk seven years' {
        $loc = Get-SayableAgeLocale -Code 'mk'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAge -Formatter $fmt -DateOfBirth '2018-06-15' -AsOf '2025-06-15' | Should -Be '7 години'
    }

    # Swahili
    # 29.22
    It '29.22 sw justBorn' {
        $loc = Get-SayableAgeLocale -Code 'sw'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-06-15' -AsOf '2025-06-15' | Should -Be 'Mzaliwa mpya'
    }
    # 29.23
    It '29.23 sw one day' {
        $loc = Get-SayableAgeLocale -Code 'sw'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-06-14' -AsOf '2025-06-15' | Should -Be 'siku 1'
    }
    # 29.24
    It '29.24 sw three days' {
        $loc = Get-SayableAgeLocale -Code 'sw'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-06-12' -AsOf '2025-06-15' | Should -Be 'siku 3'
    }
    # 29.25
    It '29.25 sw six months' {
        $loc = Get-SayableAgeLocale -Code 'sw'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-01-15' -AsOf '2025-07-15' | Should -Be 'miezi 6'
    }
    # 29.26
    It '29.26 sw two years one month' {
        $loc = Get-SayableAgeLocale -Code 'sw'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAge -Formatter $fmt -DateOfBirth '2023-06-15' -AsOf '2025-07-15' | Should -Be 'miaka 2, mwezi 1'
    }
    # 29.27
    It '29.27 sw half years' {
        $loc = Get-SayableAgeLocale -Code 'sw'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAge -Formatter $fmt -DateOfBirth '2022-06-15' -AsOf '2025-12-15' | Should -Be 'miaka 3 na nusu'
    }

    # Indonesian
    # 29.28
    It '29.28 id justBorn' {
        $loc = Get-SayableAgeLocale -Code 'id'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-06-15' -AsOf '2025-06-15' | Should -Be 'Baru lahir'
    }
    It '29.29 id one day' {
        $loc = Get-SayableAgeLocale -Code 'id'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-06-14' -AsOf '2025-06-15' | Should -Be '1 hari'
    }
    It '29.30 id three days' {
        $loc = Get-SayableAgeLocale -Code 'id'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-06-12' -AsOf '2025-06-15' | Should -Be '3 hari'
    }
    It '29.31 id six months' {
        $loc = Get-SayableAgeLocale -Code 'id'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-01-15' -AsOf '2025-07-15' | Should -Be '6 bulan'
    }
    It '29.32 id half years' {
        $loc = Get-SayableAgeLocale -Code 'id'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAge -Formatter $fmt -DateOfBirth '2022-06-15' -AsOf '2025-12-15' | Should -Be '3 tahun setengah'
    }
    It '29.33 id seven years' {
        $loc = Get-SayableAgeLocale -Code 'id'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAge -Formatter $fmt -DateOfBirth '2018-06-15' -AsOf '2025-06-15' | Should -Be '7 tahun'
    }

    # Amharic
    It '29.34 am justBorn' {
        $loc = Get-SayableAgeLocale -Code 'am'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-06-15' -AsOf '2025-06-15' | Should -Be 'አዲስ የተወለደ'
    }
    It '29.35 am one day' {
        $loc = Get-SayableAgeLocale -Code 'am'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-06-14' -AsOf '2025-06-15' | Should -Be '1 ቀን'
    }
    It '29.36 am three days' {
        $loc = Get-SayableAgeLocale -Code 'am'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-06-12' -AsOf '2025-06-15' | Should -Be '3 ቀናት'
    }
    It '29.37 am one week one day ethiopic delimiter' {
        $loc = Get-SayableAgeLocale -Code 'am'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-06-07' -AsOf '2025-06-15' | Should -Be '1 ሳምንት፣ 1 ቀን'
    }
    It '29.38 am six months' {
        $loc = Get-SayableAgeLocale -Code 'am'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-01-15' -AsOf '2025-07-15' | Should -Be '6 ወራት'
    }
    It '29.39 am half years' {
        $loc = Get-SayableAgeLocale -Code 'am'
        $fmt = New-SayableAgeFormatter -Locale $loc
        Format-SayableAge -Formatter $fmt -DateOfBirth '2022-06-15' -AsOf '2025-12-15' | Should -Be '3 ዓመታት ተኩል'
    }
}

# ================================================================
# Section 30: Locale lookup by code string
# ================================================================
Describe 'Locale lookup by code string' {
    # 30.1
    It 'get locale en' {
        $loc = Get-SayableAgeLocale -Code 'en'
        $loc | Should -Not -BeNullOrEmpty
        $loc['code'] | Should -Be 'en'
    }

    # 30.2
    It 'get locale fr' {
        $loc = Get-SayableAgeLocale -Code 'fr'
        $loc | Should -Not -BeNullOrEmpty
        $loc['code'] | Should -Be 'fr'
    }

    # 30.3
    It 'get locale unknown' {
        $loc = Get-SayableAgeLocale -Code 'xx'
        $loc | Should -BeNullOrEmpty
    }

    # 30.4
    It 'get locale empty' {
        $loc = Get-SayableAgeLocale -Code ''
        $loc | Should -BeNullOrEmpty
    }

    # 30.5
    It 'get locale case sensitive' {
        $loc = Get-SayableAgeLocale -Code 'EN'
        $loc | Should -BeNullOrEmpty
    }
}

# ================================================================
# Sections 31-33: weeks+days across month ends, half-year plurals, input validation
# ================================================================
Describe 'Sections 31-33: weeks+days across month ends, half-year plurals, input validation' {
    # 31.1
    It '31.1 88 days across a 28-day February' {
        $fmt = New-SayableAgeFormatter -Locale (Get-SayableAgeLocale -Code 'en')
        Format-SayableAge -Formatter $fmt -DateOfBirth '2016-12-31' -AsOf '2017-03-29' | Should -BeExactly '12 weeks, 4 days'
    }

    # 31.2
    It '31.2 90 days across a year end into a leap year' {
        $fmt = New-SayableAgeFormatter -Locale (Get-SayableAgeLocale -Code 'en')
        Format-SayableAge -Formatter $fmt -DateOfBirth '1991-11-27' -AsOf '1992-02-25' | Should -BeExactly '12 weeks, 6 days'
    }

    # 31.3
    It '31.3 33 days across a year end' {
        $fmt = New-SayableAgeFormatter -Locale (Get-SayableAgeLocale -Code 'en')
        Format-SayableAge -Formatter $fmt -DateOfBirth '2020-11-30' -AsOf '2021-01-02' | Should -BeExactly '4 weeks, 5 days'
    }

    # 31.4
    It '31.4 Compact form of 31.1' {
        $fmt = New-SayableAgeFormatter -Locale (Get-SayableAgeLocale -Code 'en') -Compactness 'compact'
        Format-SayableAge -Formatter $fmt -DateOfBirth '2016-12-31' -AsOf '2017-03-29' | Should -BeExactly '12w4d'
    }

    # 32.1
    It '32.1 Polish 3 is ''few''' {
        $fmt = New-SayableAgeFormatter -Locale (Get-SayableAgeLocale -Code 'pl')
        Format-SayableAge -Formatter $fmt -DateOfBirth '2021-06-15' -AsOf '2025-01-15' | Should -BeExactly '3 i pół lata'
    }

    # 32.2
    It '32.2 Polish 5 is ''many''' {
        $fmt = New-SayableAgeFormatter -Locale (Get-SayableAgeLocale -Code 'pl') -Compactness 'short'
        Format-SayableAge -Formatter $fmt -DateOfBirth '2020-06-15' -AsOf '2025-12-15' | Should -BeExactly '5 i pół lat'
    }

    # 32.3
    It '32.3 Tachelhit 6 is ''few''' {
        $fmt = New-SayableAgeFormatter -Locale (Get-SayableAgeLocale -Code 'shi')
        Format-SayableAge -Formatter $fmt -DateOfBirth '2005-06-08' -AsOf '2012-06-07' | Should -BeExactly '6 iseggasen d uzgen'
    }

    # 33.1
    It '33.1 February 30 doesn''t exist' {
        $fmt = New-SayableAgeFormatter -Locale (Get-SayableAgeLocale -Code 'en')
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-02-30' -AsOf '2032-06-25' | Should -BeNullOrEmpty
    }

    # 33.2
    It '33.2 Month 13' {
        $fmt = New-SayableAgeFormatter -Locale (Get-SayableAgeLocale -Code 'en')
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-13-01' -AsOf '2027-01-31' | Should -BeNullOrEmpty
    }

    # 33.3
    It '33.3 February 29 in a non-leap year' {
        $fmt = New-SayableAgeFormatter -Locale (Get-SayableAgeLocale -Code 'en')
        Format-SayableAge -Formatter $fmt -DateOfBirth '2023-02-29' -AsOf '2025-03-01' | Should -BeNullOrEmpty
    }

    # 33.4
    It '33.4 Day 00' {
        $fmt = New-SayableAgeFormatter -Locale (Get-SayableAgeLocale -Code 'en')
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-06-00' -AsOf '2027-02-25' | Should -BeNullOrEmpty
    }

    # 33.5
    It '33.5 Unpadded month and day' {
        $fmt = New-SayableAgeFormatter -Locale (Get-SayableAgeLocale -Code 'en')
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-6-1' -AsOf '2027-02-25' | Should -BeNullOrEmpty
    }

    # 33.6
    It '33.6 Surrounding whitespace' {
        $fmt = New-SayableAgeFormatter -Locale (Get-SayableAgeLocale -Code 'en')
        Format-SayableAge -Formatter $fmt -DateOfBirth ' 2025-06-01' -AsOf '2027-02-25' | Should -BeNullOrEmpty
    }

    # 33.7
    It '33.7 A datetime is not a date' {
        $fmt = New-SayableAgeFormatter -Locale (Get-SayableAgeLocale -Code 'en')
        Format-SayableAge -Formatter $fmt -DateOfBirth '2025-06-15T10:00:00' -AsOf '2027-02-25' | Should -BeNullOrEmpty
    }

    # 33.8
    It '33.8 Invalid asOf' {
        $fmt = New-SayableAgeFormatter -Locale (Get-SayableAgeLocale -Code 'en')
        Format-SayableAge -Formatter $fmt -DateOfBirth '2020-01-01' -AsOf '2025-04-31' | Should -BeNullOrEmpty
    }

    # 33.9
    It '33.9 formatStage validates too' {
        $fmt = New-SayableAgeFormatter -Locale (Get-SayableAgeLocale -Code 'en')
        Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2025-02-30' -AsOf '2027-09-05' | Should -BeNullOrEmpty
    }

    # 33.10
    It '33.10 February 29 in a leap year is valid' {
        $fmt = New-SayableAgeFormatter -Locale (Get-SayableAgeLocale -Code 'en')
        Format-SayableAge -Formatter $fmt -DateOfBirth '2024-02-29' -AsOf '2026-03-01' | Should -BeExactly '2 years'
    }
}
