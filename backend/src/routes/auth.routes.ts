import { Router, Request, Response } from 'express';
import { AuthService } from '../services/AuthService';
import { validate } from '../middleware/validation';

const router = Router();

// Register new user
router.post(
  '/register',
  validate([
    { field: 'email', required: true, type: 'email' },
    { field: 'username', required: true, type: 'string', minLength: 3, maxLength: 50 },
    { field: 'password', required: true, type: 'string', minLength: 6 },
    { field: 'displayName', required: true, type: 'string', minLength: 2, maxLength: 100 },
  ]),
  async (req: Request, res: Response) => {
    try {
      const { user, token } = await AuthService.register({
        ...req.body,
        isAnonymous: false,
      });

      res.status(201).json({
        success: true,
        data: { user, token },
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message,
      });
    }
  }
);

// Login
router.post(
  '/login',
  validate([
    { field: 'email', required: true, type: 'email' },
    { field: 'password', required: true, type: 'string' },
  ]),
  async (req: Request, res: Response) => {
    try {
      const { user, token } = await AuthService.login(req.body);

      res.json({
        success: true,
        data: { user, token },
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message,
      });
    }
  }
);

// Create anonymous user
router.post(
  '/anonymous',
  validate([
    { field: 'displayName', required: true, type: 'string', minLength: 2, maxLength: 100 },
  ]),
  async (req: Request, res: Response) => {
    try {
      const { user, token } = await AuthService.createAnonymousUser(req.body.displayName);

      res.status(201).json({
        success: true,
        data: { user, token },
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message,
      });
    }
  }
);

export default router;
