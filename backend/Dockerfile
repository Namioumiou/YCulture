# Development Dockerfile for YCulture Backend
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Install dependencies for building native modules
RUN apk add --no-cache python3 make g++

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .

# Expose port
EXPOSE 3000

# Start development server (overridden by docker-compose command)
CMD ["npm", "run", "dev"]
