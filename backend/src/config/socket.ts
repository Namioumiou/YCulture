import { Server, ServerOptions } from 'socket.io';
import dotenv from 'dotenv';

dotenv.config();

export const socketConfig: Partial<ServerOptions> = {
  cors: {
    origin: process.env.SOCKET_CORS_ORIGIN || 'http://localhost:3000',
    credentials: true,
  },
  pingTimeout: parseInt(process.env.SOCKET_PING_TIMEOUT || '60000'),
  pingInterval: parseInt(process.env.SOCKET_PING_INTERVAL || '25000'),
  transports: ['websocket', 'polling'],
};

export const gameConfig = {
  sessionTTL: parseInt(process.env.GAME_SESSION_TTL || '7200'),
  playerOnlineTTL: parseInt(process.env.PLAYER_ONLINE_TTL || '60'),
  maxPlayersPerGame: parseInt(process.env.MAX_PLAYERS_PER_GAME || '20'),
  defaultQuestionsPerGame: parseInt(process.env.DEFAULT_QUESTIONS_PER_GAME || '10'),
  defaultTimePerQuestion: parseInt(process.env.DEFAULT_TIME_PER_QUESTION || '30'),
};
