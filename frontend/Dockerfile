FROM node:22-alpine AS build

# Create app directory
WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Copy application code
COPY . .

# Build the application
RUN npm run build

# Production stage
FROM node:22-alpine

WORKDIR /app

# Copy package files and dependencies
COPY --from=build /app/package.json /app/package-lock.json ./
RUN npm install --omit=dev

# Copy the build output
COPY --from=build /app/build ./build
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/docker-entrypoint.sh ./docker-entrypoint.sh

# Make entrypoint script executable
RUN chmod +x ./docker-entrypoint.sh

# Expose the port the app runs on
EXPOSE 3001

# Set the environment variable for the server to listen on the correct port
ENV PORT=3001 
ENV HOST=0.0.0.0
ENV NODE_ENV=production

# Install debugging tools
RUN apk add --no-cache curl net-tools procps

# Use our custom entrypoint script
ENTRYPOINT ["./docker-entrypoint.sh"] 