import pool from '../config/database';
import { Game, CreateGameDto, GameStatus, GameMode } from '../types';

export class GameModel {
  static async create(gameData: CreateGameDto): Promise<Game> {
    const roomCode = this.generateRoomCode();
    
    const query = `
      INSERT INTO games (room_code, host_id, status, mode, max_players, questions_per_game, time_per_question)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING *
    `;
    
    const values = [
      roomCode,
      gameData.hostId,
      GameStatus.WAITING,
      gameData.mode,
      gameData.maxPlayers || 20,
      gameData.questionsPerGame || 10,
      gameData.timePerQuestion || 30,
    ];

    const result = await pool.query(query, values);
    return this.mapToGame(result.rows[0]);
  }

  static async findById(id: number): Promise<Game | null> {
    const query = 'SELECT * FROM games WHERE id = $1';
    const result = await pool.query(query, [id]);
    return result.rows[0] ? this.mapToGame(result.rows[0]) : null;
  }

  static async findByRoomCode(roomCode: string): Promise<Game | null> {
    const query = 'SELECT * FROM games WHERE room_code = $1';
    const result = await pool.query(query, [roomCode]);
    return result.rows[0] ? this.mapToGame(result.rows[0]) : null;
  }

  static async updateStatus(gameId: number, status: GameStatus): Promise<void> {
    const query = 'UPDATE games SET status = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2';
    await pool.query(query, [status, gameId]);
  }

  static async updatePlayerCount(gameId: number, count: number): Promise<void> {
    const query = 'UPDATE games SET current_players = $1 WHERE id = $2';
    await pool.query(query, [count, gameId]);
  }

  static async updateCurrentQuestion(gameId: number, questionIndex: number): Promise<void> {
    const query = 'UPDATE games SET current_question_index = $1 WHERE id = $2';
    await pool.query(query, [questionIndex, gameId]);
  }

  static async startGame(gameId: number): Promise<void> {
    const query = `
      UPDATE games 
      SET status = $1, started_at = CURRENT_TIMESTAMP 
      WHERE id = $2
    `;
    await pool.query(query, [GameStatus.IN_PROGRESS, gameId]);
  }

  static async completeGame(gameId: number): Promise<void> {
    const query = `
      UPDATE games 
      SET status = $1, completed_at = CURRENT_TIMESTAMP 
      WHERE id = $2
    `;
    await pool.query(query, [GameStatus.COMPLETED, gameId]);
  }

  private static generateRoomCode(): string {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    let code = '';
    for (let i = 0; i < 6; i++) {
      code += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return code;
  }

  private static mapToGame(row: any): Game {
    return {
      id: row.id,
      roomCode: row.room_code,
      hostId: row.host_id,
      status: row.status,
      mode: row.mode,
      maxPlayers: row.max_players,
      currentPlayers: row.current_players || 0,
      questionsPerGame: row.questions_per_game,
      timePerQuestion: row.time_per_question,
      currentQuestionIndex: row.current_question_index || 0,
      startedAt: row.started_at,
      completedAt: row.completed_at,
      createdAt: row.created_at,
    };
  }
}
