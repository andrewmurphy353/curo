# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),  
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.0.0] - 2026-01-20

### Breaking Changes & Complete Rewrite
- **Modern ground-up rewrite** of the entire package, aligning design, behaviour, and accuracy with the sister project [`curo-python`](https://github.com/andrewmurphy353/curo_python).
- Adopted modern Dart conventions: null-safety, sealed classes, records, enhanced enums, and idiomatic patterns.
- **Flattened API structure**: replaced deep OOP inheritance with a cleaner, more Pythonic composition style while retaining full type-safety.
- Redesigned core types:
  - Introduced immutable `Series` hierarchy (`SeriesAdvance`, `SeriesPayment`, `SeriesCharge`) for defining cash flow series.
  - Replaced mutable cash flow objects with lightweight immutable `CashFlow` records.
  - Extracted internal helpers for better testability.
- **Asynchronous solving**: `solveRate` and `solveValue` now return `Future<double>` (consistent with modern Dart expectations and the original 1.1.0 behaviour).
- Simplified precision handling: single `precision` parameter on `Calculator` (0–4 decimal places).
- All public APIs updated — existing code from ≤2.x will require migration.

### Added
- Built-in pretty-printed amortisation and APR proof schedules via `ScheduleRow.prettyPrint`.
- Comprehensive day count convention coverage unchanged but now with cleaner implementation and better documentation.
- Greatly expanded internal test coverage.

### Removed
- Legacy mutable cash flow classes and deep inheritance chains.
- Old synchronous solve methods.

This major version represents a transformative modernisation while preserving (and in many cases improving) numerical accuracy and regulatory compliance.

## [2.4.3] - 2025-12-14
### Enhancements
- Enhanced same-date `CashFlowAdvance` sorting by amount descending (most negative first).

### Fixed
- Corrected priority of same-date advances in profile sorting.

## [2.4.2] - 2025-12-12
### Enhancements
- Improved cash flow sorting to consistently order same-date flows: advances → payments → charges.
- Added `==`, `hashCode`, and `copyWith` to `DayCountFactor`.

## [2.4.1] - 2025-12-08
### Enhancements
- Strengthened root solver with bisection fallback for Newton-Raphson, improving reliability on long-term loans and edge cases.
- Expanded end-to-end tests for extreme scenarios.

### Fixed
- Profile builder now correctly honours user-provided start dates in arrears mode.
- Restricted `UKConcApp` to valid `DayCountTimePeriod` options.

## [2.4.0]
### Added
- Implemented **US Appendix J** day count convention (Regulation Z) with full unit-period and leap year support.
- Extended `DayCountFactor` to two-component model (`principalFactor` + `fractionalAdjustment`).

### Breaking
- Renamed `DayCountFactor.factor` → `principalFactor`.

### Enhancements
- Improved `DayCountFactor` string formatting for complex conventions.
- Added comprehensive tests validated against FFIEC APR calculator.

## [2.3.1]
### Fixed
- Corrected interest accrual when additional advances occur during repayment phase.

## [2.3.0]
### Added
- Unified **UK CONC App 1.1** and **1.2** into single `UKConcApp` class with `isSecuredOnLand` toggle.

## [2.2.0]
### Added
- Implemented **UK CONC App 1.1** (secured on land) and **UK CONC App 1.2** (unsecured) conventions.

## [2.1.4]
### Documentation
- Clarified that `EU200848EC` remains valid despite directive repeal.

## [2.1.3]
### Fixed
- Corrected `EU200848EC` month-end handling for February 28/29.

## [2.1.1]
### Enhancements
- Improved `DayCountFactor.toString()` and `toFoldedString()` for long formula rendering.

## [2.1.0]
### Changed
- Switched to standard Newton-Raphson solver.
### Added
- `Actual360` and `30U360` conventions.
- Support for 0–4 decimal precision.

## [2.0.0]
- Updated to Dart SDK ≥3.0.0.
- Dependency refresh and housekeeping.

## [1.1.1]
### Added
- Exported `UnsolvableException`.
### Fixed
- README examples.

## [1.1.0]
### Added
- Asynchronous computational methods.
- `UnsolvableException`.

## [1.0.0]
- Initial release.

[3.0.0]: https://github.com/andrewmurphy353/curo/releases/tag/3.0.0
