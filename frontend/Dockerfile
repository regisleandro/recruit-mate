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

# Print debug information about build output
RUN echo "Build completed. Checking output files:" && \
    ls -la .svelte-kit/output/server || echo "No .svelte-kit/output/server directory"

# Production stage
FROM node:22-alpine

WORKDIR /app

# Copy all build files and deps
COPY --from=build /app/package.json /app/package-lock.json ./
COPY --from=build /app/.svelte-kit/output/server ./
COPY --from=build /app/node_modules ./node_modules
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