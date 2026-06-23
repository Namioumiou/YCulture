import { Router, Response } from 'express';
import { GameService } from '../services/GameService';
import { authenticateToken } from '../middleware/auth';
import { validate } from '../middleware/validation';
import { AuthRequest, GameMode } from '../types';

const router = Router();

// Create a new game
router.post(
  '/create',
  authenticateToken,
  validate([
    { field: 'mode', required: true, type: 'string' },
    { field: 'maxPlayers', required: false, type: 'number', min: 2, max: 20 },
    { field: 'questionsPerGame', required: false, type: 'number', min: 5, max: 50 },
    { field: 'timePerQuestion', required: false, type: 'number', min: 10, max: 60 },
  ]),
  async (req: AuthRequest, res: Response) => {
    try {
      const game = await GameService.createGame({
        hostId: req.user!.userId,
        mode: req.body.mode as GameMode,
        maxPlayers: req.body.maxPlayers,
        questionsPerGame: req.body.questionsPerGame,
        timePerQuestion: req.body.timePerQuestion,
      });

      res.status(201).json({
        success: true,
        data: game,
      });
    } catch (error: any) {
      res.status(error.statusCode || 500).json({
        success: false,
        error: error.message,
      });
    }
  }
);

// Get game by room code
router.get('/:roomCode', async (req: AuthRequest, res: Response) => {
  try {
    const game = await GameService.getGameByRoomCode(req.params.roomCode);

    if (!game) {
      res.status(404).json({
        success: false,
        error: 'Game not found',
      });
      return;
    }

    res.json({
      success: true,
      data: game,
    });
  } catch (error: any) {
    res.status(error.statusCode || 500).json({
      success: false,
      error: error.message,
    });
  }
});

// Start game
router.post('/:gameId/start', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    await GameService.startGame(parseInt(req.params.gameId));

    res.json({
      success: true,
      message: 'Game started',
    });
  } catch (error: any) {
    res.status(error.statusCode || 500).json({
      success: false,
      error: error.message,
    });
  }
});

export default router;
