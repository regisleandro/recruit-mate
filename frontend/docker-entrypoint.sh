#!/bin/sh
set -e

echo "Starting Docker entrypoint script"
echo "Current directory: $(pwd)"
echo "Node.js version: $(node -v)"

# Make sure environment variables are set
export PORT=${PORT:-3001}
export HOST=${HOST:-0.0.0.0}
export NODE_ENV=${NODE_ENV:-production}

echo "Starting server on $HOST:$PORT (NODE_ENV=$NODE_ENV)"

# Explicitly launch the server with host and port
exec node -e "
  process.env.HOST = '$HOST';
  process.env.PORT = '$PORT';
  process.env.NODE_ENV = '$NODE_ENV';
  console.log('Server starting on http://' + process.env.HOST + ':' + process.env.PORT);
  const server = require('./index.js');
  console.log('Server loaded');
" 