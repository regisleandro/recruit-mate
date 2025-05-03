FROM ruby:3.2.6

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    npm \
    postgresql-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Set Rails environment to production
ENV RAILS_ENV=production
ENV RACK_ENV=production
ENV NODE_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_FILES=true

# Note: When running the container, you must provide:
# - SECRET_KEY_BASE environment variable
# - REDIS_URL if using Redis cache (defaults to redis://localhost:6379/1)
# - DATABASE_URL for PostgreSQL connection

# Copy gemfile and lock file
COPY Gemfile Gemfile.lock ./

# Install gems without development and test dependencies
RUN bundle config set --local without 'development test'
RUN bundle install --jobs 4 --retry 3 && \
    rm -rf /usr/local/bundle/cache/*.gem && \
    find /usr/local/bundle/gems/ -name "*.c" -delete && \
    find /usr/local/bundle/gems/ -name "*.o" -delete

# Copy the application code
COPY . .

# Remove unnecessary files to reduce image size
RUN rm -rf node_modules tmp/cache spec test

# Create a non-root user and switch to it
RUN adduser --disabled-password --gecos "" rails
RUN chown -R rails:rails /app
USER rails

# Expose port 3000
EXPOSE 3000

# Start the server in production mode
CMD ["bin/docker-entrypoint"] 