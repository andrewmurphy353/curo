import { Frequency } from '../series/frequency';

/**
 * Creates a Date object with only the date fields (year, month, day) initialized.
 */
export function utcDate(dateTime: Date): Date {
  return new Date(Date.UTC(
    dateTime.getUTCFullYear(),
    dateTime.getUTCMonth(),
    dateTime.getUTCDate()
  ));
}

/**
 * Compute the actual number of days between two dates.
 */
export function actualDays(date1: Date, date2: Date): number {
  return Math.abs(
    utcDate(date1).getTime() - utcDate(date2).getTime()
  ) / (1000 * 60 * 60 * 24);
}

/**
 * Compute the number of months between two dates.
 */
export function monthsBetweenDates(date1: Date, date2: Date): number {
  let d1 = date1;
  let d2 = date2;
  
  if (d1.getTime() > d2.getTime()) {
    const temp = d1;
    d1 = d2;
    d2 = temp;
  }
  
  const monthAdj = (d1.getUTCDate() > d2.getUTCDate() && 
    !(hasMonthEndDay(d1) && hasMonthEndDay(d2))) ? -1 : 0;
  
  return (d2.getUTCFullYear() - d1.getUTCFullYear()) * 12 +
    (d2.getUTCMonth() - d1.getUTCMonth()) + monthAdj;
}

/**
 * Check if a date is the last day of the month.
 */
export function hasMonthEndDay(date: Date): boolean {
  if (isLeapYear(date.getUTCFullYear()) && date.getUTCMonth() === 1) {
    return date.getUTCDate() === 29;
  }
  return daysInMonth[date.getUTCMonth()] === date.getUTCDate();
}

/**
 * Check if a particular range of years contains a leap-year.
 */
export function hasLeapYear(yearFrom: number, yearTo: number): boolean {
  for (let i = yearFrom; i <= yearTo; i++) {
    if (isLeapYear(i)) {
      return true;
    }
  }
  return false;
}

/**
 * Check if a year is a leap year per the Gregorian calendar.
 */
export function isLeapYear(year: number): boolean {
  return (year % 4 === 0 && year % 100 !== 0) || (year % 400 === 0);
}

/**
 * Roll a date forward by the period implicit in the provided frequency.
 */
export function rollDate(dateToRoll: Date, frequency: Frequency, dayPref?: number): Date {
  switch (frequency) {
    case Frequency.Weekly:
      return rollDay(dateToRoll, 7);
    case Frequency.Fortnightly:
      return rollDay(dateToRoll, 14);
    case Frequency.Monthly:
      return rollMonth(dateToRoll, 1, dayPref);
    case Frequency.Quarterly:
      return rollMonth(dateToRoll, 3, dayPref);
    case Frequency.HalfYearly:
      return rollMonth(dateToRoll, 6, dayPref);
    case Frequency.Yearly:
      return rollMonth(dateToRoll, 12, dayPref);
  }
}

/**
 * Roll a date by the number of days specified.
 */
export function rollDay(dateToRoll: Date, numDays: number): Date {
  const newDate = utcDate(dateToRoll);
  newDate.setUTCDate(newDate.getUTCDate() + numDays);
  return newDate;
}

/**
 * Roll a date by the number of months specified.
 */
export function rollMonth(dateToRoll: Date, numMonths: number, dayPref?: number): Date {
  const date = utcDate(dateToRoll);
  const currentDay = date.getUTCDate();
  const currentMonth = date.getUTCMonth();
  const currentYear = date.getUTCFullYear();

  let newMonth = (currentMonth + numMonths) % 12;
  if (newMonth < 0) {
    newMonth += 12;
  }

  const monthShift = currentMonth + numMonths;
  let newYear = currentYear;
  newYear += Math.floor(monthShift / 12);
  if (monthShift % 12 === 0) {
    newYear--;
  }

  let preferredDay = dayPref || currentDay;
  if (preferredDay <= 0) {
    preferredDay = currentDay;
  }

  let newDay: number;
  if (preferredDay > daysInMonth[newMonth]) {
    if (isLeapYear(newYear) && newMonth === 1) {
      newDay = 29;
    } else {
      newDay = daysInMonth[newMonth];
    }
  } else {
    newDay = preferredDay;
  }

  return new Date(Date.UTC(newYear, newMonth, newDay));
}

/**
 * Number of days in each month starting January (non leap year)
 */
export const daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
