# Examples

These examples demonstrate key features of the **Curo** financial calculation library through practical, real-world scenarios. Each includes complete working Dart code, expected output, an amortisation (or APR proof) schedule, and a descriptive cash flow diagram.

The examples progress from basic to advanced concepts, showcasing how to model common loan structures, regulatory calculations, and specialised repayment profiles.

- **[Example 1](example_01.md): Determine a payment in an arrears repayment profile**  
    Introduces the core usage: calculating the monthly instalment for a simple $10,000 loan over six months with payments in arrears, and verifies the implicit interest rate.

- **[Example 2](example_02.md): Determine the APR implicit in a repayment schedule, including charges**  
    Shows how to compute a regulatory Annual Percentage Rate (APR) for a €10,000 loan that includes a €50 fee, using a legally defined day-count convention.

- **[Example 3](example_03.md): Determine a payment using a different interest frequency**  
    Demonstrates monthly repayments with quarterly compounding interest on a $10,000 loan, requiring separate payment and interest-capitalisation series.

- **[Example 4](example_04.md): Determine a supplier 0% finance scheme contribution, combined with a deferred settlement**  
    Models a borrower-facing 0% interest scheme for a $10,000 purchase, solving for the undisclosed supplier contribution needed to deliver the lender's required return, including a one-month settlement deferral.

- **[Example 5](example_05.md): Determine a payment using a stepped weighted profile**  
    Illustrates accelerated capital repayment by applying proportional weightings to groups of instalments (100%, 60%, 40%) over 12 months on a $10,000 loan.

- **[Example 6](example_06.md): Determine a payment in a weighted 3+n repayment profile**  
    Shows front-loading with a triple-weighted first payment (common in leasing as "3+33" or similar), followed by normal instalments on a $10,000 advance over six months.

Feel free to explore the examples in any order — each is self-contained and highlights a unique aspect of the library.