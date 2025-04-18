require 'logger'

# Ensure Logger is loaded before ActiveSupport tries to use it
unless defined?(::Logger)
  require 'logger'
end 