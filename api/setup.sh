#!/bin/bash
set -e

echo "PostgreSQL is up - executing command"

# Check if database exists
bundle exec rails db:create db:migrate db:seed

# Remove a potentially pre-existing server.pid for Rails.
rm -f /app/tmp/pids/server.pid

# Start the Rails server
exec "$@" 