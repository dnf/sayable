# All tests use explicit date pairs for determinism.

BeforeAll {
    Import-Module "$PSScriptRoot/../SayableDate.psm1" -Force
}

# ================================================================
# Null / edge cases
# ================================================================
Describe 'Null / edge cases' {
    # 1.1
    It 'returns null for null input' {
        Get-SayableDate -Date $null | Should -BeNullOrEmpty
    }

    # 1.2
    It 'returns null for empty string' {
        Get-SayableDate -Date '' | Should -BeNullOrEmpty
    }

    # 1.3
    It 'returns null for invalid input' {
        Get-SayableDate -Date 'invalid' | Should -BeNullOrEmpty
    }

    # 1.4
    It 'returns null when asOf is null' {
        Get-SayableRelativeDate -Date '2025-03-15' -AsOf $null | Should -BeNullOrEmpty
    }

    # 1.5
    It 'returns null when date is null for relative' {
        Get-SayableRelativeDate -Date $null -AsOf '2025-03-15' | Should -BeNullOrEmpty
    }
}

# ================================================================
# format_date — normal compactness (English)
# ================================================================
Describe 'format_date — normal compactness (English)' {
    # 2.1
    It 'formats March 15th' {
        Get-SayableDate -Date '2025-03-15' | Should -Be 'March 15th'
    }

    # 2.2
    It 'formats January 1st' {
        Get-SayableDate -Date '2025-01-01' | Should -Be 'January 1st'
    }

    # 2.3
    It 'formats May 22nd' {
        Get-SayableDate -Date '2025-05-22' | Should -Be 'May 22nd'
    }

    # 2.4
    It 'formats July 3rd' {
        Get-SayableDate -Date '2025-07-03' | Should -Be 'July 3rd'
    }

    # 2.5
    It 'formats December 31st' {
        Get-SayableDate -Date '2025-12-31' | Should -Be 'December 31st'
    }

    # 2.6
    It 'formats June 11th (no exception for 11)' {
        Get-SayableDate -Date '2025-06-11' | Should -Be 'June 11th'
    }

    # 2.7
    It 'handles ISO datetime input' {
        Get-SayableDate -Date '2025-03-15T14:30:00' | Should -Be 'March 15th'
    }
}

# ================================================================
# format_date — short compactness (English)
# ================================================================
Describe 'format_date — short compactness (English)' {
    BeforeAll {
        $loc = Get-SayableDateLocale -Code 'en'
        $script:shortFmt = New-SayableDateFormatter -Locale $loc -Compactness 'short'
    }

    # 3.1
    It 'short: Mar 15' {
        Format-SayableDate -Formatter $script:shortFmt -Date '2025-03-15' | Should -Be 'Mar 15'
    }

    # 3.2
    It 'short: Jan 1' {
        Format-SayableDate -Formatter $script:shortFmt -Date '2025-01-01' | Should -Be 'Jan 1'
    }

    # 3.3
    It 'short: Dec 25' {
        Format-SayableDate -Formatter $script:shortFmt -Date '2025-12-25' | Should -Be 'Dec 25'
    }
}

# ================================================================
# format_date — compact (English)
# ================================================================
Describe 'format_date — compact (English)' {
    BeforeAll {
        $loc = Get-SayableDateLocale -Code 'en'
        $script:compactFmt = New-SayableDateFormatter -Locale $loc -Compactness 'compact'
    }

    # 4.1
    It 'compact: 3/15' {
        Format-SayableDate -Formatter $script:compactFmt -Date '2025-03-15' | Should -Be '3/15'
    }

    # 4.2
    It 'compact: 1/1' {
        Format-SayableDate -Formatter $script:compactFmt -Date '2025-01-01' | Should -Be '1/1'
    }
}

