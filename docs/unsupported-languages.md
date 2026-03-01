# Unsupported Languages

This document explains why certain languages are not included despite being commonly requested.

## Objective-C

Objective-C was evaluated and ultimately excluded for the following reasons:

1. **Cross-platform reliability.** parent-time requires identical output across all platforms (macOS, Linux, Windows). GNUstep's `NSCalendar` implementation has known bugs with date difference calculations that produce different results from Apple's Foundation on macOS.

2. **No official Linux tooling.** There are no official Objective-C Docker images, and the GNUstep test framework (UnitKit) is barely maintained on Linux. This makes CI testing fragile and difficult to reproduce.

3. **The project requires identical output.** Every implementation must produce byte-identical output for the same inputs on every platform. `NSCalendar` bugs on Linux make this unreliable without significant workarounds that would undermine the zero-dependency goal.

4. **Existing alternatives.** The C++ implementation covers the same niche -- compiled, zero-dependency, and works on all platforms. Swift also serves Apple ecosystem developers who want native integration.
