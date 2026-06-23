import dotenv from 'dotenv';

dotenv.config();

export const authConfig = {
  jwtSecret: process.env.JWT_SECRET || 'your_jwt_secret_change_me',
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '7d',
  jwtRefreshSecret: process.env.JWT_REFRESH_SECRET || 'your_refresh_secret_change_me',
  jwtRefreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '30d',
  saltRounds: 10,
};
