# Redis configuration for caching and other uses

# Set up Redis connection for direct Redis operations if needed
REDIS_CONFIG = {
  url: ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" },
  namespace: "recruit_mate_#{Rails.env}"
}

# For direct Redis access if needed elsewhere in the application
$redis = Redis.new(url: REDIS_CONFIG[:url]) 