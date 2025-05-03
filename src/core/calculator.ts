import { Convention } from '../daycount/convention';
import { ProfileImpl, Profile } from '../profile/profile';
import { Series } from '../series/series';
import { SeriesAdvance } from '../series/series-advance';
import { SeriesCharge } from '../series/series-charge';
import { SeriesPayment } from '../series/series-payment';
import { utcDate } from '../utilities/dates';
import { gaussRound } from '../utilities/math';
import { buildProfile, assignFactors, updateUnknowns, amortiseInterest } from '../profile/helper';
import { SolveRoot } from './solve-root';
import { SolveCashFlow } from './solve-cashflow';
import { SolveNfv } from './solve-nfv';

/**
 * The calculator class provides the entry point for solving unknown values
 * and/or unknown interest rates implicit in a cash flow series.
 */
export class Calculator {
  private _precision: number;
  private _profile?: Profile;
  private _isBespokeProfile: boolean;
  private _series: Series[];

  /**
   * Instantiates a calculator instance.
   * 
   * @param options Configuration options
   * @param options.precision The number of fractional digits to apply in rounding (0-4)
   * @param options.profile Optional bespoke profile with custom cash flows
   */
  constructor(options?: {
    precision?: number;
    profile?: Profile;
  }) {
    const precision = options?.profile?.precision ?? options?.precision ?? 2;
    
    if (precision < 0 || precision > 4) {
      throw new Error(`The precision of ${precision} is unsupported. Valid options are between 0 and 4 inclusive`);
    }
    
    this._precision = precision;
    this._isBespokeProfile = !!options?.profile;
    
    if (options?.profile) {
      this._profile = options.profile;
    }
    
    this._series = [];
  }

  /**
   * Returns the number of fractional digits used in rounding cash flow values.
   */
  get precision(): number {
    return this._precision;
  }

  /**
   * Returns a reference to the cash flow profile.
   */
  get profile(): Profile | undefined {
    if (!this._profile) {
      throw new Error("The profile has not been initialised yet.");
    }
    return this._profile;
  }

  /**
   * Returns a reference to the series current state.
   */
  get series(): Series[] {
    return this._series;
  }

  /**
   * Adds a cash flow series item to the series array.
   * 
   * The order of addition is important for undated series items, as the
   * internal computation of cash flow dates is inferred from the natural
   * order of the series array.
   */
  add(series: Series): void {
    if (this._isBespokeProfile) {
      throw new Error('The add(series) option cannot be used with a user-defined profile.');
    }

    let newSeries = series;
    if (series.value !== null) {
      const value = gaussRound(series.value, this._precision);
      
      if (series instanceof SeriesAdvance) {
        newSeries = new SeriesAdvance({
          ...series,
          value
        });
      } else if (series instanceof SeriesPayment) {
        newSeries = new SeriesPayment({
          ...series,
          value
        });
      } else if (series instanceof SeriesCharge) {
        newSeries = new SeriesCharge({
          ...series,
          value
        });
      }
    }
    
    this._series.push(newSeries);
  }

  /**
   * Solves for an unknown value or values.
   * 
   * @param options Configuration options
   * @param options.dayCount Convention for determining time intervals
   * @param options.interestRate Annual effective interest rate as decimal
   * @param options.startDate Date to use for undated cash flows
   * @param options.rootGuess Initial guess for solving algorithm
   */
  async solveValue(options: {
    dayCount: Convention;
    interestRate: number;
    startDate?: Date;
    rootGuess?: number;
  }): Promise<number> {
    const { dayCount, interestRate, startDate, rootGuess = 0.1 } = options;
    
    if (!this._profile && !this._isBespokeProfile) {
      this._buildProfile(startDate);
    }
    
    if (!this._profile) {
      throw new Error("Profile not initialized");
    }
    
    this._profile = new ProfileImpl({
      ...this._profile,
      dayCount
    });
    
    this._profile = assignFactors(this._profile);

    let value = SolveRoot.solve({
      callback: new SolveCashFlow({
        profile: this._profile,
        effectiveRate: interestRate
      }),
      guess: rootGuess
    });
    
    value = gaussRound(value, this._precision);

    this._profile = new ProfileImpl({
      ...this._profile,
      cashFlows: updateUnknowns({
        cashFlows: this._profile.cashFlows,
        value,
        precision: this._precision
      })
    });

    if (!dayCount.useXirrMethod) {
      this._profile = new ProfileImpl({
        ...this._profile,
        cashFlows: amortiseInterest(
          this._profile.cashFlows,
          interestRate,
          this._precision
        )
      });
    }

    return value;
  }

  /**
   * Solves for an unknown interest rate, returning the result as a decimal.
   * 
   * @param options Configuration options
   * @param options.dayCount Convention for determining time intervals
   * @param options.startDate Date to use for undated cash flows
   * @param options.rootGuess Initial guess for solving algorithm
   */
  async solveRate(options: {
    dayCount: Convention;
    startDate?: Date;
    rootGuess?: number;
  }): Promise<number> {
    const { dayCount, startDate, rootGuess = 0.1 } = options;
    
    if (!this._profile && !this._isBespokeProfile) {
      this._buildProfile(startDate);
    }
    
    if (!this._profile) {
      throw new Error("Profile not initialized");
    }
    
    this._profile = new ProfileImpl({
      ...this._profile,
      dayCount
    });
    
    this._profile = assignFactors(this._profile);

    const interest = SolveRoot.solve({
      callback: new SolveNfv({
        profile: this._profile
      }),
      guess: rootGuess
    });

    if (!dayCount.useXirrMethod) {
      this._profile = new ProfileImpl({
        ...this._profile,
        cashFlows: amortiseInterest(
          this._profile.cashFlows,
          interest,
          this._precision
        )
      });
    }

    return interest;
  }

  /**
   * Utility method that builds the profile from the cash flow series.
   */
  private _buildProfile(startDate?: Date): void {
    this._profile = new ProfileImpl({
      cashFlows: buildProfile({
        series: this._series,
        startDate: startDate ? utcDate(startDate) : utcDate(new Date())
      }),
      precision: this._precision
    });
  }
}
