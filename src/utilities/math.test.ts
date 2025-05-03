import { gaussRound } from './math';

describe('math utilities', () => {
  describe('gaussRound', () => {
    it('should round to the nearest even number for 0.5', () => {
      expect(gaussRound(1.5)).toBe(2.0);
      expect(gaussRound(2.5)).toBe(2.0);
    });

    it('should round to specified precision', () => {
      expect(gaussRound(1.535, 2)).toBe(1.54);
    });

    it('should handle various rounding scenarios', () => {
      expect(gaussRound(1.4)).toBe(1.0);
      expect(gaussRound(1.6)).toBe(2.0);
      expect(gaussRound(2.4)).toBe(2.0);
      expect(gaussRound(2.6)).toBe(3.0);
    });
  });
});
