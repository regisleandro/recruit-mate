#!/bin/sh
set -e

echo "Starting Docker entrypoint script"
echo "Current directory: $(pwd)"
echo "Node.js version: $(node -v)"
echo "Listing build directory:"
ls -la build

# Make sure environment variables are set
export PORT=${PORT:-3001}
export HOST=${HOST:-0.0.0.0}
export NODE_ENV=${NODE_ENV:-production}

echo "Starting server on $HOST:$PORT (NODE_ENV=$NODE_ENV)"

# Execute the server from the build directory (SvelteKit with adapter-node)
exec node build/index.js 