import { UnsolvableException } from './unsolvable-exception';

/**
 * Interface for root-finding callbacks
 */
export interface SolveCallback {
  /**
   * Evaluates the function at a given point
   */
  evaluate(x: number): number;
}

/**
 * Options for the root-finding algorithm
 */
export interface SolveRootOptions {
  /** Callback to evaluate the function */
  callback: SolveCallback;
  /** Initial guess for the root */
  guess?: number;
  /** Maximum number of iterations */
  maxIterations?: number;
  /** Tolerance for convergence */
  tolerance?: number;
}

/**
 * Utility class for finding roots of equations using numerical methods.
 */
export class SolveRoot {
  /**
   * Solves for the root of a function using a numerical method.
   * 
   * @param options Configuration options
   * @returns The root value
   * @throws UnsolvableException if the root cannot be found
   */
  static solve(options: SolveRootOptions): number {
    const { callback, guess = 0.1, maxIterations = 100, tolerance = 1e-10 } = options;
    
    let x = guess;
    let iteration = 0;
    
    while (iteration < maxIterations) {
      const fx = callback.evaluate(x);
      
      if (Math.abs(fx) < tolerance) {
        return x;
      }
      
      const h = Math.max(1e-8, Math.abs(x) * 1e-8);
      const df = (callback.evaluate(x + h) - fx) / h;
      
      if (Math.abs(df) < 1e-10) {
        throw new UnsolvableException('Derivative too small, cannot continue');
      }
      
      const dx = fx / df;
      x = x - dx;
      
      if (Math.abs(dx) < tolerance) {
        return x;
      }
      
      iteration++;
    }
    
    throw new UnsolvableException(`Failed to converge after ${maxIterations} iterations`);
  }
}
