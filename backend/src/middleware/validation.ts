import { Request, Response, NextFunction } from 'express';
import { AppError } from './errorHandler';

export interface ValidationRule {
  field: string;
  required?: boolean;
  type?: 'string' | 'number' | 'boolean' | 'email';
  minLength?: number;
  maxLength?: number;
  min?: number;
  max?: number;
  pattern?: RegExp;
}

export const validate = (rules: ValidationRule[]) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    const errors: string[] = [];

    for (const rule of rules) {
      const value = req.body[rule.field];

      // Check required
      if (rule.required && (value === undefined || value === null || value === '')) {
        errors.push(`${rule.field} is required`);
        continue;
      }

      // Skip other validations if field is not required and not provided
      if (!rule.required && (value === undefined || value === null)) {
        continue;
      }

      // Type validation
      if (rule.type) {
        if (rule.type === 'email' && typeof value === 'string') {
          const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
          if (!emailRegex.test(value)) {
            errors.push(`${rule.field} must be a valid email`);
          }
        } else if (rule.type === 'number' && typeof value !== 'number') {
          errors.push(`${rule.field} must be a number`);
        } else if (rule.type === 'string' && typeof value !== 'string') {
          errors.push(`${rule.field} must be a string`);
        } else if (rule.type === 'boolean' && typeof value !== 'boolean') {
          errors.push(`${rule.field} must be a boolean`);
        }
      }

      // String validations
      if (typeof value === 'string') {
        if (rule.minLength && value.length < rule.minLength) {
          errors.push(`${rule.field} must be at least ${rule.minLength} characters`);
        }
        if (rule.maxLength && value.length > rule.maxLength) {
          errors.push(`${rule.field} must be at most ${rule.maxLength} characters`);
        }
        if (rule.pattern && !rule.pattern.test(value)) {
          errors.push(`${rule.field} format is invalid`);
        }
      }

      // Number validations
      if (typeof value === 'number') {
        if (rule.min !== undefined && value < rule.min) {
          errors.push(`${rule.field} must be at least ${rule.min}`);
        }
        if (rule.max !== undefined && value > rule.max) {
          errors.push(`${rule.field} must be at most ${rule.max}`);
        }
      }
    }

    if (errors.length > 0) {
      throw new AppError(`Validation failed: ${errors.join(', ')}`, 400);
    }

    next();
  };
};
