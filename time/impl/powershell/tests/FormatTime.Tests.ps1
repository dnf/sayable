# All tests use explicit inputs for determinism.

BeforeAll {
    Import-Module "$PSScriptRoot/../SayableTime.psm1" -Force
}

# ================================================================
# Null / edge cases
# ================================================================
Describe 'Null / edge cases' {
    # 1.1
    It 'returns null for null input' {
        Get-SayableTime -InputStr $null | Should -BeNullOrEmpty
    }

    # 1.2
    It 'returns null for empty string' {
        Get-SayableTime -InputStr '' | Should -BeNullOrEmpty
    }

    # 1.3
    It 'returns null for invalid input' {
        Get-SayableTime -InputStr 'invalid' | Should -BeNullOrEmpty
    }

    # 1.4
    It 'returns null for out-of-range hour' {
        Get-SayableTime -InputStr '25:00' | Should -BeNullOrEmpty
    }
}

# ================================================================
# Clock time (normal compactness)
# ================================================================
Describe 'Clock time (normal compactness)' {
    # 2.1
    It 'midnight' {
        Get-SayableTime -InputStr '00:00' | Should -Be 'midnight'
    }

    # 2.2
    It 'noon' {
        Get-SayableTime -InputStr '12:00' | Should -Be 'noon'
    }

    # 2.3
    It 'three o''clock' {
        Get-SayableTime -InputStr '15:00' | Should -Be "three o'clock"
    }

    # 2.4
    It 'a quarter past two' {
        Get-SayableTime -InputStr '14:15' | Should -Be 'a quarter past two'
    }

    # 2.5
    It 'half past nine' {
        Get-SayableTime -InputStr '09:30' | Should -Be 'half past nine'
    }

    # 2.6
    It 'a quarter to eleven' {
        Get-SayableTime -InputStr '10:45' | Should -Be 'a quarter to eleven'
    }

    # 2.7
    It 'five past eight' {
        Get-SayableTime -InputStr '08:05' | Should -Be 'five past eight'
    }

    # 2.8
    It 'five to five' {
        Get-SayableTime -InputStr '16:55' | Should -Be 'five to five'
    }

    # 2.9
    It '23:58 rounds to midnight' {
        Get-SayableTime -InputStr '23:58' | Should -Be 'midnight'
    }

    # 2.10
    It '07:22 rounds to twenty past seven' {
        Get-SayableTime -InputStr '07:22' | Should -Be 'twenty past seven'
    }

    # 2.11
    It 'ISO datetime input' {
        Get-SayableTime -InputStr '2025-01-15T14:15:00' | Should -Be 'a quarter past two'
    }
}

# ================================================================
# Clock time (short compactness)
# ================================================================
Describe 'Clock time (short compactness)' {
    BeforeAll {
        $loc = Get-SayableTimeLocale -Code 'en'
        $script:shortFmt = New-SayableTimeFormatter -Locale $loc -Compactness 'short'
    }

    # 3.1
    It 'short: 2:15 PM' {
        Format-SayableTime -Formatter $script:shortFmt -InputStr '14:15' | Should -Be '2:15 PM'
    }

    # 3.2
    It 'short: 9:30 AM' {
        Format-SayableTime -Formatter $script:shortFmt -InputStr '09:30' | Should -Be '9:30 AM'
    }

    # 3.3
    It 'short: 12:00 AM (midnight)' {
        Format-SayableTime -Formatter $script:shortFmt -InputStr '00:00' | Should -Be '12:00 AM'
    }

    # 3.4
    It 'short: 12:00 PM (noon)' {
        Format-SayableTime -Formatter $script:shortFmt -InputStr '12:00' | Should -Be '12:00 PM'
    }
}

# ================================================================
# Clock time (compact)
# ================================================================
Describe 'Clock time (compact)' {
    BeforeAll {
        $loc = Get-SayableTimeLocale -Code 'en'
        $script:compactFmt = New-SayableTimeFormatter -Locale $loc -Compactness 'compact'
    }

    # 4.1
    It 'compact: 2:15p' {
        Format-SayableTime -Formatter $script:compactFmt -InputStr '14:15' | Should -Be '2:15p'
    }

    # 4.2
    It 'compact: 9:30a' {
        Format-SayableTime -Formatter $script:compactFmt -InputStr '09:30' | Should -Be '9:30a'
    }
}

# ================================================================
# Locale — German
# ================================================================
Describe 'Locale — German (Time)' {
    BeforeAll {
        $loc = Get-SayableTimeLocale -Code 'de'
        $script:deFmt = New-SayableTimeFormatter -Locale $loc
    }

    # 5.1
    It 'German: halb vier' {
        Format-SayableTime -Formatter $script:deFmt -InputStr '15:30' | Should -Be 'halb vier'
    }
}