# ================================================================
# format_relative — proximity tiers (English)
# ================================================================
Describe 'format_relative — proximity tiers (English)' {
    # 5.1
    It 'today' {
        Get-SayableRelativeDate -Date '2025-03-15' -AsOf '2025-03-15' | Should -Be 'today'
    }

    # 5.2
    It 'tomorrow' {
        Get-SayableRelativeDate -Date '2025-03-16' -AsOf '2025-03-15' | Should -Be 'tomorrow'
    }

    # 5.3
    It 'yesterday' {
        Get-SayableRelativeDate -Date '2025-03-14' -AsOf '2025-03-15' | Should -Be 'yesterday'
    }

    # 5.4
    It 'day after tomorrow' {
        Get-SayableRelativeDate -Date '2025-03-17' -AsOf '2025-03-15' | Should -Be 'the day after tomorrow'
    }

    # 5.5
    It 'day before yesterday' {
        Get-SayableRelativeDate -Date '2025-03-13' -AsOf '2025-03-15' | Should -Be 'the day before yesterday'
    }

    # 5.6
    It 'this Wednesday (+4 days)' {
        Get-SayableRelativeDate -Date '2025-03-19' -AsOf '2025-03-15' | Should -Be 'this Wednesday'
    }

    # 5.7
    It 'this Thursday (+5 days)' {
        Get-SayableRelativeDate -Date '2025-03-20' -AsOf '2025-03-15' | Should -Be 'this Thursday'
    }

    # 5.8
    It 'last Tuesday (-4 days)' {
        Get-SayableRelativeDate -Date '2025-03-11' -AsOf '2025-03-15' | Should -Be 'last Tuesday'
    }

    # 5.9
    It 'next Saturday (+7 days)' {
        Get-SayableRelativeDate -Date '2025-03-22' -AsOf '2025-03-15' | Should -Be 'next Saturday'
    }

    # 5.10
    It 'next Thursday (+12 days)' {
        Get-SayableRelativeDate -Date '2025-03-27' -AsOf '2025-03-15' | Should -Be 'next Thursday'
    }

    # 5.11
    It 'calendar fallback same year' {
        Get-SayableRelativeDate -Date '2025-03-01' -AsOf '2025-03-15' | Should -Be 'March 1st'
    }

    # 5.12
    It 'calendar fallback future same year' {
        Get-SayableRelativeDate -Date '2025-04-10' -AsOf '2025-03-15' | Should -Be 'April 10th'
    }

    # 5.13
    It 'different year includes year' {
        Get-SayableRelativeDate -Date '2026-01-05' -AsOf '2025-03-15' | Should -Be 'January 5th, 2026'
    }

    # 5.14
    It 'past year includes year' {
        Get-SayableRelativeDate -Date '2024-12-25' -AsOf '2025-03-15' | Should -Be 'December 25th, 2024'
    }
}

# ================================================================
# format_relative — compact skips weekday tiers
# ================================================================
Describe 'format_relative — compact skips weekday tiers' {
    BeforeAll {
        $loc = Get-SayableDateLocale -Code 'en'
        $script:compactRelFmt = New-SayableDateFormatter -Locale $loc -Compactness 'compact'
    }

    # 6.1
    It 'compact: today' {
        Format-SayableRelativeDate -Formatter $script:compactRelFmt -Date '2025-03-15' -AsOf '2025-03-15' | Should -Be 'today'
    }

    # 6.2
    It 'compact: tomorrow' {
        Format-SayableRelativeDate -Formatter $script:compactRelFmt -Date '2025-03-16' -AsOf '2025-03-15' | Should -Be 'tomorrow'
    }

    # 6.3
    It 'compact: straight to numeric' {
        Format-SayableRelativeDate -Formatter $script:compactRelFmt -Date '2025-03-19' -AsOf '2025-03-15' | Should -Be '3/19'
    }

    # 6.4
    It 'compact: different year' {
        Format-SayableRelativeDate -Formatter $script:compactRelFmt -Date '2026-01-05' -AsOf '2025-03-15' | Should -Be '1/5/26'
    }
}

# ================================================================
# Locale — German
# ================================================================
Describe 'Locale — German' {
    BeforeAll {
        $loc = Get-SayableDateLocale -Code 'de'
        $script:deFmt = New-SayableDateFormatter -Locale $loc
    }

    # 7.1
    It 'German: 15. März' {
        Format-SayableDate -Formatter $script:deFmt -Date '2025-03-15' | Should -Be '15. März'
    }

    # 7.2
    It 'German: morgen' {
        Format-SayableRelativeDate -Formatter $script:deFmt -Date '2025-03-16' -AsOf '2025-03-15' | Should -Be 'morgen'
    }

    # 7.3
    It 'German: übermorgen' {
        Format-SayableRelativeDate -Formatter $script:deFmt -Date '2025-03-17' -AsOf '2025-03-15' | Should -Be 'übermorgen'
    }

    # 7.4
    It 'German: diesen Mittwoch' {
        Format-SayableRelativeDate -Formatter $script:deFmt -Date '2025-03-19' -AsOf '2025-03-15' | Should -Be 'diesen Mittwoch'
    }
}

