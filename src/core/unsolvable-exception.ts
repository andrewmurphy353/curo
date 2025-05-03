/**
 * Exception thrown when a calculation cannot be solved.
 */
export class UnsolvableException extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'UnsolvableException';
    
    Object.setPrototypeOf(this, UnsolvableException.prototype);
  }
}
