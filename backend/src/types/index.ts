import { Request } from 'express';
import { Socket } from 'socket.io';

// User Types
export interface User {
  id: number;
  username?: string;
  email?: string;
  displayName: string;
  isAnonymous: boolean;
  avatarUrl?: string;
  totalGamesPlayed: number;
  totalWins: number;
  totalScore: number;
  highestScore: number;
  createdAt: Date;
  updatedAt: Date;
  lastSeenAt?: Date;
}

export interface CreateUserDto {
  username?: string;
  email?: string;
  password?: string;
  displayName: string;
  isAnonymous: boolean;
}

export interface LoginDto {
  email: string;
  password: string;
}

// Game Types
export enum GameStatus {
  WAITING = 'waiting',
  IN_PROGRESS = 'in_progress',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled',
}

export enum GameMode {
  MULTIPLAYER = 'multiplayer',
  SOLO_PRACTICE = 'solo_practice',
}

export interface Game {
  id: number;
  roomCode: string;
  hostId: number;
  status: GameStatus;
  mode: GameMode;
  maxPlayers: number;
  currentPlayers: number;
  questionsPerGame: number;
  timePerQuestion: number;
  currentQuestionIndex: number;
  startedAt?: Date;
  completedAt?: Date;
  createdAt: Date;
}

export interface CreateGameDto {
  hostId: number;
  mode: GameMode;
  maxPlayers?: number;
  questionsPerGame?: number;
  timePerQuestion?: number;
  categoryIds?: number[];
}

// Question Types
export enum QuestionType {
  MULTIPLE_CHOICE = 'multiple_choice',
  TRUE_FALSE = 'true_false',
}

export enum DifficultyLevel {
  EASY = 'easy',
  MEDIUM = 'medium',
  HARD = 'hard',
}

export interface Question {
  id: number;
  questionText: string;
  questionType: QuestionType;
  difficulty: DifficultyLevel;
  points: number;
  timeLimit: number;
  imageUrl?: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface Answer {
  id: number;
  questionId: number;
  answerText: string;
  isCorrect: boolean;
  displayOrder: number;
}

export interface QuestionWithAnswers extends Question {
  answers: Answer[];
  categories: Category[];
}

// Category Types
export interface Category {
  id: number;
  name: string;
  description?: string;
  iconUrl?: string;
}

// Game Participant Types
export interface GameParticipant {
  id: number;
  gameId: number;
  userId: number;
  score: number;
  correctAnswers: number;
  wrongAnswers: number;
  joinedAt: Date;
  leftAt?: Date;
}

// Player Answer Types
export interface PlayerAnswer {
  id: number;
  gameId: number;
  questionId: number;
  userId: number;
  answerId: number;
  isCorrect: boolean;
  timeToAnswer: number;
  pointsEarned: number;
  answeredAt: Date;
}

// Socket Event Types
export interface AuthenticatedSocket extends Socket {
  userId?: number;
  username?: string;
}

export interface JoinRoomData {
  roomCode: string;
  userId: number;
  displayName: string;
}

export interface SubmitAnswerData {
  gameId: number;
  questionId: number;
  answerId: number;
  timeToAnswer: number;
}

export interface LeaveRoomData {
  roomCode: string;
  userId: number;
}

// Leaderboard Types
export interface LeaderboardEntry {
  userId: number;
  displayName: string;
  avatarUrl?: string;
  totalScore: number;
  totalWins: number;
  totalGamesPlayed: number;
  rank: number;
}

export interface GameLeaderboardEntry {
  userId: number;
  displayName: string;
  score: number;
  correctAnswers: number;
  rank: number;
}

// JWT Payload
export interface JwtPayload {
  userId: number;
  username?: string;
  email?: string;
  isAnonymous: boolean;
}

// Express Request with User
export interface AuthRequest extends Request {
  user?: JwtPayload;
}

// API Response Types
export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}
