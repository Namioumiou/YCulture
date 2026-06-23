import express from 'express';
import { createServer } from 'http';
import { Server } from 'socket.io';
import dotenv from 'dotenv';
import cors from 'cors';
import swaggerUi from 'swagger-ui-express';
import swaggerDocument from './config/swagger.json';

// Config
import { socketConfig } from './config/socket';
import { connectRedis } from './config/redis';

// Routes
import authRoutes from './routes/auth.routes';
import gameRoutes from './routes/game.routes';
import userRoutes from './routes/user.routes';
import leaderboardRoutes from './routes/leaderboard.routes';

// Middleware
import { errorHandler } from './middleware/errorHandler';

// Socket handlers
import { handleConnection } from './socket/handlers/connectionHandler';
import { handleRoom } from './socket/handlers/roomHandler';
import { handleGame } from './socket/handlers/gameHandler';

// Load environment variables
dotenv.config();

const app = express();
const httpServer = createServer(app);
const io = new Server(httpServer, socketConfig);

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Swagger API Documentation
app.use('/swagger', swaggerUi.serve, swaggerUi.setup(swaggerDocument, {
  customCss: '.swagger-ui .topbar { display: none }',
  customSiteTitle: 'YCulture API Documentation',
}));

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/games', gameRoutes);
app.use('/api/users', userRoutes);
app.use('/api/leaderboard', leaderboardRoutes);

// Error handler (must be last)
app.use(errorHandler);

// Socket.io connection handling
io.on('connection', (socket) => {
  handleConnection(io)(socket);
  handleRoom(io)(socket);
  handleGame(io)(socket);
});

// Initialize and start server
const PORT = process.env.PORT || 3001;

const startServer = async () => {
  try {
    // Connect to Redis
    await connectRedis();
    
    // Start HTTP server
    httpServer.listen(PORT, () => {
      console.log(`🚀 Server running on port ${PORT}`);
      console.log(`📡 Socket.io ready for connections`);
      console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
};

startServer();
