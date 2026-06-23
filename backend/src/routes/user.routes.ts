import { Router, Response } from 'express';
import { UserModel } from '../models/User';
import { authenticateToken } from '../middleware/auth';
import { AuthRequest } from '../types';

const router = Router();

// Get current user profile
router.get('/me', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const user = await UserModel.findById(req.user!.userId);

    if (!user) {
      res.status(404).json({
        success: false,
        error: 'User not found',
      });
      return;
    }

    res.json({
      success: true,
      data: user,
    });
  } catch (error: any) {
    res.status(error.statusCode || 500).json({
      success: false,
      error: error.message,
    });
  }
});

// Get user by ID
router.get('/:userId', async (req: AuthRequest, res: Response) => {
  try {
    const user = await UserModel.findById(parseInt(req.params.userId));

    if (!user) {
      res.status(404).json({
        success: false,
        error: 'User not found',
      });
      return;
    }

    res.json({
      success: true,
      data: user,
    });
  } catch (error: any) {
    res.status(error.statusCode || 500).json({
      success: false,
      error: error.message,
    });
  }
});

export default router;
