# TooMuchTheme

## `tmTheme` support library for Swift

Includes:

- `Theme` type
  - `Codable` to/from `tmTheme` format
  - Generate `NSAttributedString` attributes from a given `Theme` and `Scope` or `Context`
- `ScopeSelector` type
  - `Codable` to/from string format
  - `Scope` and `Context` matching
  - Fully compatible with TextMate 2 format
- `Scope` and `Context` types
  - A `Scope` is a list of scope names, which emulates a TextMate scope (grammar derivation)
    - `Codable` to/from space-separated scope names string
    - Direct (`matchAndRemoveFirst`) and transitive (`matchAndRemoveLeading`) scope name matching
  - A `Context` models a text editing selection, and is either
    - A `Scope` (`main`), or
    - A pair of `Scope`s, one to the left of the text cursor (`left`) and one to the right (`main`)
- `ScopeName` type
    - `Codable` to/from dot-separated components string
    - Prefix matching

For example usage:

- of scopes and scope selectors, please see this package's test files
- of themes and string attribute generation, please see [this file](https://github.com/BushelScript/BushelScript/blob/3327cd9e89a58c5e2b7bbbe166496107c71e576c/BushelScript%20Editor/BushelScript%20Editor/Preferences/HighlightStyles.swift)
