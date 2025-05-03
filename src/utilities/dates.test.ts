import { 
  utcDate, 
  actualDays, 
  monthsBetweenDates, 
  hasMonthEndDay, 
  isLeapYear, 
  rollDay, 
  rollMonth 
} from './dates';
import { Frequency } from '../series/frequency';

describe('dates utilities', () => {
  describe('utcDate', () => {
    it('should create a UTC date with only date parts', () => {
      const date = new Date(Date.UTC(2022, 0, 1, 12, 30, 45));
      const result = utcDate(date);
      
      expect(result.getUTCFullYear()).toBe(2022);
      expect(result.getUTCMonth()).toBe(0);
      expect(result.getUTCDate()).toBe(1);
      expect(result.getUTCHours()).toBe(0);
      expect(result.getUTCMinutes()).toBe(0);
      expect(result.getUTCSeconds()).toBe(0);
    });
  });

  describe('actualDays', () => {
    it('should compute days between two dates', () => {
      const date1 = new Date(Date.UTC(2022, 0, 1));
      const date2 = new Date(Date.UTC(2022, 0, 10));
      
      expect(actualDays(date1, date2)).toBe(9);
    });
  });

  describe('monthsBetweenDates', () => {
    it('should compute months between dates', () => {
      const date1 = new Date(Date.UTC(2022, 0, 15));
      const date2 = new Date(Date.UTC(2022, 3, 15));
      
      expect(monthsBetweenDates(date1, date2)).toBe(3);
    });
    
    it('should handle month-end adjustment', () => {
      const date1 = new Date(Date.UTC(2022, 0, 31));
      const date2 = new Date(Date.UTC(2022, 1, 28));
      
      expect(monthsBetweenDates(date1, date2)).toBe(1);
    });
  });

  describe('isLeapYear', () => {
    it('should correctly identify leap years', () => {
      expect(isLeapYear(2020)).toBe(true);
      expect(isLeapYear(2021)).toBe(false);
      expect(isLeapYear(2000)).toBe(true);
      expect(isLeapYear(1900)).toBe(false);
    });
  });

  describe('rollDay and rollMonth', () => {
    it('should roll forward by days', () => {
      const date = new Date(Date.UTC(2022, 0, 1));
      const result = rollDay(date, 10);
      
      expect(result.getUTCFullYear()).toBe(2022);
      expect(result.getUTCMonth()).toBe(0);
      expect(result.getUTCDate()).toBe(11);
    });
    
    it('should roll forward by months', () => {
      const date = new Date(Date.UTC(2022, 0, 15));
      const result = rollMonth(date, 3);
      
      expect(result.getUTCFullYear()).toBe(2022);
      expect(result.getUTCMonth()).toBe(3);
      expect(result.getUTCDate()).toBe(15);
    });
  });
});
