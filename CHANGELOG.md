## 2.4.3 - 2025-12-14
### Enhancements
- **Enhanced CashFlowAdvance Sorting**: Updated the `sort()` method in `helper.dart` to sort same-dated `CashFlowAdvance` objects by `value` in descending order (most negative first, e.g., -3000.0 before -200.0) after sorting by `valueDate` or `postDate`.

### Bug Fixes
- **Fixed CashFlowAdvance Value Sorting**: Corrected the sorting of same-dated `CashFlowAdvance` objects to ensure the most negative `value` comes first, resolving an issue where smaller absolute values were incorrectly prioritized.

## 2.4.2 - 2025-12-12
### Enhancements
- **Improved CashFlow Sorting**: Updated the `sort()` method in `helper.dart` to handle `CashFlowCharge` objects. Same-dated `CashFlow` objects are now consistently ordered as follows: `CashFlowAdvance` first, `CashFlowPayment` second, and `CashFlowCharge` last.
- **Enhanced Profile CashFlow Classes**: Added `==` operator overrides, `hashCode` implementations, and a `copyWith` utility method to the `DayCountFactor` class for improved usability and consistency.

## 2.4.1 - 2025-12-08
- **Enhancements:**
  - Improved Root Solver: Enhanced the `SolveRoot` class to robustly handle both interest rate and cash flow calculations, including edge cases like long-term loans (e.g., 360 months). Added a bisection fallback method to the Newton-Raphson solver, ensuring convergence for complex financial functions when initial guesses fail. This improves reliability for US Appendix J APR calculations and extreme cash flow scenarios without noticeable performance impact.
- **Testing:**
  - Expanded Test Suite: Added comprehensive end-to-end tests to stress-test the enhanced root solver. New tests cover extreme loan terms (e.g., 30–40 years), large/small cash flows and near-zero/high interest rates to validate accuracy and stability.
- **Fixes**
  - Profile Builder Date Bug: Fixed a long-standing issue in the profile 'build()` helper method where user-provided start dates were ignored in arrears mode. Previously, the series start date incorrectly rolled forward, potentially skewing payment schedules. Now correctly honours user input for consistent date initialization.
  - UKConcApp Constructor Validation: Updated the `UKConcApp` constructor’s assert statement to restrict `DayCountTimePeriod` options to `week` or `month`, preventing invalid configurations and improving error clarity.
- **Code:**
  - Housekeeping: Performed general code cleanup.

## 2.4.0
- **Feature:**
  - Implemented the **US Appendix J** day count convention for computing the Annual Percentage Rate (APR) for closed-end credit transactions, such as mortgages, under the Truth in Lending Act (TILA). This includes support for monthly, weekly, daily, and fortnightly unit-periods, with accurate handling of odd days using a 30-day month divisor (per Appendix J, Paragraph (b)(3)). Added leap year support (e.g., February 29) and validated results against the FFIEC APR tool.
  - Extended the `DayCountFactor` class to support two-component time factors (`principalFactor` for whole unit-periods and `fractionalAdjustment` for fractional periods), enhancing compatibility with USAppendixJ while maintaining support for single-factor conventions.
- **Breaking Change:**
  - Renamed `DayCountFactor.factor` to `DayCountFactor.principalFactor` to accommodate the new two-component model, breaking the API. Updated `USAppendixJ.computeFactor` to return `principalFactor` (annualised whole periods) and `fractionalAdjustment` (odd days as a fraction of the unit-period), aligning with the discounting formula \( P_x / (1 + e_x i) (1 + i)^{t_x} \).
- **Enhancement:**
  - Improved `DayCountFactor.toString()` and `toFoldedString()` methods to to accommodate the new two-component model.
- **Testing:**
  - Expanded end-to-end tests to cover all time periods (month, week, day, fortnight) and leap year scenarios (e.g., February 29, 2028), verifying accuracy against FFIEC outputs.
  - Added unit tests for `USAppendixJ.computeFactor` to validate factor separation and edge cases.

## 2.3.1
- **Fix:** Improved the `amortiseInterest` function to better handle interest accrual when additional advances occur in a repayment schedule. Previously, interest accrued between the last payment and an advance wasn't tracked, since advances didn’t account for it. Now, this interest is properly assigned to the first payment that follows the advance.

## 2.3.0
- **Feature:**
  - Consolidated the **UK CONC App 1.1** and **UK CONC App 1.2** day count conventions into a unified `UKConcApp` class, preserving the distinct FCA-defined time computation rules for consumer credit agreements secured on land (App 1.1) and not secured on land (App 1.2). Added an `isSecuredOnLand` parameter to toggle between mortgage and non-mortgage logic, maintaining the single payment edge case (CONC App 1.1.10 R (4)) for secured agreements while simplifying maintenance and reducing code duplication.

## 2.2.0
- **Feature:** 
  - Implemented the **UK CONC App 1.1** day count convention for computing the Annual Percentage Rate of Charge (APRC) for consumer credit agreements **secured on land**.
  - Implemented the **UK CONC App 1.2** day count convention for computing the APRC for consumer credit agreements **not secured on land**.

## 2.1.4
- **Documentation:** Updated EU200848EC Day Count Convention dart doc and README to clarify that, despite the European Union Directive 2008/48/EC being repealed and replaced by Directive (EU) 2023/2225, the day count implementation remains unchanged.

## 2.1.3
- **Fix:** Updated the EU200848EC computeFactor day count method to ensure that when both the initial drawdown and subsequent cash flow dates fall on the last day of their respective months, the period is calculated in whole months or years. Previously, this method correctly handled months with 30 or 31 days but failed for February 28th or 29th, where periods were incorrectly counted in days.

## 2.1.1
- **Modified:** Changed the DayCountFactor toString() and toFoldedString() methods to support compact rendering of long operand chains generated by some day count conventions, ensuring the integrity of displayed formulae is maintained.

## 2.1.0
- **Switched:** Replaced the Enhanced Newton-Raphson method with the Standard Newton-Raphson method to expand the solution space/window (the trade-off being a slightly slower convergence speed).
- **Added:** Implemented the Actual/360 day count convention
- **Added:** Implemented the 30U/360 day count convention, similar to 30/360, except February 28th (non leap-year) and 29th (leap-year) are treated as a 30-day month
- **Opened:** Adjusted the calculation precision constraint to allow input in the range 0 to 4 decimal digits
- **Code:** Performed housekeeping and clean-up

## 2.0.0
- **Updated:** Changed Dart SDK version constraint to 3.0.0 +
- **Updated:** Refreshed build package dependencies
- **Performed:** Minor code housekeeping

## 1.1.1
- **Added:** Included UnsolvableException export to library barrel file
- **Corrected:** Fixed README examples and results

## 1.1.0
- **Converted:** Transformed calculator computational methods to asynchronous functions
- **Added:** Introduced checked UnsolvableException for unsolvable values
- **Updated:** Revised examples

## 1.0.0
- **Initial:** Released initial version.