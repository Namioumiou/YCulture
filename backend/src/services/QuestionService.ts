import { QuestionModel } from '../models/Question';
import { QuestionWithAnswers, DifficultyLevel } from '../types';
import { AppError } from '../middleware/errorHandler';

export class QuestionService {
  static async getQuestionById(questionId: number): Promise<QuestionWithAnswers | null> {
    return await QuestionModel.findById(questionId);
  }

  static async getRandomQuestions(
    count: number,
    categoryIds?: number[],
    difficulty?: DifficultyLevel
  ): Promise<QuestionWithAnswers[]> {
    if (categoryIds && categoryIds.length > 0) {
      return await QuestionModel.findRandomByCategory(categoryIds, count, difficulty);
    }
    return await QuestionModel.findAll(count);
  }

  static async validateAnswer(questionId: number, answerId: number): Promise<boolean> {
    const question = await QuestionModel.findById(questionId);
    
    if (!question) {
      throw new AppError('Question not found', 404);
    }

    const answer = question.answers.find(a => a.id === answerId);
    
    if (!answer) {
      throw new AppError('Answer not found', 404);
    }

    return answer.isCorrect;
  }

  static async getCorrectAnswer(questionId: number): Promise<number | null> {
    const question = await QuestionModel.findById(questionId);
    
    if (!question) {
      return null;
    }

    const correctAnswer = question.answers.find(a => a.isCorrect);
    return correctAnswer?.id || null;
  }
}
