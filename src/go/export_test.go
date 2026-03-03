package parenttime

import "time"

// SetTimeNow overrides the clock for testing. Restore with RestoreTimeNow.
func SetTimeNow(f func() time.Time) { timeNow = f }

// RestoreTimeNow restores the real clock.
func RestoreTimeNow() { timeNow = time.Now }
