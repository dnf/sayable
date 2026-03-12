# All tests use explicit inputs for determinism.

BeforeAll {
    Import-Module "$PSScriptRoot/../SayableDuration.psm1" -Force
}

# ================================================================
# Null / edge cases
# ================================================================
Describe 'Null / edge cases' {
    # 1.1
    It 'returns null for null seconds' {
        Get-SayableDuration -StartOrSeconds $null | Should -BeNullOrEmpty
    }

    # 1.2
    It 'returns null for negative seconds' {
        Get-SayableDuration -StartOrSeconds (-1) | Should -BeNullOrEmpty
    }

    # 1.3
    It 'returns null for null start in format_since' {
        Get-SayableSince -Start $null -AsOf '2025-01-15T10:00:00' | Should -BeNullOrEmpty
    }

    # 1.4
    It 'returns null for null target in format_until' {
        Get-SayableUntil -Target $null -AsOf '2025-01-15T10:00:00' | Should -BeNullOrEmpty
    }

    # 1.5
    It 'returns null when asOf is before start in format_since' {
        Get-SayableSince -Start '2025-01-15T10:00:00' -AsOf '2025-01-15T09:00:00' | Should -BeNullOrEmpty
    }

    # 1.6
    It 'returns null when target is in the past for format_until' {
        Get-SayableUntil -Target '2025-01-15T09:00:00' -AsOf '2025-01-15T10:00:00' | Should -BeNullOrEmpty
    }
}

# ================================================================
# Duration — seconds tier (0-59s)
# ================================================================
Describe 'Duration — seconds tier (0-59s)' {
    # 2.1
    It '0 seconds = just now' {
        Get-SayableDuration -StartOrSeconds 0 | Should -Be 'just now'
    }

    # 2.2
    It '1 second' {
        Get-SayableDuration -StartOrSeconds 1 | Should -Be '1 second'
    }

    # 2.3
    It '45 seconds' {
        Get-SayableDuration -StartOrSeconds 45 | Should -Be '45 seconds'
    }

    # 2.4
    It '59 seconds' {
        Get-SayableDuration -StartOrSeconds 59 | Should -Be '59 seconds'
    }
}

# ================================================================
# Duration — minutes + seconds tier (1-4 min)
# ================================================================
Describe 'Duration — minutes + seconds tier (1-4 min)' {
    # 3.1
    It '1 minute' {
        Get-SayableDuration -StartOrSeconds 60 | Should -Be '1 minute'
    }

    # 3.2
    It '1 minute, 30 seconds' {
        Get-SayableDuration -StartOrSeconds 90 | Should -Be '1 minute, 30 seconds'
    }

    # 3.3
    It '4 minutes' {
        Get-SayableDuration -StartOrSeconds 240 | Should -Be '4 minutes'
    }

    # 3.4
    It '4 minutes, 30 seconds' {
        Get-SayableDuration -StartOrSeconds 270 | Should -Be '4 minutes, 30 seconds'
    }
}

# ================================================================
# Duration — minutes tier (5-59 min)
# ================================================================
Describe 'Duration — minutes tier (5-59 min)' {
    # 4.1
    It '5 minutes' {
        Get-SayableDuration -StartOrSeconds 300 | Should -Be '5 minutes'
    }

    # 4.2
    It '25 minutes' {
        Get-SayableDuration -StartOrSeconds 1500 | Should -Be '25 minutes'
    }

    # 4.3
    It '59 minutes' {
        Get-SayableDuration -StartOrSeconds 3540 | Should -Be '59 minutes'
    }
}

# ================================================================
# Duration — hours + minutes tier (1-5 hr)
# ================================================================
Describe 'Duration — hours + minutes tier (1-5 hr)' {
    # 5.1
    It '1 hour' {
        Get-SayableDuration -StartOrSeconds 3600 | Should -Be '1 hour'
    }

    # 5.2
    It '1½ hours (half marker)' {
        Get-SayableDuration -StartOrSeconds 5400 | Should -BeExactly '1½ hours'
    }

    # 5.3
    It '2 hours, 15 minutes' {
        Get-SayableDuration -StartOrSeconds 8100 | Should -Be '2 hours, 15 minutes'
    }

    # 5.4
    It '5 hours' {
        Get-SayableDuration -StartOrSeconds 18000 | Should -Be '5 hours'
    }
}

