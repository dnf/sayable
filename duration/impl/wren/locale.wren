// Type definitions for sayable-duration locale data.
// A locale class exposes static getters for all fields.
// See the "duration" section of locales/*.json for the canonical schema.
//
// Required static fields:
//   code      : String
//   plural    : Fn that takes an integer and returns a plural category string
//   units     : Map of unit name to unit forms (String or Map of category to template)
//   half      : String with {n} and/or {0} placeholder
//   delimiter : String
//   justNow   : String
//   ago       : String with {0} placeholder
//   inFuture  : String with {0} placeholder
//
// Optional compactness overrides:
//   short   : Map with optional keys: units, half, delimiter, ago, inFuture
//   compact : Map with optional keys: units, half, delimiter, ago, inFuture
