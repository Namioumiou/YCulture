import { Server } from 'socket.io';
import { GameService } from '../../services/GameService';
import { AuthenticatedSocket, JoinRoomData, LeaveRoomData } from '../../types';

export const handleRoom = (io: Server) => {
  return (socket: AuthenticatedSocket) => {
    // Join room
    socket.on('join_room', async (data: JoinRoomData) => {
      try {
        const { roomCode, userId, displayName } = data;

        // Validate user
        if (socket.userId !== userId) {
          socket.emit('error', { message: 'Unauthorized' });
          return;
        }

        // Get game
        const game = await GameService.getGameByRoomCode(roomCode);
        if (!game) {
          socket.emit('error', { message: 'Game not found' });
          return;
        }

        // Add player to game
        await GameService.addPlayerToGame(roomCode, userId);

        // Join socket room
        socket.join(roomCode);

        // Get all players
        const players = await GameService.getGamePlayers(roomCode);

        // Notify room
        io.to(roomCode).emit('player_joined', {
          userId,
          displayName,
          playerCount: players.length,
        });

        // Send game state to new player
        socket.emit('room_joined', {
          game,
          players,
        });

        console.log(`User ${userId} joined room ${roomCode}`);
      } catch (error: any) {
        console.error('Join room error:', error);
        socket.emit('error', { message: error.message || 'Failed to join room' });
      }
    });

    // Leave room
    socket.on('leave_room', async (data: LeaveRoomData) => {
      try {
        const { roomCode, userId } = data;

        // Validate user
        if (socket.userId !== userId) {
          socket.emit('error', { message: 'Unauthorized' });
          return;
        }

        // Remove player from game
        await GameService.removePlayerFromGame(roomCode, userId);

        // Leave socket room
        socket.leave(roomCode);

        // Get remaining players
        const players = await GameService.getGamePlayers(roomCode);

        // Notify room
        io.to(roomCode).emit('player_left', {
          userId,
          playerCount: players.length,
        });

        console.log(`User ${userId} left room ${roomCode}`);
      } catch (error: any) {
        console.error('Leave room error:', error);
        socket.emit('error', { message: error.message || 'Failed to leave room' });
      }
    });
  };
};
