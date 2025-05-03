import { Frequency } from './frequency';
import { Mode } from './mode';
import { SeriesBase } from './series';

/**
 * Represents a series of advances (typically money lent/borrowed).
 */
export class SeriesAdvance extends SeriesBase {
  constructor(options: {
    numberOf?: number;
    label?: string;
    value?: number | null;
    postDateFrom?: Date;
    frequency?: Frequency;
    mode?: Mode;
  } = {}) {
    super({
      numberOf: options.numberOf ?? 1,
      label: options.label ?? 'Advance',
      value: options.value,
      postDateFrom: options.postDateFrom,
      frequency: options.frequency ?? Frequency.Monthly,
      mode: options.mode ?? Mode.Advance
    });
  }
}
