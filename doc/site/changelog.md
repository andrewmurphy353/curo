# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),  
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.0.2] - 2026-01-26

### Fixed
- Added missing tolerance argument to solve method signatures
- Added missing changelog entry to this doc/site changelog summary

## [3.0.1] - 2026-01-22

### Fixed
- Corrected first draw-down date detection when solving for an unknown advance amount (previously skipped due to placeholder 0.0 value).
- Improved discount factor operand logging: now correctly labels time fraction as `t` (e.g., "t = 31/360 = 0.08611111") instead of `f` for Standard formula, aligning notation with US Appendix J convention.

### Changed
- Removed redundant `isCharge` field from `CashFlow` record (superseded by `CashFlowType.type`); updated all references accordingly.

## [3.0.0] - 2026-01-20

### Breaking Changes — Complete Rewrite

Version 3.0.0 is a **full ground-up modernisation** of the package, bringing it in line with current Dart best practices and achieving full design and numerical parity with the sister project [`curo-python`](https://github.com/andrewmurphy353/curo_python).

Key breaking changes:
- Adopted modern Dart features: null-safety, sealed classes, records, enhanced enums
- Flattened API surface: replaced deep inheritance with composition-based design
- Immutable cash flow model: introduced `SeriesAdvance`, `SeriesPayment`, `SeriesCharge`
- Asynchronous solving: `solveRate` and `solveValue` now return `Future<double>`
- Simplified precision: single `precision` parameter (0–4 decimals) on `Calculator`
- Removed legacy mutable classes and synchronous solve methods

**Migration required** for any code using versions ≤2.x.

### Added
- Pretty-printed amortisation schedules and APR proof tables via `Schedule.prettyPrint`
- Expanded test coverage and internal refactoring for maintainability
- Full alignment with curo-python behaviour and accuracy

### Notes
This major release represents a significant leap in code quality, type safety, and long-term maintainability while preserving (and often improving) numerical precision and regulatory compliance.