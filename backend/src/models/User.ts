import pool from '../config/database';
import { User, CreateUserDto } from '../types';

export class UserModel {
  static async create(userData: CreateUserDto): Promise<User> {
    const query = `
      INSERT INTO users (username, email, password_hash, display_name, is_anonymous)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *
    `;
    
    const values = [
      userData.username || null,
      userData.email || null,
      userData.password || null,
      userData.displayName,
      userData.isAnonymous,
    ];

    const result = await pool.query(query, values);
    return this.mapToUser(result.rows[0]);
  }

  static async findById(id: number): Promise<User | null> {
    const query = 'SELECT * FROM users WHERE id = $1';
    const result = await pool.query(query, [id]);
    return result.rows[0] ? this.mapToUser(result.rows[0]) : null;
  }

  static async findByEmail(email: string): Promise<User | null> {
    const query = 'SELECT * FROM users WHERE email = $1';
    const result = await pool.query(query, [email]);
    return result.rows[0] ? this.mapToUser(result.rows[0]) : null;
  }

  static async findByUsername(username: string): Promise<User | null> {
    const query = 'SELECT * FROM users WHERE username = $1';
    const result = await pool.query(query, [username]);
    return result.rows[0] ? this.mapToUser(result.rows[0]) : null;
  }

  static async updateLastSeen(userId: number): Promise<void> {
    const query = 'UPDATE users SET last_seen_at = CURRENT_TIMESTAMP WHERE id = $1';
    await pool.query(query, [userId]);
  }

  static async updateStats(
    userId: number,
    stats: { gamesPlayed?: number; wins?: number; score?: number; highestScore?: number }
  ): Promise<void> {
    const updates: string[] = [];
    const values: any[] = [];
    let paramIndex = 1;

    if (stats.gamesPlayed !== undefined) {
      updates.push(`total_games_played = total_games_played + $${paramIndex++}`);
      values.push(stats.gamesPlayed);
    }
    if (stats.wins !== undefined) {
      updates.push(`total_wins = total_wins + $${paramIndex++}`);
      values.push(stats.wins);
    }
    if (stats.score !== undefined) {
      updates.push(`total_score = total_score + $${paramIndex++}`);
      values.push(stats.score);
    }
    if (stats.highestScore !== undefined) {
      updates.push(`highest_score = GREATEST(highest_score, $${paramIndex++})`);
      values.push(stats.highestScore);
    }

    if (updates.length === 0) return;

    values.push(userId);
    const query = `UPDATE users SET ${updates.join(', ')}, updated_at = CURRENT_TIMESTAMP WHERE id = $${paramIndex}`;
    await pool.query(query, values);
  }

  private static mapToUser(row: any): User {
    return {
      id: row.id,
      username: row.username,
      email: row.email,
      displayName: row.display_name,
      isAnonymous: row.is_anonymous,
      avatarUrl: row.avatar_url,
      totalGamesPlayed: row.total_games_played,
      totalWins: row.total_wins,
      totalScore: parseInt(row.total_score),
      highestScore: row.highest_score,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
      lastSeenAt: row.last_seen_at,
    };
  }
}
