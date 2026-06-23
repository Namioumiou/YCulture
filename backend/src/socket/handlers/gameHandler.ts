import { Server } from 'socket.io';
import { GameService } from '../../services/GameService';
import { QuestionService } from '../../services/QuestionService';
import { AuthenticatedSocket, SubmitAnswerData, QuestionWithAnswers } from '../../types';
import redisClient from '../../config/redis';
import { calculatePoints } from '../../utils/helpers';

// Game state management
const gameTimers: Map<number, NodeJS.Timeout> = new Map();
const gameState: Map<number, {
  currentQuestionIndex: number;
  questionStartTime: number;
  playersAnswered: Set<number>;
  streaks: Map<number, number>;
  questions: QuestionWithAnswers[];
  roomCode: string;
}> = new Map();

export const handleGame = (io: Server) => {
  return (socket: AuthenticatedSocket) => {
    // Start game
    socket.on('start_game', async (data: { gameId: number; roomCode: string }) => {
      try {
        const { gameId, roomCode } = data;
        const game = await GameService.getGameByRoomCode(roomCode);

        if (!game) {
          socket.emit('error', { message: 'Game not found' });
          return;
        }

        if (game.hostId !== socket.userId) {
          socket.emit('error', { message: 'Only the host can start the game' });
          return;
        }

        if (game.status !== 'waiting') {
          socket.emit('error', { message: 'Game already started' });
          return;
        }

        // Start the game
        await GameService.startGame(gameId);

        // Get questions for the game
        const questions = await GameService.getQuestionsForGame(gameId, game.questionsPerGame);

        if (!questions || questions.length === 0) {
          socket.emit('error', { message: 'No questions available' });
          return;
        }

        // Initialize game state
        gameState.set(gameId, {
          currentQuestionIndex: 0,
          questionStartTime: Date.now(),
          playersAnswered: new Set(),
          streaks: new Map(),
          questions,
          roomCode,
        });

        // Notify all players in the room
        io.to(roomCode).emit('game_started', {
          gameId,
          totalQuestions: questions.length,
          timePerQuestion: game.timePerQuestion,
        });

        // Send first question after 3 seconds
        setTimeout(() => {
          sendQuestion(io, gameId, 0, game.timePerQuestion);
        }, 3000);

        console.log(`Game ${gameId} started in room ${roomCode}`);
      } catch (error: any) {
        console.error('Start game error:', error);
        socket.emit('error', { message: error.message || 'Failed to start game' });
      }
    });

    // Submit answer
    socket.on('submit_answer', async (data: SubmitAnswerData) => {
      try {
        const { gameId, questionId, answerId, timeToAnswer } = data;

        if (!socket.userId) {
          socket.emit('error', { message: 'Unauthorized' });
          return;
        }

        const state = gameState.get(gameId);
        if (!state) {
          socket.emit('error', { message: 'Game not found or not started' });
          return;
        }

        // Check if player already answered this question
        if (state.playersAnswered.has(socket.userId)) {
          return; // Ignore duplicate answers
        }

        // Get the current question
        const question = state.questions[state.currentQuestionIndex];
        if (question.id !== questionId) {
          socket.emit('error', { message: 'Invalid question' });
          return;
        }

        // Validate answer
        const isCorrect = await QuestionService.validateAnswer(questionId, answerId);
        
        // Calculate score
        const points = isCorrect ? calculatePoints(question.points, timeToAnswer, question.timeLimit) : 0;

        // Update streak
        const currentStreak = state.streaks.get(socket.userId) || 0;
        const newStreak = isCorrect ? currentStreak + 1 : 0;
        state.streaks.set(socket.userId, newStreak);

        // Streak bonus (100 points per streak level after first)
        const streakBonus = newStreak > 1 ? (newStreak - 1) * 100 : 0;
        const totalPoints = points + streakBonus;

        // Store answer in Redis
        const answerKey = `game:${gameId}:answers:${questionId}:${socket.userId}`;
        await redisClient.setEx(
          answerKey,
          3600,
          JSON.stringify({ 
            answerId, 
            timeToAnswer, 
            isCorrect,
            points: totalPoints,
            streak: newStreak,
            timestamp: Date.now() 
          })
        );

        // Update player score in Redis
        if (isCorrect) {
          const scoreKey = `game:${gameId}:score:${socket.userId}`;
          await redisClient.incrBy(scoreKey, totalPoints);
          await redisClient.expire(scoreKey, 7200);
        }

        // Mark player as answered
        state.playersAnswered.add(socket.userId);

        // Get correct answer
        const correctAnswer = question.answers.find(a => a.isCorrect);

        // Send result to player
        socket.emit('answer_result', {
          isCorrect,
          points: totalPoints,
          streak: newStreak,
          correctAnswerId: correctAnswer?.id,
          correctAnswerText: correctAnswer?.answerText,
        });

        // Get current leaderboard
        const leaderboard = await getGameLeaderboard(gameId, state.roomCode);
        io.to(state.roomCode).emit('leaderboard_update', { leaderboard });

        // Check if all players answered
        const playerCount = await GameService.getGamePlayers(state.roomCode);
        if (state.playersAnswered.size >= playerCount.length) {
          // All players answered, move to next question
          clearTimeout(gameTimers.get(gameId));
          setTimeout(() => {
            moveToNextQuestion(io, gameId);
          }, 3000); // 3 second delay before next question
        }

        console.log(`User ${socket.userId} submitted answer for question ${questionId}: ${isCorrect ? 'correct' : 'incorrect'}`);
      } catch (error: any) {
        console.error('Submit answer error:', error);
        socket.emit('error', { message: error.message || 'Failed to submit answer' });
      }
    });

    // Force next question (host only)
    socket.on('next_question', async (data: { gameId: number; roomCode: string }) => {
      try {
        const { gameId, roomCode } = data;
        const game = await GameService.getGameByRoomCode(roomCode);

        if (!game || game.hostId !== socket.userId) {
          socket.emit('error', { message: 'Only the host can skip questions' });
          return;
        }

        clearTimeout(gameTimers.get(gameId));
        moveToNextQuestion(io, gameId);
      } catch (error: any) {
        console.error('Next question error:', error);
        socket.emit('error', { message: error.message || 'Failed to move to next question' });
      }
    });

    // End game (host only)
    socket.on('end_game', async (data: { gameId: number; roomCode: string }) => {
      try {
        const { gameId, roomCode } = data;
        const game = await GameService.getGameByRoomCode(roomCode);

        if (!game || game.hostId !== socket.userId) {
          socket.emit('error', { message: 'Only the host can end the game' });
          return;
        }

        clearTimeout(gameTimers.get(gameId));
        await endGame(io, gameId);
      } catch (error: any) {
        console.error('End game error:', error);
        socket.emit('error', { message: error.message || 'Failed to end game' });
      }
    });
  };
};