# ================================================================
# Duration — hours tier (6-23 hr)
# ================================================================
Describe 'Duration — hours tier (6-23 hr)' {
    # 6.1
    It '8 hours' {
        Get-SayableDuration -StartOrSeconds 28800 | Should -Be '8 hours'
    }

    # 6.2
    It '23 hours' {
        Get-SayableDuration -StartOrSeconds 82800 | Should -Be '23 hours'
    }
}

# ================================================================
# Duration — days tier
# ================================================================
Describe 'Duration — days tier' {
    # 7.1
    It '1 day' {
        Get-SayableDuration -StartOrSeconds 86400 | Should -Be '1 day'
    }

    # 7.2
    It '1 day, 3 hours' {
        Get-SayableDuration -StartOrSeconds 97200 | Should -Be '1 day, 3 hours'
    }

    # 7.3
    It '1½ days (half marker)' {
        Get-SayableDuration -StartOrSeconds 129600 | Should -BeExactly '1½ days'
    }

    # 7.4
    It '5 days' {
        Get-SayableDuration -StartOrSeconds 432000 | Should -Be '5 days'
    }

    # 7.5
    It '2 days' {
        Get-SayableDuration -StartOrSeconds 172800 | Should -Be '2 days'
    }
}

# ================================================================
# Duration — weeks tier
# ================================================================
Describe 'Duration — weeks tier' {
    # 8.1
    It '1 week' {
        Get-SayableDuration -StartOrSeconds 604800 | Should -Be '1 week'
    }

    # 8.2
    It '2 weeks, 1 day' {
        Get-SayableDuration -StartOrSeconds 1296000 | Should -Be '2 weeks, 1 day'
    }

    # 8.3
    It '4 weeks' {
        Get-SayableDuration -StartOrSeconds 2419200 | Should -Be '4 weeks'
    }
}

# ================================================================
# Duration — months and years tier
# ================================================================
Describe 'Duration — months and years tier' {
    # 9.1
    It '1 month (~31 days)' {
        Get-SayableDuration -StartOrSeconds 2678400 | Should -Be '1 month'
    }

    # 9.2
    It '3 months (~91 days)' {
        Get-SayableDuration -StartOrSeconds 7884000 | Should -Be '3 months'
    }

    # 9.3
    It '1 year (365 days)' {
        Get-SayableDuration -StartOrSeconds 31536000 | Should -Be '1 year'
    }

    # 9.4
    It '1 year, 3 months (~456 days)' {
        Get-SayableDuration -StartOrSeconds 39420000 | Should -Be '1 year, 3 months'
    }
}

# ================================================================
# Duration from ISO timestamps
# ================================================================
Describe 'Duration from ISO timestamps' {
    # 10.1
    It '1½ hours from ISO' {
        Get-SayableDuration -StartOrSeconds '2025-01-15T10:00:00' -End '2025-01-15T11:30:00' | Should -BeExactly '1½ hours'
    }

    # 10.2
    It '45 minutes from ISO' {
        Get-SayableDuration -StartOrSeconds '2025-01-15T10:00:00' -End '2025-01-15T10:45:00' | Should -Be '45 minutes'
    }
}

# ================================================================
# Relative time — since
# ================================================================
Describe 'Relative time — since' {
    # 11.1
    It 'just now (0 diff)' {
        Get-SayableSince -Start '2025-01-15T10:00:00' -AsOf '2025-01-15T10:00:00' | Should -Be 'just now'
    }

    # 11.2
    It '30 seconds ago' {
        Get-SayableSince -Start '2025-01-15T10:00:00' -AsOf '2025-01-15T10:00:30' | Should -Be '30 seconds ago'
    }

    # 11.3
    It '45 minutes ago' {
        Get-SayableSince -Start '2025-01-15T10:00:00' -AsOf '2025-01-15T10:45:00' | Should -Be '45 minutes ago'
    }

    # 11.4
    It '3 hours ago' {
        Get-SayableSince -Start '2025-01-15T10:00:00' -AsOf '2025-01-15T13:00:00' | Should -Be '3 hours ago'
    }
}

