// Type definitions for sayable-time locale data.
// A locale class exposes static getters for all fields.
// See the "time" section of locales/*.json for the canonical schema.
//
// Required static fields:
//   code  : String
//   clock : Map with keys:
//     hours    : List of 12 hour names (twelve/zero, one, two, ..., eleven)
//     midnight : String
//     noon     : String
//     patterns : Map of minute-bucket (0,5,10,...,55) to pattern string
//                Patterns use {h} for current hour and {next_h} for next hour
//
// Optional compactness overrides:
//   short   : Map with "clock" key containing:
//     use24h : Bool
//     format : String with {h}, {mm}, {ampm} placeholders
//     amPm   : List of [am, pm] strings (optional for 24h)
//   compact : same structure as short
