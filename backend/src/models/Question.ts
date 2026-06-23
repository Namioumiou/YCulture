import pool from '../config/database';
import { Question, QuestionWithAnswers, Answer, DifficultyLevel, QuestionType } from '../types';

export class QuestionModel {
  static async findById(id: number): Promise<QuestionWithAnswers | null> {
    const query = `
      SELECT q.*, 
             json_agg(json_build_object('id', a.id, 'answerText', a.answer_text, 
                                         'isCorrect', a.is_correct, 'displayOrder', a.display_order)
                      ORDER BY a.display_order) as answers
      FROM questions q
      LEFT JOIN answers a ON q.id = a.question_id
      WHERE q.id = $1
      GROUP BY q.id
    `;
    
    const result = await pool.query(query, [id]);
    return result.rows[0] ? this.mapToQuestionWithAnswers(result.rows[0]) : null;
  }

  static async findRandomByCategory(
    categoryIds: number[],
    limit: number,
    difficulty?: DifficultyLevel
  ): Promise<QuestionWithAnswers[]> {
    let query = `
      SELECT DISTINCT q.*, 
             json_agg(json_build_object('id', a.id, 'answerText', a.answer_text, 
                                         'isCorrect', a.is_correct, 'displayOrder', a.display_order)
                      ORDER BY a.display_order) as answers
      FROM questions q
      LEFT JOIN answers a ON q.id = a.question_id
      LEFT JOIN question_categories qc ON q.id = qc.question_id
      WHERE 1=1
    `;
    
    const values: any[] = [];
    let paramIndex = 1;

    if (categoryIds.length > 0) {
      query += ` AND qc.category_id = ANY($${paramIndex++})`;
      values.push(categoryIds);
    }

    if (difficulty) {
      query += ` AND q.difficulty = $${paramIndex++}`;
      values.push(difficulty);
    }

    query += ` GROUP BY q.id ORDER BY RANDOM() LIMIT $${paramIndex}`;
    values.push(limit);

    const result = await pool.query(query, values);
    return result.rows.map(row => this.mapToQuestionWithAnswers(row));
  }

  static async findAll(limit: number = 10): Promise<QuestionWithAnswers[]> {
    const query = `
      SELECT q.*, 
             json_agg(json_build_object('id', a.id, 'answerText', a.answer_text, 
                                         'isCorrect', a.is_correct, 'displayOrder', a.display_order)
                      ORDER BY a.display_order) as answers
      FROM questions q
      LEFT JOIN answers a ON q.id = a.question_id
      GROUP BY q.id
      ORDER BY RANDOM()
      LIMIT $1
    `;
    
    const result = await pool.query(query, [limit]);
    return result.rows.map(row => this.mapToQuestionWithAnswers(row));
  }

  private static mapToQuestionWithAnswers(row: any): QuestionWithAnswers {
    return {
      id: row.id,
      questionText: row.question_text,
      questionType: row.question_type,
      difficulty: row.difficulty,
      points: row.points,
      timeLimit: row.time_limit,
      imageUrl: row.image_url,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
      answers: row.answers || [],
      categories: [],
    };
  }
}
