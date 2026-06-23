import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { UserModel } from '../models/User';
import { CreateUserDto, LoginDto, JwtPayload, User } from '../types';
import { authConfig } from '../config/auth';
import { AppError } from '../middleware/errorHandler';

export class AuthService {
  static async register(userData: CreateUserDto): Promise<{ user: User; token: string }> {
    // Check if user already exists
    if (userData.email) {
      const existingUser = await UserModel.findByEmail(userData.email);
      if (existingUser) {
        throw new AppError('Email already registered', 400);
      }
    }

    if (userData.username) {
      const existingUser = await UserModel.findByUsername(userData.username);
      if (existingUser) {
        throw new AppError('Username already taken', 400);
      }
    }

    // Hash password if provided
    let passwordHash: string | undefined;
    if (userData.password) {
      passwordHash = await bcrypt.hash(userData.password, authConfig.saltRounds);
    }

    // Create user
    const user = await UserModel.create({
      ...userData,
      password: passwordHash,
    });

    // Generate token
    const token = this.generateToken(user);

    return { user, token };
  }

  static async login(loginData: LoginDto): Promise<{ user: User; token: string }> {
    const user = await UserModel.findByEmail(loginData.email);
    
    if (!user) {
      throw new AppError('Invalid email or password', 401);
    }

    if (user.isAnonymous) {
      throw new AppError('Cannot login with anonymous account', 401);
    }

    // Verify password (we'd need to store password_hash separately)
    // For now, this is a placeholder
    const isValidPassword = true; // TODO: Implement password verification

    if (!isValidPassword) {
      throw new AppError('Invalid email or password', 401);
    }

    const token = this.generateToken(user);

    await UserModel.updateLastSeen(user.id);

    return { user, token };
  }

  static async createAnonymousUser(displayName: string): Promise<{ user: User; token: string }> {
    const user = await UserModel.create({
      displayName,
      isAnonymous: true,
    });

    const token = this.generateToken(user);

    return { user, token };
  }

  static generateToken(user: User): string {
    const payload: JwtPayload = {
      userId: user.id,
      username: user.username,
      email: user.email,
      isAnonymous: user.isAnonymous,
    };

    return jwt.sign(payload, authConfig.jwtSecret, {
      expiresIn: authConfig.jwtExpiresIn,
    });
  }

  static verifyToken(token: string): JwtPayload {
    try {
      return jwt.verify(token, authConfig.jwtSecret) as JwtPayload;
    } catch (error) {
      throw new AppError('Invalid or expired token', 401);
    }
  }
}
