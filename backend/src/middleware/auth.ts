import { Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { authConfig } from '../config/auth';
import { AuthRequest, JwtPayload } from '../types';

export const authenticateToken = (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): void => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  if (!token) {
    res.status(401).json({ success: false, error: 'Access token required' });
    return;
  }

  try {
    const decoded = jwt.verify(token, authConfig.jwtSecret) as JwtPayload;
    req.user = decoded;
    next();
  } catch (error) {
    res.status(403).json({ success: false, error: 'Invalid or expired token' });
  }
};

export const optionalAuth = (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): void => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (token) {
    try {
      const decoded = jwt.verify(token, authConfig.jwtSecret) as JwtPayload;
      req.user = decoded;
    } catch (error) {
      // Token is invalid but we continue anyway
    }
  }
  
  next();
};
