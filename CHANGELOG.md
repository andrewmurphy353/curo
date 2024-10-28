## 2.1.0
- Switched out the Enhanced Newton-Raphson method with the Standard Newton-Raphson
  method to expand the solution space/window (the trade-off being a slighty slower 
  convergence speed).
- Added the Actual/360 day count convention
- Added the 30U/360 day count convention, similar to 30/360, except February
  28th (non leap-year) and 29th (leap-year) are treated as a 30-day month
- Opened up the calculation precision constraint to allow input in the
  range 0 to 4 decimal digits
- Code housekeeping and clean-up

## 2.0.0
- Updated Dart SDK version constraint to 3.0.0 +
- Updated build package dependencies
- Performed minor code housekeeping

## 1.1.1
- Added UnsolvableException export to library barrel file
- Corrected README examples and results

## 1.1.0

- Converted calculator computational methods to asynchronous functions
- Added checked UnsolvableException for unsolvable values
- Updated examples

## 1.0.0

- Initial release version.
