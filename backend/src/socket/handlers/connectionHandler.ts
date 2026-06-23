import { Server, Socket } from 'socket.io';
import { AuthService } from '../../services/AuthService';
import { UserModel } from '../../models/User';
import { AuthenticatedSocket } from '../../types';

export const handleConnection = (io: Server) => {
  return async (socket: Socket) => {
    const authSocket = socket as AuthenticatedSocket;

    console.log('Client attempting to connect:', socket.id);

    // Authenticate socket connection
    const token = socket.handshake.auth.token || socket.handshake.query.token;

    if (!token) {
      console.log('No token provided, disconnecting:', socket.id);
      socket.disconnect();
      return;
    }

    try {
      const payload = AuthService.verifyToken(token as string);
      authSocket.userId = payload.userId;
      authSocket.username = payload.username;

      console.log(`✅ User ${payload.userId} connected:`, socket.id);

      // Update last seen
      await UserModel.updateLastSeen(payload.userId);

      // Send connection success
      socket.emit('connected', {
        userId: payload.userId,
        username: payload.username,
      });

      // Handle disconnect
      socket.on('disconnect', async () => {
        console.log(`User ${authSocket.userId} disconnected:`, socket.id);
        
        if (authSocket.userId) {
          await UserModel.updateLastSeen(authSocket.userId);
        }
      });

    } catch (error) {
      console.error('Authentication failed:', error);
      socket.emit('error', { message: 'Authentication failed' });
      socket.disconnect();
    }
  };
};