# ================================================================
# Locale — French
# ================================================================
Describe 'Locale — French' {
    BeforeAll {
        $loc = Get-SayableDateLocale -Code 'fr'
        $script:frFmt = New-SayableDateFormatter -Locale $loc
    }

    # 8.1
    It 'French: 1er mars' {
        Format-SayableDate -Formatter $script:frFmt -Date '2025-03-01' | Should -Be '1er mars'
    }

    # 8.2
    It 'French: 15 mars' {
        Format-SayableDate -Formatter $script:frFmt -Date '2025-03-15' | Should -Be '15 mars'
    }

    # 8.3
    It 'French: demain' {
        Format-SayableRelativeDate -Formatter $script:frFmt -Date '2025-03-16' -AsOf '2025-03-15' | Should -Be 'demain'
    }
}

# ================================================================
# Locale — Japanese
# ================================================================
Describe 'Locale — Japanese' {
    BeforeAll {
        $loc = Get-SayableDateLocale -Code 'ja'
        $script:jaFmt = New-SayableDateFormatter -Locale $loc
    }

    # 9.1
    It 'Japanese: 3月15日' {
        Format-SayableDate -Formatter $script:jaFmt -Date '2025-03-15' | Should -BeExactly '3月15日'
    }

    # 9.2
    It 'Japanese: 明日' {
        Format-SayableRelativeDate -Formatter $script:jaFmt -Date '2025-03-16' -AsOf '2025-03-15' | Should -BeExactly '明日'
    }

    # 9.3
    It 'Japanese: 今度の水曜日' {
        Format-SayableRelativeDate -Formatter $script:jaFmt -Date '2025-03-19' -AsOf '2025-03-15' | Should -BeExactly '今度の水曜日'
    }
}

# ================================================================
# Locale — Russian (genitive months)
# ================================================================
Describe 'Locale — Russian (genitive months)' {
    BeforeAll {
        $loc = Get-SayableDateLocale -Code 'ru'
        $script:ruFmt = New-SayableDateFormatter -Locale $loc
    }

    # 10.1
    It 'Russian: 15 марта' {
        Format-SayableDate -Formatter $script:ruFmt -Date '2025-03-15' | Should -BeExactly '15 марта'
    }

    # 10.2
    It 'Russian: завтра' {
        Format-SayableRelativeDate -Formatter $script:ruFmt -Date '2025-03-16' -AsOf '2025-03-15' | Should -BeExactly 'завтра'
    }
}

# ================================================================
# Locale — Arabic
# ================================================================
Describe 'Locale — Arabic' {
    BeforeAll {
        $loc = Get-SayableDateLocale -Code 'ar'
        $script:arFmt = New-SayableDateFormatter -Locale $loc
    }

    # 11.1
    It 'Arabic: 15 مارس' {
        Format-SayableDate -Formatter $script:arFmt -Date '2025-03-15' | Should -BeExactly '15 مارس'
    }

    # 11.2
    It 'Arabic: غداً' {
        Format-SayableRelativeDate -Formatter $script:arFmt -Date '2025-03-16' -AsOf '2025-03-15' | Should -BeExactly 'غداً'
    }
}

# ================================================================
# Locale — Spanish
# ================================================================
Describe 'Locale — Spanish' {
    BeforeAll {
        $loc = Get-SayableDateLocale -Code 'es'
        $script:esFmt = New-SayableDateFormatter -Locale $loc
    }

    # 12.1
    It 'Spanish: 15 de marzo' {
        Format-SayableDate -Formatter $script:esFmt -Date '2025-03-15' | Should -Be '15 de marzo'
    }

    # 12.2
    It 'Spanish: pasado mañana' {
        Format-SayableRelativeDate -Formatter $script:esFmt -Date '2025-03-17' -AsOf '2025-03-15' | Should -BeExactly 'pasado mañana'
    }
}