# ================================================================
# Relative time — until
# ================================================================
Describe 'Relative time — until' {
    # 12.1
    It 'just now (0 diff)' {
        Get-SayableUntil -Target '2025-01-15T10:00:00' -AsOf '2025-01-15T10:00:00' | Should -Be 'just now'
    }

    # 12.2
    It 'in 20 minutes' {
        Get-SayableUntil -Target '2025-01-15T10:20:00' -AsOf '2025-01-15T10:00:00' | Should -Be 'in 20 minutes'
    }

    # 12.3
    It 'in 3 hours' {
        Get-SayableUntil -Target '2025-01-15T13:00:00' -AsOf '2025-01-15T10:00:00' | Should -Be 'in 3 hours'
    }
}

# ================================================================
# Locale — German
# ================================================================
Describe 'Locale — German (Duration)' {
    BeforeAll {
        $loc = Get-SayableDurationLocale -Code 'de'
        $script:deFmt = New-SayableDurationFormatter -Locale $loc
    }

    # 13.1
    It 'German: 1 Stunde' {
        Format-SayableDuration -Formatter $script:deFmt -StartOrSeconds 3600 | Should -Be '1 Stunde'
    }

    # 13.2
    It 'German: vor 5 Minuten' {
        Format-SayableSince -Formatter $script:deFmt -Start '2025-01-15T10:00:00' -AsOf '2025-01-15T10:05:00' | Should -Be 'vor 5 Minuten'
    }
}

# ================================================================
# Locale — French
# ================================================================
Describe 'Locale — French (Duration)' {
    BeforeAll {
        $loc = Get-SayableDurationLocale -Code 'fr'
        $script:frFmt = New-SayableDurationFormatter -Locale $loc
    }

    # 14.1
    It 'French: 2 heures' {
        Format-SayableDuration -Formatter $script:frFmt -StartOrSeconds 7200 | Should -Be '2 heures'
    }
}

# ================================================================
# Locale — Japanese
# ================================================================
Describe 'Locale — Japanese (Duration)' {
    BeforeAll {
        $loc = Get-SayableDurationLocale -Code 'ja'
        $script:jaFmt = New-SayableDurationFormatter -Locale $loc
    }

    # 15.1
    It 'Japanese: 2分' {
        Format-SayableDuration -Formatter $script:jaFmt -StartOrSeconds 120 | Should -BeExactly '2分'
    }

    # 15.2
    It 'Japanese: 1時間前' {
        Format-SayableSince -Formatter $script:jaFmt -Start '2025-01-15T10:00:00' -AsOf '2025-01-15T11:00:00' | Should -BeExactly '1時間前'
    }
}

# ================================================================
# Short compactness — duration
# ================================================================
Describe 'Short compactness — duration' {
    BeforeAll {
        $loc = Get-SayableDurationLocale -Code 'en'
        $script:shortFmt = New-SayableDurationFormatter -Locale $loc -Compactness 'short'
    }

    # 16.1
    It 'short: 1h' {
        Format-SayableDuration -Formatter $script:shortFmt -StartOrSeconds 3600 | Should -Be '1h'
    }

    # 16.2
    It 'short: 1m, 30s' {
        Format-SayableDuration -Formatter $script:shortFmt -StartOrSeconds 90 | Should -Be '1m, 30s'
    }
}

# ================================================================
# Compact compactness — duration
# ================================================================
Describe 'Compact compactness — duration' {
    BeforeAll {
        $loc = Get-SayableDurationLocale -Code 'en'
        $script:compactFmt = New-SayableDurationFormatter -Locale $loc -Compactness 'compact'
    }

    # 17.1
    It 'compact: 1h' {
        Format-SayableDuration -Formatter $script:compactFmt -StartOrSeconds 3600 | Should -Be '1h'
    }

    # 17.2
    It 'compact: 1m30s' {
        Format-SayableDuration -Formatter $script:compactFmt -StartOrSeconds 90 | Should -Be '1m30s'
    }
}