# ================================================================
# Locale — French
# ================================================================
Describe 'Locale — French (Time)' {
    BeforeAll {
        $loc = Get-SayableTimeLocale -Code 'fr'
        $script:frFmt = New-SayableTimeFormatter -Locale $loc
    }

    # 6.1
    It 'French: trois heures et quart' {
        Format-SayableTime -Formatter $script:frFmt -InputStr '15:15' | Should -Be 'trois heures et quart'
    }

    # 6.2
    It 'French: une heure' {
        Format-SayableTime -Formatter $script:frFmt -InputStr '13:00' | Should -Be 'une heure'
    }

    # 6.3
    It 'French: une heure et demie' {
        Format-SayableTime -Formatter $script:frFmt -InputStr '13:30' | Should -Be 'une heure et demie'
    }

    # 6.4
    It 'French: trois heures moins le quart' {
        Format-SayableTime -Formatter $script:frFmt -InputStr '14:45' | Should -Be 'trois heures moins le quart'
    }

    # 6.5
    It 'French: trois heures moins dix' {
        Format-SayableTime -Formatter $script:frFmt -InputStr '14:50' | Should -Be 'trois heures moins dix'
    }
}

# ================================================================
# Locale — Japanese
# ================================================================
Describe 'Locale — Japanese (Time)' {
    BeforeAll {
        $loc = Get-SayableTimeLocale -Code 'ja'
        $script:jaFmt = New-SayableTimeFormatter -Locale $loc
    }

    # 7.1
    It 'Japanese: 三時半' {
        Format-SayableTime -Formatter $script:jaFmt -InputStr '15:30' | Should -BeExactly '三時半'
    }
}

# ================================================================
# Locale — Finnish (dot separator, short)
# ================================================================
Describe 'Locale — Finnish (dot separator, short)' {
    BeforeAll {
        $loc = Get-SayableTimeLocale -Code 'fi'
        $script:fiFmt = New-SayableTimeFormatter -Locale $loc -Compactness 'short'
    }

    # 8.1
    It 'Finnish short: 14.15' {
        Format-SayableTime -Formatter $script:fiFmt -InputStr '14:15' | Should -Be '14.15'
    }

    # 8.2
    It 'Finnish short: 0.00 (midnight)' {
        Format-SayableTime -Formatter $script:fiFmt -InputStr '00:00' | Should -Be '0.00'
    }
}

# ================================================================
# Sections 9-10: minutes in short/compact, input validation
# ================================================================
Describe 'Sections 9-10: minutes in short/compact, input validation' {
    # 9.1
    It '9.1 digital modes keep the exact minute' {
        $fmt = New-SayableTimeFormatter -Locale (Get-SayableTimeLocale -Code 'en') -Compactness 'short'
        Format-SayableTime -Formatter $fmt -InputStr '18:01' | Should -BeExactly '6:01 PM'
    }

    # 9.2
    It '9.2 digital modes keep the exact minute' {
        $fmt = New-SayableTimeFormatter -Locale (Get-SayableTimeLocale -Code 'en') -Compactness 'compact'
        Format-SayableTime -Formatter $fmt -InputStr '19:05' | Should -BeExactly '7:05p'
    }

    # 10.1
    It '10.1 one-digit hour' {
        $fmt = New-SayableTimeFormatter -Locale (Get-SayableTimeLocale -Code 'en')
        Format-SayableTime -Formatter $fmt -InputStr '9:30' | Should -BeExactly 'half past nine'
    }

    # 10.2
    It '10.2 two-digit hour' {
        $fmt = New-SayableTimeFormatter -Locale (Get-SayableTimeLocale -Code 'en')
        Format-SayableTime -Formatter $fmt -InputStr '09:30' | Should -BeExactly 'half past nine'
    }

    # 10.3
    It '10.3 leading whitespace' {
        $fmt = New-SayableTimeFormatter -Locale (Get-SayableTimeLocale -Code 'en')
        Format-SayableTime -Formatter $fmt -InputStr ' 9:30' | Should -BeNullOrEmpty
    }

    # 10.4
    It '10.4 trailing whitespace' {
        $fmt = New-SayableTimeFormatter -Locale (Get-SayableTimeLocale -Code 'en')
        Format-SayableTime -Formatter $fmt -InputStr '9:30 ' | Should -BeNullOrEmpty
    }

    # 10.5
    It '10.5 minutes need two digits' {
        $fmt = New-SayableTimeFormatter -Locale (Get-SayableTimeLocale -Code 'en')
        Format-SayableTime -Formatter $fmt -InputStr '9:5' | Should -BeNullOrEmpty
    }

    # 10.6
    It '10.6 hour out of range' {
        $fmt = New-SayableTimeFormatter -Locale (Get-SayableTimeLocale -Code 'en')
        Format-SayableTime -Formatter $fmt -InputStr '24:00' | Should -BeNullOrEmpty
    }

    # 10.7
    It '10.7 seconds are allowed and ignored' {
        $fmt = New-SayableTimeFormatter -Locale (Get-SayableTimeLocale -Code 'en')
        Format-SayableTime -Formatter $fmt -InputStr '14:15:30' | Should -BeExactly 'a quarter past two'
    }

    # 10.8
    It '10.8 ISO datetime with zone suffix (ignored)' {
        $fmt = New-SayableTimeFormatter -Locale (Get-SayableTimeLocale -Code 'en')
        Format-SayableTime -Formatter $fmt -InputStr '2025-01-15T14:15:00Z' | Should -BeExactly 'a quarter past two'
    }

    # 10.9
    It '10.9 ISO datetime with an impossible date' {
        $fmt = New-SayableTimeFormatter -Locale (Get-SayableTimeLocale -Code 'en')
        Format-SayableTime -Formatter $fmt -InputStr '2025-02-30T14:15:00' | Should -BeNullOrEmpty
    }
}
