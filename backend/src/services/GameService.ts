import { GameModel } from '../models/Game';
import { QuestionModel } from '../models/Question';
import redisClient from '../config/redis';
import { CreateGameDto, Game, GameStatus, QuestionWithAnswers } from '../types';
import { AppError } from '../middleware/errorHandler';
import { gameConfig } from '../config/socket';

export class GameService {
  static async createGame(gameData: CreateGameDto): Promise<Game> {
    const game = await GameModel.create(gameData);

    // Store game session in Redis
    await this.saveGameToRedis(game);

    return game;
  }

  static async getGameByRoomCode(roomCode: string): Promise<Game | null> {
    // Try Redis first
    const cachedGame = await redisClient.get(`game:${roomCode}`);
    if (cachedGame) {
      return JSON.parse(cachedGame);
    }

    // Fallback to database
    const game = await GameModel.findByRoomCode(roomCode);
    if (game) {
      await this.saveGameToRedis(game);
    }

    return game;
  }

  static async startGame(gameId: number): Promise<void> {
    await GameModel.startGame(gameId);
    
    const game = await GameModel.findById(gameId);
    if (game) {
      await this.saveGameToRedis(game);
    }
  }

  static async completeGame(gameId: number): Promise<void> {
    await GameModel.completeGame(gameId);
    
    const game = await GameModel.findById(gameId);
    if (game) {
      // Update Redis with completed status
      await this.saveGameToRedis(game);
      
      // Set expiration for cleanup (2 hours)
      await redisClient.expire(`game:${game.roomCode}`, gameConfig.sessionTTL);
    }
  }

  static async addPlayerToGame(roomCode: string, userId: number): Promise<void> {
    const game = await this.getGameByRoomCode(roomCode);
    
    if (!game) {
      throw new AppError('Game not found', 404);
    }

    if (game.status !== GameStatus.WAITING) {
      throw new AppError('Game already started', 400);
    }

    if (game.currentPlayers >= game.maxPlayers) {
      throw new AppError('Game is full', 400);
    }

    // Add player to Redis set
    await redisClient.sAdd(`game:${roomCode}:players`, userId.toString());
    
    // Update player count
    const playerCount = await redisClient.sCard(`game:${roomCode}:players`);
    await GameModel.updatePlayerCount(game.id, playerCount);
    
    game.currentPlayers = playerCount;
    await this.saveGameToRedis(game);
  }

  static async removePlayerFromGame(roomCode: string, userId: number): Promise<void> {
    await redisClient.sRem(`game:${roomCode}:players`, userId.toString());
    
    const game = await this.getGameByRoomCode(roomCode);
    if (game) {
      const playerCount = await redisClient.sCard(`game:${roomCode}:players`);
      await GameModel.updatePlayerCount(game.id, playerCount);
      
      game.currentPlayers = playerCount;
      await this.saveGameToRedis(game);
    }
  }

  static async getGamePlayers(roomCode: string): Promise<number[]> {
    const players = await redisClient.sMembers(`game:${roomCode}:players`);
    return players.map(p => parseInt(p));
  }

  static async getQuestionsForGame(gameId: number, count: number): Promise<any[]> {
    // Get random questions
    const questions = await QuestionModel.findAll(count);
    
    // Store questions for this game in Redis
    await redisClient.setEx(
      `game:${gameId}:questions`,
      gameConfig.sessionTTL,
      JSON.stringify(questions)
    );

    return questions;
  }

  private static async saveGameToRedis(game: Game): Promise<void> {
    await redisClient.setEx(
      `game:${game.roomCode}`,
      gameConfig.sessionTTL,
      JSON.stringify(game)
    );
  }
}