// Send question to all players
async function sendQuestion(io: Server, gameId: number, questionIndex: number, timeLimit: number) {
  const state = gameState.get(gameId);
  if (!state) return;

  const question = state.questions[questionIndex];
  
  // Reset players answered for new question
  state.playersAnswered.clear();
  state.currentQuestionIndex = questionIndex;
  state.questionStartTime = Date.now();

  // Send question (without revealing correct answer)
  io.to(state.roomCode).emit('new_question', {
    questionNumber: questionIndex + 1,
    totalQuestions: state.questions.length,
    question: {
      id: question.id,
      questionText: question.questionText,
      questionType: question.questionType,
      imageUrl: question.imageUrl,
      answers: question.answers.map(a => ({
        id: a.id,
        answerText: a.answerText,
        displayOrder: a.displayOrder,
      })),
    },
    timeLimit,
  });

  console.log(`Question ${questionIndex + 1}/${state.questions.length} sent to room ${state.roomCode}`);

  // Set timer for auto-advance
  const timer = setTimeout(() => {
    moveToNextQuestion(io, gameId);
  }, timeLimit * 1000);

  gameTimers.set(gameId, timer);
}

// Move to next question or end game
async function moveToNextQuestion(io: Server, gameId: number) {
  const state = gameState.get(gameId);
  if (!state) return;

  const nextIndex = state.currentQuestionIndex + 1;

  if (nextIndex >= state.questions.length) {
    // Game finished
    await endGame(io, gameId);
  } else {
    // Get game to retrieve timePerQuestion
    const game = await GameService.getGameByRoomCode(state.roomCode);
    if (!game) return;

    // Send next question after brief delay
    setTimeout(() => {
      sendQuestion(io, gameId, nextIndex, game.timePerQuestion);
    }, 3000);
  }
}

// Get game leaderboard from Redis
async function getGameLeaderboard(gameId: number, roomCode: string) {
  const playerIds = await GameService.getGamePlayers(roomCode);
  const leaderboard = [];

  for (const playerId of playerIds) {
    const scoreKey = `game:${gameId}:score:${playerId}`;
    const score = await redisClient.get(scoreKey);
    
    leaderboard.push({
      userId: playerId,
      score: parseInt(score || '0'),
    });
  }

  // Sort by score descending
  leaderboard.sort((a, b) => b.score - a.score);
  
  return leaderboard.map((entry, index) => ({
    ...entry,
    rank: index + 1,
  }));
}

// End game
async function endGame(io: Server, gameId: number) {
  try {
    const state = gameState.get(gameId);
    if (!state) return;

    // Complete the game
    await GameService.completeGame(gameId);

    // Get final leaderboard
    const leaderboard = await getGameLeaderboard(gameId, state.roomCode);

    // Broadcast game end
    io.to(state.roomCode).emit('game_ended', {
      gameId,
      leaderboard,
      winner: leaderboard[0],
    });

    console.log(`Game ${gameId} ended. Winner: User ${leaderboard[0]?.userId}`);

    // Cleanup
    clearTimeout(gameTimers.get(gameId));
    gameTimers.delete(gameId);
    gameState.delete(gameId);

    // Cleanup Redis scores after 5 minutes
    setTimeout(async () => {
      const playerIds = await GameService.getGamePlayers(state.roomCode);
      for (const playerId of playerIds) {
        await redisClient.del(`game:${gameId}:score:${playerId}`);
      }
    }, 300000);

  } catch (error) {
    console.error('Error ending game:', error);
  }
}
