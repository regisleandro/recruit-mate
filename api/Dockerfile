# ---- First stage: Build dependencies ----
FROM --platform=linux/amd64 ruby:3.2.6 as builder

WORKDIR /app

# Install minimal build tools
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    nodejs \
    npm && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set environment
ENV RAILS_ENV=production \
    RACK_ENV=production \
    NODE_ENV=production \
    BUNDLE_PATH=/usr/local/bundle

# Create bundle directory
RUN mkdir -p $BUNDLE_PATH

# Copy Gemfile and lock file
COPY Gemfile Gemfile.lock ./

# Install gems without development/test groups
RUN bundle config set --local path "$BUNDLE_PATH" && \
    bundle config set --local without 'development test' && \
    bundle install --jobs 4 --retry 3

# Copy rest of app
COPY . .

# Precompile assets if you have any
# RUN bundle exec rake assets:precompile

# ---- Second stage: Final lightweight image ----
FROM --platform=linux/amd64 ruby:3.2.6

WORKDIR /app

# Install runtime dependencies only
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    libpq-dev \
    nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set environment
ENV RAILS_ENV=production \
    RACK_ENV=production \
    NODE_ENV=production \
    BUNDLE_PATH=/usr/local/bundle

# Copy vendored gems from previous stage - ensure full bundle is copied
COPY --from=builder $BUNDLE_PATH $BUNDLE_PATH
COPY --from=builder /app /app

# Create non-root user
RUN adduser --disabled-password --gecos "" rails && \
    chown -R rails:rails /app

# Make setup.sh executable
RUN chmod +x /app/setup.sh

USER rails

EXPOSE 3000
CMD ["/app/setup.sh", "bundle", "exec", "rails", "server", "-b", "0.0.0.0"]