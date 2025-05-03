import { Frequency } from './frequency';
import { Mode } from './mode';

/**
 * Base interface for all series types
 */
export interface Series {
  /** Number of cash flows in the series */
  numberOf: number;
  
  /** Descriptive label for the series */
  label: string;
  
  /** Cash flow value */
  value: number | null;
  
  /** Start date for the series */
  postDateFrom?: Date;
  
  /** Frequency of cash flows */
  frequency: Frequency;
  
  /** Whether cash flows occur at start or end of period */
  mode: Mode;
}

/**
 * Base implementation for series types
 */
export abstract class SeriesBase implements Series {
  readonly numberOf: number;
  readonly label: string;
  readonly value: number | null;
  readonly postDateFrom?: Date;
  readonly frequency: Frequency;
  readonly mode: Mode;

  constructor(options: {
    numberOf?: number;
    label?: string;
    value?: number | null;
    postDateFrom?: Date;
    frequency?: Frequency;
    mode?: Mode;
  }) {
    this.numberOf = options.numberOf ?? 1;
    this.label = options.label ?? '';
    this.value = options.value ?? null;
    this.postDateFrom = options.postDateFrom;
    this.frequency = options.frequency ?? Frequency.Monthly;
    this.mode = options.mode ?? Mode.Arrear;
  }
}
