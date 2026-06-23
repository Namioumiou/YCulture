import { Router, Request, Response } from 'express';
import { LeaderboardService } from '../services/LeaderboardService';

const router = Router();

// Get global leaderboard
router.get('/', async (req: Request, res: Response) => {
  try {
    const limit = parseInt(req.query.limit as string) || 100;
    const leaderboard = await LeaderboardService.getGlobalLeaderboard(limit);

    res.json({
      success: true,
      data: leaderboard,
    });
  } catch (error: any) {
    res.status(error.statusCode || 500).json({
      success: false,
      error: error.message,
    });
  }
});

// Get user rank
router.get('/rank/:userId', async (req: Request, res: Response) => {
  try {
    const userId = parseInt(req.params.userId);
    const rank = await LeaderboardService.getUserRank(userId);

    res.json({
      success: true,
      data: { rank },
    });
  } catch (error: any) {
    res.status(error.statusCode || 500).json({
      success: false,
      error: error.message,
    });
  }
});

export default router;
