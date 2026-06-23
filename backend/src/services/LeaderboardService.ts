import pool from '../config/database';
import { LeaderboardEntry } from '../types';

export class LeaderboardService {
  static async getGlobalLeaderboard(limit: number = 100): Promise<LeaderboardEntry[]> {
    const query = `
      SELECT 
        id as user_id,
        display_name,
        avatar_url,
        total_score,
        total_wins,
        total_games_played,
        ROW_NUMBER() OVER (ORDER BY total_score DESC) as rank
      FROM users
      WHERE is_anonymous = false
      ORDER BY total_score DESC
      LIMIT $1
    `;

    const result = await pool.query(query, [limit]);
    
    return result.rows.map(row => ({
      userId: row.user_id,
      displayName: row.display_name,
      avatarUrl: row.avatar_url,
      totalScore: parseInt(row.total_score),
      totalWins: row.total_wins,
      totalGamesPlayed: row.total_games_played,
      rank: row.rank,
    }));
  }

  static async getUserRank(userId: number): Promise<number> {
    const query = `
      WITH ranked_users AS (
        SELECT id, ROW_NUMBER() OVER (ORDER BY total_score DESC) as rank
        FROM users
        WHERE is_anonymous = false
      )
      SELECT rank FROM ranked_users WHERE id = $1
    `;

    const result = await pool.query(query, [userId]);
    return result.rows[0]?.rank || 0;
  }
}
